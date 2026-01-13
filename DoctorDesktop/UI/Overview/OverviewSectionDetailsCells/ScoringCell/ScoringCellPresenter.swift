//
//  ScoringCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/3/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol ScoringCellPresenter {
  var scoreName: String { get }
  var conclusion: String? { get }
  var value: String? { get }
}

class ScoringCellPresenterImpl: ScoringCellPresenter {
  let scoring: Scoring

  var scoreName: String { return scoring.description }
  var conclusion: String? { return scoring.conclusion }
  var value: String? { return scoring.value }

  init(with scoring: Scoring) {
    self.scoring = scoring
  }
}
