
//
//  OperationCatheterizationEndoscopyCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/5/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol OperationCatheterizationEndoscopyCellPresenter {
  var serviceName: String { get }
  var surgeon: String { get }
  var anthesia: String { get }
  var date: String { get }
}

class OperationCatheterizationEndoscopyCellPresenterImpl: OperationCatheterizationEndoscopyCellPresenter {
  let operationCatherEndoscopy: OperationCatherEndoscopy

  var serviceName: String { return operationCatherEndoscopy.englishName }
  var surgeon: String { return operationCatherEndoscopy.surgeonEnglishName }
  var anthesia: String { return operationCatherEndoscopy.anthesiaEnglishName ?? "" }
  var date: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyy"
    return dateFormatter.string(from: operationCatherEndoscopy.expectedDoneDate)
  }

  init(with operationCatherEndoscopy: OperationCatherEndoscopy) {
    self.operationCatherEndoscopy = operationCatherEndoscopy
  }
}
