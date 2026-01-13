//
//  SymptomCategoryCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol SymptomCategoryCellPresenter {
  var symptomCategory: SymptomCategory { get }
}

class SymptomCategoryCellPresenterImpl: SymptomCategoryCellPresenter {
  let symptomCategory: SymptomCategory
  
  init(with symptomCategory: SymptomCategory) {
    self.symptomCategory = symptomCategory
  }
}
