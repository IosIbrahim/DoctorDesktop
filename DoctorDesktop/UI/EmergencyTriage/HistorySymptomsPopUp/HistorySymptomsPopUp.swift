//
//  HistorySymptomsPopUp.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 3/18/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

protocol HistorySymptomsPopUpDelegate {
  func historySymptomsPopUp(_ historySymptomsPopUp: HistorySymptomsPopUp, didSelectCategory historySymptomCategory: HistorySymptomCategory)
}

class HistorySymptomsPopUp: UIViewController {
  var presenter: HistorySymptomsPopUpPresenter!
  var delegate: HistorySymptomsPopUpDelegate?
  
  @IBOutlet weak var symptomCategoriesTable: UITableView!
  @IBOutlet weak var symptomsTable: UITableView!
  
  override func viewDidLoad() {
    SymptomCategoryCell.register(with: self.symptomCategoriesTable)
    SymptomCell.register(with: self.symptomsTable)
  }
  @IBAction func didClickDismiss(_ sender: Any) {
    self.dismiss(animated: true)
  }
  
  init(with presenter: HistorySymptomsPopUpPresenter) {
    self.presenter = presenter
    super.init(nibName: "HistorySymptomsPopUpView", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension HistorySymptomsPopUp: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.symptomCategoriesTable { return self.presenter.historySymptomCategories.count }
    else if tableView == self.symptomsTable { return self.presenter.historySymptoms.count }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == self.symptomCategoriesTable {
      let symptomCategoryCell = SymptomCategoryCellPresenterImpl(with: presenter.historySymptomCategories[indexPath.row])
      return SymptomCategoryCell.dequeue(from: tableView, for: indexPath, with: symptomCategoryCell)
    } else if tableView == self.symptomsTable {
      let symptomCellPresenter = SymptomCellPresenterImpl(with: presenter.historySymptoms[indexPath.row])
      return SymptomCell.dequeue(from: tableView, for: indexPath, with: symptomCellPresenter)
    }
    return UITableViewCell()
  }
}

extension HistorySymptomsPopUp: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if tableView == self.symptomCategoriesTable {
      delegate?.historySymptomsPopUp(self, didSelectCategory: self.presenter.historySymptomCategories[indexPath.row])
    }
  }
}
