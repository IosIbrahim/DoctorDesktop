//
//  EmergencyTriagePresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/19/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

typealias TriageDataBlock = ((UCAFData?, DiagnosisCategories, HistorySymptomCategories, Scores) -> Void)
typealias RegularSymptomCategoriesBlock = ((RegularSymptomCategories) -> Void)
typealias SymptomsBlock = ((Symptoms) -> Void)
typealias Scores = [Score]
typealias DiagnosisCategories = [DiagnosisCategory]
typealias SymptomCategories = [SymptomCategory]
typealias RegularSymptomCategories = [RegularSymptomCategory]
typealias HistorySymptomCategories = [HistorySymptomCategory]
typealias Symptoms = [Symptom]
typealias PediatricsScoreElements = [PediatricsScoreElement]

protocol EmergencyTriagePresenter {
  var user: User { get }
  var patient: EmergencyPatient { get }
  var vitals: UCAFData? { get }
  var diagnosisCategories: DiagnosisCategories { get }
  var scores: Scores { get }
  var currentScore: Score? { get set }
  var historySymptomCategories: HistorySymptomCategories { get }
  var regularSymptomCategories: RegularSymptomCategories { get }
  var symptoms: Symptoms { get }
  var selectedSymptoms: [String] { get }
  var newlySelectedSymptoms: [String] { get set }
  var unselectedSymptoms: [String: String] { get set }
  var painLevel: Int { get set }
  var updatedVitals: [String: String] { get set }
  var selectedPediatricChoices: [PediatricsScoreChoice] { get set }
  var selectedDiagnosisCategory: DiagnosisCategory? { get set }
  var selectedSymptomCategory: SymptomCategory? { get set }
  func getTriageInfo(finished: @escaping EmptyBlock)
  func getSymptomCategories(finished: @escaping EmptyBlock)
  func getSymptoms(finished: @escaping EmptyBlock)
  func getHistorySymptoms(historySymptomCategory: HistorySymptomCategory, finished: @escaping SymptomsBlock)
  func saveTriageInfo(finished: @escaping EmptyBlock)
}

class EmergencyTriagePresenterImpl: EmergencyTriagePresenter {
  let user: User
  let patient: EmergencyPatient
  var modelLayer: ModelLayer
  var vitals: UCAFData?
  var diagnosisCategories: DiagnosisCategories = []
  var scores: Scores = []
  var currentScore: Score?
  var historySymptomCategories: HistorySymptomCategories = []
  var regularSymptomCategories: RegularSymptomCategories = []
  var symptoms: Symptoms = []
  var newlySelectedSymptoms: [String] = []
  var unselectedSymptoms: [String: String] = [:]
  var painLevel: Int = 0
  var updatedVitals: [String : String] = [:]
  var selectedPediatricChoices: [PediatricsScoreChoice] = []
  
  var formattedNewlySelectedSymptomsJSON: [Any] {
    return self.newlySelectedSymptoms.map { index in return ["COT_ID": index, "BUFFER_STATUS": "1"] }
  }
  
  var formattedUnselectedSymptomsJSON: [Any] {
    return self.unselectedSymptoms.map { entry in return ["COT_ID": entry.key, "SER": entry.value, "BUFFER_STATUS": "3"] }
  }
  
  var selectedSymptoms: [String] {
    return self.symptoms.filter { symptom in return symptom.transDate != nil }.map { symptom in return symptom.id }
  }
  
  var formattedSelectedPediatricsPainChoicesJSON: [Any] {
    let choices = self.selectedPediatricChoices.filter { entry in return entry.SER != nil || (entry.value != nil && entry.value! != "0") }
    return choices.map { entry in
      var dict: [String: String] = [:]
      dict["ITEM_ID"] = entry.id
      dict["ITEM_VALUE"] = entry.value!
      if let ser = entry.SER {
        dict["SER"] = ser
        dict["BUFFER_STATUS"] = entry.value! == "0" ? "3" : "2"
      } else { dict["BUFFER_STATUS"] = "1" }
      return dict
    }
  }
  
