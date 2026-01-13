//
//  DiagnosisCategoryPopUpCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol DiagnosisCategoryPopUpCellPresenter {
  var diagnosisCategory: DiagnosisCategory { get }
}

class DiagnosisCategoryPopUpCellPresenterImpl: DiagnosisCategoryPopUpCellPresenter {
  let diagnosisCategory: DiagnosisCategory
  
  init(with diagnosisCategory: DiagnosisCategory) {
    self.diagnosisCategory = diagnosisCategory
  }
}
