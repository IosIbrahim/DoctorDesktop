//
//  VitalSignsEntryPresenter.swift
//  DoctorDesktop
//
//  Code-only screen that mirrors the Android Add-Vital-Signs design.
//  Kept intentionally small — UI state lives in the ViewController; this
//  presenter just carries the Patient/User bindings and (later) save hook.
//

import Foundation

protocol VitalSignsEntryPresenter {
  var patient: Patient { get }
  var user: User { get }
  var screenTitle: String { get }
  var patientDisplayName: String { get }
  var patientDisplaySubtitle: String { get }

  /// Fetches the latest Vitals/UCAF payload for this patient's visit from the
  /// server (`MedicalRecord/loadUcaf`) and returns any server-computed CTAS.
  /// Either argument may be nil if the server returned nothing for that
  /// section. The completion is always invoked on the main queue.
  func loadInitialData(completion: @escaping (UCAFLoadData?, UCAFCTASServer?) -> Void)

  /// Fetches the Special Habits record from `MedicalRecord/loadSpecialHappits`.
  /// Returns nil when the patient has no habits record at all.
  /// Completion is always invoked on the main queue.
  func loadSpecialHabits(completion: @escaping (SpecialHabitsData?) -> Void)

  /// Fetches the patient's visit history from `LoadPatientEpisodes`.
  /// Returns nil on network / parse failure. Completion always on main queue.
  func loadPatientHistory(completion: @escaping (PatientHistory?) -> Void)

  /// Called when the user taps Save.
  /// Fires `saveSpecialHabits` + `saveUCAF` in parallel; succeeds only if
  /// both return code == 1.  Completion is always on the main queue.
  func save(values: VitalSignsEntryValues, completion: @escaping (Bool, String?) -> Void)
}

/// All numeric / text fields are strings straight from the text fields so the
/// VC doesn't have to know about parsing yet.
struct VitalSignsEntryValues {
  // Scoring
  var painScale: Int = 0
  var patientCase: String?
  var ctasScore: String?

  // Special habits
  /// nil = not answered, true = has habits, false = no known habits
  var hasSpecialHabits: Bool? = nil
  var habitAlcohol: Bool = false
  var habitSmoker: Bool = false
  var habitMorphine: Bool = false
  var habitCannabinoid: Bool = false
  var habitSubstanceUse: Bool = false
  var habitShisha: Bool = false
  var habitVape: Bool = false
  var habitOther: Bool = false

  // Special needs flags
  var isMute: Bool = false
  var isBlind: Bool = false
  var isHandicapped: Bool = false
  var hasAbuse: Bool = false
  var hasNeglect: Bool = false
  var hasSuicide: Bool = false
  var hasSelfHarm: Bool = false

  // Vitals (all optional strings)
  var bpSystolic: String?
  var bpDiastolic: String?
  var temperature: String?
  var pulse: String?
  var respiratoryRate: String?
  var o2Sat: String?
  var height: String?
  var weight: String?
  var bloodSugar: String?
  var sugarUrine: String?
  var urineAlbumin: String?
  var acetoneUrine: String?
  var apau: String?
  var urineOut: String?
  var peripheralPulse: String?
  var intraAbdominalPressure: String?
  var o2Delivery: String?
  var chestCircumference: String?
  var totalBilirubin: String?
  var headCircumference: String?
  var abdomenCircumference: String?
  var spirometer: String?
}

final class VitalSignsEntryPresenterImpl: VitalSignsEntryPresenter {
  let patient: Patient
  let user: User
  private let modelLayer: ModelLayer

  /// Stored after `loadInitialData` so `buildSaveUcafBody` can echo back the
  /// SER / RCP_SERV_SER / HOSP_ID that the server needs to identify the record.
  private var loadedUcaf: UCAFLoadData?

  init(patient: Patient, user: User, modelLayer: ModelLayer) {
    self.patient = patient
    self.user = user
    self.modelLayer = modelLayer
  }

  var screenTitle: String { return "Add Vital Signs" }

