//
//  RadTestCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/24/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class RadTestCell: UITableViewCell {
  var presenter: RadTestCellPresenter!

    @IBOutlet weak var pickerName: UIView!
    @IBOutlet weak var serviceName: UILabel!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var result: UILabel!
  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var preview: UIButton!
  @IBOutlet weak var packsHistory: UIButton!

  override func prepareForReuse() {
    self.serviceName.text = ""
    self.status.text = ""
    self.result.text = ""
    self.date.text = ""
    pickerName.layer.cornerRadius = 5
  }
}

//MARK: - Configure
extension RadTestCell {
  func configure(with presenter: RadTestCellPresenter) {
    self.presenter = presenter
    self.serviceName.text = presenter.serviceName
    self.status.text = presenter.status
    self.result.text = presenter.result
    self.date.text = presenter.date
  }
}

//MARK: - Helper Methods
extension RadTestCell {
  public static var cellId: String {
    return "RadTestCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: RadTestCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: RadTestCell.cellId, bundle: RadTestCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(RadTestCell.nib, forCellReuseIdentifier: RadTestCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> RadTestCell {
    return bundle.loadNibNamed(RadTestCell.cellId, owner: owner, options: nil)?.first as! RadTestCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: RadTestCellPresenter) -> RadTestCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RadTestCell.cellId, for: indexPath) as! RadTestCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> RadTestCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RadTestCell.cellId) as! RadTestCell
    cell.serviceName.text = "Service Name"
    cell.status.text = "Status"
    cell.result.text = "Result"
    cell.date.text = "Date"
    cell.serviceName.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.status.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.result.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.date.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    cell.preview.removeFromSuperview()
    cell.packsHistory.removeFromSuperview()
    return cell
  }
}
