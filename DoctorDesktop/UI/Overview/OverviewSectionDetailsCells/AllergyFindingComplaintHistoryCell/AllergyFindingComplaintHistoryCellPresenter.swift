//
//  FindingCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/5/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol AllergyFindingComplaintHistoryCellPresenter {
  var description: String { get }
  var speciality: String { get }
  var date: String { get }
}

class AllergyFindingComplaintHistoryCellPresenterImpl: AllergyFindingComplaintHistoryCellPresenter {
  let allergyFindingComplaintHistory: AllergyFindingComplaintHistory

  var description: String { return allergyFindingComplaintHistory.englishDescription ?? "" }
  var speciality: String { return allergyFindingComplaintHistory.visitSpecialityEnglishName ??
    allergyFindingComplaintHistory.allergyTypeEnglishName ?? "" }
  var date: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyy"
    return dateFormatter.string(from: allergyFindingComplaintHistory.transactionDate)
  }

  init(with allergyFindingComplaintHistory: AllergyFindingComplaintHistory) {
    self.allergyFindingComplaintHistory = allergyFindingComplaintHistory
  }
}
