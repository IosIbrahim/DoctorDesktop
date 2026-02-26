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
  func getInpatientUnits(with params: [String: String], finished: @escaping InpatientUnitsBlock)
  func getInpatientPatients(with params: [String: String], finished: @escaping InpatientPatientsBlock)
  func getOutpatientClinics(with params: [String: String], finished: @escaping OutpatientClinicsBlock)
  func getOutpatientPatients(with params: [String: String], finished: @escaping OutpatientPatientsBlock)
    func changePatientStatus(with params: [String: String], finished: @escaping OutpatientPatientsBlock)

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
  func getSymptomCategories(with params: [String: String], finished: @escaping RegularSymptomCategoriesBlock)
  func getSymptoms(with params: [String: String], finished: @escaping SymptomsBlock)

  func loadFlagImage(with params: [String: String], finished: @escaping DataBlock)
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
    
    func changePatientStatus(with params: [String: String], finished: @escaping OutpatientPatientsBlock) {
      networkLayer.changePatientStatus(with: params) { data in
        let outpatientPatients = self.translationLayer.getOutpatientPatientsDTOsFromJson(data)
        finished(outpatientPatients)
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
}

extension ModelLayerImpl {
  func loadFlagImage(with params: [String: String], finished: @escaping DataBlock) {
    networkLayer.loadFlagImage(with: params) { data in
      finished(data)
    }
  }
}
