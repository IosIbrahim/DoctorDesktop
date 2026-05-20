//
//  ModelLayer.swift
//  Doctor DeskTop
//
//  Created by Mohammed Sami on 12/9/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

typealias PatientCountsBlock = ((PatientCount) -> Void)

protocol ModelLayer {
    func login(with params: [String: String], finished: @escaping UserAndComponentsBlock)
    func getPatientsCount(with params: [String: String], finished: @escaping PatientCountsBlock)
    func getDoctorPermissions(with params: [String: String], finished: @escaping DoctorPermissionsBlock)
    func getInpatientUnits(with params: [String: String], finished: @escaping InpatientUnitsBlock)
    
    func getInpatientPatients(with params: [String: String], finished: @escaping InpatientPatientsBlock)
    func getOutpatientClinics(with params: [String: String], finished: @escaping OutpatientClinicsBlock)
    func getOutpatientPatients(with params: [String: String], finished: @escaping OutpatientPatientsBlock)
    func changePatientStatus(with params: [String: String], status: String, finished: @escaping (Bool, String?) -> Void)
    
    func getEmergencyPatients(with params: [String: String], finished: @escaping EmergencyPatientsBlock)
    func getOperationPatients(with params: [String: String], finished: @escaping ([OperationPatient]) -> Void)
    func getClinicalPatients(with params: [String: String], finished: @escaping ([ClinicalPatient]) -> Void)
    func getTemplate(with params:[String: String], finished: @escaping TemplateBlock)
    
    func validateServiceRow(with params:[String: String], finished: @escaping ServicesDetailsBlock)
    func getLabServices(with params:[String: String], finished: @escaping LabRadServicesBlock)
    func saveOrder(with params:[String: String], orderType: TemplateType, finished: @escaping MessageBlock)
    func getPatientHistory(with params:[String: String], finished: @escaping PatientHistoryBlock)
    
    func getPatientSummary(with params:[String: String], finished: @escaping PatientSummaryBlock)
    func getPacksURL(with params:[String: String], finished: @escaping URLBlock)
    func getTriageInfo(with params: [String: String], finished: @escaping TriageDataBlock)
    func loadUcaf(with params: [String: String], finished: @escaping (UCAFLoadData?, UCAFCTASServer?) -> Void)
    func loadSpecialHabits(with params: [String: String], finished: @escaping (SpecialHabitsData?) -> Void)
    func saveSpecialHabits(body: [String: Any], finished: @escaping (Bool, String?) -> Void)
    /// Saves the UCAF (vitals + special-needs) record.  Response: {"code":1,"message":"Save Success"}
    func saveUcaf(body: [String: Any], finished: @escaping (Bool, String?) -> Void)
    /// Loads the progress-notes screen (list + 4 lookup arrays).
    func loadDoctorNurseNotes(with params: [String: String], finished: @escaping (DoctorNurseNotesData) -> Void)
    /// Saves a new progress note (BUFFER_STATUS=1) OR soft-deletes one
    /// (BUFFER_STATUS=3) — the server distinguishes the two via the BUFFER_STATUS
    /// field inside DOCTOR_NURSE_REMARKS plus the PROCESS_ID/TRACER_PLACE_ID in
    /// DD_UC_PARMS. Response: `{"message":"Save Success"}`.
    /// Returns (success, serverMessage) via the completion.
    func saveDoctorNurseNotes(with params: [String: String], finished: @escaping (Bool, String?) -> Void)
    /// POSTs a reply to an existing progress note. Returns (success, message)
    /// — message is `"Save Success"` on the happy path.
    func saveDoctorNurseReply(with params: [String: String], finished: @escaping (Bool, String?) -> Void)

    func getSymptomCategories(with params: [String: String], finished: @escaping RegularSymptomCategoriesBlock)
    func getSymptoms(with params: [String: String], finished: @escaping SymptomsBlock)
    func loadFlagImage(with params: [String: String], finished: @escaping DataBlock)
    func getVisitsDetail(with params: [String: String], finished: @escaping VisitDetailBlock)
  }

