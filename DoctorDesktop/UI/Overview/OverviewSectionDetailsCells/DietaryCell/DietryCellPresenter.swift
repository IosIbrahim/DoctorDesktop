//
//  DietaryCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/17/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol DietaryCellPresenter {
  var dietaryName: String { get }
  var remarks: String? { get }
  var date: String { get }
}

class DietaryCellPresenterImpl: DietaryCellPresenter {
  let dietary: Dietary

  var dietaryName: String { return dietary.dietEnglishName }
  var remarks: String? { return dietary.remarks }
  var date: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyy"
    return dateFormatter.string(from: dietary.lastModDate)
  }
  init(with dietary: Dietary) {
    self.dietary = dietary
  }
}
