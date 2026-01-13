//
//  UnitsPopup.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/14/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol UnitsPopupDelegate {
  func unitsPopup(_ unitsPopup: UnitsPopup, didSelectUnitAt index: Int)
}

class UnitsPopup: UIViewController {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!

  var presenter: UnitsPopupPresenter!
  var delegate: UnitsPopupDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    titleLabel.text = presenter.title
    UnitsPopupCell.register(with: tableView)
    tableView.tableFooterView = UIView()
  }
  
  init(with presenter: UnitsPopupPresenter) {
    self.presenter = presenter
    
    super.init(nibName: "UnitsPopup", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UnitsPopup: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.patientUnits.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let inpatientUnitsPopupCellPresenter = UnitsPopupCellPresenterImpl(with: presenter.patientUnits[indexPath.row])
    let cell = UnitsPopupCell.dequeue(from: tableView, for: indexPath, with: inpatientUnitsPopupCellPresenter)
    return cell
  }
}

extension UnitsPopup: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //tableView.deselectRow(at: indexPath, animated: true)
    delegate?.unitsPopup(self, didSelectUnitAt: indexPath.row)
  }
}

