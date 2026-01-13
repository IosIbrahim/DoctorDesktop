//
//  MedicationCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/23/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class MedicationCell: UITableViewCell {
  var presenter: MedicationCellPresenter!

  @IBOutlet weak var drug: UILabel!
  @IBOutlet weak var doctor: UILabel!
  @IBOutlet weak var date: UILabel!

  override func prepareForReuse() {
    self.drug.text = ""
    self.doctor.text = ""
    self.date.text = ""
  }
}

//MARK: - Configure
extension MedicationCell {
  func configure(with presenter: MedicationCellPresenter) {
    self.presenter = presenter
    self.drug.text = presenter.drug
    self.doctor.text = presenter.doctor
    self.date.text = presenter.date
    
//    print(User)
  }
}

//MARK: - Helper Methods
extension MedicationCell {
  public static var cellId: String {
    return "MedicationCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: MedicationCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: MedicationCell.cellId, bundle: MedicationCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(MedicationCell.nib, forCellReuseIdentifier: MedicationCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> MedicationCell {
    return bundle.loadNibNamed(MedicationCell.cellId, owner: owner, options: nil)?.first as! MedicationCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: MedicationCellPresenter) -> MedicationCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MedicationCell.cellId, for: indexPath) as! MedicationCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> MedicationCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MedicationCell.cellId) as! MedicationCell
    cell.drug.text = "Drug"
    cell.doctor.text = "Docter"
    cell.date.text = "Date"
    cell.drug.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.doctor.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.date.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}
