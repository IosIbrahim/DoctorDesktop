//
//  EmergencyCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/24/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol EmergencyCellPresenter {
  var patientName: String { get }
  var visitStartDate: String { get }
  var arrivalMethod: String? { get }
  var genderAgeImage: UIImage? { get }
  var flagImageName: String { get }
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
  
  var patientName: String { return emergencyPatient.name }
  var visitStartDate: String { return emergencyPatient.visitStartDate/*formatter.string(from: emergencyPatient.visitStartDate)*/ }
  var arrivalMethod: String? { return emergencyPatient.arrivalMethod }
  var flagImageName: String { return emergencyPatient.flagImageName }

  init(with emergencyPatient: EmergencyPatient) {
    self.emergencyPatient = emergencyPatient
    formatter.dateFormat = "dd-MM-yyyy"
  }

}
