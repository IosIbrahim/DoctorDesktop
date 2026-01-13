//
//  VitalCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/19/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

protocol VitalCellPresenter {
  var vital: Vital { get }
  var label: String { get }
  var value: String { get }
  var backgroudColor: UIColor { get }
  var image: UIImage { get }
}

class VitalCellPresenterImpl: VitalCellPresenter {
  var vital: Vital
  var value: String
  var backgroudColor: UIColor { return vital.color }
  var image: UIImage { return vital.icon }
  var label: String { return vital.title }
  
  init(with vital: Vital, value: String?) {
    self.vital = vital
    if let value = value {
      self.value = value
    } else {
      self.value = vital == .bloodPressure ? "/" : "-"
    }
  }
}
