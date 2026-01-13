//
//  DocdeskCell.swift
//  Doctor DeskTop
//
//  Created by Eng Nour Hegazy on 12/5/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

class ComponentCell: UICollectionViewCell {
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  fileprivate var presenter: ComponentCellPresenter!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.cellView.layer.cornerRadius = 20
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    cellView.backgroundColor = .clear
    countLabel.text = ""
    titleLabel.text = ""
    imageView.image = nil
  }
}

//MARK: - Configure
extension ComponentCell {
  func configure(with presenter: ComponentCellPresenter) {
    let layer = CAGradientLayer()
    layer.frame = self.bounds
    layer.colors = [presenter.startColor.withAlphaComponent(0.90).cgColor, presenter.endColor.withAlphaComponent(0.90).cgColor]
    layer.startPoint = CGPoint(x: 0.0, y: 0.5)
    layer.endPoint = CGPoint(x: 1.0, y: 0.5)
    layer.cornerRadius = 10
    self.backgroundView = UIView()
    self.backgroundView?.layer.addSublayer(layer)
    
    self.titleLabel.text = presenter.title
    self.countLabel.text = presenter.count
    self.imageView.image = presenter.image
  }
}

//MARK: - Helper Methods
extension ComponentCell {
  public static var cellId: String {
    return "ComponentCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: ComponentCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: ComponentCell.cellId, bundle: ComponentCell.bundle)
  }
  
  public static func register(with collectionView: UICollectionView) {
    collectionView.register(ComponentCell.nib, forCellWithReuseIdentifier: ComponentCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> ComponentCell {
    return bundle.loadNibNamed(ComponentCell.cellId, owner: owner, options: nil)?.first as! ComponentCell
  }
  
  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: ComponentCellPresenter) -> ComponentCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ComponentCell.cellId, for: indexPath) as! ComponentCell
    cell.configure(with: presenter)
    return cell
  }
}

