//
//  OutpatientCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/18/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol OutpatientCellPresenter {
  var genderAgeImage: UIImage? { get }
  var patientName: String { get }
  var patientNationality: String { get }
  var doctorName: String { get }
  var clinicTitle: String { get }
}

class OutpatientCellPresenterImpl: OutpatientCellPresenter {
  var outpatientPatient: OutpatientPatient
  
  var genderAgeImage: UIImage? {
    guard let genderAgeType = GenderAgeType(rawValue: outpatientPatient.genderAge) else {
      return nil
    }
    return getGenderAgeImage(genderAgeType: genderAgeType)
  }
  
  var patientName: String { return outpatientPatient.name }
  var patientNationality: String { return outpatientPatient.nationality }
  var doctorName: String { return outpatientPatient.doctorName }
  var clinicTitle: String { return outpatientPatient.name }

  init(with outpatientPatient: OutpatientPatient) {
    self.outpatientPatient = outpatientPatient
  }

}
