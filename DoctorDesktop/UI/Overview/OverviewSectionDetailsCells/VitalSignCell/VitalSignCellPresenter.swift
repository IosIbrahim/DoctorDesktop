//
//  VitalSignCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/14/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol VitalSignCellPresenter {
  var vitalSignTitle: String { get }
  var currentResult: String { get }
  var firstPreviousResult: String { get }
  var secondPreviousResult: String { get }
}

class VitalSignCellPresenterImpl: VitalSignCellPresenter {
  let vitalSign: VitalSign
  var vitalSignTitle: String { return vitalSign.englishName }
  var currentResult: String {
    guard let currentResultTitle = vitalSign.details?.first?.itemValue,
      let currentResultSince = getNumberOfDaysUntilTodayStartingFromDate(vitalSign.details?.first?.itemDateTime) else { return "" }
    return "\(currentResultTitle)\nSince \(currentResultSince) Days"
  }
  var firstPreviousResult: String {
    guard let firstPreviousResultTitle = vitalSign.details?[safe:1]?.itemValue,
      let firstPreviousResultSince = getNumberOfDaysUntilTodayStartingFromDate(vitalSign.details?[safe:1]?.itemDateTime) else { return ""}
    return "\(firstPreviousResultTitle)\nSince \(firstPreviousResultSince) Days"
  }
  var secondPreviousResult: String {
    guard let secondPreviousResultTitle = vitalSign.details?[safe:2]?.itemValue,
      let secondPreviousResultSince = getNumberOfDaysUntilTodayStartingFromDate(vitalSign.details?[safe:2]?.itemDateTime) else { return ""}
    return "\(secondPreviousResultTitle)\nSince \(secondPreviousResultSince) Days"
  }
  init(withVitalSign vitalSign: VitalSign) {
    self.vitalSign = vitalSign
  }
}
