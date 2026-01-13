//
//  PatientHistory.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/23/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

typealias Operation = OperationCatherEndoscopy
typealias Cather = OperationCatherEndoscopy
typealias Endoscopy = OperationCatherEndoscopy
typealias Allergy = AllergyFindingComplaintHistory
typealias Finding = AllergyFindingComplaintHistory
typealias Complaint = [AllergyFindingComplaintHistory]
typealias History = AllergyFindingComplaintHistory

struct PatientSummary {
  let complaints: [Complaint]?
  let findings: [Finding]?
  let diagnosis: [Diagnosis]?
  let history: [History]?
  let allergies: [Allergy]?
  let medications: [Medication]?
  let scorings: [Scoring]?
  let nurseRemarks: [NurseRemark]?
  let operations: [Operation]?
  let catheters: [Cather]?
  let endoscopies: [Endoscopy]?
  let rads: [Rad]?
  let clinicServices: [ClinicService]?
  let dietaries: [Dietary]?
  let labs: [Lab]?
  let vitalSigns: [VitalSign]?
}

struct AllergyFindingComplaintHistory: Decodable {
  let englishDescription: String?
  let arabicDescription: String?
  let transactionDate: Date
  let visitSpecialityArabicName: String?
  let visitSpecialityEnglishName: String?
  let allergyTypeArabicName: String?
  let allergyTypeEnglishName: String?

  enum CodingKeys: String, CodingKey {
    case englishDescription = "DESC_EN"
    case arabicDescription = "DESC_AR"
    case transactionDate = "TRANS_DATE"
    case visitSpecialityArabicName = "VISIT_SPECIALITY_NAME_AR"
    case visitSpecialityEnglishName = "VISIT_SPECIALITY_NAME_EN"
    case allergyTypeArabicName = "ALLERGY_TYPE_NAME_AR"
    case allergyTypeEnglishName = "ALLERGY_TYPE_NAME_EN"
  }
}

struct Diagnosis: Decodable {
  let code: String
  let transactionDate: Date
  let itemDescription: String
  let status: String

  enum CodingKeys: String, CodingKey {
    case code = "CODE"
    case transactionDate = "TRANS_DATE"
    case itemDescription = "ITEM_DESC"
    case status = "STATUS"
  }
}

struct Medication: Decodable {
  let englishNotes: String?
  let arabicNotes: String?
  let englishNotesDescription: String?
  let arabicNotesDescription: String?
  let transactionDate: String?
  let prescriptionTypeArabicName: String?
  let prescriptionTypeEnglishName: String?
  let itemArabicName: String?
  let itemEnglishName: String?
  let doctorShortEnlgishName: String?
  let doctorShortArabicName: String?

  enum CodingKeys: String, CodingKey {
    case englishNotes = "NOTES_EN"
    case arabicNotes = "NOTES_AR"
    case englishNotesDescription = "NOTES_DESC_EN"
    case arabicNotesDescription = "NOTES_DESC_AR"
    case transactionDate = "TRANSDATE"
    case prescriptionTypeArabicName = "PRESC_TYPE_NAME_AR"
    case prescriptionTypeEnglishName = "PRESC_TYPE_NAME_EN"
    case itemArabicName = "ITEMARNAME"
    case itemEnglishName = "ITEMENNAME"
    case doctorShortEnlgishName = "EMP_SHORT_EN"
    case doctorShortArabicName = "EMP_SHORT_AR"
  }
}

struct Scoring: Decodable {
  let description: String
  let value: String?
  let conclusion: String?

  enum CodingKeys: String, CodingKey {
    case description = "SCORE_DESC"
    case value = "SCORE_VALUE"
    case conclusion = "CONCULSION_DESC"
  }
}

struct NurseRemark: Decodable {
  let doctorArabicName: String?
  let doctorEnglishName: String?
  let nurseArabicName: String?
  let nurseEnglishName: String?
  let doctorTransactionDate: String?
  let nurseTransactionDate: String?
  let arabicDescription: String?
  let englishDescription: String?
  let nurseNotes: String?

