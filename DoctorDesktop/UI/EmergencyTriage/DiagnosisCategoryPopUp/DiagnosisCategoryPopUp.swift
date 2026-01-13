//
//  DiagnosisCategoryPopUp.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

protocol DiagnosisCategoryPopUpDelegate {
  func diagnosisCateogryPopUp(_ diagnosisCateogryPopUp: DiagnosisCategoryPopUp, didSelectCategoryAt index: Int)
}

class DiagnosisCategoryPopUp: UIViewController {
  var presenter: DiagnosisCategoryPopUpPresenter!
  var delegate: DiagnosisCategoryPopUpDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DiagnosisCategoryPopUpCell.register(with: tableView)
  }
  
  init(with presenter: DiagnosisCategoryPopUpPresenter) {
    self.presenter = presenter
    super.init(nibName: "DiagnosisCategoryPopUpView", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension DiagnosisCategoryPopUp: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.diagnosisCategories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let diagnosisCategoryPopUpCell = DiagnosisCategoryPopUpCellPresenterImpl(with: presenter.diagnosisCategories[indexPath.row])
    let cell = DiagnosisCategoryPopUpCell.dequeue(from: tableView, for: indexPath, with: diagnosisCategoryPopUpCell)
    return cell
  }
}

extension DiagnosisCategoryPopUp: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.diagnosisCateogryPopUp(self, didSelectCategoryAt: indexPath.row)
  }
}
