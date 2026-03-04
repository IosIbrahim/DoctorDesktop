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
  var user: String { get }
  var date: String { get }
}

class AllergyFindingComplaintHistoryCellPresenterImpl: AllergyFindingComplaintHistoryCellPresenter {
  let allergyFindingComplaintHistory: Complaint

  var description: String { return allergyFindingComplaintHistory.descEn ?? "" }
  var user: String { return allergyFindingComplaintHistory.userNameEn ?? ""}
//  var date: String {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "dd/MM/yyy"
//    return dateFormatter.string(from: allergyFindingComplaintHistory.transactionDate)
//  }
    var date: String {return allergyFindingComplaintHistory.visitStartDate ?? "" }
  init(with allergyFindingComplaintHistory: Complaint) {
    self.allergyFindingComplaintHistory = allergyFindingComplaintHistory
  }
}
