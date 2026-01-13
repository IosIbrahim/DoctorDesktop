//
//  PediatricsScorePopUpCell.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 3/7/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class PediatricsScorePopUpCell: UICollectionViewCell {
  
  @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var title: UILabel!
  
  private var presenter: PediatricsScorePopUpCellPresenter!
  
  var id: String { return self.presenter.id }
  var desc: String? { return self.presenter.description }
  var choice: PediatricsScoreChoice? { return self.presenter.pediatricsScoreElement as? PediatricsScoreChoice }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.cellView.backgroundColor = .clear
  }
}


//MARK: - Configure
extension PediatricsScorePopUpCell {
  func configure(with presenter: PediatricsScorePopUpCellPresenter) {
    self.presenter = presenter
    self.title.text = presenter.description
  }
}

//MARK: - Helper Methods
extension PediatricsScorePopUpCell {
  public static var cellId: String {
    return "PediatricsScorePopUpCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: PediatricsScorePopUpCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: PediatricsScorePopUpCell.cellId, bundle: PediatricsScorePopUpCell.bundle)
  }
  
  public static func register(with collectionView: UICollectionView) {
    collectionView.register(PediatricsScorePopUpCell.nib, forCellWithReuseIdentifier: PediatricsScorePopUpCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> PediatricsScorePopUpCell {
    return bundle.loadNibNamed(PediatricsScorePopUpCell.cellId, owner: owner, options: nil)?.first as! PediatricsScorePopUpCell
  }
  
  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: PediatricsScorePopUpCellPresenter) -> PediatricsScorePopUpCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PediatricsScorePopUpCell.cellId, for: indexPath) as! PediatricsScorePopUpCell
    cell.configure(with: presenter)
    return cell
  }
}
