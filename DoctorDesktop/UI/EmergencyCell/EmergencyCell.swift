//
//  EmergencyCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/24/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

class EmergencyCell: UITableViewCell {
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var genderAgeView: UIView!
  @IBOutlet weak var genderAgeImageView: UIImageView!
  @IBOutlet weak var patientNameLabel: UILabel!
  @IBOutlet weak var patientCountryFlagImage: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    cellView.layer.cornerRadius = 10
    genderAgeView.layer.cornerRadius = genderAgeView.bounds.width/2
  }
  
  override func prepareForReuse() {
    patientNameLabel.text = ""
    genderAgeImageView.image = nil
    patientCountryFlagImage.image = nil
  }
}

//MARK: - Configure
extension EmergencyCell {
  func configure(with presenter: EmergencyCellPresenter) {
    patientNameLabel.text = presenter.patientName
    genderAgeImageView.image = presenter.genderAgeImage

    let url = URL(string: AppURLS.ip+AppURLS.imageApi+presenter.flagImageName)
    patientCountryFlagImage.kf.setImage(with: url)
  }
}

//MARK: - Helper Methods
extension EmergencyCell {
  public static var cellId: String {
    return "EmergencyCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: EmergencyCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: EmergencyCell.cellId, bundle: EmergencyCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(EmergencyCell.nib, forCellReuseIdentifier: EmergencyCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> EmergencyCell {
    return bundle.loadNibNamed(EmergencyCell.cellId, owner: owner, options: nil)?.first as! EmergencyCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: EmergencyCellPresenter) -> EmergencyCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: EmergencyCell.cellId, for: indexPath) as! EmergencyCell
    cell.configure(with: presenter)
    return cell
  }
}

