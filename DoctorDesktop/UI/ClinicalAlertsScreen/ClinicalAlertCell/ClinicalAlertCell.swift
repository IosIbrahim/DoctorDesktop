//
//  ClinicalAlertCell.swift
//  DoctorDesktop
//
//  Created by mac-pc on 12/19/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

class ClinicalAlertCell: UITableViewCell {
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var genderAgeView: UIView!
  @IBOutlet weak var genderAgeImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var countryLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet weak var viewMoreButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    cellView.layer.cornerRadius = 10
    genderAgeView.layer.cornerRadius = genderAgeView.bounds.width/2
  }

  override func prepareForReuse() {
    genderAgeImageView.image = nil
    nameLabel.text = ""
    countryLabel.text = ""
    ageLabel.text = ""
  }
}

//MARK: - Configure
extension ClinicalAlertCell {
  func configure(with presenter: ClinicalAlertCellPresenter) {
    genderAgeImageView.image = presenter.genderAgeImage
    nameLabel.text = presenter.name
    countryLabel.text = presenter.nationality
    ageLabel.text = presenter.age
  }
}

//MARK: - Helper Methods
extension ClinicalAlertCell {
  public static var cellId: String {
    return "ClinicalAlertCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: ClinicalAlertCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: ClinicalAlertCell.cellId, bundle: ClinicalAlertCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(ClinicalAlertCell.nib, forCellReuseIdentifier: ClinicalAlertCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> ClinicalAlertCell {
    return bundle.loadNibNamed(ClinicalAlertCell.cellId, owner: owner, options: nil)?.first as! ClinicalAlertCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: ClinicalAlertCellPresenter) -> ClinicalAlertCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ClinicalAlertCell.cellId, for: indexPath) as! ClinicalAlertCell
    cell.configure(with: presenter)
    return cell
  }
}
