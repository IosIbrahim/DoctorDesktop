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
    /// Structured REPLY_ROW(s). The server returns this in three different
    /// shapes depending on how many replies the note has:
    ///   • absent / `""` — no replies → empty array
    ///   • one reply     — REPLY_ROW is a single object
    ///   • 2+ replies    — REPLY_ROW is an array of objects
    /// We normalise all three into a single `[DoctorNurseNoteReply]` so the
    /// cell can iterate without caring about the wire shape.
    let replyDetails: [DoctorNurseNoteReply]

    /// Convenience for callers that only care about the first reply.
    var replyDetail: DoctorNurseNoteReply? { replyDetails.first }

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
        // When the nested form is present we keep BOTH `reply` (the plain text
        // of the FIRST reply, for legacy callers) and `replyDetails` (the full
        // list — single-object and array shapes are both flattened here).
        if let s = try? c.decode(String.self, forKey: .reply) {
            reply         = s.isEmpty ? nil : s
            replyDetails  = []
        } else if let nested = try? c.decode(ReplyEnvelope.self, forKey: .reply) {
            replyDetails  = nested.rows
            reply         = nested.rows.first?.replyDesc
        } else {
            reply         = nil
            replyDetails  = []
        }
    }

    /// Helper for decoding the nested REPLY object form. The server sends
    /// REPLY_ROW as either a single object OR an array depending on whether
    /// the note has one reply or many — `RowList` flattens both into one array.
    private struct ReplyEnvelope: Decodable {
        let rows: [DoctorNurseNoteReply]
        enum CodingKeys: String, CodingKey { case replyRow = "REPLY_ROW" }
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            // Try array first (2+ replies), then single object (1 reply).
            if let arr = try? c.decode([DoctorNurseNoteReply].self, forKey: .replyRow) {
                rows = arr
            } else if let one = try? c.decode(DoctorNurseNoteReply.self, forKey: .replyRow) {
                rows = [one]
            } else {
                rows = []
            }
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
         recommendation: String?, modifyFlag: String?, reply: String?,
         replyDetails: [DoctorNurseNoteReply] = []) {
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
        self.replyDetails = replyDetails
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
            reply: reply,
            replyDetails: replyDetails
        )
    }
}

// MARK: - Reply (decoded from REPLY_ROW)

/// One reply attached to a parent DoctorNurseNote. Decoded from the nested
/// REPLY object form returned by DDDocNurseNotesLoad:
///
///     "REPLY": { "REPLY_ROW": {
///         "SER": "22373",
///         "REPLY_DESC": "...",
///         "USER_ENTER_NAME_AR": "...",
///         "USER_ENTER_NAME_EN": "Moustafa Ali Hussein Hassanein",
///         "DATE_ENTER": "18/10/2025 15:11:39",
///         "USER_DELETE": null, "DATE_DELETE": null, "DELETE_FLAG": null,
///         "USER_OPEN_FLAG": "N", "MODIFY_FLAG": "1"
///     } }
///
/// Every field is optional because the server occasionally omits values
/// (DELETE_FLAG comes back as `null` for live replies); the cell defaults
/// safely whenever a field is missing.
struct DoctorNurseNoteReply: Decodable {
    let ser: String?
    let replyDesc: String?
    let userEnterNameEn: String?
    let userEnterNameAr: String?
    let dateEnter: String?
    let userDelete: String?
    let dateDelete: String?
    let deleteFlag: String?
    let userOpenFlag: String?
    let modifyFlag: String?

    enum CodingKeys: String, CodingKey {
        case ser             = "SER"
        case replyDesc       = "REPLY_DESC"
        case userEnterNameEn = "USER_ENTER_NAME_EN"
        case userEnterNameAr = "USER_ENTER_NAME_AR"
        case dateEnter       = "DATE_ENTER"
        case userDelete      = "USER_DELETE"
        case dateDelete      = "DATE_DELETE"
        case deleteFlag      = "DELETE_FLAG"
        case userOpenFlag    = "USER_OPEN_FLAG"
        case modifyFlag      = "MODIFY_FLAG"
    }

    // Same `try?`-everywhere strategy as DoctorNurseNote so a missing /
    // mismatched field can never break the surrounding array decode.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ser             = (try? c.decode(String.self, forKey: .ser))
        replyDesc       = (try? c.decode(String.self, forKey: .replyDesc))
        userEnterNameEn = (try? c.decode(String.self, forKey: .userEnterNameEn))
        userEnterNameAr = (try? c.decode(String.self, forKey: .userEnterNameAr))
        dateEnter       = (try? c.decode(String.self, forKey: .dateEnter))
        userDelete      = (try? c.decode(String.self, forKey: .userDelete))
        dateDelete      = (try? c.decode(String.self, forKey: .dateDelete))
        deleteFlag      = (try? c.decode(String.self, forKey: .deleteFlag))
        userOpenFlag    = (try? c.decode(String.self, forKey: .userOpenFlag))
        modifyFlag      = (try? c.decode(String.self, forKey: .modifyFlag))
    }

    /// Memberwise init — used to build replies locally before the server
    /// has a SER for them (the iOS-only "compose reply" feature). Order
    /// follows the property declarations above.
    init(ser: String?,
         replyDesc: String?,
         userEnterNameEn: String?,
         userEnterNameAr: String?,
         dateEnter: String?,
         userDelete: String?,
         dateDelete: String?,
         deleteFlag: String?,
         userOpenFlag: String?,
         modifyFlag: String?) {
        self.ser             = ser
        self.replyDesc       = replyDesc
        self.userEnterNameEn = userEnterNameEn
        self.userEnterNameAr = userEnterNameAr
        self.dateEnter       = dateEnter
        self.userDelete      = userDelete
        self.dateDelete      = dateDelete
        self.deleteFlag      = deleteFlag
        self.userOpenFlag    = userOpenFlag
        self.modifyFlag      = modifyFlag
    }

    /// True when the server has soft-deleted this reply.
    var isDeleted: Bool { return deleteFlag == "1" }

    /// Locale-aware author name. Falls back to the other language when the
    /// preferred one is empty.
    var authorName: String {
        let isArabic = Locale.current.languageCode == "ar"
        let nameAr = userEnterNameAr?.trimmingCharacters(in: .whitespaces) ?? ""
        let nameEn = userEnterNameEn?.trimmingCharacters(in: .whitespaces) ?? ""
        if isArabic { return nameAr.isEmpty ? nameEn : nameAr }
        return nameEn.isEmpty ? nameAr : nameEn
    }

    /// Trimmed reply body, ready for display.
    var body: String {
        return (replyDesc ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
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
