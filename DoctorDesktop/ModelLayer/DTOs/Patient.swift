//
//  Patient.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/12/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol Patient {
  var id: String { get }
  var genderAge: String { get }
  var visitId: String { get }
  var placeId: String { get }
  var financialAccount: String { get }
  var flagImageName: String { get }
  var countyFlag: UIImage? { get set }
  var name: String { get }
  var nationality: String { get }
}

struct InpatientPatient: Decodable, Patient {
  private let nameInEnglish: String
  private let nameInArabic: String
  private let nationalityInEnglish: String
  private let nationalityInArabic: String
  private let ageInEnglish: String
  private let ageInArabic: String

  private let doctorNameInEnglish: String
  private let doctorNameInArabic: String
  private let bedNumberInEnglish: String
  private let bedNumberInArabic: String

  var id: String
  var genderAge: String
  var visitId: String
  var placeId: String
  var financialAccount: String
  var flagImageName: String
  var countyFlag: UIImage?
  var name: String { return nameInEnglish }
  var nationality: String { return nationalityInEnglish }

  var age: String { return ageInEnglish}
  var doctorName: String { return doctorNameInEnglish }
  var bedNumber: String { return bedNumberInEnglish }

    enum CodingKeys: String, CodingKey {
    case nameInEnglish = "PATIENT_DESC_EN"
    case nameInArabic = "PATIENT_DESC_AR"
    case nationalityInEnglish = "NAT_NAME_EN"
    case nationalityInArabic = "NAT_NAME_AR"
    case ageInEnglish = "AGE_DESC_ROUND_EN"
    case ageInArabic = "AGE_DESC_ROUND_AR"
    case doctorNameInEnglish = "EMP_NAME_EN"
    case doctorNameInArabic = "EMP_NAME_AR"
    case bedNumberInEnglish = "BED_DESC_EN"
    case bedNumberInArabic = "BED_DESC_AR"

    case id = "PATIENTID"
    case genderAge = "GENDER_AGE"
    case visitId = "VISIT_ID"
    case placeId = "PLACE_ID"
    case financialAccount = "PATFINANACCOUNT"
    case flagImageName = "PIC_PATH"
  }
}

struct OutpatientPatient: Decodable, Patient {
  private let nameInEnglish: String
  private let nameInArabic: String
  private let nationalityInEnglish: String
  private let nationalityInArabic: String
  private let doctorNameInEnglish: String
  private let doctorNameInArabic: String
  let serviceStatus: String

  var id: String
  var genderAge: String
  var visitId: String
  var placeId: String
  var financialAccount: String
  var flagImageName: String
  var countyFlag: UIImage?
  var name: String { return nameInEnglish }
  var nationality: String { return nationalityInEnglish }

  var doctorName: String { return doctorNameInEnglish }

  enum CodingKeys: String, CodingKey {
    case nameInEnglish = "COMPLETEPATNAME_EN"
    case nameInArabic = "COMPLETEPATNAME"
    case nationalityInEnglish = "NAT_NAME_EN"
    case nationalityInArabic = "NAT_NAME_AR"
    case doctorNameInEnglish = "EMP_NAME_EN"
    case doctorNameInArabic = "EMP_NAME_AR"
    case serviceStatus = "SERVSTATUS"

    case id = "PATIENTID"
    case genderAge = "GENDER_AGE"
    case visitId = "VISIT_ID"
    case placeId = "PLACE_ID"
    case financialAccount = "PATFINANACCOUNT"
    case flagImageName = "PIC_PATH"
  }
}

struct EmergencyPatient: Decodable, Patient {
  private let nameInEnglish: String
  private let nameInArabic: String
  private let nationalityInEnglish: String
  private let nationalityInArabic: String
  private let arrivalMethodInEnglish: String?
  private let arrivalMethodInArabic: String?
  let visitStartDate: String
  let triaged: String
  let accuteCondition: String?

  var id: String
  var genderAge: String
  var visitId: String
  var placeId: String
  var financialAccount: String
  var flagImageName: String
  var countyFlag: UIImage?
  var name: String { return nameInEnglish }
  var nationality: String { return nationalityInEnglish }

  var arrivalMethod: String? { return arrivalMethodInEnglish }

  enum CodingKeys: String, CodingKey {
    case nameInEnglish = "ITEM_DESC_EN"
    case nameInArabic = "ITEM_DESC_AR"
    case nationalityInEnglish = "NAT_NAME_EN"
    case nationalityInArabic = "NAT_NAME_AR"
    case arrivalMethodInEnglish = "ARRIVAL_TYPE_NAME_EN"
    case arrivalMethodInArabic = "ARRIVAL_TYPE_NAME_AR"
    case visitStartDate = "VISIT_START_DATE"
    case triaged = "EMERGENCY_TRIAGE_FLAG"
    case accuteCondition = "ACCUTY_COND"

    case id = "PATIENTID"
    case genderAge = "GENDER_AGE"
    case visitId = "VISIT_ID"
    case placeId = "PLACE_ID"
    case financialAccount = "PATFINANACCOUNT"
    case flagImageName = "PIC_PATH"
  }
}

struct ClinicalPatient: Decodable, Patient {
  private let nameInEnglish: String
  private let nameInArabic: String
  private let nationalityInEnglish: String
  private let nationalityInArabic: String
  private let ageInEnglish: String
  private let ageInArabic: String

