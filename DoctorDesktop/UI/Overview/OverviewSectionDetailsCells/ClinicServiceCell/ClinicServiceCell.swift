//
//  ClinicServiceCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/16/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class ClinicServiceCell: UITableViewCell {
  var presenter: ClinicServiceCellPresenter!

  @IBOutlet weak var serviceName: UILabel!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var date: UILabel!

  override func prepareForReuse() {
    self.serviceName.text = ""
    self.status.text = ""
    self.date.text = ""
  }
}

//MARK: - Configure
extension ClinicServiceCell {
  func configure(with presenter: ClinicServiceCellPresenter) {
    self.presenter = presenter
    self.serviceName.text = presenter.serviceName
    self.status.text = presenter.status
    self.date.text = presenter.date
  }
}

//MARK: - Helper Methods
extension ClinicServiceCell {
  public static var cellId: String {
    return "ClinicServiceCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: ClinicServiceCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: ClinicServiceCell.cellId, bundle: ClinicServiceCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(ClinicServiceCell.nib, forCellReuseIdentifier: ClinicServiceCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> ClinicServiceCell {
    return bundle.loadNibNamed(ClinicServiceCell.cellId, owner: owner, options: nil)?.first as! ClinicServiceCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: ClinicServiceCellPresenter) -> ClinicServiceCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ClinicServiceCell.cellId, for: indexPath) as! ClinicServiceCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> ClinicServiceCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ClinicServiceCell.cellId) as! ClinicServiceCell
    cell.serviceName.text = "Service Name"
    cell.status.text = "Status"
    cell.date.text = "Date"
    cell.serviceName.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.status.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.date.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}
