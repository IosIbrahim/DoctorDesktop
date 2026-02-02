//
//  RadTestCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/24/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol RadTestCellPresenter {
  var serviceName: String { get }
  var status: String { get }
  var result: String { get }
  var date: String { get }
}

class RadTestCellPresenterImpl: RadTestCellPresenter {
  let radTest: Rad

  var serviceName: String { return radTest.englishEndResult }
  var status: String { return radTest.englishStatus }
  var result: String { return radTest.englishEndResult }
  var date: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyy"
//    return dateFormatter.string(from: radTest.requestDate)
      return radTest.requestDate.components(separatedBy: .whitespaces).first ?? ""
  }

  init(with radTest: Rad) {
    self.radTest = radTest
  }
}
