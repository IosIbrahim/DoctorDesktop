//
//  OverviewSectionCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/15/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import PocketSVG

class OverviewSectionCell: UICollectionViewCell {
  @IBOutlet weak var sectionImageView: UIView!
  @IBOutlet weak var sectionTitleLabel: UILabel!
  @IBOutlet weak var counterView: UIView!
  @IBOutlet weak var counterLabel: UILabel!
  @IBOutlet weak var sectionView: UIView!

  var presenter: OverviewSectionCellPresenter!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.counterView.layer.cornerRadius = self.counterLabel.bounds.width/2
    self.counterView.layer.borderWidth = 1
    self.counterView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    self.sectionView.layer.cornerRadius = sectionView.bounds.width/2
  }

  override func prepareForReuse() {
    for subview in self.sectionImageView.subviews {
      subview.removeFromSuperview()
    }
    sectionTitleLabel.text = ""
    counterLabel.text = ""
  }
}

//MARK: - Configure
extension OverviewSectionCell {
  func configure(with presenter: OverviewSectionCellPresenter) {
    self.presenter = presenter
    if let url = Bundle.main.url(forResource: presenter.sectionImageName, withExtension: "svg") {
      let svgImageView = SVGImageView(contentsOf: url)
      svgImageView.frame = sectionImageView.bounds
      svgImageView.contentMode = .scaleAspectFit
      sectionImageView.addSubview(svgImageView)
    }
    self.sectionView.backgroundColor = presenter.sectionColor
    self.sectionTitleLabel.text = presenter.sectionTitle
    self.counterLabel.text = "\(presenter.counter)"
  }
}

//MARK: - Helper Methods
extension OverviewSectionCell {
  public static var cellId: String {
    return "OverviewSectionCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: OverviewSectionCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: OverviewSectionCell.cellId, bundle: OverviewSectionCell.bundle)
  }

  public static func register(with collectionView: UICollectionView) {
    collectionView.register(OverviewSectionCell.nib, forCellWithReuseIdentifier: OverviewSectionCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> OverviewSectionCell {
    return bundle.loadNibNamed(OverviewSectionCell.cellId, owner: owner, options: nil)?.first as! OverviewSectionCell
  }

  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: OverviewSectionCellPresenter) -> OverviewSectionCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewSectionCell.cellId, for: indexPath) as! OverviewSectionCell
    cell.configure(with: presenter)
    return cell
  }
}
