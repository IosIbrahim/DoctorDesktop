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
  var date: String { get }
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
  var date:String
  var financialAccount: String
  var flagImageName: String
  var countyFlag: UIImage?
  var name: String { return nameInEnglish }
  var nationality: String { return nationalityInEnglish }

  var age: String { return ageInEnglish}
  var doctorName: String { return doctorNameInEnglish }
  var bedNumber: String { return bedNumberInEnglish }
    func getPatientName()-> String {
        return "\(id) - \(nameInEnglish)"
    }
    
    func getDocName() -> String {
        return doctorNameInEnglish
    }

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
    case date = "VISIT_START_DATE"
  }
}

struct MainResponseModel:Codable {
    let root:String?
    enum CodingKeys: String, CodingKey {
        case root = "Root"
    }
}

struct MainRootModel:Codable {
    let clinics:String?
    enum CodingKeys: String, CodingKey {
        case clinics = "CLINIC_PATIENTS"
    }
}



struct OutpatientPatient: Decodable, Patient {
    private let ageDec: String?
    var walkFlag :String?
    var assistantDocID:String?
    var btnCategory:String?
    var cashierFlag:String?
    var checkPatHasOPD:String?
    var clinitLetter:String?
    var clinicNameAr:String?
    var clinicNameEN:String?
    private let nameInEnglish: String
    private let nameInArabic: String
    var convReq:String?
    var convConsultionID:String?
    var convRemark:String?
    var ctasScore:String?
    var dischargeFlag:String?
    var dsiplayMode:String?
    var doneDoctorId:String?
    var empNameAr:String?
    var empNameEn:String?
    var erFlag:String?
    var expectedDate:String?
    var genderAGE: String
    var genderAgeNameAr:String?
    var genderAgeNameEn:String?
    var genderNameAr:String?
    var genderNameEn:String?
    var highLightFlag:String?
    var homeVisitFlag:String?
    var mappedClinicID:String?
    var motherPatientID:String?
    var motherVisitID:String?
    private let nationalityInEnglish: String
    private let nationalityInArabic: String
    var newBornIn:String?
    var newBornOut:String?
    var noSpecialConsution:String?
    var opCallArrivalDate:String?
    var outNoofPats:String?
    var overBook:String?
    var painAssessValue:String?
    var patFinanCount:String?
    var patID: String
    var patMobile:String?
    var patClinicFlag:String?
    var patNoteDesc:String?
    var patStatusNameAr:String?
    var patStatusNameEn:String?
    var patImage: String?
    var placeID:String?
    var queueMappedID:String?
    var queueScreenCalled:String?
    var queSer:String?
    var queSysSer:String?
    var recallStatus:String?
    var resDate:String?
    var resType:String?
    var schedSerial:String?
    var ser:String?
    var serColor:String?
    var serviceNameAr:String?
    var serviceNameEn:String?
    var serviceTime:String?
    var serVStatus:String?
    var serVStatusNameEn:String?
    var serVStatusNameAr:String?
    var shiftID:String?
    var sigQueueID:String?
    var spec:String?
    var vip:String?
    var vipLevel:String?
    var virology:String?
    var visitID: String
//    var scores: [ClinicalPatientScore]?
//    var panicLabResults: [ClinicalPatientPanicLabRadResult]?
//    var panicRadResults: [ClinicalPatientPanicLabRadResult]?
    
    
    var id: String { return patID }
    var genderAge: String { return genderAgeNameEn ?? "" }
    var visitId: String { return visitID }
    var placeId: String { return placeID ?? "" }
    var date: String { return expectedDate ?? ""  }
    var financialAccount: String { return patFinanCount ?? "" }
    var flagImageName: String { return patImage ?? "" }
    var countyFlag: UIImage?
    var name: String { return nameInEnglish }
    var nationality: String { return nationalityInEnglish }
    var age: String { return ageDec ?? "" }
    
    