class ModelLayerImpl: ModelLayer {
  var networkLayer: NetworkLayer
  var translationLayer: TranslationLayer
  
  init(networkLayer: NetworkLayer, translationLayer: TranslationLayer) {
    self.networkLayer = networkLayer
    self.translationLayer = translationLayer
  }
  
  func login(with params: [String: String], finished: @escaping UserAndComponentsBlock) {
    networkLayer.login(with: params) { data in
      let components = self.translationLayer.createComponentDTOsFromJsonData(data)
      let user = self.translationLayer.createUserDTOFromJsonData(data)
      
      finished(user, components)
    }
  }
  
  func getPatientsCount(with params: [String: String], finished: @escaping PatientCountsBlock) {
    networkLayer.getPatientsCount(with: params) { data in
      let patientCount = self.translationLayer.getCountsFromJson(data)
      finished(patientCount)
    }
  }
    
    func getDoctorPermissions(with params: [String: String], finished: @escaping DoctorPermissionsBlock) {
      networkLayer.getDoctorPermission(with: params) { data in
        let models = self.translationLayer.getDoctorPermissionsFromJson(data)
        finished(models)
      }
    }
  
  func getInpatientUnits(with params: [String: String], finished: @escaping InpatientUnitsBlock) {
    networkLayer.getInpatientUnits(with: params) { data in
      let inpatientUnits = self.translationLayer.getInpatientUnitDTOsFromJson(data)
      finished(inpatientUnits)
    }
  }
  
  func getInpatientPatients(with params: [String : String], finished: @escaping InpatientPatientsBlock) {
    networkLayer.getInpatientPatients(with: params) { data in
      let inpatientPatients = self.translationLayer.getInpatientPatientsDTOsFromJson(data)
      finished(inpatientPatients)
    }
  }
  
  func getOutpatientClinics(with params: [String: String], finished: @escaping OutpatientClinicsBlock) {
    networkLayer.getOutpatientClinics(with: params) { data in
      let outpatientClinics = self.translationLayer.getOutpatientClinicDTOsFromJson(data)
      finished(outpatientClinics)
    }
  }
  
  func getOutpatientPatients(with params: [String: String], finished: @escaping OutpatientPatientsBlock) {
    networkLayer.getOutpatientPatients(with: params) { data in
      let outpatientPatients = self.translationLayer.getOutpatientPatientsDTOsFromJson(data)
      finished(outpatientPatients)
    }
  }
    
    /// Reports `(success, errorMessage)`:
    ///   • success=true  → server accepted, caller should advance the local state
    ///   • success=false → either a network failure or the server returned a
    ///                     `{"Message":"..."}` error envelope; the message is
    ///                     surfaced so the caller can show it to the user
    ///
    /// IMPORTANT: do NOT route this through the OutpatientPatients translation
    /// layer — these endpoints don't return a CLINIC_PATIENTS_ROW payload, so
    /// the parser would silently swallow real errors as "empty array OK".
    func changePatientStatus(with params: [String: String],
                             status: String,
                             finished: @escaping (Bool, String?) -> Void) {
      networkLayer.changePatientStatus(with: params, status: status) { data in
        // `try?` wraps in Optional and so does `as?` — without the outer
        // parens we'd end up with `[String: Any]??` and `if let` would only
        // peel one layer.
        if let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
           let message = json["Message"] as? String {
          // Server's standard error envelope.
          finished(false, message)
          return
        }
        // No "Message" key → server accepted (200 OK with empty body or success payload).
        finished(true, nil)
      }
    }
  
    
  func getEmergencyPatients(with params: [String: String], finished: @escaping EmergencyPatientsBlock) {
    networkLayer.getEmergencyPatients(with: params) { data in
      let emergencyPatients = self.translationLayer.getEmergencyPatientsDTOsFromJson(data)
      finished(emergencyPatients)
    }
  }
    func getOperationPatients(with params: [String: String], finished: @escaping ([OperationPatient]) -> Void) {
        networkLayer.getOperationPatients(with: params) { data in
            let emergencyPatients = self.translationLayer.getOperationPatientDTOFromJsonData(data)
            finished(emergencyPatients)
        }
    }

