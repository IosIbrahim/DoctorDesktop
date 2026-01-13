
//
//  MedicationCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/23/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol MedicationCellPresenter {
  var drug: String { get }
  var doctor: String { get }
  var date: String { get }
}

class MedicationCellPresenterImpl: MedicationCellPresenter {
  let medication: Medication

  var drug: String { return medication.englishNotes ?? "" }
  var doctor: String { return medication.doctorShortEnlgishName ?? " " }
  var date: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyy"
//    return dateFormatter.string(from: medication.transactionDate)
    return medication.transactionDate ?? "12/2/1994"
  }
  init(with medication: Medication) {
    self.medication = medication
  }
}
