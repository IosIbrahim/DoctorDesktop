//
//  OrderCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/4/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import Toastlity

class OrderCell: UICollectionViewCell {
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var imageCircleView: UIView!

  @IBOutlet weak var categoryImageView: UIImageView!
  @IBOutlet weak var categoryTitle: UILabel!
  
  var presenter: OrderCellPresenter!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    cellView.layer.cornerRadius = 10
    imageCircleView.layer.cornerRadius = imageCircleView.bounds.height/2
    imageCircleView.layer.borderWidth = 2
    imageCircleView.layer.borderColor = #colorLiteral(red: 0.2745098039, green: 0.7411764706, blue: 0.7490196078, alpha: 1)
    categoryImageView.layer.cornerRadius = categoryImageView.bounds.height/2
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    categoryImageView.image = nil
    categoryTitle.text = ""
  }
}

//MARK: - Configure
extension OrderCell {
  func configure(with presenter: OrderCellPresenter) {
    self.categoryTitle.text = presenter.title
    self.categoryImageView.image = presenter.image
  }
}

//MARK: - Helper Methods
extension OrderCell {
  public static var cellId: String {
    return "OrderCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: OrderCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: OrderCell.cellId, bundle: OrderCell.bundle)
  }
  
  public static func register(with collectionView: UICollectionView) {
    collectionView.register(OrderCell.nib, forCellWithReuseIdentifier: OrderCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> OrderCell {
    return bundle.loadNibNamed(OrderCell.cellId, owner: owner, options: nil)?.first as! OrderCell
  }
  
  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: OrderCellPresenter) -> OrderCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCell.cellId, for: indexPath) as! OrderCell
    cell.configure(with: presenter)
    return cell
  }
}



extension ToastSettings {
    static var agent: ToastSettings {
        var settings = ToastSettings.default
        settings.mode = .top
        settings.backgroundColor = .blue
        settings.textColor = .white
        settings.font = .boldSystemFont(ofSize: 15)
        settings.autoHide = true
        return settings
    }
}