  func getClinicalPatients(with params: [String: String], finished: @escaping ([ClinicalPatient]) -> Void) {
    networkLayer.getClinicalPatients(with: params) { data in
      let clinicalPatients = self.translationLayer.getClinicalPatientDTOFromJsonData(data)
      finished(clinicalPatients)
    }
  }
}

extension ModelLayerImpl {
  func getTemplate(with params:[String: String], finished: @escaping TemplateBlock) {
    networkLayer.getTemplate(with: params) { data in
      let template = self.translationLayer.getTemplateDTOFromJson(data)
      finished(template)
    }
  }
}

extension ModelLayerImpl {
  func validateServiceRow(with params:[String: String], finished: @escaping ServicesDetailsBlock) {
    networkLayer.validateServiceRow(with: params) { data in
      let servicesDetails = self.translationLayer.getServiceDetailsDTOsFromJson(data)
      finished(servicesDetails)
    }
  }
}

extension ModelLayerImpl {
  func getLabServices(with params:[String: String], finished: @escaping LabRadServicesBlock) {
    networkLayer.getLabServices(with: params) { data in
      let labServices = self.translationLayer.getLabServiceDTOFromJson(data)
      finished(labServices)
    }
  }
}

extension ModelLayerImpl {
  func getRadServices(with params:[String: String], finished: @escaping LabRadServicesBlock) {
    networkLayer.getRadServices(with: params) { data in
      let radServices = self.translationLayer.getRadServiceDTOFromJson(data)
      finished(radServices)
    }
  }
}

extension ModelLayerImpl {
  func saveOrder(with params:[String: String], orderType: TemplateType, finished: @escaping MessageBlock) {
    networkLayer.saveOrder(with: params, orderType: orderType) { data in
      let message = self.translationLayer.getMessageFromLabOrdeSaveResponse(data)
      finished(message)
    }
  }
}

extension ModelLayerImpl {
  func getPatientHistory(with params:[String: String], finished: @escaping PatientHistoryBlock) {
    networkLayer.getPatientHistory(with: params) { data in
      let patientHistory = self.translationLayer.getPatientHistoryDTOFromJson(data)
      finished(patientHistory)
    }
  }
}

extension ModelLayerImpl {
  func getPatientSummary(with params:[String: String], finished: @escaping PatientSummaryBlock) {
    networkLayer.getPatientSummary(with: params) { data in
      let patientSummary = self.translationLayer.getPatientSummaryDTOFromJson(data)
      finished(patientSummary)
    }
  }
}

extension ModelLayerImpl {
  func getPacksURL(with params:[String: String], finished: @escaping URLBlock) {
    networkLayer.getPacksURL(with: params) { data in
      let packsURL = self.translationLayer.getPacksURLFromJson(data)
      finished(packsURL)
    }
  }
}

extension ModelLayerImpl {
  func getTriageInfo(with params: [String: String], finished: @escaping TriageDataBlock) {
    networkLayer.getTriageInfo(with: params) { data in
      let ucafData = self.translationLayer.getVitalsDTOsFromJson(data)
      let diagnosisCategories = self.translationLayer.getDiagnosisCategoriesDTOsFromJson(data)
      let historySymptomCategories = self.translationLayer.getHistorySymptomsDTOsFromJson(data)
      let scores = self.translationLayer.getPainScoresDTOsFromJson(data)
      finished(ucafData, diagnosisCategories, historySymptomCategories, scores)
    }
  }

  func getSymptomCategories(with params: [String: String], finished: @escaping RegularSymptomCategoriesBlock) {
    networkLayer.getSymptoms(with: params) { data in
      let symptomCategories = self.translationLayer.getSymptomCategoriesDTOsFromJson(data)
      finished(symptomCategories)
    }
  }

