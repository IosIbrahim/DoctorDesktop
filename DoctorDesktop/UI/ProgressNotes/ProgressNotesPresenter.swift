//
//  ProgressNotesPresenter.swift
//  DoctorDesktop
//
//  MVP presenter for the programmatic ProgressNotesViewController.
//  Owns:
//    • Notes list + four lookup arrays returned by DDDocNurseNotesLoad.
//    • Active filter state (visit-type + category) that is forwarded to the API.
//    • Composer draft state (text, priority, show-to, voice URL).
//

import Foundation

// MARK: - View-facing protocol

protocol ProgressNotesView: AnyObject {
    /// Called on the main queue after notes + lookups load or reload.
    func progressNotesDidReload()
    /// Called after a send attempt; message is the server message if any.
    func progressNotesDidSend(success: Bool, message: String?)
}

// MARK: - Display item

/// One row in the table. Notes that have a non-deleted REPLY_ROW expand into
/// TWO sequential items — the parent note (left bubble) immediately followed
/// by its reply (right bubble) — matching the Android chat layout.
enum ProgressNoteDisplayItem {
    case note(DoctorNurseNote)
    case reply(DoctorNurseNoteReply, parentSer: String?)
}

// MARK: - Presenter protocol

protocol ProgressNotesPresenter: AnyObject {
    // Context
    var patient: Patient { get }
    var user:    User    { get }

    // Loaded lookup arrays (populated after first successful load)
    var notes:       [DoctorNurseNote] { get }
    /// Flat list the table renders — interleaves notes with their replies so
    /// each reply gets its own right-aligned bubble cell.
    var displayItems: [ProgressNoteDisplayItem] { get }
    var priorities:  [NurseNoteLookup] { get }   // NURSE_REMARKS_PRIORITY_ROW
    var showToList:  [NurseNoteLookup] { get }   // NURSE_REMARKS_SHOW_D_N_ROW
    var visitTypes:  [NurseNoteLookup] { get }   // VISIT_TYPE_ROW
    var filters:     [NurseNoteLookup] { get }   // NURSE_REMARKS_FILTER_ROW

    // Active filter state (from the filter sheet)
    var activeVisitTypeId: String { get }   // "" = all
    var activeFilterId:    String { get }   // "" = all

    // Derived labels for the active filter
    var activeVisitTypeLabel: String { get }
    var activeFilterLabel:    String { get }

    // Composer draft state
    var draftText:       String { get set }
    var draftVoiceURL:   URL?   { get set }
    var draftPriorityId: String { get set }  // "1" Normal / "3" Urgent
    var draftShowToId:   String { get set }  // from showToList

    // Derived chip labels
    var draftPriorityLabel: String { get }
    var draftShowToLabel:   String { get }
    /// True when draftPriorityId resolves to "Urgent" (id ≠ the first/normal row).
    var isUrgentPriority: Bool { get }

    // View binding
    func attach(view: ProgressNotesView)

    // API calls
    /// Initial load (INIT=1) that also fetches all lookup arrays.
    func load()
    /// Re-query with the given filter ids; pass "" for "all".
    func applyFilter(visitTypeId: String, filterId: String)
    /// Reset both active filters to "" and reload.
    func resetFilter()
    /// Send the current draft.
    func send()
    /// True while a `send()` POST is in flight. The view binds the send
    /// button's enabled-state to this so rapid double-taps can't fire
    /// multiple POSTs (which is what produced 3-4 duplicate rows server-side).
    var isSending: Bool { get }
    /// Soft-delete the note at the given row in `notes`. The UI shows an
    /// optimistic strikethrough while the POST is in flight.
    func deleteNote(at index: Int)

    // MARK: - Replies
    //
    // The server stores ONE reply per note in REPLY_ROW. The "compose reply"
    // feature now POSTs to DDDocNurseReplySave and reloads on success so
    // the freshly-saved reply round-trips through the authoritative list.
    // The local dictionary `localReplies` is kept as the optimistic
    // intermediate state — the bubble appears instantly, then `load()`
    // wipes it and replaces it with REPLY_ROW from the server.

    /// Optimistically append a reply locally, then fire the POST. On
    /// success the screen reloads (server REPLY_ROW replaces the local
    /// bubble); on failure the optimistic insert is rolled back.
    /// `parentSer` MUST be the SER of a real (synced) parent note —
    /// you cannot reply to a reply, and you cannot reply to an
    /// optimistic row that hasn't received its server SER yet.
    func addLocalReply(toNoteSer parentSer: String, body: String)
}

