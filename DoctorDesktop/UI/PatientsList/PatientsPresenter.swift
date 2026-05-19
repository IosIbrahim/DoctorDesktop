//
//  OutpatientPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/18/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

typealias PatientUnits = [PatientUnit]
typealias Precritions = [precrition]
typealias prescriptionDeatilsModels = [prescriptionDeatilsModel]
//typealias dosageModels = [dosageModel]
typealias InpatientUnitsBlock = ((PatientUnits) -> Void)

typealias InpatientPatients = [InpatientPatient]
typealias medictions = [Medication]
typealias InpatientPatientsBlock = ((InpatientPatients) -> Void)
typealias OutpatientClinic = PatientUnit

typealias DoctorPermissions = [PermissionModel]
typealias DoctorPermissionsBlock = ((DoctorPermissions) -> Void)

typealias OutpatientClinics = [OutpatientClinic]
typealias OutpatientClinicsBlock = ((OutpatientClinics) -> Void)
typealias OutpatientPatients = [OutpatientPatient]

typealias OutpatientPatientsBlock = ((OutpatientPatients) -> Void)
typealias ClinicalPatients = [ClinicalPatient]
typealias EmergencyPatients = [EmergencyPatient]
typealias EmergencyPatientsBlock = ((EmergencyPatients) -> Void)
typealias ImageBlock = ((UIImage) -> Void)

func getGenderAgeImage(genderAgeType: GenderAgeType) -> UIImage {
  let image: UIImage!
  switch genderAgeType {
  case .childMale: image = #imageLiteral(resourceName: "male_child")
  case .childFemale: image = #imageLiteral(resourceName: "female_child")
  case .male,.oldMale: image = #imageLiteral(resourceName: "male_customer")
  case .female,.oldFemale: image = #imageLiteral(resourceName: "female_customer")
  case .pregnant: image = #imageLiteral(resourceName: "pregnant")
  }
  return image
}

protocol PatientsPresenter {
  var user: User { get }
  var componentType: ComponentType { get }
  var permission:PermissionModel { get }
  var patientUnits: PatientUnits { get }
  var title: String { get }
  
  var inpatientPatients: InpatientPatients { get }
  var outpatientPatients: OutpatientPatients { get }
  var triagedEmergencyPatients: EmergencyPatients { get }
  var notTriagedEmergencyPatients: EmergencyPatients { get }
    var clinicalPatients : ClinicalPatients { get }
    var operationPatients : [OperationPatient] { get }

  func clearData()
  func getInpatientUnits(isICU: Int, finished: @escaping EmptyBlock)
  func getInpatientPatients(withSelectedUnitIndex index: Int, isICU: Int, finished: @escaping EmptyBlock)
  func getOutpatientClinics(withDate: Date, finished: @escaping EmptyBlock)
  func getOutpatientPatients(withDate: Date, selectedClinicIndex: Int, finished: @escaping EmptyBlock)
  func getEmergencyPatients(withDate: Date, finished: @escaping EmptyBlock)
  func getOperationPatients(withDate: Date, finished: @escaping EmptyBlock)
  /// Reports `(success, errorMessage)` so the caller only refreshes the UI
  /// when the server confirms — and can show the message on failure.
  func changePatientStatus(index: Int, finished: @escaping (Bool, String?) -> Void)

  func getClinicalPatients(date: Date, finished: @escaping EmptyBlock)
  func loadFlagImage(flageImageName: String, finished: @escaping ImageBlock)
}

class PatientsPresenterImpl: PatientsPresenter {
  private var modelLayer: ModelLayer
  
  let user: User
  let componentType: ComponentType
    var permission:PermissionModel
  var patientUnits = PatientUnits()
  var outpatientPatients = OutpatientPatients()
  var inpatientPatients = InpatientPatients()
  var triagedEmergencyPatients = EmergencyPatients()
  var notTriagedEmergencyPatients = EmergencyPatients()
  var clinicalPatients = ClinicalPatients()
  var operationPatients = [OperationPatient]()
  let formatter = DateFormatter()

   
    
    init(modelLayer: ModelLayer, componentType: ComponentType, user: User,permission:PermissionModel) {
        self.modelLayer = modelLayer
        self.componentType = componentType
        self.user = user
        self.permission = permission
        // CRITICAL: pin to en_US_POSIX so the formatter emits a regular space
        // (U+0020) between time and AM/PM, Western digits, and a Gregorian
        // calendar regardless of the user's iOS region / locale / 12-vs-24h
        // preference. iOS 15.4+ silently inserts U+202F (narrow no-break
        // space) on the default locale, which the .NET backend rejects with
        // `{"message":"String was not recognized as a valid DateTime."}`.
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
  }

  var title: String {
    switch componentType {
    case .nicu: return "NICU"
    case .ICU: return "ICU"
    case .inpatient:return "Inpatients"
    case .outpatient: return "Outpatients"
    case .emergency:return "Emergency"
    case .consultation: return "Consultations"
//    case .clinicalAlert:
//      return "Clinical Alerts"
//    case .operations:
//        return "Operations"
 //   default: return ""
    case .operations:
        return "Operations"
    }
  }
  
}

extension PatientsPresenterImpl {
  func getInpatientUnits(isICU: Int, finished: @escaping EmptyBlock) {
    let params = [
        "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "UNIT_ICU_FLAG": "\(isICU)",
      "COMPUTER_NAME": "iOS",
      "USER_OPEN_FLAG": "D"
    ]
    
    modelLayer.getInpatientUnits(with: params) { inpatientUnits in
      self.patientUnits = inpatientUnits
      finished()
    }
  }
  