  var selectedDiagnosisCategory: DiagnosisCategory?
  var selectedSymptomCategory: SymptomCategory?
  
  init(modelLayer: ModelLayer, patient: EmergencyPatient, user: User) {
    self.user = user
    self.patient = patient
    self.modelLayer = modelLayer
  }
}

extension EmergencyTriagePresenterImpl {
  func getTriageInfo(finished: @escaping EmptyBlock) {
    let params = [
      "PATIENT_ID": patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
      "BRANCH_ID": user.branch ?? "",
      "VISIT_ID": patient.visitId,
      "VISIT_ID_ARRAY": "0",
      "INIT": "1"
    ]
    modelLayer.getTriageInfo(with: params) { ucafData, diagnosisCategories, historySymptomCategories, scores in
      if let ucafData: UCAFData = ucafData {
        self.vitals = ucafData
      }
      self.diagnosisCategories = diagnosisCategories
      self.historySymptomCategories = historySymptomCategories
      self.scores = scores
      finished()
    }
  }

  func getSymptomCategories(finished: @escaping EmptyBlock) {
    if let selectedDiagnosisCategory = self.selectedDiagnosisCategory {
      let params = [
        "PATIENT_ID": patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
        "VISIT_ID": patient.visitId,
        "SER": selectedDiagnosisCategory.id,
        "TYPE_FLAG": "2",
        ]
      modelLayer.getSymptomCategories(with: params) { regularSymptomCategories in
        self.regularSymptomCategories = regularSymptomCategories
        finished()
      }
    }
  }

  func getSymptoms(finished: @escaping EmptyBlock) {
    if let selectedSymptomCategory = self.selectedSymptomCategory {
      let params = [
        "PATIENT_ID": patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
        "VISIT_ID": patient.visitId,
        "SER": selectedSymptomCategory.id,
        "TYPE_FLAG": "3",
        ]
      modelLayer.getSymptoms(with: params) { symptoms in
        self.symptoms = symptoms
        finished()
      }
    }
  }
  
  func getHistorySymptoms(historySymptomCategory: HistorySymptomCategory, finished: @escaping SymptomsBlock) {
    let params = [
      "PATIENT_ID": patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
      "VISIT_ID": patient.visitId,
      "SER": historySymptomCategory.id,
      "TYPE_FLAG": "3",
      ]
    modelLayer.getSymptoms(with: params) { symptoms in
      finished(symptoms.filter { symptom in return symptom.ser != nil })
    }
  }
  
  func saveTriageInfo(finished: @escaping EmptyBlock) {
    self.updatedVitals["MODIFY_DATE_STR_FORMATED"] = "21/11/2017 15:50:00"
    self.updatedVitals["BUFFER_STATUS"] = "2"
    var updatedSymptoms: [Any] = []
    updatedSymptoms.append(contentsOf: self.formattedUnselectedSymptomsJSON)
    updatedSymptoms.append(contentsOf: self.formattedNewlySelectedSymptomsJSON)
    
    var params: [String: Any] = [
      "DD_UC_PARMS": [
        "SELECTED_DATE_STR_FORMATED": self.patient.visitStartDate,
        "VISIT_ID": self.patient.visitId,
        "PROCESS_ID": "56528",
        "VISIT_ID_ARRAY": self.patient.visitId,
        "PATIENT_ID": self.patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
        "TRACER_PLACE_ID": "21",
        "ITEM_VALUE": self.painLevel
      ],
      "SI":[
        "BranchID": "1",
        "ComputerName": "ESERAG",
        "UserID": "KHABEER",
        "Lang": "0"
      ],
      "_RCP_OUTPAT_DATAENTRY": [self.updatedVitals],
      "_RCP_PATIENT_COT": updatedSymptoms
    ]
    if self.formattedSelectedPediatricsPainChoicesJSON.count != 0 {
      params["_RCP_PATIENT_SCORE_DETIALS"] = self.formattedSelectedPediatricsPainChoicesJSON
    }
    
    print("\(getEncodedBodyParam(jsonObject: params))")
  }
}