// MARK: - Implementation

final class ProgressNotesPresenterImpl: ProgressNotesPresenter {

    // MARK: Dependencies

    let patient:    Patient
    let user:       User
    private let modelLayer: ModelLayer
    private weak var view:  ProgressNotesView?

    // MARK: Loaded data

    /// Full unfiltered dataset returned by the API.  Client-side filter is applied
    /// on the fly in `notes` so no second network call is needed when the user
    /// changes the filter selection.
    private var allNotes: [DoctorNurseNote] = []

    /// Filtered view of `allNotes` — what the table actually displays.
    var notes: [DoctorNurseNote] { applyClientFilter(to: allNotes) }

    /// Local-only replies composed on this device. Keyed by parent note SER.
    /// Wiped on every `load()` (until the server API is wired the new
    /// reply only lives in memory — that's the explicit user requirement).
    private var localReplies: [String: [DoctorNurseNoteReply]] = [:]

    /// Set to true while a save POST is in flight; gates `send()` against
    /// re-entry from rapid taps.
    private(set) var isSending: Bool = false

    /// Flat list of cells: each note is followed by its server-side reply
    /// (when present and not server-deleted) and then any local replies
    /// composed on this device. Replies inherit the parent's filter
    /// visibility because they're built from the already-filtered `notes`.
    var displayItems: [ProgressNoteDisplayItem] {
        var items: [ProgressNoteDisplayItem] = []
        // Estimate: parent + server reply + ≤2 local replies on average.
        items.reserveCapacity(notes.count * 3)
        for n in notes {
            items.append(.note(n))
            // Server-side replies. REPLY_ROW comes back as either a single
            // object or an array depending on the count — both shapes are
            // already normalised into `replyDetails` by the DTO layer, so we
            // can just iterate. Skipping deleted/empty rows mirrors the old
            // single-reply branch.
            for r in n.replyDetails where !r.isDeleted && !r.body.isEmpty {
                items.append(.reply(r, parentSer: n.ser))
            }
            // Locally-composed replies appended in order. We key by SER so
            // a reply stays attached to the right note even when the server
            // returns a fresh list (replies on rows the server never knew
            // about — i.e. SER == "0" optimistic inserts — also work).
            if let ser = n.ser, let extras = localReplies[ser] {
                for r in extras where !r.body.isEmpty {
                    items.append(.reply(r, parentSer: ser))
                }
            }
        }
        return items
    }

    private(set) var priorities: [NurseNoteLookup] = []
    private(set) var showToList: [NurseNoteLookup] = []
    private(set) var visitTypes: [NurseNoteLookup] = []
    private(set) var filters:    [NurseNoteLookup] = []

    // MARK: Active filter state

    private(set) var activeVisitTypeId: String = ""
    private(set) var activeFilterId:    String = ""

    // MARK: Composer draft

    var draftText:       String = ""
    var draftVoiceURL:   URL?
    var draftPriorityId: String = "1"
    var draftShowToId:   String = ""

    // MARK: Init

    private let visitIdArray: String   // comma-separated visit IDs, e.g. "2,1"

    init(patient: Patient, user: User, modelLayer: ModelLayer, visitIdArray: String) {
        self.patient      = patient
        self.user         = user
        self.modelLayer   = modelLayer
        self.visitIdArray = visitIdArray
    }

    // MARK: Binding

    func attach(view: ProgressNotesView) { self.view = view }

    // MARK: Derived labels

    var draftPriorityLabel: String {
        priorities.first(where: { $0.id == draftPriorityId })?.label
            ?? (draftPriorityId == "3" ? "Urgent" : "Normal")
    }

    var draftShowToLabel: String {
        showToList.first(where: { $0.id == draftShowToId })?.label ?? "All"
    }

    /// "Urgent" when draftPriorityId is NOT the first (Normal) row id.
    /// Handles arbitrary server priority ids — the first row is always treated as Normal.
    var isUrgentPriority: Bool {
        guard let first = priorities.first else {
            return draftPriorityId != "1"
        }
        return draftPriorityId != first.id
    }

    var activeVisitTypeLabel: String {
        guard !activeVisitTypeId.isEmpty else { return "All" }
        return visitTypes.first(where: { $0.id == activeVisitTypeId })?.label ?? "All"
    }

