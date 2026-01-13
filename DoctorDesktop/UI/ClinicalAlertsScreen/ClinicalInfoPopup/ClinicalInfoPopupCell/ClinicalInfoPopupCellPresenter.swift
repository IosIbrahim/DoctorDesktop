//
//  ClinicalInfoPopupCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol ClinicalInfoPopupCellPresenter {
  var title: String { get }
  var details: String { get }
}

class ClinicalInfoPopupCellPresenterImpl: ClinicalInfoPopupCellPresenter {
  var clinicalPatientInfo: ClinicalPatientInfo

  var title: String { return clinicalPatientInfo.title }
  var details: String { return clinicalPatientInfo.details }

  init(with clinicalPatientInfo: ClinicalPatientInfo) {
    self.clinicalPatientInfo = clinicalPatientInfo
  }
}
