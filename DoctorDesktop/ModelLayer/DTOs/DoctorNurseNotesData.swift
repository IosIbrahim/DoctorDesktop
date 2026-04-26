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

    /// True when the server has soft-deleted this row.
    var isDeleted: Bool { return deleteUpdateFlag == "1" }

    /// Best text for the note body: NURSE_NOTES if present, else English description.
    var body: String {
        if let n = nurseNotes, !n.isEmpty { return n }
        return descEn ?? ""
    }

    // MARK: - Decodable
    //
    // We need a hand-rolled `init(from:)` instead of the synthesized one because
    // the server sends REPLY in two completely different shapes:
    //
    //   • Empty string:  "REPLY":""
    //   • Nested object: "REPLY":{"REPLY_ROW":{"REPLY_DESC":"ttttt", ...}}
    //
    // The synthesized decoder declares `reply: String?` and throws on shape #2,
    // which causes the entire DOCTOR_NURSE_REMARKS_ROW array to fail decoding —
    // dropping every note in the response. To stay tolerant we use `try?` for
    // every field and decode REPLY through a custom helper that flattens the
    // nested object into its `REPLY_DESC` text.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ser                  = (try? c.decode(String.self, forKey: .ser))
        empNameEn            = (try? c.decode(String.self, forKey: .empNameEn))
        empNameAr            = (try? c.decode(String.self, forKey: .empNameAr))
        specialityEn         = (try? c.decode(String.self, forKey: .specialityEn))
        categoryEn           = (try? c.decode(String.self, forKey: .categoryEn))
        transDate            = (try? c.decode(String.self, forKey: .transDate))
        descEn               = (try? c.decode(String.self, forKey: .descEn))
        descAr               = (try? c.decode(String.self, forKey: .descAr))
        nurseNotes           = (try? c.decode(String.self, forKey: .nurseNotes))
        userOpenFlag         = (try? c.decode(String.self, forKey: .userOpenFlag))
        priorityType         = (try? c.decode(String.self, forKey: .priorityType))
        typeFlag             = (try? c.decode(String.self, forKey: .typeFlag))
        showDN               = (try? c.decode(String.self, forKey: .showDN))
        patientId            = (try? c.decode(String.self, forKey: .patientId))
        visitId              = (try? c.decode(String.self, forKey: .visitId))
        userId               = (try? c.decode(String.self, forKey: .userId))
        deleteUpdateUser     = (try? c.decode(String.self, forKey: .deleteUpdateUser))
        deleteUpdateDateTime = (try? c.decode(String.self, forKey: .deleteUpdateDateTime))
        deleteUpdateFlag     = (try? c.decode(String.self, forKey: .deleteUpdateFlag))
        conclusion           = (try? c.decode(String.self, forKey: .conclusion))
        recommendation       = (try? c.decode(String.self, forKey: .recommendation))
        modifyFlag           = (try? c.decode(String.self, forKey: .modifyFlag))

        // REPLY: try plain String first; fall back to the nested object form.
        if let s = try? c.decode(String.self, forKey: .reply) {
            reply = s.isEmpty ? nil : s
        } else if let nested = try? c.decode(ReplyEnvelope.self, forKey: .reply) {
            reply = nested.replyRow?.replyDesc
        } else {
            reply = nil
        }
    }

    /// Helper for decoding the nested REPLY object form:
    /// `{"REPLY_ROW":{"REPLY_DESC":"…"}}`. Anything missing → nil and the
    /// wrapper falls back to "no reply".
    private struct ReplyEnvelope: Decodable {
        let replyRow: ReplyRow?
        enum CodingKeys: String, CodingKey { case replyRow = "REPLY_ROW" }
        struct ReplyRow: Decodable {
            let replyDesc: String?
            enum CodingKeys: String, CodingKey { case replyDesc = "REPLY_DESC" }
        }
    }

    /// Memberwise init — needed for hand-built rows (optimistic inserts,
    /// deletion-marking copies, unit tests). Has the same parameter order as
    /// the property declarations above.
    init(ser: String?, empNameEn: String?, empNameAr: String?,
         specialityEn: String?, categoryEn: String?,
         transDate: String?, descEn: String?, descAr: String?,
         nurseNotes: String?, userOpenFlag: String?, priorityType: String?,
         typeFlag: String?, showDN: String?, patientId: String?,
         visitId: String?, userId: String?,
         deleteUpdateUser: String?, deleteUpdateDateTime: String?,
         deleteUpdateFlag: String?, conclusion: String?,
         recommendation: String?, modifyFlag: String?, reply: String?) {
        self.ser = ser
        self.empNameEn = empNameEn
        self.empNameAr = empNameAr
        self.specialityEn = specialityEn
        self.categoryEn = categoryEn
        self.transDate = transDate
        self.descEn = descEn
        self.descAr = descAr
        self.nurseNotes = nurseNotes
        self.userOpenFlag = userOpenFlag
        self.priorityType = priorityType
        self.typeFlag = typeFlag
        self.showDN = showDN
        self.patientId = patientId
        self.visitId = visitId
        self.userId = userId
        self.deleteUpdateUser = deleteUpdateUser
        self.deleteUpdateDateTime = deleteUpdateDateTime
        self.deleteUpdateFlag = deleteUpdateFlag
        self.conclusion = conclusion
        self.recommendation = recommendation
        self.modifyFlag = modifyFlag
        self.reply = reply
    }

    /// Returns a copy with DELETE_UPDATE_* fields filled in as if the server had
    /// just processed a soft-delete. Used for optimistic UI updates while the
    /// delete POST is in flight.
    func markedDeleted(by userId: String?, at dateTime: String) -> DoctorNurseNote {
        return DoctorNurseNote(
            ser: ser,
            empNameEn: empNameEn,
            empNameAr: empNameAr,
            specialityEn: specialityEn,
            categoryEn: categoryEn,
            transDate: transDate,
            descEn: descEn,
            descAr: descAr,
            nurseNotes: nurseNotes,
            userOpenFlag: userOpenFlag,
            priorityType: priorityType,
            typeFlag: typeFlag,
            showDN: showDN,
            patientId: patientId,
            visitId: visitId,
            userId: self.userId,
            deleteUpdateUser: userId,
            deleteUpdateDateTime: dateTime,
            deleteUpdateFlag: "1",
            conclusion: conclusion,
            recommendation: recommendation,
            modifyFlag: "0",
            reply: reply
        )
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