  func getInpatientPatients(withSelectedUnitIndex index: Int, isICU: Int, finished: @escaping EmptyBlock) {
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "SER": patientUnits[index].id,
      "UNIT_ICU_FLAG": "\(isICU)",
      "COMPUTER_NAME": "iOS",
      "USER_OPEN_FLAG": "D"
    ]
    
    modelLayer.getInpatientPatients(with: params) { inpatientPatients in
      self.inpatientPatients = inpatientPatients
      finished()
    }
  }
}

extension PatientsPresenterImpl {
  func getOutpatientClinics(withDate date: Date, finished: @escaping EmptyBlock) {
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "COMPUTER_NAME": "iOS",
      "USER_OPEN_FLAG": "D",
      "SER_ARRAY": "13040", // fixed for now "Eng Taha"
      "DATE_FROM_STR_FORMATED": formatter.string(from: date)
    ]
    
    modelLayer.getOutpatientClinics(with: params) { outpatientClinics in
      // Only keep clinics that have at least one patient waiting
      self.patientUnits = outpatientClinics.filter { $0.patientsCount != "0" }
      finished()
    }
  }
  
  func getOutpatientPatients(withDate date: Date, selectedClinicIndex index: Int, finished: @escaping EmptyBlock) {
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "CLINIC_ID": patientUnits[index].id,
      "COMPUTER_NAME": "iOS",
      "USER_OPEN_FLAG": "D",
      "SHIFT_ID": patientUnits[index].shiftFlag ?? "",
      "DATE_FROM_STR_FORMATED": formatter.string(from: date)
    ]
    
    modelLayer.getOutpatientPatients(with: params) { outpatientPatients in
      self.outpatientPatients = outpatientPatients
      finished()
    }
  }
}

extension PatientsPresenterImpl {
  func getEmergencyPatients(withDate date: Date, finished: @escaping EmptyBlock) {
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "COMPUTER_NAME": "iOS",
      "USER_OPEN_FLAG": "D",
      "DATE_FROM_STR_FORMATED": formatter.string(from: date)
    ]
    
    modelLayer.getEmergencyPatients(with: params) { emergencyPatients in
      let emergencyPatients: EmergencyPatients = emergencyPatients
      self.triagedEmergencyPatients = emergencyPatients.filter({patient in return patient.triaged != "0"})
      self.notTriagedEmergencyPatients = emergencyPatients.filter({patient in return patient.triaged == "0"})
      finished()
    }
  }
}

extension PatientsPresenterImpl {
  func getClinicalPatients(date: Date, finished: @escaping EmptyBlock) {
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "UNIT_ICU_FLAG": "0",
      "USER_OPEN_FLAG": "D",
      "DATE_FROM_STR_FORMATED": formatter.string(from: date)
    ]

    modelLayer.getClinicalPatients(with: params) { clinicalPatients in
      self.clinicalPatients = clinicalPatients
      finished()
    }
  }
    func getOperationPatients(withDate date: Date, finished: @escaping EmptyBlock) {
        let params = [
            "BRANCH_ID":             user.branch ?? "",
            "USER_ID":               user.userName ?? "",
            "COMPUTER_NAME":         "iOS",
            "USER_OPEN_FLAG":        "D",
            // REQ_DOC_ID filters the OR schedule to operations where the
            // logged-in doctor is the surgeon. Matches Android's behaviour
            // and the URL your friend tested with (REQ_DOC_ID=43 = the
            // user's EMPID).
            "REQ_DOC_ID":            user.id ?? "",
            "DATE_FROM_STR_FORMATED": formatter.string(from: date)
        ]
        
        modelLayer.getOperationPatients(with: params) { emergencyPatients in
            self.operationPatients = emergencyPatients
            
            finished()
        }
    }
    
    func changePatientStatus(index: Int, finished: @escaping (Bool, String?) -> Void) {
        let model = outpatientPatients[index]
        // Only B (Arrival) → A (Check In) → S (Check Out) drive a server call.
        // D (Done) is terminal; anything else (CALL, C, "") has no endpoint.
        guard let status = model.serVStatus,
              ["B", "A", "S"].contains(status) else {
            finished(false, nil)
            return
        }

        // Param shape mirrors the Android adapter (`lan` lowercase, SER is
        // the row's visit/reservation serial — NOT the status code).
        let params: [String: String] = [
            "BRANCH_ID": user.branch ?? "",
            "USER_ID":   user.userName ?? "",
            "SER":       model.ser ?? "",
            "lan":       "0",
        ]

        modelLayer.changePatientStatus(with: params, status: status) { success, errorMessage in
            // CRITICAL: only advance the local state when the server confirms.
            // If we advanced optimistically on every callback, a 4xx/5xx (e.g.
            // 405 Method Not Allowed, 401 Unauthorized) would still flip the
            // button to the next stage and the doctor would think the action
            // succeeded.
            guard success else {
                finished(false, errorMessage)
                return
            }
            switch status {
            case "B": self.outpatientPatients[index].serVStatus = "A"
            case "A": self.outpatientPatients[index].serVStatus = "S"
            case "S": self.outpatientPatients[index].serVStatus = "D"
            default: break
            }
            finished(true, nil)
        }
    }
}

extension PatientsPresenterImpl {
  func loadFlagImage(flageImageName: String, finished: @escaping ImageBlock) {
    let params = ["flagImageName": flageImageName]

    modelLayer.loadFlagImage(with: params) { imageData in
      if let flagImage = UIImage(data: imageData) {
        finished(flagImage)
      }
    }
  }
}


extension PatientsPresenterImpl {
  func clearData() {
    patientUnits.removeAll()
    inpatientPatients.removeAll()
    outpatientPatients.removeAll()
    triagedEmergencyPatients.removeAll()
    notTriagedEmergencyPatients.removeAll()
    clinicalPatients.removeAll()
    operationPatients.removeAll()
  }
}
