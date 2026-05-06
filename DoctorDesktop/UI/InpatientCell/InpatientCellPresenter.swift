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
    var age: String { get }
    var highLight: String { get }
    var gender: String { get }
    var genderColor: UIColor { get }
    var avatarTint: UIColor { get }
}

class InpatientCellPresenterImpl: InpatientCellPresenter {
    var inpatientPatient: InpatientPatient

    var genderAgeImage: UIImage? {
        guard let genderAgeType = GenderAgeType(rawValue: inpatientPatient.genderAge) else { return nil }
        return getGenderAgeImage(genderAgeType: genderAgeType)
    }

    var patientName: String { return inpatientPatient.getPatientName() }
    var doctorName: String  { return inpatientPatient.getDocName() }
    var date: String        { return inpatientPatient.date }
    var bedNumberName: String { return inpatientPatient.bedNumber }
    var age: String         { return inpatientPatient.age }
    var flagImageName: String { return inpatientPatient.flagImageName }
    var highLight: String   { return inpatientPatient.highLightFlag ?? "" }

    /// Derived from the GENDER_AGE numeric code (1/3/6 = male, 2/4/5/7 = female).
    var gender: String {
        switch GenderAgeType(rawValue: inpatientPatient.genderAge) {
        case .male, .oldMale, .childMale:                  return "Male"
        case .female, .oldFemale, .childFemale, .pregnant: return "Female"
        default:                                           return ""
        }
    }

    var genderColor: UIColor {
        switch gender {
        case "Male":   return UIColor(red: 0.18, green: 0.49, blue: 0.90, alpha: 1)
        case "Female": return UIColor(red: 0.91, green: 0.30, blue: 0.50, alpha: 1)
        default:       return UIColor(white: 0.45, alpha: 1)
        }
    }

    /// Soft tint for the avatar-circle background.
    var avatarTint: UIColor {
        switch gender {
        case "Male":   return UIColor(red: 0.36, green: 0.62, blue: 0.95, alpha: 1)
        case "Female": return UIColor(red: 0.95, green: 0.50, blue: 0.66, alpha: 1)
        default:       return UIColor(red: 64/255, green: 178/255, blue: 178/255, alpha: 1)
        }
    }

    init(with inpatientPatient: InpatientPatient) {
        self.inpatientPatient = inpatientPatient
    }
}