    var activeFilterLabel: String {
        guard !activeFilterId.isEmpty else { return "My View" }
        return filters.first(where: { $0.id == activeFilterId })?.label ?? "My View"
    }

    // MARK: API

    func load() {
        fetch(init: "1", visitTypeId: "", filterId: "")
    }

    func applyFilter(visitTypeId: String, filterId: String) {
        activeVisitTypeId = visitTypeId
        activeFilterId    = filterId
        // Filtering is client-side: no extra network call required.
        // `notes` is a computed property that re-applies the filter on every access.
        DispatchQueue.main.async { self.view?.progressNotesDidReload() }
    }

    func resetFilter() {
        activeVisitTypeId = ""
        activeFilterId    = ""
        DispatchQueue.main.async { self.view?.progressNotesDidReload() }
    }

    func send() {
        // Re-entrancy guard.  Without it, rapid taps on the Send button would
        // fire `presenter.send()` 3-4 times before the first POST returned —
        // each tap re-pulled the (still-populated) text field into draftText
        // and inserted a new optimistic row, and the server actually received
        // 3-4 separate inserts, producing identical-looking duplicates on the
        // next reload.
        if isSending { return }

        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            view?.progressNotesDidSend(success: false,
                                       message: "Please enter a note.")
            return
        }
        isSending = true

        // ── Build the three JSON payloads the server expects ─────────────────
        let branchID = Int(user.branch ?? "1") ?? 1
        let langID   = 2
        let si: [String: Any] = [
            "BranchID":     branchID,
            "ComputerName": "ios",
            "GroupID":      user.group ?? "DR",
            "LanguageID":   langID,
            "UserID":       user.userName ?? user.id ?? ""
        ]

        let remark: [String: Any] = [
            "BUFFER_STATUS": "1",
            "PRIORITY_TYPE": Int(draftPriorityId) ?? 1,
            "SHOW_D_N":      Int(draftShowToId)   ?? 3,
            "VISIT_ID":      patient.visitId,
            "DESC_EN":       trimmed
        ]

        // PROCESS_ID / TRACER_PLACE_ID are fixed IDs for the "Save Progress Note"
        // flow on the server (matching the values used by Android + Postman).
        let ucParms: [String: Any] = [
            "PATIENT_ID":      patient.id,
            "VISIT_ID":        patient.visitId,
            "PROCESS_ID":      "994",
            "TRACER_PLACE_ID": "9",
            "USER_OPEN_FLAG":  "D"
        ]

        guard
            let siData      = try? JSONSerialization.data(withJSONObject: si,      options: []),
            let remarksData = try? JSONSerialization.data(withJSONObject: [remark], options: []),
            let ucData      = try? JSONSerialization.data(withJSONObject: ucParms, options: []),
            let siStr       = String(data: siData,      encoding: .utf8),
            let remarksStr  = String(data: remarksData, encoding: .utf8),
            let ucStr       = String(data: ucData,      encoding: .utf8)
        else {
            DispatchQueue.main.async {
                self.view?.progressNotesDidSend(success: false,
                                                message: "Could not build request payload.")
            }
            return
        }

        let params: [String: String] = [
            "SI":                   siStr,
            "DOCTOR_NURSE_REMARKS": remarksStr,
            "DD_UC_PARMS":          ucStr
        ]

        // ── Optimistic insert so the UI feels instant ─────────────────────────
        let now = Self.nowString()
        let optimistic = DoctorNurseNote(
            ser: "0",
            empNameEn: user.englishName ?? user.userName,
            empNameAr: user.arabicName,
            specialityEn: nil,
            categoryEn: nil,
            transDate: now,
            descEn: trimmed,
            descAr: nil,
            nurseNotes: trimmed,
            userOpenFlag: "D",
            priorityType: draftPriorityId,
            typeFlag: "0",
            showDN: draftShowToId,
            patientId: patient.id,
            visitId: patient.visitId,
            userId: user.userName ?? user.id,
            deleteUpdateUser: nil,
            deleteUpdateDateTime: nil,
            deleteUpdateFlag: nil,
            conclusion: nil,
            recommendation: nil,
            modifyFlag: "1",
            reply: nil
        )
        allNotes.insert(optimistic, at: 0)
        draftText     = ""
        draftVoiceURL = nil
        DispatchQueue.main.async { self.view?.progressNotesDidReload() }

