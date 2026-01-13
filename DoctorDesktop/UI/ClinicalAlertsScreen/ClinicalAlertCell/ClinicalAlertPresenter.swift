//
//  ClinicalAlertPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol ClinicalAlertCellPresenter {
  var name: String { get }
  var nationality: String { get }
  var age: String { get }
  var genderAgeImage: UIImage? { get }
}

class ClinicalAlertCellPresenterImpl: ClinicalAlertCellPresenter {
  var clinicalPatient: ClinicalPatient
  let formatter = DateFormatter()

  var genderAgeImage: UIImage? {
    guard let genderAgeType = GenderAgeType(rawValue: clinicalPatient.genderAge) else { return nil}
    return getGenderAgeImage(genderAgeType: genderAgeType)
  }

  var name: String { return clinicalPatient.name }
  var nationality: String { return clinicalPatient.nationality }
  var age: String { return clinicalPatient.age }

  init(with clinicalPatient: ClinicalPatient) {
    self.clinicalPatient = clinicalPatient
    formatter.dateFormat = "dd-MM-yyyy"
  }
}
