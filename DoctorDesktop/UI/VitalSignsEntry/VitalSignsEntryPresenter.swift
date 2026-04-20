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

  init(patient: Patient, user: User) {
    self.patient = patient
    self.user = user
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

  func save(values: VitalSignsEntryValues, completion: @escaping (Bool) -> Void) {
    // Placeholder: the Android counterpart posts to the triage endpoint.
    // Here we just succeed locally so the UX flow works end-to-end.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      completion(true)
    }
  }
}
