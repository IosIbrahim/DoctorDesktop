//
//  OverviewPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/14/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

typealias PatientHistoryBlock = (PatientHistory) -> Void
typealias PatientSummaryBlock = (PatientSummary) -> Void

enum OverviewSection: Int {
  case vitalSigns = 0   //  0
  case progressNotes    //  1
  case medication       //  2
  case diagnosis        //  3
  case labExamination   //  4
  case radTest          //  5
  case pathology        //  6  ← matches Android grid position
  case scoring          //  7
  case finding          //  8
  case complaints       //  9
  case history          // 10
  case operationRequest // 11  ← matches Android grid position
  case operation        // 12
  case catheterization  // 13
  case endoscopy        // 14
  case dietary          // 15
  case bloodBank        // 16
  case medicalReport    // 17

  var title: String {
    switch self {
    case .vitalSigns:       return "Vital Signs"
    case .progressNotes:    return "Progress Notes"
    case .medication:       return "Medication"
    case .diagnosis:        return "Diagnosis"
    case .labExamination:   return "Lab Examination"
    case .radTest:          return "Rad Test"
    case .pathology:        return "Pathology"
    case .scoring:          return "Scoring"
    case .finding:          return "Finding"
    case .complaints:       return "Complaints"
    case .history:          return "History"
    case .operationRequest: return "Operation Request"
    case .operation:        return "Operation"
    case .catheterization:  return "Catheterization"
    case .endoscopy:        return "Endoscopy"
    case .dietary:          return "Dietary"
    case .bloodBank:        return "Blood Bank"
    case .medicalReport:    return "Medical Report"
    }
  }

  var imageName: String {
    switch self {
    case .vitalSigns:       return "vital"
    case .progressNotes:    return "notes"
    case .medication:       return "medication"
    case .diagnosis:        return "diagnosis"
    case .labExamination:   return "lab"
    case .radTest:          return "rad"
    case .pathology:        return "hematology"
    case .scoring:          return "scoring"
    case .finding:          return "examination"
    case .complaints:       return "examination"
    case .history:          return "history"
    case .operationRequest: return "operations"
    case .operation:        return "operation"
    case .catheterization:  return "catheterization"
    case .endoscopy:        return "endoscopy"
    case .dietary:          return "diatery"
    case .bloodBank:        return "blood"
    case .medicalReport:    return "ic-progress"
    }
  }

  var color: UIColor {
    switch self {
    case .vitalSigns:       return #colorLiteral(red: 0.3411764706, green: 0.6588235294, blue: 0.8196078431, alpha: 1)
    case .progressNotes:    return #colorLiteral(red: 0.3411764706, green: 0.6588235294, blue: 0.8196078431, alpha: 1)
    case .medication:       return #colorLiteral(red: 0.4941176471, green: 0.4549019608, blue: 0.8352941176, alpha: 1)
    case .diagnosis:        return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .labExamination:   return #colorLiteral(red: 0.003921568627, green: 0.2901960784, blue: 0.4117647059, alpha: 1)
    case .radTest:          return #colorLiteral(red: 0.8705882353, green: 0.231372549, blue: 0.2980392157, alpha: 1)
    case .pathology:        return #colorLiteral(red: 0.5568627451, green: 0.2666666667, blue: 0.6784313725, alpha: 1)
    case .scoring:          return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .finding:          return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .complaints:       return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .history:          return #colorLiteral(red: 0.003921568627, green: 0.2901960784, blue: 0.4117647059, alpha: 1)
    case .operationRequest: return #colorLiteral(red: 0.7411764706, green: 0.2235294118, blue: 0.2235294118, alpha: 1)
    case .operation:        return #colorLiteral(red: 0.3294117647, green: 0.7490196078, blue: 0.5137254902, alpha: 1)
    case .catheterization:  return #colorLiteral(red: 0.3294117647, green: 0.7490196078, blue: 0.5137254902, alpha: 1)
    case .endoscopy:        return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .dietary:          return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .bloodBank:        return #colorLiteral(red: 0.8, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
    case .medicalReport:    return #colorLiteral(red: 0.1764705882, green: 0.4980392157, blue: 0.7568627451, alpha: 1)
    }
  }

  static var count: Int { return OverviewSection.medicalReport.rawValue + 1 }
}

protocol OverviewPresenter {
  var patient: Patient { get }
  var patientHistory: PatientHistory? { get }
  var patientSummary: PatientSummary? { get }
  var visitDetail: VisitDetail? { get }
  var patientSummaryCounts: [Int] { get }
  var currentVisitIds: [String] { get }
  var currentDoctorVisitsIds: [String] { get }
  var currentSpecialityVisitsIds: [String] { get }
    var arguments: Dictionary<String, Any> { get }

  var patientHistoryActiveIconImages: [UIImage] { get }
  var patientHistoryNotActiveIconImages: [UIImage] { get }
  var patientHistoryActiveContentImages: [UIImage] { get }
  var patientHistoryNotActiveContentImage: UIImage { get }
  var patientHistoryTitles: [String] { get }

