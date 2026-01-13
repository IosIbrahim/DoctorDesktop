//
//  ClinicalInfoPopupCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class ClinicalInfoPopupCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailsLabel: UILabel!

  override func prepareForReuse() {
    titleLabel.text = ""
    detailsLabel.text = ""
  }
}

//MARK: - Configure
extension ClinicalInfoPopupCell {
  func configure(with presenter: ClinicalInfoPopupCellPresenter) {
    titleLabel.text = presenter.title
    detailsLabel.text = presenter.details
  }
}

//MARK: - Helper Methods
extension ClinicalInfoPopupCell {
  public static var cellId: String {
    return "ClinicalInfoPopupCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: ClinicalInfoPopupCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: ClinicalInfoPopupCell.cellId, bundle: ClinicalInfoPopupCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(ClinicalInfoPopupCell.nib, forCellReuseIdentifier: ClinicalInfoPopupCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> ClinicalInfoPopupCell {
    return bundle.loadNibNamed(ClinicalInfoPopupCell.cellId, owner: owner, options: nil)?.first as! ClinicalInfoPopupCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: ClinicalInfoPopupCellPresenter) -> ClinicalInfoPopupCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ClinicalInfoPopupCell.cellId, for: indexPath) as! ClinicalInfoPopupCell
    cell.configure(with: presenter)
    return cell
  }
}
