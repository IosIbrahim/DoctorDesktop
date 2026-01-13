//
//  UnitsPopupCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/14/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit
import DropDown

class UnitsPopupCell: DropDownCell {
  @IBOutlet weak var unitTitle: UILabel!
  @IBOutlet weak var countView: UIView!
  @IBOutlet weak var countLabel: UILabel!
  
  fileprivate var presenter: UnitsPopupCellPresenter!

  override func awakeFromNib() {
    super.awakeFromNib()    
    countView.layer.cornerRadius = countView.bounds.width / 2.0
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    unitTitle.text = ""
    countLabel.text = ""
    countView.isHidden = false
  }
}

//MARK: - Configure
extension UnitsPopupCell {
  func configure(with presenter: UnitsPopupCellPresenter) {
    self.unitTitle.text = presenter.unitTitle
    if presenter.patientsCount == "0" {
      countView.isHidden = true
    } else {
      self.countLabel.text = presenter.patientsCount
    }
  }
}

//MARK: - Helper Methods
extension UnitsPopupCell {
  public static var cellId: String {
    return "UnitsPopupCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: UnitsPopupCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: UnitsPopupCell.cellId, bundle: UnitsPopupCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(UnitsPopupCell.nib, forCellReuseIdentifier: UnitsPopupCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> UnitsPopupCell {
    return bundle.loadNibNamed(UnitsPopupCell.cellId, owner: owner, options: nil)?.first as! UnitsPopupCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: UnitsPopupCellPresenter) -> UnitsPopupCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UnitsPopupCell.cellId, for: indexPath) as! UnitsPopupCell
    cell.configure(with: presenter)
    return cell
  }
}