    var user: User { get }
    var permisions: PermissionModel { get }
   func getPatientHistory(finished: @escaping EmptyBlock)
   func getPermissions(finished: @escaping EmptyBlock)
   func getVisitsDetail(finished: @escaping EmptyBlock)

    func getArguments(_ overView:OverviewSection)
    func getPatientSummary(filtrationType: PatientHistoryFiltrationType, finished: @escaping EmptyBlock)
}

class OverviewPresenterImpl: OverviewPresenter {
    private var modelLayer: ModelLayer
    let patient: Patient
    let user: User
    let permisions:PermissionModel
    var arguments:Dictionary<String, Any>
    var patientHistory: PatientHistory?
    var patientSummary: PatientSummary?
    var visitDetail: VisitDetail?
    var permisionsDataSource = DoctorPermissions()
    private var count: Int = 0

    init(modelLayer: ModelLayer, patient: Patient, user: User,permision:PermissionModel) {
        self.modelLayer = modelLayer
        self.patient = patient
        self.permisions = permision
        self.user = user
        self.arguments = .init()
  }

  var patientHistoryActiveIconImages = [#imageLiteral(resourceName: "visit_icon"), #imageLiteral(resourceName: "allvisit"), #imageLiteral(resourceName: "lab"), #imageLiteral(resourceName: "dr_icon")]
  var patientHistoryNotActiveIconImages = [#imageLiteral(resourceName: "visit_icon_no_activ"), #imageLiteral(resourceName: "allvisit_not_active"), #imageLiteral(resourceName: "lab_not_active"), #imageLiteral(resourceName: "dr_icon_not_active")]
  var patientHistoryActiveContentImages = [#imageLiteral(resourceName: "visit_content"), #imageLiteral(resourceName: "visit_content"), #imageLiteral(resourceName: "lab_content_actvie"), #imageLiteral(resourceName: "dr_content_active")]
  var patientHistoryNotActiveContentImage = #imageLiteral(resourceName: "visit_content_not_active")
  var patientHistoryTitles: [String] {
    let speciality = patientHistory?.currentSpeciality.name ?? "Speciality"
    let doctor     = patientHistory?.currentDoctor.name ?? "Doctor"
    return ["Current Visit", "All Visits", speciality, doctor]
  }


  // IMPORTANT: order must match OverviewSection raw values exactly (0…17).
  var patientSummaryCounts: [Int] {
    return [
      patientSummary?.vitalSigns?.filter { !($0.details?.isEmpty ?? true) }.count ?? 0,  //  0  vitalSigns
      patientSummary?.nurseRemarks?.count      ?? 0,  //  1  progressNotes
      patientSummary?.medications?.count       ?? 0,  //  2  medication
      patientSummary?.diagnosis?.count         ?? 0,  //  3  diagnosis
      patientSummary?.labs?.count              ?? 0,  //  4  labExamination
      patientSummary?.rads?.count              ?? 0,  //  5  radTest
      patientSummary?.pathologies?.count       ?? 0,  //  6  pathology        ← Android pos 6
      patientSummary?.scorings?.count          ?? 0,  //  7  scoring
      patientSummary?.findings?.count          ?? 0,  //  8  finding
      patientSummary?.complaints?.count        ?? 0,  //  9  complaints
      patientSummary?.history?.count           ?? 0,  // 10  history
      patientSummary?.operationRequests?.count ?? 0,  // 11  operationRequest  ← Android pos 11
      patientSummary?.operations?.count        ?? 0,  // 12  operation
      patientSummary?.catheters?.count         ?? 0,  // 13  catheterization
      patientSummary?.endoscopies?.count       ?? 0,  // 14  endoscopy
      patientSummary?.dietaries?.count         ?? 0,  // 15  dietary
      patientSummary?.bloodBankItems?.count    ?? 0,  // 16  bloodBank
      patientSummary?.medicalReports?.count    ?? 0,  // 17  medicalReport
    ]
  }

  var currentVisitIds: [String] {
    // Android sends ALL visit IDs in VISIT_ID_ARRAY for the "Current Visit" tab
    // (including linked visits from the same admission, e.g. ER → Inpatient).
    // We do the same so Finding / Complaints counts match Android.
    guard let visits = patientHistory?.patientVisits else { return [] }
    return visits.map { $0.id }
  }

  var currentDoctorVisitsIds: [String] {
    var tempCurrentDoctorVisitsIds = [String]()
    guard let visits = patientHistory?.patientVisits,
      let currentDoctorId = patientHistory?.currentDoctor.id else { return [] }
    for visit in visits {
      if visit.doctorId == currentDoctorId {
        tempCurrentDoctorVisitsIds.append(visit.id)
      }
    }
    return tempCurrentDoctorVisitsIds
  }

  var currentSpecialityVisitsIds: [String] {
    var tempCurrentSpecialityVisitsIds = [String]()
    guard let visits = patientHistory?.patientVisits,
      let currentSpecialityId = patientHistory?.currentSpeciality.id else { return [] }
    for visit in visits {
      if visit.specialityId == currentSpecialityId {
        tempCurrentSpecialityVisitsIds.append(visit.id)
      }
    }
    return tempCurrentSpecialityVisitsIds
  }

  func getPatientHistory(finished: @escaping EmptyBlock) {
    let params = [
      "COMPUTER_NAME": "iOS",
      "INDEX_FROM":    "0",
      "INDEX_TO":      "15",
      "Lang":          "2",       // matches Android — 2 = English
      "USER_ID":       user.userName ?? user.id ?? "",
      "BRANCH_ID":     user.branch   ?? "",
      "PATIENT_ID":    patient.id,
      "VISIT_ID":      patient.visitId
    ]
    modelLayer.getPatientHistory(with: params) { patientHistory in
      if let err = patientHistory.error {
        print(err)
        self.count += 1
        if self.count <= 3 {
          // Retry — the retry chain will call finished() exactly once.
          self.getPatientHistory(finished: finished)
          return
        }
      } else {
        self.patientHistory = patientHistory
        // getPermissions will call finished() on main thread when done.
        self.getPermissions(finished: finished)
        return
      }
      // Reached only when retries are exhausted — fire finished on main thread.
      DispatchQueue.main.async { finished() }
    }
  }

  func getPermissions(finished: @escaping EmptyBlock) {
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "PROCESS_ID": "\(permisions.id ?? 0)",
      "OBJECT_ID": "\(permisions.objectId ?? 0)",
      "PROCESS_INFO_CODE": "\(permisions.processInfoCode ?? 0)",
      "CAT_ID": "",
      "DEFAULTGROUP": "DR"
    ]
    modelLayer.getDoctorPermissions(with: params) { permisions in
      self.permisionsDataSource = permisions
      self.checKPermisions(finished: finished)
      // Always dispatch UI callback to main thread.
      DispatchQueue.main.async { finished() }
    }
  }
    
    private func checKPermisions(finished: @escaping EmptyBlock) {

    }

  func getVisitsDetail(finished: @escaping EmptyBlock) {
    let params: [String: String] = [
      "COMPUTER_NAME": "iOS",
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "PATIENT_ID": patient.id,
      "VISIT_ID": patient.visitId
    ]
    modelLayer.getVisitsDetail(with: params) { detail in
      self.visitDetail = detail
      print("🩸 VisitDetail received:")
      print("   bloodTypeEn      = \(detail?.bloodTypeEn ?? "nil")")
      print("   bloodTypeAr      = \(detail?.bloodTypeAr ?? "nil")")
      print("   patientTel       = \(detail?.patientTel ?? "nil")")
      print("   contractNameEn   = \(detail?.contractNameEn ?? "nil")")
      print("   allergyStatusEn  = \(detail?.allergyStatusEn ?? "nil")")
      print("   genderAgeNameEn  = \(detail?.genderAgeNameEn ?? "nil")")
      DispatchQueue.main.async { finished() }
    }
  }
    
    func getArguments(_ overView: OverviewSection)  {
        arguments =  ["overviewSection": overView,
                      "patientSummary": patientSummary ?? [],
                      "patient":patient,
                      "permission":permisions,
                      "user": user,
                      "visitIdArray": currentVisitIds.joined(separator: ",")]
    }
    
  func getPatientSummary(filtrationType: PatientHistoryFiltrationType, finished: @escaping EmptyBlock) {
    var params = [
      "COMPUTER_NAME": "iOS",
      "TRACER_PLACE_ID": "0",
      "PROCESS_ID": "20531",
      "USER_ID": user.id ?? "",
      "BRANCH_ID": user.branch ?? "",
      "PATIENT_ID": patient.id,
      "VISIT_ID": patient.visitId,
    ]
    switch filtrationType {
    case .currentVisit:     params["VISIT_ID_ARRAY"] = currentVisitIds.joined(separator: ",")
    case .currentSpeciality: params["VISIT_ID_ARRAY"] = currentSpecialityVisitsIds.joined(separator: ",")
    case .currentDoctor:    params["VISIT_ID_ARRAY"] = currentDoctorVisitsIds.joined(separator: ",")
    default: break
    }
    modelLayer.getPatientSummary(with: params) { patientSummary in
      self.patientSummary = patientSummary
      if let err = patientSummary.message {
        print(err)
        self.count += 1
        if self.count <= 3 {
          // Retry — don't call finished() yet; the retry will when it succeeds.
          self.getPatientSummary(filtrationType: filtrationType, finished: finished)
          return
        }
      } else {
        if self.permisionsDataSource.isEmpty {
          // Permissions fetch will call finished() on main thread when done.
          self.getPermissions(finished: finished)
          return
        }
      }
      // Reached when: success (permissions already loaded) OR retries exhausted.
      DispatchQueue.main.async { finished() }
    }
  }
}
