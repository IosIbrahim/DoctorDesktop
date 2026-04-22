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
    let userOpenFlag: String?      // "D" doctor, "N" nurse, "P" pharmacy …
    let priorityType: String?      // "1" Normal, "2" Urgent
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

    /// True when PRIORITY_TYPE == "2" (Urgent). ID "1" = Normal, ID "2" = Urgent
    /// (confirmed from NURSE_REMARKS_PRIORITY_ROW in the API response).
    var isUrgent: Bool { return priorityType == "2" }

    /// Best text for the note body: NURSE_NOTES if present, else English description.
    var body: String {
        if let n = nurseNotes, !n.isEmpty { return n }
        return descEn ?? ""
    }
}

// MARK: - Lookup item (used by priority / visit-type / show-to / filter)

/// Generic id + label pair decoded from the server's uniform lookup format:
///   { "ID": "1", "NAME_EN": "Inpatient", "NAME_AR": "داخلى" }
///
/// `label` is resolved at decode time from NAME_EN / NAME_AR based on the
/// current device language (Arabic → NAME_AR, everything else → NAME_EN).
struct NurseNoteLookup: Decodable {
    /// Raw value sent back to the API (e.g. TYPE_FLAG, PRIORITY_TYPE …).
    let id: String
    /// Display string already resolved for the current app language.
    let label: String

    // Convenience init used in tests, optimistic inserts, and "All" rows.
    init(id: String, label: String) {
        self.id    = id
        self.label = label
    }

    // MARK: Decodable

    private enum CodingKeys: String, CodingKey {
        case id     = "ID"
        case nameEn = "NAME_EN"
        case nameAr = "NAME_AR"
    }

    init(from decoder: Decoder) throws {
        let c      = try decoder.container(keyedBy: CodingKeys.self)
        id         = (try? c.decode(String.self, forKey: .id)) ?? ""
        let nameEn = (try? c.decode(String.self, forKey: .nameEn)) ?? ""
        let nameAr = (try? c.decode(String.self, forKey: .nameAr)) ?? ""
        // Prefer Arabic label when the device is set to Arabic.
        let isArabic = Locale.current.languageCode == "ar"
        label = isArabic && !nameAr.isEmpty ? nameAr : (nameEn.isEmpty ? nameAr : nameEn)
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
