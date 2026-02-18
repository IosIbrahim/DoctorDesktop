//
//  LabsCell.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 17/02/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

class LabsCell: UITableViewCell {
    
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var presenter: LabsCellPresenter!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - Configure
extension LabsCell {
  func configure(with presenter: LabsCellPresenter) {
    self.presenter = presenter
    self.serviceName.text = presenter.serviceName
    self.status.text = presenter.status
    self.date.text = presenter.date
  }
}

//MARK: - Helper Methods
extension LabsCell {
  public static var cellId: String {
    return "LabsCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: LabsCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: LabsCell.cellId, bundle: LabsCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(LabsCell.nib, forCellReuseIdentifier: LabsCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> LabsCell {
    return bundle.loadNibNamed(LabsCell.cellId, owner: owner, options: nil)?.first as! LabsCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: LabsCellPresenter) -> LabsCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: LabsCell.cellId, for: indexPath) as! LabsCell
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
