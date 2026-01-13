//
//  DiagnosisCategoryPopUpPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol DiagnosisCategoryPopUpPresenter {
  var diagnosisCategories: DiagnosisCategories { get }
}

class DiagnosisCategoryPopUpPresenterImpl: DiagnosisCategoryPopUpPresenter {
  var diagnosisCategories: DiagnosisCategories
  
  init(_ diagnosisCategories: DiagnosisCategories) {
    self.diagnosisCategories = diagnosisCategories
  }
}
