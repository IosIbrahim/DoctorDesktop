//
//  OrderServiceList.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/14/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import Toast_Swift
import NVActivityIndicatorView

class OrderServiceList: UIViewController, NVActivityIndicatorViewable {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var categoryImageView: UIImageView!
  @IBOutlet weak var categoryImageCircleView: UIView!
  @IBOutlet weak var addButton: UIBarButtonItem!

  private var presenter: OrderServiceListPresenter!
  private var orderServiceCellMaker: DependencyRegistry.OrderServiceCellMaker!
  private weak var navigationCoordinator: NavigationCoordinator?

  var selectedIndices = [IndexPath]()
  
  func configure(with presenter: OrderServiceListPresenter,
                 orderServiceCellMaker: @escaping DependencyRegistry.OrderServiceCellMaker,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.orderServiceCellMaker = orderServiceCellMaker
    self.navigationCoordinator = navigationCoordinator
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    switch presenter.templateType {
    case .labOrder: title = "Lab Order"
    case .radOrder: title = "Rad Order"
    }
    tableView.tableFooterView = UIView()
    OrderServiceCell.register(with: tableView)
    categoryLabel.text = presenter.categoryName
    categoryLabel.textColor = presenter.categoryColor
    categoryImageView.image = presenter.categoryImage
    categoryImageCircleView.layer.borderWidth = 1
    categoryImageCircleView.layer.borderColor = presenter.categoryColor.cgColor
    categoryImageCircleView.layer.cornerRadius = categoryImageCircleView.bounds.height/2
  }
}

extension OrderServiceList {
  func showToastFor(index: Int) {
    guard let prepareInstructions = presenter.services[index].prepareInstructions else {return}
    view.makeToast(prepareInstructions)
  }
  
  @objc func didPressAlarmButton(sender: UIButton) {
    showToastFor(index: sender.tag)
  }
  
  @IBAction func didPressPlusButton() {
    let servicesIds = selectedIndices.map() { indexPath in
      presenter.services[indexPath.row].id
    }
    startAnimating(message: "Validate Services...")
    presenter.validateServiceRow(withServicesIds: servicesIds) {
      self.stopAnimating()
      let args = ["servicesDetails": self.presenter.servicesDetails ?? [],
                  "templateType": self.presenter.templateType,
                  "user": self.presenter.user,
                  "labOrderServiceListPresenter": self.presenter,
                  "patient": self.presenter.patient,
                  "requestDoctor": self.presenter.generalParams.requestDoctor] as [String : Any]
      self.navigationCoordinator?.next(arguments: args)
    }
  }
}

extension OrderServiceList: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.services.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = orderServiceCellMaker(tableView, indexPath, presenter.services[indexPath.row])
    cell.accessoryType = selectedIndices.contains(indexPath) ? .checkmark : .none
    cell.alarmButton.tag = indexPath.row
    cell.alarmButton.addTarget(self, action: #selector(didPressAlarmButton(sender:)), for: .touchUpInside)
    return cell
  }
}

extension OrderServiceList: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    selectedIndices.append(indexPath)
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
    if let index = selectedIndices.index(of: indexPath) {
      selectedIndices.remove(at: index)
    }
  }
}
