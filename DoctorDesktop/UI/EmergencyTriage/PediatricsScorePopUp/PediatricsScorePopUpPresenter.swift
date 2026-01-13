//
//  PediatricsScorePopUpPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 3/7/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol PediatricsScorePopUpPresenter {
  var pediatricsScoreElements: PediatricsScoreElements { get }
  var selectedScoreChoices: [PediatricsScoreChoice] { get set }
  var totalScore: Int { get set }
}

class PediatricsScorePopUpPresenterImpl: PediatricsScorePopUpPresenter {
  var pediatricsScoreElements: PediatricsScoreElements
  var selectedScoreChoices: [PediatricsScoreChoice]
  var totalScore: Int = 0
  
  init(_ pediatricsScoreElements: PediatricsScoreElements, selectedScoreChoices: [PediatricsScoreChoice]) {
    self.pediatricsScoreElements = pediatricsScoreElements
    self.selectedScoreChoices = selectedScoreChoices
  }
}