  var patientDisplayName: String {
    let name = patient.name
    return name.isEmpty ? "-" : name
  }

  var patientDisplaySubtitle: String {
    // Keep it simple and safe across Patient implementers.
    let nationality = patient.nationality
    let date = patient.date
    if !nationality.isEmpty && !date.isEmpty { return "\(nationality) • \(date)" }
    if !nationality.isEmpty { return nationality }
    return date
  }

  func loadInitialData(completion: @escaping (UCAFLoadData?, UCAFCTASServer?) -> Void) {
    // Mirrors the Android `MedicalRecordRepository.loadUcaf` params. Uses the
    // same shape as the existing triage call (BRANCH_ID/VISIT_ID/PATIENT_ID)
    // since this backend keys visits the same way across these endpoints.
    let params: [String: String] = [
      "PATIENT_ID": patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
      "VISIT_ID":   patient.visitId,
      "BRANCH_ID":  user.branch ?? "",
      "LANG":       "E"
    ]
    modelLayer.loadUcaf(with: params) { [weak self] ucaf, ctas in
      self?.loadedUcaf = ucaf   // cache for save
      DispatchQueue.main.async {
        completion(ucaf, ctas)
      }
    }
  }

  func loadSpecialHabits(completion: @escaping (SpecialHabitsData?) -> Void) {
    // PROCESS_ID 3909 is the server-side workflow ID for the Special Habits
    // data-entry process. TRACER_PLACE_ID is the patient's current place/clinic.
    let params: [String: String] = [
      "PATIENT_ID":      patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
      "VISIT_ID":        patient.visitId,
      "BRANCH_ID":       user.branch   ?? "",
      "USER_ID":         user.userName ?? user.id ?? "",
      "COMPUTER_NAME":   "iOS",
      "PROCESS_ID":      "3909",
      "TRACER_PLACE_ID": patient.placeId
    ]
    modelLayer.loadSpecialHabits(with: params) { habits in
      DispatchQueue.main.async { completion(habits) }
    }
  }

  func loadPatientHistory(completion: @escaping (PatientHistory?) -> Void) {
    // Mirrors OverviewPresenterImpl.getPatientHistory params exactly.
    let params: [String: String] = [
      "COMPUTER_NAME": "iOS",
      "INDEX_FROM":    "0",
      "INDEX_TO":      "15",
      "Lang":          "2",
      "USER_ID":       user.userName ?? user.id ?? "",
      "BRANCH_ID":     user.branch   ?? "",
      "PATIENT_ID":    patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
      "VISIT_ID":      patient.visitId
    ]
    modelLayer.getPatientHistory(with: params) { history in
      DispatchQueue.main.async {
        // If the server returned an error message, surface nil so the VC can
        // display a graceful fallback instead of stale / partial data.
        completion(history.error == nil ? history : nil)
      }
    }
  }

  func save(values: VitalSignsEntryValues, completion: @escaping (Bool, String?) -> Void) {
    let habitsBody = buildSaveSpecialHabitsBody(values: values)
    let ucafBody   = buildSaveUcafBody(values: values)

    // Fire both in parallel; overall success = both return code 1.
    let group = DispatchGroup()
    var habitsOK  = false
    var ucafOK    = false
    var errorMsg: String?

    group.enter()
    modelLayer.saveSpecialHabits(body: habitsBody) { ok, msg in
      habitsOK = ok
      if let m = msg, !ok { errorMsg = m }
      group.leave()
    }

    group.enter()
    modelLayer.saveUcaf(body: ucafBody) { ok, msg in
      ucafOK = ok
      if let m = msg, !ok { errorMsg = m }
      group.leave()
    }

    group.notify(queue: .main) {
      completion(habitsOK && ucafOK, errorMsg)
    }
  }

  // MARK: - Private body builder