  enum CodingKeys: String, CodingKey {
      case ageDec = "AGE_DESC"
      case walkFlag = "APPOINTMENT_WALKIN_FLAG"
      case assistantDocID = "ASSISTANT_DOCID"
      case btnCategory = "BUTTON_CATEGORY"
      case cashierFlag = "CASHIER_FLAG"
      case checkPatHasOPD = "CHECK_PAT_HAS_OPD_VITAL"
      case clinitLetter = "CLINIC_LETTER"
      case clinicNameAr = "CLINIC_NAME_AR"
      case clinicNameEN = "CLINIC_NAME_EN"
      case nameInEnglish = "COMPLETEPATNAME_EN"
      case nameInArabic = "COMPLETEPATNAME"
      case convReq = "CONV_REQ"
      case convConsultionID = "CONV_REQ_CONSULTAION_ID"
      case convRemark = "CONV_REQ_REMARK"
      case ctasScore = "CTAS_SCORE_VALUE"
      case dischargeFlag = "DISCHARGE_FLAG"
      case dsiplayMode = "DISPLAY_MODE"
      case doneDoctorId = "DONEDOCTORID"
      case empNameAr = "EMP_NAME_AR"
      case empNameEn = "EMP_NAME_EN"
      case erFlag = "ER_BOUNCE_BACK_FLAG"
      case expectedDate = "EXPECTEDDONEDATE"
      case genderAGE = "GENDER_AGE"
      case genderAgeNameAr = "GENDER_AGE_NAME_AR"
      case genderAgeNameEn = "GENDER_AGE_NAME_EN"
      case genderNameAr = "GENDER_NAME_AR"
      case genderNameEn = "GENDER_NAME_EN"
      case highLightFlag = "HIGHLIGHT_FLAG"
      case homeVisitFlag = "HOME_VISIT_FLAG"
      case mappedClinicID = "MAPPED_CLINIC_ID"
      case motherPatientID = "MOTHER_PATIENTID"
      case motherVisitID = "MOTHER_VISIT_ID"
      case nationalityInEnglish = "NAT_NAME_EN"
      case nationalityInArabic = "NAT_NAME_AR"
      case newBornIn = "NEW_BORN_IN"
      case newBornOut = "NEW_BORN_OUT"
      case noSpecialConsution = "NO_SPECIALITY_CONSULTATION"
      case opCallArrivalDate = "OP_CALL_ARRIVAL_DATE"
      case outNoofPats = "OUT_OF_NOOF_PATS"
      case overBook = "OVER_BOOK"
      case painAssessValue = "PAIN_ASSESMENT_VALUE"
      case patFinanCount = "PATFINANACCOUNT"
      case patID = "PATIENTID"
      case patMobile = "PATIENT_MOBILE"
      case patClinicFlag = "PAT_CLINICS_FLAG"
      case patNoteDesc = "PAT_NOTE_DESC"
      case patStatusNameAr = "PAT_STATUS_NAME_AR"
      case patStatusNameEn = "PAT_STATUS_NAME_EN"
      case patImage = "PIC_PATH"
      case placeID = "PLACE_ID"
      case queueMappedID = "QUEUE_MAPPED_SERVICE_POINT_ID"
      case queueScreenCalled = "QUEUE_SCREEN_CALLED"
      case queSer = "QUE_SER"
      case queSysSer = "QUE_SYS_SER"
      case recallStatus = "RECALL_STATUS"
      case resDate = "RES_DATE"
      case resType = "RES_TYPE"
      case schedSerial = "SCHED_SERIAL"
      case ser = "SER"
      case serColor = "SERVICE_COLOR"
      case serviceNameAr = "SERVICE_NAME_AR"
      case serviceNameEn = "SERVICE_NAME_EN"
      case serviceTime = "SERVICE_TIME"
      case serVStatus = "SERVSTATUS"
      case serVStatusNameEn = "SERVSTATUS_NAME_EN"
      case serVStatusNameAr = "SERVSTATUS_NAME_AR"
      case shiftID = "SHIFT_ID"
      case sigQueueID = "SIH_QUEUE_ID"
      case spec = "SPEC"
      case vip = "VIP"
      case vipLevel = "VIP_LEVEL"
      case virology = "VIROLOGY"
      case visitID = "VISIT_ID"
//      case scores = "PAT_SCORES"
//      case panicLabResults = "PANIC_LAB_RESULTS"
//      case panicRadResults = "PANIC_RAD_RESULTS"
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
  var date:String { return visitStartDate}
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
    private let ageDec: String
    var walkFlag :String?
    var assistantDocID:String?
    var btnCategory:String?
    var cashierFlag:String?
    var checkPatHasOPD:String?
    var clinitLetter:String?
    var clinicNameAr:String?
    var clinicNameEN:String?
    private let nameInEnglish: String
    private let nameInArabic: String
    var convReq:String?
    var convConsultionID:String?
    var convRemark:String?
    var ctasScore:String?
    var dischargeFlag:String?
    var dsiplayMode:String?
    var doneDoctorId:String?
    var empNameAr:String?
    var empNameEn:String?
    var erFlag:String?
    var expectedDate:String?
    var genderAGE: String
    var genderAgeNameAr:String?
    var genderAgeNameEn:String?
    var genderNameAr:String?
    var genderNameEn:String?
    var highLightFlag:String?
    var homeVisitFlag:String?
    var mappedClinicID:String?
    var motherPatientID:String?
    var motherVisitID:String?
    private let nationalityInEnglish: String
    private let nationalityInArabic: String
    var newBornIn:String?
    var newBornOut:String?
    var noSpecialConsution:String?
    var opCallArrivalDate:String?
    var outNoofPats:String?
    var overBook:String?
    var painAssessValue:String?
    var patFinanCount:String?
    var patID: String
    var patMobile:String?
    var patClinicFlag:String?
    var patNoteDesc:String?
    var patStatusNameAr:String?
    var patStatusNameEn:String?
    var patImage: String?
    var placeID:String?
    var queueMappedID:String?
    var queueScreenCalled:String?
    var queSer:String?
    var queSysSer:String?
    var recallStatus:String?
    var resDate:String?
    var resType:String?
    var schedSerial:String?
    var ser:String?
    var serColor:String?
    var serviceNameAr:String?
    var serviceNameEn:String?
    var serviceTime:String?
    var serVStatus:String?
    var serVStatusNameEn:String?
    var serVStatusNameAr:String?
    var shiftID:String?
    var sigQueueID:String?
    var spec:String?
    var vip:String?
    var vipLevel:String?
    var virology:String?
    var visitID: String
    var scores: [ClinicalPatientScore]?
    var panicLabResults: [ClinicalPatientPanicLabRadResult]?
    var panicRadResults: [ClinicalPatientPanicLabRadResult]?
    
    
    var id: String { return patID }
    var genderAge: String { return genderAgeNameEn ?? "" }
    var visitId: String { return visitID }
    var placeId: String { return placeID ?? "" }
    var date: String { return expectedDate ?? ""  }
    var financialAccount: String { return patFinanCount ?? "" }
    var flagImageName: String { return patImage ?? "" }
    var countyFlag: UIImage?
    var name: String { return nameInEnglish }
    var nationality: String { return nationalityInEnglish }
    var age: String { return ageDec }
    