  func getSymptoms(with params: [String: String], finished: @escaping SymptomsBlock) {
    networkLayer.getSymptoms(with: params) { data in
      let symptoms = self.translationLayer.getSymptomsDTOsFromJson(data)
      finished(symptoms)
    }
  }

  func loadUcaf(with params: [String: String], finished: @escaping (UCAFLoadData?, UCAFCTASServer?) -> Void) {
    networkLayer.loadUcaf(with: params) { data in
      let ucaf = self.translationLayer.getLoadUcafFromJson(data)
      let ctas = self.translationLayer.getLoadUcafCTASFromJson(data)
      finished(ucaf, ctas)
    }
  }

  func loadSpecialHabits(with params: [String: String], finished: @escaping (SpecialHabitsData?) -> Void) {
    networkLayer.loadSpecialHabits(with: params) { data in
      let habits = self.translationLayer.getSpecialHabitsFromJson(data)
      finished(habits)
    }
  }

  func saveSpecialHabits(body: [String: Any], finished: @escaping (Bool, String?) -> Void) {
    networkLayer.saveSpecialHabits(body: body) { data in
      // Response: {"code":1,"message":"Save Success"}
      // code 1 = success, anything else = failure.
      guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
        finished(false, nil); return
      }
      let code    = json["code"]    as? Int ?? 0
      let message = json["message"] as? String
      finished(code == 1, message)
    }
  }

  func saveUcaf(body: [String: Any], finished: @escaping (Bool, String?) -> Void) {
    networkLayer.saveUcaf(body: body) { data in
      guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
        finished(false, nil); return
      }
      let code    = json["code"]    as? Int ?? 0
      let message = json["message"] as? String
      finished(code == 1, message)
    }
  }

  func loadDoctorNurseNotes(with params: [String: String],
                            finished: @escaping (DoctorNurseNotesData) -> Void) {
    networkLayer.loadDoctorNurseNotes(with: params) { data in
      let result = self.translationLayer.getDoctorNurseNotesFromJson(data)
      finished(result)
    }
  }

  func saveDoctorNurseNotes(with params: [String: String],
                            finished: @escaping (Bool, String?) -> Void) {
    networkLayer.saveDoctorNurseNotes(with: params) { data in
      // Server returns `{"message":"Save Success"}` on success, other message on failure.
      guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
        finished(false, nil); return
      }
      let message = json["message"] as? String
      let success = (message ?? "").lowercased().contains("success")
      finished(success, message)
    }
  }

  func saveDoctorNurseReply(with params: [String: String],
                            finished: @escaping (Bool, String?) -> Void) {
    networkLayer.saveDoctorNurseReply(with: params) { data in
      // Same response shape as saveDoctorNurseNotes — `{"message":"Save Success"}`
      // on success, anything else on failure.
      guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
        finished(false, nil); return
      }
      let message = json["message"] as? String
      let success = (message ?? "").lowercased().contains("success")
      finished(success, message)
    }
  }

  // NOTE: There is no separate `deleteDoctorNurseNote` here on purpose. The
  // server uses a single endpoint for both create and soft-delete; the caller
  // sets `BUFFER_STATUS=3` (plus PROCESS_ID=4179, TRACER_PLACE_ID=298) inside
  // the params and routes through `saveDoctorNurseNotes` above.
}

extension ModelLayerImpl {
  func loadFlagImage(with params: [String: String], finished: @escaping DataBlock) {
    networkLayer.loadFlagImage(with: params) { data in
      finished(data)
    }
  }
}

extension ModelLayerImpl {
  func getVisitsDetail(with params: [String: String], finished: @escaping VisitDetailBlock) {
    networkLayer.getVisitsDetail(with: params) { data in
      let visitDetail = self.translationLayer.getVisitDetailDTOFromJson(data)
      finished(visitDetail)
    }
  }
}
