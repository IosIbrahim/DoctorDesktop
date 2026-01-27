//
//  PatientHistoryFiltrationCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/17/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class PatientHistoryFiltrationCell: UICollectionViewCell {
  @IBOutlet weak var contentImageView: UIImageView!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pickerImage: UIView!
    
    @IBOutlet weak var pickerShadow: UIView!
    var presenter: PatientHistoryFiltrationCellPresenter!

  override func awakeFromNib() {
    super.awakeFromNib()
      pickerShadow.makeShadow(color: .lightGray, alpha: 0.2, radius: 8)
  }
}

//MARK: - Configure
extension PatientHistoryFiltrationCell {
    func configure(with presenter: PatientHistoryFiltrationCellPresenter,hideImage:Bool = true) {
    self.presenter = presenter
 //   contentImageView.image = #imageLiteral(resourceName: "visit_content_not_active")
    contentImageView.image = UIImage(named: "visit_content_not_active")
    iconImageView.image = presenter.patientHistoryFiltrationType.inactiveIconImage
    switch presenter.patientHistoryFiltrationType {
    case let .currentVisit(title): titleLabel.text = title
    case let .allVisits(title): titleLabel.text = title
    case let .currentSpeciality(title): titleLabel.text = title
    case let .currentDoctor(title): titleLabel.text = title
    }
        pickerImage.isHidden = hideImage
  }
}

extension PatientHistoryFiltrationCell {
  override var isSelected: Bool {
    didSet {
      print("\(presenter.patientHistoryFiltrationType.rawValue), \(isSelected)")
      iconImageView.image = isSelected ? presenter.patientHistoryFiltrationType.activeIconImage :
        presenter.patientHistoryFiltrationType.inactiveIconImage
      contentImageView.image = isSelected ? presenter.patientHistoryFiltrationType.activeContentImage : #imageLiteral(resourceName: "visit_content_not_active")
    }
  }
}

//MARK: - Helper Methods
extension PatientHistoryFiltrationCell {
  public static var cellId: String {
    return "PatientHistoryFiltrationCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: PatientHistoryFiltrationCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: PatientHistoryFiltrationCell.cellId, bundle: PatientHistoryFiltrationCell.bundle)
  }

  public static func register(with collectionView: UICollectionView) {
    collectionView.register(PatientHistoryFiltrationCell.nib, forCellWithReuseIdentifier: PatientHistoryFiltrationCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> PatientHistoryFiltrationCell {
    return bundle.loadNibNamed(PatientHistoryFiltrationCell.cellId, owner: owner, options: nil)?.first as! PatientHistoryFiltrationCell
  }

  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: PatientHistoryFiltrationCellPresenter) -> PatientHistoryFiltrationCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatientHistoryFiltrationCell.cellId, for: indexPath) as! PatientHistoryFiltrationCell
    cell.configure(with: presenter)
    return cell
  }
}


extension UIView {
    func makeShadow(color: UIColor, alpha: Float, radius: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = alpha
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: radius * UIScreen.main.bounds.width / 360)
    }
}
