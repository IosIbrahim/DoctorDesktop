//
//  OrderServiceCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/14/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class OrderServiceCell: UITableViewCell {
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var alarmButton: UIButton!
  
  var presenter: OrderServiceCellPresenter!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    name.text = ""
    alarmButton.setImage(nil, for: .normal)
  }
}

//MARK: - Configure
extension OrderServiceCell {
  func configure(with presenter: OrderServiceCellPresenter) {
    self.name.text = presenter.serviceName
    alarmButton.setImage(presenter.servicePrepareInstructions != nil ? #imageLiteral(resourceName: "alarm") : nil, for: .normal)
  }
}

//MARK: - Helper Methods
extension OrderServiceCell {
  public static var cellId: String {
    return "OrderServiceCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: OrderServiceCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: OrderServiceCell.cellId, bundle: OrderServiceCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(OrderServiceCell.nib, forCellReuseIdentifier: OrderServiceCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> OrderServiceCell {
    return bundle.loadNibNamed(OrderServiceCell.cellId, owner: owner, options: nil)?.first as! OrderServiceCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: OrderServiceCellPresenter) -> OrderServiceCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OrderServiceCell.cellId, for: indexPath) as! OrderServiceCell
    cell.configure(with: presenter)
    return cell
  }
}
