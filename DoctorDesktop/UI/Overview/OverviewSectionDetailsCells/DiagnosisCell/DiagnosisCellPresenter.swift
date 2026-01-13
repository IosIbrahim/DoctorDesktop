//
//  DiagnosisCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/23/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol DiagnosisCellPresenter {
  var code: String { get }
  var description: String { get }
  var date: String { get }
  var status: String { get }
}

class DiagnosisCellPresenterImpl: DiagnosisCellPresenter {
  let diagnosis: Diagnosis

  var code: String { return diagnosis.code }
  var description: String { return diagnosis.itemDescription }
  var date: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyy"
    return dateFormatter.string(from: diagnosis.transactionDate)
  }
  var status: String {
    if diagnosis.status == "1"      { return "Initial" }
    else if diagnosis.status == "2" { return "Final" }
    else                            { return "" }
  }

  init(with diagnosis: Diagnosis) {
    self.diagnosis = diagnosis
  }
}

