//
//  PediatricsScorePopUpCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 3/7/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

protocol PediatricsScorePopUpCellPresenter {
  var pediatricsScoreElement: PediatricsScoreElement { get }
  var id: String { get }
  var description: String? { get }
  var value: String? { get }
  var SER: String? { get }
}

class PediatricsScorePopUpCellPresenterImpl: PediatricsScorePopUpCellPresenter {
  var pediatricsScoreElement: PediatricsScoreElement
  var id: String { return pediatricsScoreElement.id }
  var description: String? { return pediatricsScoreElement.englishDescription }
  var value: String? { return pediatricsScoreElement.value }
  var SER: String? { return pediatricsScoreElement.SER }
  
  init(with pediatricsScoreElement: PediatricsScoreElement) {
    self.pediatricsScoreElement = pediatricsScoreElement
  }
}
