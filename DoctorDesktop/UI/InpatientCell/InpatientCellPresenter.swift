//
//  InpatientCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/13/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

enum GenderAgeType: String {
  case childMale = "1"
  case childFemale = "2"
  case male = "3"
  case female = "4"
  case pregnant = "5"
  case oldMale = "6"
  case oldFemale = "7"
}

protocol InpatientCellPresenter {
  var genderAgeImage: UIImage? { get }
  var patientName: String { get }
  var doctorName: String { get }
  var date: String { get }
  var bedNumberName: String { get }
  var flagImageName: String { get }
   var age:String {  get }
}

class InpatientCellPresenterImpl: InpatientCellPresenter {
  var inpatientPatient: InpatientPatient

  var genderAgeImage: UIImage? {
    guard let genderAgeType = GenderAgeType(rawValue: inpatientPatient.genderAge) else {
      return nil
    }
    return getGenderAgeImage(genderAgeType: genderAgeType)
  }
  
  var patientName: String { return inpatientPatient.getPatientName() }
  var doctorName: String { return inpatientPatient.getDocName() }
  var date:String { return  inpatientPatient.date  }
  var bedNumberName: String { return inpatientPatient.bedNumber }
  var age:String { return inpatientPatient.age }
  var flagImageName: String { return inpatientPatient.flagImageName }

  init(with inpatientPatient: InpatientPatient) {
    self.inpatientPatient = inpatientPatient
  }
  
}
