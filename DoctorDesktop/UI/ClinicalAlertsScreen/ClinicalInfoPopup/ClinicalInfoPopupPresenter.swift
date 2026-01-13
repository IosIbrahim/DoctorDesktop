//
//  ClinicalInfoPopupPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol ClinicalInfoPopupPresenter {
  var patientName: String { get }
  var scores: [ClinicalPatientScore]? { get }
  var panicLabResults: [ClinicalPatientPanicLabRadResult]? { get }
  var panicRadResults: [ClinicalPatientPanicLabRadResult]? { get }
}

class ClinicalInfoPopupPresenterImpl: ClinicalInfoPopupPresenter {
  var clinicalPatient: ClinicalPatient
  var patientName: String { return clinicalPatient.name }
  var scores: [ClinicalPatientScore]? { return clinicalPatient.scores }
  var panicLabResults: [ClinicalPatientPanicLabRadResult]? { return clinicalPatient.panicLabResults }
  var panicRadResults: [ClinicalPatientPanicLabRadResult]? { return clinicalPatient.panicRadResults }

  init(clinicalPatient: ClinicalPatient) {
    self.clinicalPatient = clinicalPatient
  }
}
