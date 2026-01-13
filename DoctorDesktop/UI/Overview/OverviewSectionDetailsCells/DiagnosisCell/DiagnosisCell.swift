//
//  DiagnosisCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/23/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class DiagnosisCell: UITableViewCell {
  var presenter: DiagnosisCellPresenter!

  @IBOutlet weak var code: UILabel!
  @IBOutlet weak var descriptionLbl: UILabel!
  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var status: UILabel!

  override func prepareForReuse() {
    self.code.text = ""
    self.descriptionLbl.text = ""
    self.date.text = ""
    self.status.text = ""
  }
}

//MARK: - Configure
extension DiagnosisCell {
  func configure(with presenter: DiagnosisCellPresenter) {
    self.presenter = presenter
    self.code.text = presenter.code
    self.descriptionLbl.text = presenter.description
    self.date.text = presenter.date
    self.status.text = presenter.status
  }
}

//MARK: - Helper Methods
extension DiagnosisCell {
  public static var cellId: String {
    return "DiagnosisCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: DiagnosisCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: DiagnosisCell.cellId, bundle: DiagnosisCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(DiagnosisCell.nib, forCellReuseIdentifier: DiagnosisCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> DiagnosisCell {
    return bundle.loadNibNamed(DiagnosisCell.cellId, owner: owner, options: nil)?.first as! DiagnosisCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: DiagnosisCellPresenter) -> DiagnosisCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DiagnosisCell.cellId, for: indexPath) as! DiagnosisCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> DiagnosisCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DiagnosisCell.cellId) as! DiagnosisCell
    cell.code.text = "Code"
    cell.descriptionLbl.text = "Description"
    cell.date.text = "Date"
    cell.status.text = ""
    cell.code.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.descriptionLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.date.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}
