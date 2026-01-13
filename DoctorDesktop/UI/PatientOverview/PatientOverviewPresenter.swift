//
//  PatientOverviewPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/12/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol PatientOverviewPresenter {
  var user: User { get }
  var patient: Patient { get }
}

class PatientOverviewPresenterImpl: PatientOverviewPresenter {
  let user: User
  let patient: Patient

  init(patient: Patient, user: User) {
    self.user = user
    self.patient = patient
  }
}
