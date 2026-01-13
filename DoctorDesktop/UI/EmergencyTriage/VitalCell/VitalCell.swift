//
//  VitalCell.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/19/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class VitalCell: UICollectionViewCell {
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var vitalLabel: UILabel!
  @IBOutlet weak var vitalIcon: UIImageView!
  @IBOutlet weak var vitalValue: UITextField!
  
  private var presenter: VitalCellPresenter!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.cellView.backgroundColor = .clear
    self.vitalLabel.text = self.presenter.vital == .bloodPressure ? "/" : "-"
    self.vitalValue.text = ""
    self.vitalIcon.image = nil
  }
}

extension VitalCell: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if self.presenter.vital != .bloodPressure {
      textField.text = textField.text?.trimmingCharacters(in: .whitespaces) == "-" ? "" : textField.text
    }
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let text = textField.text,
      let textRange = Range(range, in: text) {
      let updatedText = text.replacingCharacters(in: textRange, with: string)
      if self.presenter.vital == .bloodPressure && updatedText.contains("/") { return true } else { return self.presenter.vital != .bloodPressure }
    }
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    textField.text = textField.text?.trimmingCharacters(in: .whitespaces) == "" ? "-" : textField.text
    return true
  }
}

//MARK: - Configure
extension VitalCell {
  func configure(with presenter: VitalCellPresenter) {
    self.presenter = presenter
    self.cellView.backgroundColor = presenter.backgroudColor
    self.vitalLabel.text = presenter.label
    self.vitalValue.text = presenter.value
    self.vitalIcon.image = presenter.image
  }
}

extension VitalCell {
  func getJSONKey() -> String { return presenter.vital.rawValue }
  func getVitalType() -> Vital { return presenter.vital }
}

//MARK: - Helper Methods
extension VitalCell {
  public static var cellId: String {
    return "VitalCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: VitalCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: VitalCell.cellId, bundle: VitalCell.bundle)
  }
  
  public static func register(with collectionView: UICollectionView) {
    collectionView.register(VitalCell.nib, forCellWithReuseIdentifier: VitalCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> VitalCell {
    return bundle.loadNibNamed(VitalCell.cellId, owner: owner, options: nil)?.first as! VitalCell
  }
  
  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: VitalCellPresenter) -> VitalCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VitalCell.cellId, for: indexPath) as! VitalCell
    cell.configure(with: presenter)
    return cell
  }
}