  /// Builds the nested JSON body for POST saveSpecialHabits, mirroring the
  /// Android contract exactly.
  private func buildSaveSpecialHabitsBody(values: VitalSignsEntryValues) -> [String: Any] {
    let flag: (Bool) -> String = { $0 ? "1" : "0" }
    let hasHabits = values.hasSpecialHabits == true

    let ucParms: [String: Any] = [
      "BRANCH_ID":     user.branch   ?? "",
      "COMPUTER_NAME": "iOS",
      "PATIENT_ID":    patient.id,
      "PROCESS_ID":    "214613",       // server-side save process ID for special habits
      "SPEC_ID":       patient.placeId,
      "USER_ID":       user.userName  ?? user.id ?? "",
      "VISIT_ID":      patient.visitId
    ]

    // HISTORY_H.STATUS_FLAG = "2" is always sent as-is (matches Android).
    let historyH: [String: Any] = [
      "PATIENT_ID":  patient.id,
      "STATUS_FLAG": "2"
    ]

    let habitsPayload: [String: Any] = [
      "STATUS_FLAG":      hasHabits ? "1" : "0",
      "ALCOHOL_FLAG":     flag(values.habitAlcohol),
      "SMOKER_FLAG":      flag(values.habitSmoker),
      "MORPHINE_FLAG":    flag(values.habitMorphine),
      "CANNABINOID_FLAG": flag(values.habitCannabinoid),
      "DRUGS_FLAG":       flag(values.habitSubstanceUse),
      "SHISHA_FLAG":      flag(values.habitShisha),
      "SHISHA_TEXT":      "",
      "VAPE_FLAG":        flag(values.habitVape),
      "OTHER_FLAG":       flag(values.habitOther)
    ]

    return [
      "_DD_UC_PARMS":           ucParms,
      "HISTORY_H":              historyH,
      "_PATIENT_SPECIAL_HABITS": habitsPayload
    ]
  }

