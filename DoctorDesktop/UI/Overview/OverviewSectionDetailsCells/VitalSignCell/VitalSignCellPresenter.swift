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

  private static let displayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy\nHH:mm:ss"
    return f
  }()

  var vitalSignTitle: String { return vitalSign.englishName }

  var currentResult: String {
    return formatted(detail: vitalSign.details?[safe: 0])
  }
  var firstPreviousResult: String {
    return formatted(detail: vitalSign.details?[safe: 1])
  }
  var secondPreviousResult: String {
    return formatted(detail: vitalSign.details?[safe: 2])
  }

  private func formatted(detail: VitalSign.VitalSignDetail?) -> String {
    guard let d = detail, !d.itemValue.isEmpty else { return "" }
    let dateStr = VitalSignCellPresenterImpl.displayFormatter.string(from: d.itemDateTime)
    // Blood Pressure (and any reading with a secondary value) → "120 / 80"
    let valueStr: String
    if let other = d.itemValueOther, !other.isEmpty {
      valueStr = "\(d.itemValue) / \(other)"
    } else {
      valueStr = d.itemValue
    }
    return "\(valueStr)\n\(dateStr)"
  }

  init(withVitalSign vitalSign: VitalSign) {
    self.vitalSign = vitalSign
  }
}
