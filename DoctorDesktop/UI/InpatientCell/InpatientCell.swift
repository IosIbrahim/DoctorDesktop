//
//  InpatientCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/11/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit
import Kingfisher

class InpatientCell: UITableViewCell {
  
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var genderAgeView: UIView!
  @IBOutlet weak var genderAgeImageView: UIImageView!
  @IBOutlet weak var patientNameLabel: UILabel!
  @IBOutlet weak var doctorNameLabel: UILabel!
  @IBOutlet weak var bedNumberLabel: UILabel!
//  @IBOutlet weak var patientCountryFlagImage: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    cellView.layer.cornerRadius = 10
    genderAgeView.layer.cornerRadius = genderAgeView.bounds.width/2
  }  
}

//MARK: - Configure
extension InpatientCell {
  func configure(with presenter: InpatientCellPresenter) {
  //  let doctorFirstName = presenter.doctorName.components(separatedBy: CharacterSet(charactersIn: " ")).first ?? presenter.doctorName
    self.patientNameLabel.text = presenter.patientName
    let com = presenter.date.components(separatedBy: .whitespaces)
    lblDate.text = com.first
      
    genderAgeImageView.image = presenter.genderAgeImage
    doctorNameLabel.text = "Dr/ \(presenter.doctorName)"
      
    bedNumberLabel.text = presenter.bedNumberName
    bedNumberLabel.adjustsFontSizeToFitWidth = true
    genderAgeImageView.image = presenter.genderAgeImage
    lblAge.text = presenter.age
//    let url = URL(string: AppURLS.ip+AppURLS.imageApi+presenter.flagImageName)
//    patientCountryFlagImage.kf.setImage(with: url)
  }
}

//MARK: - Helper Methods
extension InpatientCell {
  public static var cellId: String {
    return "InpatientCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: InpatientCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: InpatientCell.cellId, bundle: InpatientCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(InpatientCell.nib, forCellReuseIdentifier: InpatientCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> InpatientCell {
    return bundle.loadNibNamed(InpatientCell.cellId, owner: owner, options: nil)?.first as! InpatientCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: InpatientCellPresenter) -> InpatientCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: InpatientCell.cellId, for: indexPath) as! InpatientCell
    cell.configure(with: presenter)
    return cell
  }
}
