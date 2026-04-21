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

  /// Fetches recorded vital signs history from `GetPatCustomizedSummary`.
  /// Returns the `[VitalSign]` array (may be empty). Completion always on main queue.
  func loadVitalSignsHistory(completion: @escaping ([VitalSign]) -> Void)

  /// Fetches the patient's visit history from `LoadPatientEpisodes`.
  /// Returns nil on network / parse failure. Completion always on main queue.
  func loadPatientHistory(completion: @escaping (PatientHistory?) -> Void)

  /// Called when the user taps Save. Currently local-only (matches the
  /// placeholder nature of the Android screen in this codebase). A real
  /// submit would be wired through ModelLayer here.
  func save(values: VitalSignsEntryValues, completion: @escaping (Bool) -> Void)
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
    modelLayer.loadUcaf(with: params) { ucaf, ctas in
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

  func loadVitalSignsHistory(completion: @escaping ([VitalSign]) -> Void) {
    // Same params as OverviewPresenterImpl.getPatientSummary — scoped to the
    // current visit only (VISIT_ID_ARRAY = single visit ID).
    let params: [String: String] = [
      "COMPUTER_NAME":   "iOS",
      "TRACER_PLACE_ID": patient.placeId,
      "PROCESS_ID":      "20531",
      "USER_ID":         user.userName ?? user.id ?? "",
      "BRANCH_ID":       user.branch   ?? "",
      "PATIENT_ID":      patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
      "VISIT_ID_ARRAY":  patient.visitId
    ]
    modelLayer.getPatientSummary(with: params) { summary in
      DispatchQueue.main.async {
        completion(summary.vitalSigns ?? [])
      }
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

  func save(values: VitalSignsEntryValues, completion: @escaping (Bool) -> Void) {
    let body = buildSaveSpecialHabitsBody(values: values)
    modelLayer.saveSpecialHabits(body: body) { success, message in
      DispatchQueue.main.async { completion(success) }
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
}
