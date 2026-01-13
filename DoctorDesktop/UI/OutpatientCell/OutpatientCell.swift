//
//  OutpatientCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/18/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

class OutpatientCell: UITableViewCell {
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var genderAgeView: UIView!
  @IBOutlet weak var genderAgeImageView: UIImageView!
  @IBOutlet weak var patientNameLabel: UILabel!
  @IBOutlet weak var patientNationalityLabel: UILabel!
  @IBOutlet weak var clinicTitleLabel: UILabel!
  @IBOutlet weak var statusButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    cellView.layer.cornerRadius = 10
    genderAgeView.layer.cornerRadius = genderAgeView.bounds.width/2
    statusButton.layer.cornerRadius = 8
  }
  
  override func prepareForReuse() {
    patientNameLabel.text = ""
    patientNationalityLabel.text = ""
    clinicTitleLabel.text = ""
    genderAgeImageView.image = nil
  }
}

//MARK: - Configure
extension OutpatientCell {
  func configure(with presenter: OutpatientCellPresenter) {
    self.patientNameLabel.text = presenter.patientName
    self.patientNationalityLabel.text = presenter.patientNationality
    self.genderAgeImageView.image = presenter.genderAgeImage
    self.clinicTitleLabel.text = presenter.clinicTitle
  }
}

//MARK: - Helper Methods
extension OutpatientCell {
  public static var cellId: String {
    return "OutpatientCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: OutpatientCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: OutpatientCell.cellId, bundle: OutpatientCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(OutpatientCell.nib, forCellReuseIdentifier: OutpatientCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> OutpatientCell {
    return bundle.loadNibNamed(OutpatientCell.cellId, owner: owner, options: nil)?.first as! OutpatientCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: OutpatientCellPresenter) -> OutpatientCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OutpatientCell.cellId, for: indexPath) as! OutpatientCell
    cell.configure(with: presenter)
    return cell
  }
}
