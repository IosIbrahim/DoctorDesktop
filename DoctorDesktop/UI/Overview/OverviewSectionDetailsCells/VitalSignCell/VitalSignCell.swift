//
//  VitalSignCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/14/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class VitalSignCell: UITableViewCell {
  var presenter: VitalSignCellPresenter!

  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var currentResult: UILabel!
  @IBOutlet weak var firstPreviousResult: UILabel!
  @IBOutlet weak var secondPreviousResult: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func prepareForReuse() {
    self.title.text = ""
    self.currentResult.text = ""
    self.firstPreviousResult.text = ""
    self.secondPreviousResult.text = ""
  }
}

//MARK: - Configure
extension VitalSignCell {
  func configure(with presenter: VitalSignCellPresenter) {
    self.presenter = presenter
    self.title.text = presenter.vitalSignTitle
    self.currentResult.text = presenter.currentResult
    self.firstPreviousResult.text = presenter.firstPreviousResult
    self.secondPreviousResult.text = presenter.secondPreviousResult
  }
}

//MARK: - Helper Methods
extension VitalSignCell {
  public static var cellId: String {
    return "VitalSignCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: VitalSignCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: VitalSignCell.cellId, bundle: VitalSignCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(VitalSignCell.nib, forCellReuseIdentifier: VitalSignCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> VitalSignCell {
    return bundle.loadNibNamed(VitalSignCell.cellId, owner: owner, options: nil)?.first as! VitalSignCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: VitalSignCellPresenter) -> VitalSignCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: VitalSignCell.cellId, for: indexPath) as! VitalSignCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> VitalSignCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: VitalSignCell.cellId) as! VitalSignCell
    cell.title.text = "Name"
    cell.currentResult.text = "Result"
    cell.firstPreviousResult.text = "Previous"
    cell.secondPreviousResult.text = "Previous"
    cell.title.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    cell.currentResult.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.firstPreviousResult.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.secondPreviousResult.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}

