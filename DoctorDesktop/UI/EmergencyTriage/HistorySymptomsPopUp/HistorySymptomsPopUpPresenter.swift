//
//  HistorySymptomsPopUpPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 3/18/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol HistorySymptomsPopUpPresenter {
  var historySymptomCategories: HistorySymptomCategories { get }
  var historySymptoms: Symptoms { get set }
}

class HistorySymptomsPopUpPresenterImpl: HistorySymptomsPopUpPresenter {
  var historySymptomCategories: HistorySymptomCategories
  var historySymptoms: Symptoms = []
  
  init(_ historySymptomCategories: HistorySymptomCategories) {
    self.historySymptomCategories = historySymptomCategories
  }
}