  enum CodingKeys: String, CodingKey {
      case ageDec = "AGE_DESC"
      case walkFlag = "APPOINTMENT_WALKIN_FLAG"
      case assistantDocID = "ASSISTANT_DOCID"
      case btnCategory = "BUTTON_CATEGORY"
      case cashierFlag = "CASHIER_FLAG"
      case checkPatHasOPD = "CHECK_PAT_HAS_OPD_VITAL"
      case clinitLetter = "CLINIC_LETTER"
      case clinicNameAr = "CLINIC_NAME_AR"
      case clinicNameEN = "CLINIC_NAME_EN"
      case nameInEnglish = "COMPLETEPATNAME_EN"
      case nameInArabic = "COMPLETEPATNAME"
      case convReq = "CONV_REQ"
      case convConsultionID = "CONV_REQ_CONSULTAION_ID"
      case convRemark = "CONV_REQ_REMARK"
      case ctasScore = "CTAS_SCORE_VALUE"
      case dischargeFlag = "DISCHARGE_FLAG"
      case dsiplayMode = "DISPLAY_MODE"
      case doneDoctorId = "DONEDOCTORID"
      case empNameAr = "EMP_NAME_AR"
      case empNameEn = "EMP_NAME_EN"
      case erFlag = "ER_BOUNCE_BACK_FLAG"
      case expectedDate = "EXPECTEDDONEDATE"
      case genderAGE = "GENDER_AGE"
      case genderAgeNameAr = "GENDER_AGE_NAME_AR"
      case genderAgeNameEn = "GENDER_AGE_NAME_EN"
      case genderNameAr = "GENDER_NAME_AR"
      case genderNameEn = "GENDER_NAME_EN"
      case highLightFlag = "HIGHLIGHT_FLAG"
      case homeVisitFlag = "HOME_VISIT_FLAG"
      case mappedClinicID = "MAPPED_CLINIC_ID"
      case motherPatientID = "MOTHER_PATIENTID"
      case motherVisitID = "MOTHER_VISIT_ID"
      case nationalityInEnglish = "NAT_NAME_EN"
      case nationalityInArabic = "NAT_NAME_AR"
      case newBornIn = "NEW_BORN_IN"
      case newBornOut = "NEW_BORN_OUT"
      case noSpecialConsution = "NO_SPECIALITY_CONSULTATION"
      case opCallArrivalDate = "OP_CALL_ARRIVAL_DATE"
      case outNoofPats = "OUT_OF_NOOF_PATS"
      case overBook = "OVER_BOOK"
      case painAssessValue = "PAIN_ASSESMENT_VALUE"
      case patFinanCount = "PATFINANACCOUNT"
      case patID = "PATIENTID"
      case patMobile = "PATIENT_MOBILE"
      case patClinicFlag = "PAT_CLINICS_FLAG"
      case patNoteDesc = "PAT_NOTE_DESC"
      case patStatusNameAr = "PAT_STATUS_NAME_AR"
      case patStatusNameEn = "PAT_STATUS_NAME_EN"
      case patImage = "PIC_PATH"
      case placeID = "PLACE_ID"
      case queueMappedID = "QUEUE_MAPPED_SERVICE_POINT_ID"
      case queueScreenCalled = "QUEUE_SCREEN_CALLED"
      case queSer = "QUE_SER"
      case queSysSer = "QUE_SYS_SER"
      case recallStatus = "RECALL_STATUS"
      case resDate = "RES_DATE"
      case resType = "RES_TYPE"
      case schedSerial = "SCHED_SERIAL"
      case ser = "SER"
      case serColor = "SERVICE_COLOR"
      case serviceNameAr = "SERVICE_NAME_AR"
      case serviceNameEn = "SERVICE_NAME_EN"
      case serviceTime = "SERVICE_TIME"
      case serVStatus = "SERVSTATUS"
      case serVStatusNameEn = "SERVSTATUS_NAME_EN"
      case serVStatusNameAr = "SERVSTATUS_NAME_AR"
      case shiftID = "SHIFT_ID"
      case sigQueueID = "SIH_QUEUE_ID"
      case spec = "SPEC"
      case vip = "VIP"
      case vipLevel = "VIP_LEVEL"
      case virology = "VIROLOGY"
      case visitID = "VISIT_ID"
      case scores = "PAT_SCORES"
      case panicLabResults = "PANIC_LAB_RESULTS"
      case panicRadResults = "PANIC_RAD_RESULTS"
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
      let ageDec = try container.decode(String.self, forKey: .ageDec)
      let walkFlag = try container.decode(String.self, forKey: .walkFlag)
      let assistantDocID = try container.decode(String.self, forKey: .assistantDocID)
      let btnCategory = try container.decode(String.self, forKey: .btnCategory)
      let cashierFlag = try container.decode(String.self, forKey: .cashierFlag)
      let checkPatHasOPD = try container.decode(String.self, forKey: .checkPatHasOPD)
      let clinitLetter = try container.decode(String.self, forKey: .clinitLetter)
      let clinicNameAr = try container.decode(String.self, forKey: .clinicNameAr)
      let clinicNameEN = try container.decode(String.self, forKey: .clinicNameEN)
      let nameInEnglish = try container.decode(String.self, forKey: .nameInEnglish)
      let nameInArabic = try container.decode(String.self, forKey: .nameInArabic)
      
