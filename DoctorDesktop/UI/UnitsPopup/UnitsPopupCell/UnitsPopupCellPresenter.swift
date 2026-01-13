//
//  UnitsPopupCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/14/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

protocol UnitsPopupCellPresenter {
  var unitTitle: String { get }
  var patientsCount: String { get }
}

class UnitsPopupCellPresenterImpl: UnitsPopupCellPresenter {
  let inpatientUnit: PatientUnit
  var unitTitle: String { return inpatientUnit.name }
  var patientsCount: String { return inpatientUnit.patientsCount }
  
  init(with inpatientUnit: PatientUnit) {
    self.inpatientUnit = inpatientUnit
  }
}