        // ── Fire the API call ────────────────────────────────────────────────
        modelLayer.saveDoctorNurseNotes(with: params) { [weak self] success, message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.view?.progressNotesDidSend(success: true,
                                                    message: message ?? "Sent")
                    // Keep `isSending` true through the reload — between the
                    // save callback and the load() callback there's a brief
                    // window during which a fast retap could fire a second
                    // save and the server would persist a duplicate. The
                    // load() callback will clear isSending once the server's
                    // authoritative list is in.
                    self.fetchAndClearSending()
                } else {
                    // Roll back the optimistic insert on failure.
                    self.isSending = false
                    if !self.allNotes.isEmpty { self.allNotes.removeFirst() }
                    self.view?.progressNotesDidReload()
                    self.view?.progressNotesDidSend(
                        success: false,
                        message: message ?? "Could not save the note. Please try again.")
                }
            }
        }
    }

    /// load() variant used after a successful save. Clears `isSending` only
    /// once the post-save reload has populated the authoritative list, closing
    /// the rapid-retap duplicate-save window.
    private func fetchAndClearSending() {
        fetch(init: "1", visitTypeId: "", filterId: "", clearIsSendingOnDone: true)
    }

    // MARK: - Local reply append

    func addLocalReply(toNoteSer parentSer: String, body: String) {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !parentSer.isEmpty, parentSer != "0" else {
            // Should be blocked at the call site (the Reply pill is hidden
            // for unsynced rows), but guard here too — replying to an
            // optimistic row would 500 the server.
            DispatchQueue.main.async {
                self.view?.progressNotesDidSend(
                    success: false,
                    message: "This note hasn't synced yet. Try again in a moment.")
            }
            return
        }

        // ── Optimistic local bubble so the UI feels instant ────────────────
        // SER is nil because the server hasn't assigned one yet; the
        // post-success reload replaces this with the authoritative
        // REPLY_ROW (which carries the real SER, dateEnter, etc.).
        let reply = DoctorNurseNoteReply(
            ser:             nil,
            replyDesc:       trimmed,
            userEnterNameEn: user.englishName ?? user.userName,
            userEnterNameAr: user.arabicName,
            dateEnter:       Self.nowString(),
            userDelete:      nil,
            dateDelete:      nil,
            deleteFlag:      nil,
            userOpenFlag:    "D",
            modifyFlag:      "1"
        )

        var bucket = localReplies[parentSer] ?? []
        bucket.append(reply)
        localReplies[parentSer] = bucket
        DispatchQueue.main.async { self.view?.progressNotesDidReload() }

        // ── Build payload (matches Android byte-for-byte) ──────────────────
        // SI: branch / user identity (same shape as save).
        // DOCTOR_NURSE_REMARKS: single-row array — BUFFER_STATUS=1 is the
        // server's "insert" flag; PARENT_SER points at the note we're
        // replying to; REPLY_DESC carries the body.
        // DD_UC_PARMS: PROCESS_ID="2064" routes the request to the reply
        // handler on the server (distinct from save's "994" / delete's
        // "4179").
        let branchID = Int(user.branch ?? "1") ?? 1
        let si: [String: Any] = [
            "BranchID":     branchID,
            "ComputerName": "ios",
            "GroupID":      user.group ?? "DR",
            "LanguageID":   2,
            "UserID":       user.userName ?? user.id ?? ""
        ]
        let remark: [String: Any] = [
            "BUFFER_STATUS": "1",
            "PARENT_SER":    parentSer,
            "REPLY_DESC":    trimmed
        ]
        let ucParms: [String: Any] = [
            "PATIENT_ID":      patient.id,
            "VISIT_ID":        patient.visitId,
            "PROCESS_ID":      "2064",
            "TRACER_PLACE_ID": "9",
            "USER_OPEN_FLAG":  "D"
        ]

        guard
            let siData      = try? JSONSerialization.data(withJSONObject: si,      options: []),
            let remarksData = try? JSONSerialization.data(withJSONObject: [remark], options: []),
            let ucData      = try? JSONSerialization.data(withJSONObject: ucParms, options: []),
            let siStr       = String(data: siData,      encoding: .utf8),
            let remarksStr  = String(data: remarksData, encoding: .utf8),
            let ucStr       = String(data: ucData,      encoding: .utf8)
        else {
            rollbackLastLocalReply(parentSer: parentSer)
            DispatchQueue.main.async {
                self.view?.progressNotesDidSend(
                    success: false,
                    message: "Could not build reply payload.")
            }
            return
        }

        let params: [String: String] = [
            "SI":                   siStr,
            "DOCTOR_NURSE_REMARKS": remarksStr,
            "DD_UC_PARMS":          ucStr
        ]

        modelLayer.saveDoctorNurseReply(with: params) { [weak self] success, message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    print("✅ [NurseReplySave] server confirmed reply on parent \(parentSer)")
                    // Reload — load() clears `localReplies` and pulls the
                    // authoritative REPLY_ROW for the parent note.
                    self.load()
                    self.view?.progressNotesDidSend(success: true,
                                                    message: message ?? "Reply sent")
                } else {
                    print("⚠️ [NurseReplySave] server failed — \(message ?? "<nil>"). Reverting.")
                    self.rollbackLastLocalReply(parentSer: parentSer)
                    self.view?.progressNotesDidReload()
                    self.view?.progressNotesDidSend(
                        success: false,
                        message: message ?? "Could not send the reply. Please try again.")
                }
            }
        }
    }

    /// Drops the most-recently-appended optimistic reply for `parentSer`.
    /// Called when the POST fails so the local bubble disappears.
    private func rollbackLastLocalReply(parentSer: String) {
        guard var bucket = localReplies[parentSer], !bucket.isEmpty else { return }
        bucket.removeLast()
        if bucket.isEmpty {
            localReplies.removeValue(forKey: parentSer)
        } else {
            localReplies[parentSer] = bucket
        }
    }

    // MARK: Delete

    /// Soft-delete at a filtered-list index. Builds the exact payload Android
    /// sends and POSTs through the regular Save endpoint — the server distinguishes
    /// "delete" from "create" by `BUFFER_STATUS=3` plus the dedicated process IDs
    /// (PROCESS_ID=4179 / TRACER_PLACE_ID=298).  We optimistically mark the row
    /// deleted so the strikethrough appears instantly, then reload from the server
    /// on success so DELETE_UPDATE_DATETIME / DELETE_UPDATE_USER round-trip.
    func deleteNote(at index: Int) {
        let filtered = notes
        guard index >= 0, index < filtered.count else { return }
        let target = filtered[index]

        // Locate the row in the unfiltered backing store by SER (stable identifier).
        guard let allIdx = allNotes.firstIndex(where: { $0.ser == target.ser }) else {
            return
        }

        // Already deleted? No-op (idempotent — prevents double POSTs from rapid taps).
        if allNotes[allIdx].isDeleted { return }

        // ── Build payload exactly as Android sends it ─────────────────────────────
        // Android trace decoded:
        //   SI={BranchID:1,ComputerName:"android",GroupID:"DR",LanguageID:2,UserID:"KHABEER"}
        //   DOCTOR_NURSE_REMARKS=[{BUFFER_STATUS:"3",SER:"…",VISIT_ID:"…"}]
        //   DD_UC_PARMS={PATIENT_ID:"…",VISIT_ID:"…",PROCESS_ID:"4179",
        //                TRACER_PLACE_ID:"298",USER_OPEN_FLAG:"D"}
        let branchID = Int(user.branch ?? "1") ?? 1
        let si: [String: Any] = [
            "BranchID":     branchID,
            "ComputerName": "ios",
            "GroupID":      user.group ?? "DR",
            "LanguageID":   2,
            "UserID":       user.userName ?? user.id ?? ""
        ]

        // BUFFER_STATUS=3 is the magic flag the server checks to perform a soft
        // delete instead of an insert. Only SER + VISIT_ID accompany it.
        let remark: [String: Any] = [
            "BUFFER_STATUS": "3",
            "SER":           target.ser ?? "",
            "VISIT_ID":      target.visitId ?? patient.visitId
        ]

        // Distinct process IDs route the request to the delete handler on the
        // server side (different from save's 994 / 9).
        let ucParms: [String: Any] = [
            "PATIENT_ID":      patient.id,
            "VISIT_ID":        patient.visitId,
            "PROCESS_ID":      "4179",
            "TRACER_PLACE_ID": "298",
            "USER_OPEN_FLAG":  "D"
        ]

        guard
            let siData      = try? JSONSerialization.data(withJSONObject: si,      options: []),
            let remarksData = try? JSONSerialization.data(withJSONObject: [remark], options: []),
            let ucData      = try? JSONSerialization.data(withJSONObject: ucParms, options: []),
            let siStr       = String(data: siData,      encoding: .utf8),
            let remarksStr  = String(data: remarksData, encoding: .utf8),
            let ucStr       = String(data: ucData,      encoding: .utf8)
        else { return }

        let params: [String: String] = [
            "SI":                   siStr,
            "DOCTOR_NURSE_REMARKS": remarksStr,
            "DD_UC_PARMS":          ucStr
        ]

        // ── Optimistic strikethrough ─────────────────────────────────────────────
        let original = allNotes[allIdx]
        allNotes[allIdx] = original.markedDeleted(
            by: user.userName ?? user.id,
            at: Self.nowString())
        DispatchQueue.main.async { self.view?.progressNotesDidReload() }

        // ── Fire the API call ────────────────────────────────────────────────────
        // Delete uses the SAME endpoint as save — the server inspects BUFFER_STATUS
        // to choose between insert and soft-delete. So we route through
        // `saveDoctorNurseNotes`; no separate "delete" endpoint is needed.
        modelLayer.saveDoctorNurseNotes(with: params) { [weak self] success, message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    print("✅ [NurseNotesDelete] server confirmed soft-delete (\(target.ser ?? "?"))")
                    // Reload from server to pick up DELETE_UPDATE_FLAG=1 on the row,
                    // which keeps the strikethrough sticky after navigating away
                    // and back into the screen.
                    self.load()
                } else {
                    print("⚠️ [NurseNotesDelete] server failed — message=\(message ?? "<nil>"). Reverting.")
                    if allIdx < self.allNotes.count {
                        self.allNotes[allIdx] = original
                    }
                    self.view?.progressNotesDidReload()
                }
            }
        }
    }

    // MARK: Client-side filtering

    /// Returns `source` filtered by the currently active visit-type and nurse-remarks
    /// filter selections.  Both filters are independent and cumulative.
    private func applyClientFilter(to source: [DoctorNurseNote]) -> [DoctorNurseNote] {
        var result = source

        // NOTE: Deleted notes are kept in the list on purpose — the UI renders
        // them with a strikethrough (matching the Android design). Filtering out
        // rows with DELETE_UPDATE_FLAG == "1" used to happen here; it's gone so
        // the user can still see what was removed.

        // ── Visit Type (TYPE_FLAG in row == VISIT_TYPE_ROW.ID) ────────────────
        // "" means "All" → no restriction.
        if !activeVisitTypeId.isEmpty {
            result = result.filter { ($0.typeFlag ?? "") == activeVisitTypeId }
        }

        // ── Nurse Remarks filter ───────────────────────────────────────────────
        // Mapping from NURSE_REMARKS_FILTER_ROW.ID → USER_OPEN_FLAG value
        //   "0"  My View            → USER_ID == current user (trimmed)
        //   "1"  Doctors            → USER_OPEN_FLAG == "D"
        //   "2"  Nursing            → USER_OPEN_FLAG == "N"
        //   "3"  All                → no restriction
        //   "4"  Clinical Pharmacy  → USER_OPEN_FLAG == "P"
        //   "5"  Clin. Nutrition    → USER_OPEN_FLAG == "CN"
        //   "6"  Infection Control  → USER_OPEN_FLAG == "I"
        //   ""   (none/reset)       → no restriction
        if !activeFilterId.isEmpty {
            result = result.filter { matchesNurseRemarksFilter($0) }
        }

        return result
    }

    private func matchesNurseRemarksFilter(_ note: DoctorNurseNote) -> Bool {
        // Each filter matches notes that are EITHER authored by that role
        // (USER_OPEN_FLAG) OR addressed to that role (SHOW_D_N). Previously we
        // only checked USER_OPEN_FLAG — which meant a note written by a doctor
        // and "shown to" Nursing wouldn't appear under the Nursing filter.
        //
        // SHOW_D_N id mapping comes from NURSE_REMARKS_SHOW_D_N_ROW:
        //   "0" All   "1" Doctors   "2" Nursing
        //   "3" Clinical Pharmacy   "4" Clinical Nutrition   "5" Infection Control
        let openFlag = (note.userOpenFlag ?? "").uppercased()
        let showDN   = (note.showDN ?? "").trimmingCharacters(in: .whitespaces)

        switch activeFilterId {
        case "", "3":          // All / no selection
            return true
        case "0":              // My View — notes authored by the current user
            let noteUser    = (note.userId ?? "").trimmingCharacters(in: .whitespaces)
            let currentUser = (user.userName ?? user.id ?? "").trimmingCharacters(in: .whitespaces)
            return noteUser == currentUser
        case "1":              // Doctors
            return openFlag == "D" || showDN == "1" || showDN == "0"
        case "2":              // Nursing
            return openFlag == "N" || showDN == "2" || showDN == "0"
        case "4":              // Clinical Pharmacy
            return openFlag == "P" || showDN == "3" || showDN == "0"
        case "5":              // Clinical Nutrition Specialists
            return openFlag == "CN" || showDN == "4" || showDN == "0"
        case "6":              // Infection Control
            return openFlag == "I" || showDN == "5" || showDN == "0"
        default:
            return true
        }
    }

    // MARK: Private fetch

    /// Always performs a full load (INIT=1, no server-side filter params).
    /// Filtering is applied client-side in `applyClientFilter(to:)`.
    /// `clearIsSendingOnDone` is set by the post-save reload path so the send
    /// button stays locked until the authoritative list lands.
    private func fetch(init initFlag: String,
                       visitTypeId: String,
                       filterId: String,
                       clearIsSendingOnDone: Bool = false) {

        let patientId = patient.id.trimmingCharacters(in: .whitespacesAndNewlines)

        let params: [String: String] = [
            "BRANCH_ID": user.branch ?? "",
            "COMPUTER_NAME": "ios",
            "INIT": initFlag,
            "Lang": "2",
            "PATIENT_ID": patientId,
            "TYPE_FLAG": "1",
            "USER_ID": user.userName ?? user.id ?? "",
            "USER_OPEN_FLAG": "D",
            "VISIT_ID_ARRAY": visitIdArray
        ]

        modelLayer.loadDoctorNurseNotes(with: params) { [weak self] result in
            guard let self = self else { return }

            // Defensive dedup: a previous build of the save endpoint occasionally
            // produced 3-4 identical rows for a single tap (the user reported
            // "writing one note shows up 3 or 4 times"). The root cause was
            // upstream — but until that's confirmed fixed server-side, we
            // collapse any rows that share the same SER, or, if SER is missing,
            // the same (visit, user, body, date, priority) fingerprint.
            self.allNotes = Self.dedupedNotes(result.notes)
            // Server is the source of truth. Until the reply-POST API is
            // wired the local additions are intentionally discarded on every
            // refresh — that way the user never sees a "ghost" reply that
            // the server doesn't actually know about.
            self.localReplies.removeAll()

            if !result.priorities.isEmpty { self.priorities = result.priorities }
            if !result.showToList.isEmpty { self.showToList = result.showToList }
            if !result.visitTypes.isEmpty { self.visitTypes = result.visitTypes }
            if !result.filters.isEmpty { self.filters = result.filters }

            DispatchQueue.main.async {
                if clearIsSendingOnDone { self.isSending = false }
                self.view?.progressNotesDidReload()
            }
        }
    }

    // MARK: Helpers

    private static func nowString() -> String {
        let f = DateFormatter()
        f.locale     = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd/MM/yyyy hh:mm a"
        return f.string(from: Date())
    }

    /// Collapses duplicate rows in the server response.
    /// Keeps the first occurrence of any SER seen more than once; if SER is
    /// missing, falls back to a content fingerprint (visit + user + body
    /// + date + priority).  Order is preserved.
    private static func dedupedNotes(_ raw: [DoctorNurseNote]) -> [DoctorNurseNote] {
        var seenSer = Set<String>()
        var seenFingerprint = Set<String>()
        var out: [DoctorNurseNote] = []
        out.reserveCapacity(raw.count)
        for n in raw {
            let ser = (n.ser ?? "").trimmingCharacters(in: .whitespaces)
            if !ser.isEmpty, ser != "0" {
                if seenSer.contains(ser) { continue }
                seenSer.insert(ser)
                out.append(n)
                continue
            }
            // SER missing/zero → fingerprint by content so optimistic rows
            // don't collide either.
            let body = (n.nurseNotes ?? n.descEn ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let fp = [
                n.visitId    ?? "",
                n.userId     ?? "",
                n.transDate  ?? "",
                n.priorityType ?? "",
                body
            ].joined(separator: "|")
            if seenFingerprint.contains(fp) { continue }
            seenFingerprint.insert(fp)
            out.append(n)
        }
        return out
    }
}
