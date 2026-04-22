//
//  DoctorNurseNotesData.swift
//  DoctorDesktop
//
//  DTOs for the new progress-notes endpoint
//  GET /MobileApi/api/MedicalRcordController/DDDocNurseNotesLoad
//
//  The server response contains a single big DOCTOR_NURSE_REMARKS list plus
//  four lookup arrays used by the composer UI:
//    • NURSE_REMARKS_PRIORITY   — "1"=Normal, "3"=Urgent
//    • NURSE_REMARKS_VISIT_TYPE — Inpatient / Outpatient / Emergency
//    • NURSE_REMARKS_SHOW_D_N   — All / Doctors / Nursing / Clinical Pharmacy …
//    • NURSE_REMARKS_FILTER     — Notes / Recommendations / Conclusions
//

import Foundation

// MARK: - Row model for the notes list

/// One entry in Root.DOCTOR_NURSE_REMARKS.DOCTOR_NURSE_REMARKS_ROW.
/// Mirrors all fields the Android app reads; everything is optional because
/// the server occasionally omits fields and we must never crash on nil.
struct DoctorNurseNote: Decodable {
    let ser: String?
    let empNameEn: String?
    let empNameAr: String?
    let specialityEn: String?
    let categoryEn: String?
    let transDate: String?
    let descEn: String?
    let descAr: String?
    let nurseNotes: String?
    let userOpenFlag: String?      // "D" doctor, "N" nurse
    let priorityType: String?      // "1" Normal, "3" Urgent
    let typeFlag: String?
    let showDN: String?            // visibility id
    let patientId: String?
    let visitId: String?
    let userId: String?
    let deleteUpdateUser: String?
    let deleteUpdateDateTime: String?
    let deleteUpdateFlag: String?
    let conclusion: String?
    let recommendation: String?
    let modifyFlag: String?
    let reply: String?

    enum CodingKeys: String, CodingKey {
        case ser                   = "SER"
        case empNameEn             = "EMP_NAME_EN"
        case empNameAr             = "EMP_NAME_AR"
        case specialityEn          = "SPECIALITY_NAME_EN"
        case categoryEn            = "CATEGORY_NAME_EN"
        case transDate             = "TRANSDATE"
        case descEn                = "DESC_EN"
        case descAr                = "DESC_AR"
        case nurseNotes            = "NURSE_NOTES"
        case userOpenFlag          = "USER_OPEN_FLAG"
        case priorityType          = "PRIORITY_TYPE"
        case typeFlag              = "TYPE_FLAG"
        case showDN                = "SHOW_D_N"
        case patientId             = "PATIENT_ID"
        case visitId               = "VISIT_ID"
        case userId                = "USER_ID"
        case deleteUpdateUser      = "DELETE_UPDATE_USER"
        case deleteUpdateDateTime  = "DELETE_UPDATE_DATETIME"
        case deleteUpdateFlag      = "DELETE_UPDATE_FLAG"
        case conclusion            = "CONCLUSION"
        case recommendation        = "RECOMMENDATION"
        case modifyFlag            = "MODIFY_FLAG"
        case reply                 = "REPLY"
    }

    /// True if the row's PRIORITY_TYPE means "Urgent" (anything except "1").
    var isUrgent: Bool { return (priorityType ?? "1") != "1" }

    /// Best text for the note body: NURSE_NOTES if present, else English description.
    var body: String {
        if let n = nurseNotes, !n.isEmpty { return n }
        return descEn ?? ""
    }
}

// MARK: - Lookup item (used by priority / visit-type / show-to / filter)

/// Generic id + label pair. The server uses different JSON key names per lookup,
/// so we decode by peeking at the raw dictionary rather than fixed CodingKeys.
struct NurseNoteLookup: Decodable {
    let id: String
    let label: String

    init(id: String, label: String) {
        self.id = id
        self.label = label
    }

    init(from decoder: Decoder) throws {
        // All four lookup rows use a two-key dictionary: one "ID"-ish key and
        // one "NAME"-ish key. Walk the container and pick the best candidates.
        let container = try decoder.container(keyedBy: DynamicKey.self)
        var foundId: String?
        var foundName: String?
        for key in container.allKeys {
            let value = (try? container.decode(String.self, forKey: key))
                ?? (try? container.decode(Int.self, forKey: key)).map(String.init)
                ?? ""
            let upper = key.stringValue.uppercased()
            if upper.contains("NAME") || upper.contains("DESC") {
                foundName = value
            } else if foundId == nil {
                foundId = value
            }
        }
        self.id    = foundId   ?? ""
        self.label = foundName ?? foundId ?? ""
    }

    private struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int? { return nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int)       { return nil }
    }
}

// MARK: - Envelope

/// Result of DDDocNurseNotesLoad — notes + the four lookup arrays.
struct DoctorNurseNotesData {
    let notes:        [DoctorNurseNote]
    let priorities:   [NurseNoteLookup]
    let visitTypes:   [NurseNoteLookup]
    let showToList:   [NurseNoteLookup]
    let filters:      [NurseNoteLookup]

    static let empty = DoctorNurseNotesData(notes: [], priorities: [],
                                            visitTypes: [], showToList: [],
                                            filters: [])
}
