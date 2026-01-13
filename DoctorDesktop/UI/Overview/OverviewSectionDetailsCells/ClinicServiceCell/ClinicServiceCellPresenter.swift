//
//  ClinicServiceCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/16/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol ClinicServiceCellPresenter {
  var serviceName: String { get }
  var status: String { get }
  var date: String { get }
}

class ClinicServiceCellPresenterImpl: ClinicServiceCellPresenter {
  let clinicService: ClinicService

  var serviceName: String { return clinicService.englishName }
  var status: String { return clinicService.englishStatus }
  var date: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyy"
    return dateFormatter.string(from: clinicService.resultDate)
  }
  init(with clinicService: ClinicService) {
    self.clinicService = clinicService
  }
}