      let convReq = try container.decode(String.self, forKey: .convReq)
      let convConsultionID = try container.decode(String.self, forKey: .convConsultionID)
      let convRemark = try container.decode(String.self, forKey: .convRemark)
      let ctasScore = try container.decode(String.self, forKey: .ctasScore)
      let dischargeFlag = try container.decode(String.self, forKey: .dischargeFlag)
      let dsiplayMode = try container.decode(String.self, forKey: .dsiplayMode)
      let doneDoctorId = try container.decode(String.self, forKey: .doneDoctorId)
      let empNameAr = try container.decode(String.self, forKey: .empNameAr)
      let empNameEn = try container.decode(String.self, forKey: .empNameEn)
      let erFlag = try container.decode(String.self, forKey: .erFlag)
      let expectedDate = try container.decode(String.self, forKey: .expectedDate)
      
      let genderAGE = try container.decode(String.self, forKey: .genderAGE)
      let genderAgeNameAr = try container.decode(String.self, forKey: .genderAgeNameAr)
      let genderAgeNameEn = try container.decode(String.self, forKey: .genderAgeNameEn)
      let genderNameAr = try container.decode(String.self, forKey: .genderNameAr)
      let genderNameEn = try container.decode(String.self, forKey: .genderNameEn)
      let highLightFlag = try container.decode(String.self, forKey: .highLightFlag)
      let homeVisitFlag = try container.decode(String.self, forKey: .homeVisitFlag)
      let mappedClinicID = try container.decode(String.self, forKey: .mappedClinicID)
      let motherPatientID = try container.decode(String.self, forKey: .motherPatientID)
      let motherVisitID = try container.decode(String.self, forKey: .motherVisitID)
      let nationalityInEnglish = try container.decode(String.self, forKey: .nationalityInEnglish)
      
