//
//  DietaryCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/17/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class DietaryCell: UITableViewCell {
  var presenter: DietaryCellPresenter!

  @IBOutlet weak var dietary: UILabel!
  @IBOutlet weak var remarks: UILabel!
  @IBOutlet weak var date: UILabel!

  override func prepareForReuse() {
    self.dietary.text = ""
    self.remarks.text = ""
    self.date.text = ""
  }
}

//MARK: - Configure
extension DietaryCell {
  func configure(with presenter: DietaryCellPresenter) {
    self.presenter = presenter
    self.dietary.text = presenter.dietaryName
    self.remarks.text = presenter.remarks
    self.date.text = presenter.date
  }
}

//MARK: - Helper Methods
extension DietaryCell {
  public static var cellId: String {
    return "DietaryCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: DietaryCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: DietaryCell.cellId, bundle: DietaryCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(DietaryCell.nib, forCellReuseIdentifier: DietaryCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> DietaryCell {
    return bundle.loadNibNamed(DietaryCell.cellId, owner: owner, options: nil)?.first as! DietaryCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: DietaryCellPresenter) -> DietaryCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DietaryCell.cellId, for: indexPath) as! DietaryCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> DietaryCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DietaryCell.cellId) as! DietaryCell
    cell.dietary.text = "Dietary"
    cell.remarks.text = "Remarks"
    cell.date.text = "Date"
    cell.dietary.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.remarks.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.date.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}