  enum CodingKeys: String, CodingKey {
    case doctorArabicName = "EMP_NAME_AR"
    case doctorEnglishName = "EMP_NAME_EN"
    case nurseArabicName = "N_EMP_NAME_AR"
    case nurseEnglishName = "N_EMP_NAME_EN"
    case doctorTransactionDate = "TRANSDATE"
    case nurseTransactionDate = "N_TRANSDATE"
    case arabicDescription = "DESC_AR"
    case englishDescription = "DESC_EN"
    case nurseNotes = "NURSE_NOTES"
  }
}

struct OperationCatherEndoscopy: Decodable {
  let id: String
  let arabicName: String
  let englishName: String
  let expectedDoneDate: Date
  let surgeonArabicName: String
  let surgeonEnglishName: String
  let anthesiaArabicName: String?
  let anthesiaEnglishName: String?

  enum CodingKeys: String, CodingKey {
    case id = "SERVICE_ID"
    case arabicName = "SRV_AR_NAME"
    case englishName = "SRV_EN_NAME"
    case expectedDoneDate = "EXPECTEDDONEDATE"
    case surgeonArabicName = "SURGEON_NAME_AR"
    case surgeonEnglishName = "SURGEON_NAME_EN"
    case anthesiaArabicName = "ANTHESIA_NAME_AR"
    case anthesiaEnglishName = "ANTHESIA_NAME_EN"
  }
}

struct Rad: Decodable {
  let accessNumber: String
  let requestDate: Date
  let id: String
  let arabicName: String
  let englishName: String
  let englishStatus: String
  let arabicStatus: String
  let arabicEndResult: String
  let englishEndResult: String

  enum CodingKeys: String, CodingKey {
    case accessNumber = "ACCESSION_NO"
    case requestDate = "REQ_DATE"
    case id = "SERVICE_ID"
    case arabicName = "SRV_AR_NAME"
    case englishName = "SRV_EN_NAME"
    case englishStatus = "SERV_STATUS_NAME_EN"
    case arabicStatus = "SERV_STATUS_NAME_AR"
    case arabicEndResult = "END_RESULT_NAME_AR"
    case englishEndResult = "END_RESULT_NAME_EN"
  }
}

struct ClinicService: Decodable {
  let id: String
  let arabicName: String
  let englishName: String
  let arabicStatus: String
  let englishStatus: String
  let resultDate: Date

  enum CodingKeys: String, CodingKey {
    case id = "SERVICE_ID"
    case arabicName = "SRV_AR_NAME"
    case englishName = "SRV_EN_NAME"
    case arabicStatus = "SERVSTATUS_NAME_AR"
    case englishStatus = "SERVSTATUS_NAME_EN"
    case resultDate = "RES_DATE"
  }
}

struct Dietary: Decodable {
  let dietArabicName: String
  let dietEnglishName: String
  let lastModDate: Date
  let remarks: String?

  enum CodingKeys: String, CodingKey {
    case dietArabicName = "DIET_NAME_AR"
    case dietEnglishName = "DIET_NAME_EN"
    case lastModDate = "LAST_MOD_DATE"
    case remarks = "REMARKS"
  }
}

struct Lab: Decodable {
  let serviceCategoryArabicName: String
  let serviceCategoryEnglishName: String
  let notSeenCount: String
  let abnormalCount: String
  let panicCount: String
  let normalCount: String
  let pendingCount: String
  let labServices: [LabService]?

  enum CodingKeys: String, CodingKey {
    case serviceCategoryArabicName = "SRV_AR_NAME"
    case serviceCategoryEnglishName = "SRV_EN_NAME"
    case notSeenCount = "NOTSEEN_COUNT"
    case abnormalCount = "ABNORMAL_COUNT"
    case panicCount = "PANIC_COUNT"
    case normalCount = "NORMAL_COUNT"
    case pendingCount = "PENDING_COUNT"
    case labServices = "LAB_SERVICES"
    case labServicesRow = "LAB_SERVICES_ROW"
  }

  struct LabService: Decodable {
    let serviceArabicName: String
    let serviceEnglishName: String
    let sheetItems: [SheetItem]?
    enum CodingKeys: String, CodingKey {
      case serviceArabicName = "SRV_AR_NAME"
      case serviceEnglishName = "SRV_EN_NAME"
      case sheetItems = "SHEET_ITEMS"
      case sheetItemsRow = "SHEET_ITEMS_ROW"
    }
  }

