//
//  EmergencyCellPresenter.swift
//  DoctorDesktop
//

import Foundation
import UIKit

protocol EmergencyCellPresenter {
  var patientName: String { get }
  var visitStartDate: String { get }
  var arrivalMethod: String? { get }
  var genderAgeImage: UIImage? { get }
  var flagImageName: String { get }
  var mrn: String { get }
  var ageGenderText: String { get }
}

class EmergencyCellPresenterImpl: EmergencyCellPresenter {
  var emergencyPatient: EmergencyPatient
  let formatter = DateFormatter()

  var genderAgeImage: UIImage? {
    guard let genderAgeType = GenderAgeType(rawValue: emergencyPatient.genderAge) else {
      return nil
    }
    return getGenderAgeImage(genderAgeType: genderAgeType)
  }

  var patientName: String    { return emergencyPatient.name }
  var visitStartDate: String { return emergencyPatient.visitStartDate }
  var arrivalMethod: String? { return emergencyPatient.arrivalMethod }
  var flagImageName: String  { return emergencyPatient.flagImageName }
  var mrn: String            { return emergencyPatient.id }

  var ageGenderText: String {
    switch GenderAgeType(rawValue: emergencyPatient.genderAge) {
    case .male, .oldMale, .childMale: return "Male"
    case .female, .oldFemale, .childFemale, .pregnant: return "Female"
    default: return ""
    }
  }

  init(with emergencyPatient: EmergencyPatient) {
    self.emergencyPatient = emergencyPatient
    formatter.dateFormat = "dd-MM-yyyy"
  }
}
