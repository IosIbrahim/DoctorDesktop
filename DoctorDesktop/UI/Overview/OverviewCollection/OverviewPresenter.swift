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
  case vitalSigns = 0
  case progressNotes
  case medication
  case diagnosis
  //case allergies
  case labExamination
  case radTest
  case scoring
  case finding
  case complaints
  case history
  case operation
  case catheterization
  case endoscopy
  //case clinicServices
  case dietary

  var title: String {
    switch self {
    case .vitalSigns: return "Vital Signs"
    case .progressNotes: return "Progress Notes"
    case .medication: return "Medication"
    case .diagnosis: return "Diagnosis"
    //case .allergies: return "Allergies"
    case .labExamination: return "Lab Examination"
    case .radTest: return "Rad Test"
    case .scoring: return "Scoring"
    case .finding: return "Finding"
    case .complaints: return "Complaints"
    case .history: return "History"
    case .operation: return "Operation"
    case .catheterization: return "Catheterization"
    case .endoscopy: return "Endoscopy"
    //case .clinicServices: return "Clinic Services"
    case .dietary: return "Dietary"
    }
  }

  var imageName: String {
    switch self {
    case .vitalSigns: return "vital"
    case .progressNotes: return "notes"
    case .medication: return "medication"
    case .diagnosis: return "diagnosis"
    //case .allergies: ""
    case .labExamination: return "lab"
    case .radTest: return "rad"
    case .scoring: return "scoring"
    case .finding: return "examination"
    case .complaints: return "examination"
    case .history: return "history"
    case .operation: return "operation"
    case .catheterization: return "catheterization"
    case .endoscopy: return "endoscopy"
    //case .clinicServices: return ""
    case .dietary: return "diatery"
    }
  }

  var color: UIColor {
    switch self {
    case .vitalSigns: return #colorLiteral(red: 0.3411764706, green: 0.6588235294, blue: 0.8196078431, alpha: 1)
    case .progressNotes: return #colorLiteral(red: 0.3411764706, green: 0.6588235294, blue: 0.8196078431, alpha: 1)
    case .medication: return #colorLiteral(red: 0.4941176471, green: 0.4549019608, blue: 0.8352941176, alpha: 1)
    case .diagnosis: return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .labExamination: return #colorLiteral(red: 0.003921568627, green: 0.2901960784, blue: 0.4117647059, alpha: 1)
    case .radTest: return #colorLiteral(red: 0.8705882353, green: 0.231372549, blue: 0.2980392157, alpha: 1)
    case .scoring: return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .finding: return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .complaints: return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .history: return #colorLiteral(red: 0.003921568627, green: 0.2901960784, blue: 0.4117647059, alpha: 1)
    case .operation: return #colorLiteral(red: 0.3294117647, green: 0.7490196078, blue: 0.5137254902, alpha: 1)
    case .catheterization: return #colorLiteral(red: 0.3294117647, green: 0.7490196078, blue: 0.5137254902, alpha: 1)
    case .endoscopy: return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    case .dietary: return #colorLiteral(red: 0.5019607843, green: 0.7294117647, blue: 0.09411764706, alpha: 1)
    }
  }

  static var count: Int { return OverviewSection.dietary.rawValue + 1 }
}

protocol OverviewPresenter {
  var patientHistory: PatientHistory? { get }
  var patientSummary: PatientSummary? { get }
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

  func getPatientHistory(finished: @escaping EmptyBlock)
    func getArguments(_ overView:OverviewSection)
  func getPatientSummary(filtrationType: PatientHistoryFiltrationType, finished: @escaping EmptyBlock)
}

class OverviewPresenterImpl: OverviewPresenter {
  private var modelLayer: ModelLayer
  let patient: Patient
  let user: User
    var arguments:Dictionary<String, Any>
  var patientHistory: PatientHistory?
  var patientSummary: PatientSummary?

  init(modelLayer: ModelLayer, patient: Patient, user: User) {
    self.modelLayer = modelLayer
    self.patient = patient
    self.user = user
      self.arguments = .init()
  }

  var patientHistoryActiveIconImages = [#imageLiteral(resourceName: "visit_icon"), #imageLiteral(resourceName: "allvisit"), #imageLiteral(resourceName: "lab"), #imageLiteral(resourceName: "dr_icon")]
  var patientHistoryNotActiveIconImages = [#imageLiteral(resourceName: "visit_icon_no_activ"), #imageLiteral(resourceName: "allvisit_not_active"), #imageLiteral(resourceName: "lab_not_active"), #imageLiteral(resourceName: "dr_icon_not_active")]
  var patientHistoryActiveContentImages = [#imageLiteral(resourceName: "visit_content"), #imageLiteral(resourceName: "visit_content"), #imageLiteral(resourceName: "lab_content_actvie"), #imageLiteral(resourceName: "dr_content_active")]
  var patientHistoryNotActiveContentImage = #imageLiteral(resourceName: "visit_content_not_active")
  var patientHistoryTitles: [String] {
    return ["Current Visit", "All Visits",
     patientHistory?.currentSpeciality.name ?? "",
     patientHistory?.currentDoctor.name ?? ""]
  }


  var patientSummaryCounts: [Int] {
    var patientSummaryCounts = [Int]()
    patientSummaryCounts.append(patientSummary?.vitalSigns?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.nurseRemarks?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.medications?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.diagnosis?.count ?? 0)
  //  patientSummaryCounts.append(patientSummary?.allergies?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.labs?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.rads?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.scorings?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.findings?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.complaints?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.history?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.operations?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.catheters?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.endoscopies?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.clinicServices?.count ?? 0)
    patientSummaryCounts.append(patientSummary?.dietaries?.count ?? 0)
    return patientSummaryCounts
  }

  var currentVisitIds: [String] {
    var tempCurrentVisitIds = [String]()
    guard let visits = patientHistory?.patientVisits else { return [] }
    for visit in visits {
      if visit.id == patient.visitId {
        tempCurrentVisitIds.append(visit.id)
      }
    }
    return tempCurrentVisitIds
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
      "INDEX_FROM": "0",
      "INDEX_TO": "15",
      "USER_ID": user.id ?? "",
      "BRANCH_ID": user.branch ?? "",
      "PATIENT_ID": patient.id,
      "VISIT_ID": patient.visitId
    ]
    modelLayer.getPatientHistory(with: params) { patientHistory in
      self.patientHistory = patientHistory
      finished()
    }
  }
    func getArguments(_ overView: OverviewSection)  {
        arguments =  ["overviewSection": overView,
                "patientSummary": patientSummary ?? [],
                "patient":patient,
                "user": user]
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
    case .currentVisit: params["VISIT_ID_ARRAY"] = currentVisitIds.joined(separator: ",")
    case .currentSpeciality: params["VISIT_ID_ARRAY"] = currentSpecialityVisitsIds.joined(separator: ",")
    case .currentDoctor: params["VISIT_ID_ARRAY"] = currentDoctorVisitsIds.joined(separator: ",")
    default: break
    }
    modelLayer.getPatientSummary(with: params) { patientSummary in
      self.patientSummary = patientSummary
      finished()
    }
  }
}
