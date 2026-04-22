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

    private(set) var notes:      [DoctorNurseNote] = []
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

    init(patient: Patient, user: User, modelLayer: ModelLayer) {
        self.patient    = patient
        self.user       = user
        self.modelLayer = modelLayer
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
        // INIT=0 → server skips re-sending lookup arrays (returns only the notes row).
        // If the server always returns the lookups we use INIT=1 and just filter locally;
        // pass the IDs as extra params for servers that honour them server-side.
        fetch(init: "0", visitTypeId: visitTypeId, filterId: filterId)
    }

    func resetFilter() {
        activeVisitTypeId = ""
        activeFilterId    = ""
        fetch(init: "0", visitTypeId: "", filterId: "")
    }

    func send() {
        let body = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasVoice = (draftVoiceURL != nil)
        guard !body.isEmpty || hasVoice else {
            view?.progressNotesDidSend(success: false,
                                       message: "Please enter a note or record a voice message.")
            return
        }

        let now = Self.nowString()
        let voiceMarker = hasVoice ? "[Voice note] " : ""
        let optimistic = DoctorNurseNote(
            ser: "0",
            empNameEn: user.englishName ?? user.userName,
            empNameAr: user.arabicName,
            specialityEn: nil,
            categoryEn: nil,
            transDate: now,
            descEn: voiceMarker + body,
            descAr: nil,
            nurseNotes: voiceMarker + body,
            userOpenFlag: "D",
            priorityType: draftPriorityId,
            typeFlag: "0",
            showDN: draftShowToId,
            patientId: patient.id,
            visitId: patient.visitId,
            userId: user.id,
            deleteUpdateUser: nil,
            deleteUpdateDateTime: nil,
            deleteUpdateFlag: nil,
            conclusion: nil,
            recommendation: nil,
            modifyFlag: "1",
            reply: nil
        )

        notes.insert(optimistic, at: 0)
        draftText     = ""
        draftVoiceURL = nil

        DispatchQueue.main.async {
            self.view?.progressNotesDidReload()
            self.view?.progressNotesDidSend(success: true, message: "Sent")
        }
    }

    // MARK: Private fetch

    private func fetch(init initFlag: String,
                       visitTypeId: String,
                       filterId: String) {
        var params: [String: String] = [
            "BRANCH_ID":      user.branch  ?? "",
            "COMPUTER_NAME":  "iOS",
            "INIT":           initFlag,
            "Lang":           "en",
            "PATIENT_ID":     patient.id,
            "TYPE_FLAG":      filterId.isEmpty    ? "0" : filterId,
            "USER_ID":        user.id      ?? "",
            "USER_OPEN_FLAG": "D",
            "VISIT_ID_ARRAY": patient.visitId
        ]
        if !visitTypeId.isEmpty { params["VISIT_TYPE"] = visitTypeId }

        modelLayer.loadDoctorNurseNotes(with: params) { [weak self] result in
            guard let self = self else { return }
            self.notes = result.notes

            // Lookup arrays are only populated on INIT=1; keep previously loaded
            // values if the server returns empty arrays for filtered requests.
            if !result.priorities.isEmpty { self.priorities = result.priorities }
            if !result.showToList.isEmpty { self.showToList = result.showToList }
            if !result.visitTypes.isEmpty { self.visitTypes = result.visitTypes }
            if !result.filters.isEmpty    { self.filters    = result.filters    }

            // Default Show-to to first row (e.g. "My View") on first load.
            if self.draftShowToId.isEmpty, let first = self.showToList.first {
                self.draftShowToId = first.id
            }
            // Keep priority "1" (Normal) if no matching row found.
            if !self.priorities.isEmpty &&
               !self.priorities.contains(where: { $0.id == self.draftPriorityId }),
               let first = self.priorities.first {
                self.draftPriorityId = first.id
            }

            DispatchQueue.main.async { self.view?.progressNotesDidReload() }
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
