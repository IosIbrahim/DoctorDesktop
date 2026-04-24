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

// MARK: - Presenter protocol

protocol ProgressNotesPresenter: AnyObject {
    // Context
    var patient: Patient { get }
    var user:    User    { get }

    // Loaded lookup arrays (populated after first successful load)
    var notes:       [DoctorNurseNote] { get }
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
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            view?.progressNotesDidSend(success: false,
                                       message: "Please enter a note.")
            return
        }

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
                    // Reload from server to pull the authoritative row (replaces
                    // the optimistic one with the server's SER / TRANS_DATE).
                    self.load()
                } else {
                    // Roll back the optimistic insert on failure.
                    if !self.allNotes.isEmpty { self.allNotes.removeFirst() }
                    self.view?.progressNotesDidReload()
                    self.view?.progressNotesDidSend(
                        success: false,
                        message: message ?? "Could not save the note. Please try again.")
                }
            }
        }
    }

    // MARK: Client-side filtering

    /// Returns `source` filtered by the currently active visit-type and nurse-remarks
    /// filter selections.  Both filters are independent and cumulative.
    private func applyClientFilter(to source: [DoctorNurseNote]) -> [DoctorNurseNote] {
        var result = source

        // ── Hide deleted notes (DELETE_UPDATE_FLAG == "1") ────────────────────
        // Deleted notes must not appear in the active list regardless of other
        // filter settings.  MODIFY_FLAG == "0" on the same row confirms deletion.
        result = result.filter { ($0.deleteUpdateFlag ?? "") != "1" }

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
        switch activeFilterId {
        case "", "3":          // All / no selection
            return true
        case "0":              // My View — notes authored by the current user
            let noteUser    = (note.userId ?? "").trimmingCharacters(in: .whitespaces)
            let currentUser = (user.userName ?? user.id ?? "").trimmingCharacters(in: .whitespaces)
            return noteUser == currentUser
        case "1":              // Doctors
            return (note.userOpenFlag ?? "").uppercased() == "D"
        case "2":              // Nursing
            return (note.userOpenFlag ?? "").uppercased() == "N"
        case "4":              // Clinical Pharmacy
            return (note.userOpenFlag ?? "").uppercased() == "P"
        case "5":              // Clinical Nutrition Specialists
            return (note.userOpenFlag ?? "").uppercased() == "CN"
        case "6":              // Infection Control
            return (note.userOpenFlag ?? "").uppercased() == "I"
        default:
            return true
        }
    }

    // MARK: Private fetch

    /// Always performs a full load (INIT=1, no server-side filter params).
    /// Filtering is applied client-side in `applyClientFilter(to:)`.
    private func fetch(init initFlag: String,
                       visitTypeId: String,
                       filterId: String) {

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

            self.allNotes = result.notes

            if !result.priorities.isEmpty { self.priorities = result.priorities }
            if !result.showToList.isEmpty { self.showToList = result.showToList }
            if !result.visitTypes.isEmpty { self.visitTypes = result.visitTypes }
            if !result.filters.isEmpty { self.filters = result.filters }

            DispatchQueue.main.async {
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
}
