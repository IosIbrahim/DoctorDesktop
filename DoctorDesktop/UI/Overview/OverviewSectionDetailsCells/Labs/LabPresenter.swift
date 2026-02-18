//
//  LabPresenter.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 17/02/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//
import UIKit

protocol LabsCellPresenter {
  var serviceName: String { get }
  var status: String { get }
  var date: String { get }
}

class LabsCellPresenterImpl: LabsCellPresenter {
  let clinicService: Lab

  var serviceName: String { return clinicService.serviceCategoryEnglishName }
  var status: String { return clinicService.statusEn }
//  var date: String {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "dd/MM/yyy"
//    return dateFormatter.string(from: clinicService.reqDate)
//  }
    var date: String {
      return  clinicService.reqDate
    }
  init(with clinicService: Lab) {
    self.clinicService = clinicService
  }
}