  /// Builds the nested JSON body for POST /MobileApi/api/MedicalRecord/saveUCAF.
  ///
  /// Structure confirmed from Android network logs (200 OK):
  ///   _DD_UC_PARMS        — routing / identity / pain-score meta
  ///   _RCP_MASTERINDEX    — special-needs flags as integers (0 or 1)
  ///   _RCP_OUTPAT_DATAENTRY — [ one vitals dict ]
  private func buildSaveUcafBody(values: VitalSignsEntryValues) -> [String: Any] {
    let flagInt: (Bool) -> Int = { $0 ? 1 : 0 }
    let str: (String?) -> String = { $0 ?? "" }

    // ── Current date in both formats the server expects ──────────────────────
    let now = Date()
    let slashFmt  = DateFormatter(); slashFmt.dateFormat  = "dd/MM/yyyy HH:mm:ss"
    let dashFmt   = DateFormatter(); dashFmt.dateFormat   = "dd-MM-yyyy HH:mm:ss"
    let dateSlash = slashFmt.string(from: now)   // "21/04/2026 13:46:46"
    let dateDash  = dashFmt.string(from: now)    // "21-04-2026 13:46:46"

    let existingSer = (loadedUcaf?.ser ?? "").trimmingCharacters(in: .whitespaces)
    let isUpdate = !existingSer.isEmpty && existingSer != "0"

    // ── 1. Routing / identity object ─────────────────────────────────────────
    let ucParms: [String: Any] = [
      "BRANCH_ID":                  user.branch   ?? "",
      "COMPUTER_NAME":              "iOS",
      "DATE_FROM":                  dateSlash,
      "DATE_FROM_STR_FORMATED":     dateDash,
      "ITEM_VALUE":                 "\(values.painScale)",
      "PATIENT_ID":                 patient.id,        // keep raw (server wants trailing spaces)
      "PROCESS_ID":                 "1877",            // confirmed from Android
      "RCP_SERV_SER":               str(loadedUcaf?.schedSerial),
      "SCORE_CHARACTER_DESC":       painCharacterDesc(values.painScale),
      "SCORE_TYPE":                 str(loadedUcaf?.scoreType),
      "SELECTED_DATE":              dateSlash,
      "SELECTED_DATE_STR_FORMATED": dateDash,
      "SPEC_ID":                    patient.placeId,
      "TRACER_PLACE_ID":            patient.placeId,
      "USER_ID":                    user.userName ?? user.id ?? "",
      "USER_OPEN_FLAG":             "D",              // "D" = Doctor
      "VISIT_ID":                   patient.visitId,
      "VISIT_ID_ARRAY":             patient.visitId,
    ]

    // ── 2. Special-needs flags — separate object, values are integers ─────────
    let masterIndex: [String: Int] = [
      "ABUSE_FLAG":       flagInt(values.hasAbuse),
      "DEAF_FLAG":        flagInt(values.isBlind),
      "HANDICAPPED_FLAG": flagInt(values.isHandicapped),
      "MUTE_FLAG":        flagInt(values.isMute),
      "NEGLECT_FLAG":     flagInt(values.hasNeglect),
      "SELF_HARM_FLAG":   flagInt(values.hasSelfHarm),
      "SUICIDE_FLAG":     flagInt(values.hasSuicide),
    ]

    // ── 3. Vitals row (array with one element) ───────────────────────────────
    let dataEntry: [String: Any] = [
      "BLOOD_GLUCOSE":              str(values.bloodSugar),
      "BLOOD_GLUCOSE_UNIT_ID":      "3",   // constant confirmed from Android
      "HEAD_DIAMETER":              str(values.headCircumference),
      "HEIGHT":                     str(values.height),
      "O2SAT":                      str(values.o2Sat),
      "WEIGHT":                     str(values.weight),
      "WEIGHT_UNIT":                "",
      "BP":                         str(values.bpSystolic),
      "PB_2":                       str(values.bpDiastolic),
      "BUFFER_STATUS":              isUpdate ? "2" : "1",   // 2=update, 1=insert
      "HOSP_ID":                    str(loadedUcaf?.hospId),
      "MODIFY_DATE":                dateSlash,
      "MODIFY_DATE_STR_FORMATED":   dateDash,
      "PAIN_SCALE_ADULT_SCORE":     "\(values.painScale)",
      "PATIENT_ID":                 patient.id,
      "PULSE":                      str(values.pulse),
      "RESPIRATORY_RATE":           str(values.respiratoryRate),
      "SER":                        isUpdate ? existingSer : "0",  // "0" = new insert, real serial = update
      "TEMP":                       str(values.temperature),
      "USERID_ENTRY":               user.userName ?? user.id ?? "",
      "VISIT_ID":                   patient.visitId,
      // Additional vitals not in Android sample but part of this screen
      "BLOOD_KETONES":              "",
      "URINE_SUGAR":                str(values.sugarUrine),
      "URINE_ALBUMIN":              str(values.urineAlbumin),
      "ACETONE_URINE":              str(values.acetoneUrine),
      "APAU":                       str(values.apau),
      "URINE_OUT":                  str(values.urineOut),
      "PERIPHERAL_PULSE":           str(values.peripheralPulse),
      "INTRA_ABDOMINAL_PRESSURE":   str(values.intraAbdominalPressure),
      "O2_DELIVERY":                str(values.o2Delivery),
      "CHEST_CIRCUMFERENCE":        str(values.chestCircumference),
      "TOTAL_BILIRUBIN":            str(values.totalBilirubin),
      "ABDOMEN_CIRCUMFERENCE":      str(values.abdomenCircumference),
      "SPIROMETER":                 str(values.spirometer),
    ]

    return [
      "_DD_UC_PARMS":           ucParms,
      "_RCP_MASTERINDEX":       masterIndex,
      "_RCP_OUTPAT_DATAENTRY":  [dataEntry],
    ]
  }

  /// Maps a 0-10 pain scale value to the server's SCORE_CHARACTER_DESC string.
  private func painCharacterDesc(_ level: Int) -> String {
    switch level {
    case 0:       return "No Pain"
    case 1...3:   return "With Mild discomfort"
    case 4...6:   return "With Moderate discomfort"
    case 7...9:   return "With Severe discomfort"
    default:      return "With Worst Possible Pain"
    }
  }
}
