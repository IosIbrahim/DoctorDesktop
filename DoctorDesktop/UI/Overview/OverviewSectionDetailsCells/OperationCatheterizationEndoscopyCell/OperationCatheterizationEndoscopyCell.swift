//
//  OperationCatheterizationEndoscopyCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/5/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class OperationCatheterizationEndoscopyCell: UITableViewCell {
  var presenter: OperationCatheterizationEndoscopyCellPresenter!

  @IBOutlet weak var serviceName: UILabel!
  @IBOutlet weak var surgeon: UILabel!
  @IBOutlet weak var anthesia: UILabel!
  @IBOutlet weak var date: UILabel!

  override func prepareForReuse() {
    self.serviceName.text = ""
    self.surgeon.text = ""
    self.anthesia.text = ""
    self.date.text = ""
  }
}

//MARK: - Configure
extension OperationCatheterizationEndoscopyCell {
  func configure(with presenter: OperationCatheterizationEndoscopyCellPresenter) {
    self.presenter = presenter
    self.serviceName.text = presenter.serviceName
    self.surgeon.text = presenter.surgeon
    self.anthesia.text = presenter.anthesia
    self.date.text = presenter.date
  }
}

//MARK: - Helper Methods
extension OperationCatheterizationEndoscopyCell {
  public static var cellId: String {
    return "OperationCatheterizationEndoscopyCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: OperationCatheterizationEndoscopyCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: OperationCatheterizationEndoscopyCell.cellId, bundle: OperationCatheterizationEndoscopyCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(OperationCatheterizationEndoscopyCell.nib, forCellReuseIdentifier: OperationCatheterizationEndoscopyCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> OperationCatheterizationEndoscopyCell {
    return bundle.loadNibNamed(OperationCatheterizationEndoscopyCell.cellId, owner: owner, options: nil)?.first as! OperationCatheterizationEndoscopyCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: OperationCatheterizationEndoscopyCellPresenter) -> OperationCatheterizationEndoscopyCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OperationCatheterizationEndoscopyCell.cellId, for: indexPath) as! OperationCatheterizationEndoscopyCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> OperationCatheterizationEndoscopyCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OperationCatheterizationEndoscopyCell.cellId) as! OperationCatheterizationEndoscopyCell
    cell.serviceName.text = "Service Name"
    cell.surgeon.text = "Surgeon"
    cell.anthesia.text = "Anthesia"
    cell.date.text = "Date"
    cell.serviceName.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.surgeon.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.anthesia.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.date.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}