      let nationalityInArabic = try container.decode(String.self, forKey: .nationalityInArabic)
      let newBornIn = try container.decode(String.self, forKey: .newBornIn)
      let newBornOut = try container.decode(String.self, forKey: .newBornOut)
      let noSpecialConsution = try container.decode(String.self, forKey: .noSpecialConsution)
      let opCallArrivalDate = try container.decode(String.self, forKey: .opCallArrivalDate)
      let outNoofPats = try container.decode(String.self, forKey: .outNoofPats)
      let overBook = try container.decode(String.self, forKey: .overBook)
      let painAssessValue = try container.decode(String.self, forKey: .painAssessValue)
      let patFinanCount = try container.decode(String.self, forKey: .patFinanCount)
      let patID = try container.decode(String.self, forKey: .patID)
      let patMobile = try container.decode(String.self, forKey: .patMobile)
      
      let patClinicFlag = try container.decode(String.self, forKey: .patClinicFlag)
      let patNoteDesc = try container.decode(String.self, forKey: .patNoteDesc)
      let patStatusNameAr = try container.decode(String.self, forKey: .patStatusNameAr)
      let patStatusNameEn = try container.decode(String.self, forKey: .patStatusNameEn)
      let patImage = try container.decode(String.self, forKey: .patImage)
      let placeID = try container.decode(String.self, forKey: .placeID)
      let queueMappedID = try container.decode(String.self, forKey: .queueMappedID)
      let queueScreenCalled = try container.decode(String.self, forKey: .queueScreenCalled)
      let queSer = try container.decode(String.self, forKey: .queSer)
      let queSysSer = try container.decode(String.self, forKey: .queSysSer)
      let recallStatus = try container.decode(String.self, forKey: .recallStatus)
      
      let resDate = try container.decode(String.self, forKey: .resDate)
      let resType = try container.decode(String.self, forKey: .resType)
      let schedSerial = try container.decode(String.self, forKey: .schedSerial)
      let ser = try container.decode(String.self, forKey: .ser)
      let serColor = try container.decode(String.self, forKey: .serColor)
      let serviceNameAr = try container.decode(String.self, forKey: .serviceNameAr)
      let serviceNameEn = try container.decode(String.self, forKey: .serviceNameEn)
      let serviceTime = try container.decode(String.self, forKey: .serviceTime)
      let serVStatus = try container.decode(String.self, forKey: .serVStatus)
      let serVStatusNameEn = try container.decode(String.self, forKey: .serVStatusNameEn)
      let serVStatusNameAr = try container.decode(String.self, forKey: .serVStatusNameAr)
      
