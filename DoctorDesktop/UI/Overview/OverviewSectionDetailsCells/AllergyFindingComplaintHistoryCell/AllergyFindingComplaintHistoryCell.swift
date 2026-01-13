//
//  FindingCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/5/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class AllergyFindingComplaintHistoryCell: UITableViewCell {

  var presenter: AllergyFindingComplaintHistoryCellPresenter!

  @IBOutlet weak var descriptionLbl: UILabel!
  @IBOutlet weak var speciality: UILabel!
  @IBOutlet weak var date: UILabel!

  override func prepareForReuse() {
    self.descriptionLbl.text = ""
    self.speciality.text = ""
    self.date.text = ""
  }
}

//MARK: - Configure
extension AllergyFindingComplaintHistoryCell {
  func configure(with presenter: AllergyFindingComplaintHistoryCellPresenter) {
    self.presenter = presenter
    self.descriptionLbl.text = presenter.description
    self.speciality.text = presenter.speciality
    self.date.text = presenter.date
  }
}

//MARK: - Helper Methods
extension AllergyFindingComplaintHistoryCell {
  public static var cellId: String {
    return "FindingComplaintHistoryCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: AllergyFindingComplaintHistoryCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: AllergyFindingComplaintHistoryCell.cellId, bundle: AllergyFindingComplaintHistoryCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(AllergyFindingComplaintHistoryCell.nib, forCellReuseIdentifier: AllergyFindingComplaintHistoryCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> AllergyFindingComplaintHistoryCell {
    return bundle.loadNibNamed(AllergyFindingComplaintHistoryCell.cellId, owner: owner, options: nil)?.first as! AllergyFindingComplaintHistoryCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: AllergyFindingComplaintHistoryCellPresenter) -> AllergyFindingComplaintHistoryCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: AllergyFindingComplaintHistoryCell.cellId, for: indexPath) as! AllergyFindingComplaintHistoryCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> AllergyFindingComplaintHistoryCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: AllergyFindingComplaintHistoryCell.cellId) as! AllergyFindingComplaintHistoryCell
    cell.descriptionLbl.text = "Description"
    cell.speciality.text = "Speciality"
    cell.date.text = "Date"
    cell.descriptionLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.speciality.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.date.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}
