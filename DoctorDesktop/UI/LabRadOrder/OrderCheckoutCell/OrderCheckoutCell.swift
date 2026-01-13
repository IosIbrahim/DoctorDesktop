//
//  OrderCheckoutCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import VHBoomMenuButton

class OrderCheckoutCell: UITableViewCell {
  @IBOutlet weak var serviceName: UILabel!
  @IBOutlet weak var servicePrice: UILabel!
  @IBOutlet weak var serviceQuantity: UITextField!

  @IBOutlet weak var warning: UIImageView!
  @IBOutlet weak var cash: UIImageView!
  @IBOutlet weak var notes: UIImageView!
  @IBOutlet weak var emergencyLevel: UIImageView!
  @IBOutlet weak var bmb: BoomMenuButton!
  
  var presenter: OrderCheckoutCellPresenter!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    serviceName.text = ""
    servicePrice.text = ""
  }
  
}

//MARK: - Configure
extension OrderCheckoutCell {
  func configure(with presenter: OrderCheckoutCellPresenter) {
    serviceName.text = "  " + presenter.serviceName
    servicePrice.text = "  " + presenter.servicePrice
  }
}

//MARK: - Helper Methods
extension OrderCheckoutCell {
  public static var cellId: String {    
    return "OrderCheckoutCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: OrderCheckoutCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: OrderCheckoutCell.cellId, bundle: OrderCheckoutCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(OrderCheckoutCell.nib, forCellReuseIdentifier: OrderCheckoutCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> OrderCheckoutCell {
    return bundle.loadNibNamed(OrderCheckoutCell.cellId, owner: owner, options: nil)?.first as! OrderCheckoutCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: OrderCheckoutCellPresenter) -> OrderCheckoutCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OrderCheckoutCell.cellId, for: indexPath) as! OrderCheckoutCell
    cell.configure(with: presenter)
    return cell
  }
}