      let shiftID = try container.decode(String.self, forKey: .shiftID)
      let sigQueueID = try container.decode(String.self, forKey: .sigQueueID)
      let spec = try container.decode(String.self, forKey: .spec)
      let vip = try container.decode(String.self, forKey: .vip)
      let vipLevel = try container.decode(String.self, forKey: .vipLevel)
      let virology = try container.decode(String.self, forKey: .virology)
      let visitID = try container.decode(String.self, forKey: .visitID)
      
//    var scores: [ClinicalPatientScore]?
//    var panicLabResults: [ClinicalPatientPanicLabRadResult]?
//    var panicRadResults: [ClinicalPatientPanicLabRadResult]?

//    if let scoresContainer = try? container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .scores) {
//      if let score = try? scoresContainer.decode(ClinicalPatientScore.self, forKey: .scoresRow) {
//        scores = [score]
//      } else if let tempScores = try? scoresContainer.decode([ClinicalPatientScore].self, forKey: .scoresRow) {
//        scores = tempScores
//      }
//    }
//    if let panicLabResultsContainer = try? container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .panicLabResults) {
//      if let panicLabResult = try? panicLabResultsContainer.decode(ClinicalPatientPanicLabRadResult.self, forKey: .panicLabResultRow) {
//        panicLabResults = [panicLabResult]
//      } else if let tempPanicLabResults = try? panicLabResultsContainer.decode([ClinicalPatientPanicLabRadResult].self, forKey: .panicLabResultRow) {
//        panicLabResults = tempPanicLabResults
//      }
//    }
//    if let panicRadResultsContainer = try? container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .panicRadResults) {
//      if let panicRadResult = try? panicRadResultsContainer.decode(ClinicalPatientPanicLabRadResult.self, forKey: .panicRadResultRow) {
//        panicRadResults = [panicRadResult]
//      } else if let tempPanicRadResults = try? panicRadResultsContainer.decode([ClinicalPatientPanicLabRadResult].self, forKey: .panicRadResultRow) {
//        panicRadResults = tempPanicRadResults
//      }
//    }
     
      self.init(ageDec: ageDec, walkFlag: walkFlag, assistantDocID: assistantDocID, btnCategory: btnCategory, cashierFlag: cashierFlag, checkPatHasOPD: checkPatHasOPD, clinitLetter: clinitLetter, clinicNameAr: clinicNameAr, clinicNameEN: clinicNameEN, nameInEnglish: nameInEnglish, nameInArabic: nameInArabic, convReq: convReq, convConsultionID: convConsultionID, convRemark: convRemark, ctasScore: ctasScore, dischargeFlag: dischargeFlag, dsiplayMode: dsiplayMode, doneDoctorId: doneDoctorId, empNameAr: empNameAr, empNameEn: empNameEn, erFlag: erFlag, expectedDate: expectedDate, genderAGE: genderAGE, genderAgeNameAr: genderAgeNameAr, genderAgeNameEn: genderAgeNameEn, genderNameAr: genderNameAr, genderNameEn: genderNameEn, highLightFlag: highLightFlag, homeVisitFlag: homeVisitFlag, mappedClinicID: mappedClinicID, motherPatientID: motherPatientID, motherVisitID: motherVisitID, nationalityInEnglish: nationalityInEnglish, nationalityInArabic: nationalityInArabic, newBornIn: newBornIn, newBornOut: newBornOut, noSpecialConsution: noSpecialConsution, opCallArrivalDate: opCallArrivalDate, outNoofPats: outNoofPats, overBook: overBook, painAssessValue: painAssessValue, patFinanCount: patFinanCount, patID: patID, patMobile: patMobile, patClinicFlag: patClinicFlag, patNoteDesc: patNoteDesc, patStatusNameAr: patStatusNameAr, patStatusNameEn: patStatusNameEn, patImage: patImage, placeID: placeID, queueMappedID: queueMappedID, queueScreenCalled: queueScreenCalled, queSer: queSer, queSysSer: queSysSer, recallStatus: recallStatus, resDate: resDate, resType: resType, schedSerial: schedSerial, ser: ser, serColor: serColor, serviceNameAr: serviceNameAr, serviceNameEn: serviceNameEn, serviceTime: serviceTime, serVStatus: serVStatus, serVStatusNameEn: serVStatusNameEn, serVStatusNameAr: serVStatusNameAr, shiftID: shiftID, sigQueueID: sigQueueID, spec: spec, vip: vip, vipLevel: vipLevel, virology: virology, visitID: visitID,
                //scores: scores,panicLabResults: panicLabResults,panicRadResults: panicRadResults,
                countyFlag:nil)
    
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