  var id: String
  var genderAge: String
  var visitId: String
  var financialAccount: String
  var flagImageName: String
  var countyFlag: UIImage?
  var name: String { return nameInEnglish }
  var nationality: String { return nationalityInEnglish }
  var placeId: String { return "" }

  var age: String { return ageInEnglish }

  var scores: [ClinicalPatientScore]?
  var panicLabResults: [ClinicalPatientPanicLabRadResult]?
  var panicRadResults: [ClinicalPatientPanicLabRadResult]?

  enum CodingKeys: String, CodingKey {
    case nameInEnglish = "COMPLETEPATNAME_EN"
    case nameInArabic = "COMPLETEPATNAME_AR"
    case nationalityInEnglish = "NAT_NAME_EN"
    case nationalityInArabic = "NAT_NAME_AR"
    case ageInEnglish = "AGE_DESC_ROUND_EN"
    case ageInArabic = "AGE_DESC_ROUND_AR"

    case id = "PATIENTID"
    case genderAge = "GENDER_AGE"
    case visitId = "VISIT_ID"
    case financialAccount = "PATFINANACCOUNT"
    case flagImageName = "PIC_PATH"

    case scores = "PAT_SCORES"
    case panicLabResults = "PANIC_LAB_RESULT"
    case panicRadResults = "PANIC_RAD_RESULT"
  }

  enum CodingKeysRows: String, CodingKey {
    case scoresRow = "PAT_SCORES_ROW"
    case panicLabResultRow = "PANIC_LAB_RESULT_ROW"
    case panicRadResultRow = "PANIC_RAD_RESULT_ROW"
  }
}

extension ClinicalPatient {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let nameInEnglish = try container.decode(String.self, forKey: .nameInEnglish)
    let nameInArabic = try container.decode(String.self, forKey: .nameInArabic)
    let nationalityInEnglish = try container.decode(String.self, forKey: .nationalityInEnglish)
    let nationalityInArabic = try container.decode(String.self, forKey: .nationalityInArabic)
    let ageInEnglish = try container.decode(String.self, forKey: .ageInEnglish)
    let ageInArabic = try container.decode(String.self, forKey: .ageInArabic)
    let id = try container.decode(String.self, forKey: .id)
    let genderAge = try container.decode(String.self, forKey: .genderAge)
    let visitId = try container.decode(String.self, forKey: .visitId)
    let financialAccount = try container.decode(String.self, forKey: .financialAccount)
    let flagImageName = try container.decode(String.self, forKey: .flagImageName)
    var scores: [ClinicalPatientScore]?
    var panicLabResults: [ClinicalPatientPanicLabRadResult]?
    var panicRadResults: [ClinicalPatientPanicLabRadResult]?

    if let scoresContainer = try? container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .scores) {
      if let score = try? scoresContainer.decode(ClinicalPatientScore.self, forKey: .scoresRow) {
        scores = [score]
      } else if let tempScores = try? scoresContainer.decode([ClinicalPatientScore].self, forKey: .scoresRow) {
        scores = tempScores
      }
    }
    if let panicLabResultsContainer = try? container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .panicLabResults) {
      if let panicLabResult = try? panicLabResultsContainer.decode(ClinicalPatientPanicLabRadResult.self, forKey: .panicLabResultRow) {
        panicLabResults = [panicLabResult]
      } else if let tempPanicLabResults = try? panicLabResultsContainer.decode([ClinicalPatientPanicLabRadResult].self, forKey: .panicLabResultRow) {
        panicLabResults = tempPanicLabResults
      }
    }
    if let panicRadResultsContainer = try? container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .panicRadResults) {
      if let panicRadResult = try? panicRadResultsContainer.decode(ClinicalPatientPanicLabRadResult.self, forKey: .panicRadResultRow) {
        panicRadResults = [panicRadResult]
      } else if let tempPanicRadResults = try? panicRadResultsContainer.decode([ClinicalPatientPanicLabRadResult].self, forKey: .panicRadResultRow) {
        panicRadResults = tempPanicRadResults
      }
    }
    self.init(nameInEnglish: nameInEnglish, nameInArabic: nameInArabic,
              nationalityInEnglish: nationalityInEnglish, nationalityInArabic: nationalityInArabic,
              ageInEnglish: ageInEnglish, ageInArabic: ageInArabic,
              id: id, genderAge: genderAge, visitId: visitId, financialAccount: financialAccount,
              flagImageName: flagImageName, countyFlag: nil, scores: scores,
              panicLabResults: panicLabResults, panicRadResults: panicRadResults)
  }
}

protocol ClinicalPatientInfo {
  var title: String { get }
  var details: String { get }
}

struct ClinicalPatientScore: Decodable, ClinicalPatientInfo {
  let scoreDescription: String
  let scoreValue: String?

  var title: String { return scoreDescription }
  var details: String { return scoreValue ?? "--" }

  enum CodingKeys: String, CodingKey {
    case scoreDescription = "SCORE_DESC"
    case scoreValue = "SCORE_VALUE"
  }
}

struct ClinicalPatientPanicLabRadResult: Decodable, ClinicalPatientInfo {
  private let serviceNameInArabic: String
  private let serviceNameInEnglish: String
  let confirmationDate: Date
  var serviceName: String { return serviceNameInEnglish }

  var title: String { return serviceName }
  var details: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
    return formatter.string(from: confirmationDate)
  }

  enum CodingKeys: String, CodingKey {
    case serviceNameInArabic = "SERV_NAME_AR"
    case serviceNameInEnglish = "SERV_NAME_EN"
    case confirmationDate = "CONFIRM_DATE"
  }
}
