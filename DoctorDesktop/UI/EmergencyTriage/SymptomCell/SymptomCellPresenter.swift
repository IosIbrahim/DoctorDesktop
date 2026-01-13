//
//  SymptomCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol SymptomCellPresenter {
  var symptom: Symptom { get }
}

class SymptomCellPresenterImpl: SymptomCellPresenter {
  let symptom: Symptom
  
  init(with symptom: Symptom) {
    self.symptom = symptom
  }
}