  struct SheetItem: Decodable {
    let itemDescription: String
    let unitDescription: String
    let referenceRange: String?

    enum CodingKeys: String, CodingKey {
      case itemDescription = "ITEMDDESCR"
      case unitDescription = "UNITDESC"
      case referenceRange = "REFERENCE_RANGE"
    }
  }
}

extension Lab {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let serviceCategoryArabicName = try container.decode(String.self, forKey: .serviceCategoryArabicName)
    let serviceCategoryEnglishName = try container.decode(String.self, forKey: .serviceCategoryEnglishName)
    let notSeenCount = try container.decode(String.self, forKey: .notSeenCount)
    let abnormalCount = try container.decode(String.self, forKey: .abnormalCount)
    let panicCount = try container.decode(String.self, forKey: .panicCount)
    let normalCount = try container.decode(String.self, forKey: .normalCount)
    let pendingCount = try container.decode(String.self, forKey: .pendingCount)
    var labServices: [LabService]?
    if let servicesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .labServices) {
      if let labService = try? servicesContainer.decode(LabService.self, forKey: .labServicesRow) {
        labServices = [labService]
      } else if let tempLabServices = try? servicesContainer.decode([LabService].self, forKey: .labServicesRow) {
        labServices = tempLabServices
      }
    }
    self.init(serviceCategoryArabicName: serviceCategoryArabicName,
              serviceCategoryEnglishName: serviceCategoryEnglishName,
              notSeenCount: notSeenCount,
              abnormalCount: abnormalCount,
              panicCount: panicCount,
              normalCount: normalCount,
              pendingCount: pendingCount,
              labServices: labServices)
  }
}

extension Lab.LabService {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let serviceArabicName = try container.decode(String.self, forKey: .serviceArabicName)
    let serviceEnglishName = try container.decode(String.self, forKey: .serviceEnglishName)

    var sheetItems: [Lab.SheetItem]?
    if let sheetItemsContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .sheetItems) {
      if let sheetItem = try? sheetItemsContainer.decode(Lab.SheetItem.self, forKey: .sheetItemsRow) {
        sheetItems = [sheetItem]
      } else if let tempSheetItems = try? sheetItemsContainer.decode([Lab.SheetItem].self, forKey: .sheetItemsRow) {
        sheetItems = tempSheetItems
      }
    }
    self.init(serviceArabicName: serviceArabicName,
              serviceEnglishName: serviceEnglishName,
              sheetItems: sheetItems)
  }
}

struct VitalSign: Decodable {
  let arabicName: String
  let englishName: String
  let id: String
  let details: [VitalSignDetail]?
  enum CodingKeys: String, CodingKey {
    case arabicName = "NAME_AR"
    case englishName = "NAME_EN"
    case id = "ID"
    case details = "VITAL_SIGNS_DETAILS"
    case detailsRow = "VITAL_SIGNS_DETAILS_ROW"
  }

  struct VitalSignDetail: Decodable {
    let itemValue: String
    let itemType: String
    let previous: String?
    let progressValue: String
    let normalFlag: String
    let itemDateTime: Date
    enum CodingKeys: String, CodingKey {
      case itemValue = "ITEM_VALUE"
      case itemType = "ITEM_TYPE"
      case previous = "PREVIOUS_VALUE"
      case progressValue = "PROGRESS_VAL"
      case normalFlag = "NORMAL_FLAG"
      case itemDateTime = "ITEM_DATE_TIME"
    }
  }
}

extension VitalSign {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let arabicName = try container.decode(String.self, forKey: .arabicName)
    let englishName = try container.decode(String.self, forKey: .englishName)
    let id = try container.decode(String.self, forKey: .id)

    var vitalSignDetails: [VitalSignDetail]?
    if let detailsContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .details) {
      if let vitalSignDetail = try? detailsContainer.decode(VitalSignDetail.self, forKey: .detailsRow) {
        vitalSignDetails = [vitalSignDetail]
      } else if let tempVitalSignDetails = try? detailsContainer.decode([VitalSignDetail].self, forKey: .detailsRow) {
        vitalSignDetails = tempVitalSignDetails
      }
    }
    self.init(arabicName: arabicName,
              englishName: englishName,
              id: id,
              details: vitalSignDetails)
  }
}
