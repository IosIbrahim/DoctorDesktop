//
//  UnitsPopupPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/14/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

protocol UnitsPopupPresenter {
  var title: String { get }
  var patientUnits: PatientUnits { get }
}

class UnitsPopupPresenterImpl: UnitsPopupPresenter {
  var patientUnits: PatientUnits
  var title: String

  init(withTitle title: String, patientUnits: PatientUnits) {
    self.title = title
    self.patientUnits = patientUnits
  }
}
