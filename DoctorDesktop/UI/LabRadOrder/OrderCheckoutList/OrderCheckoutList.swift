//
//  OrderCheckoutList.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/19/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import PopupDialog
import SearchTextField
import NVActivityIndicatorView
import VHBoomMenuButton

class OrderCheckoutList: UIViewController, NVActivityIndicatorViewable {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var servicesSearchTextField: SearchTextField!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  
  private var presenter: OrderCheckoutListPresenter!
  private var orderCheckoutCellMaker: DependencyRegistry.OrderCheckoutCellMaker!
  private weak var navigationCoordinator: NavigationCoordinator?

  func configure(with presenter: OrderCheckoutListPresenter,
                 orderCheckoutCellMaker: @escaping DependencyRegistry.OrderCheckoutCellMaker,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.orderCheckoutCellMaker = orderCheckoutCellMaker
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
    OrderCheckoutCell.register(with: tableView)
    tableView.tableFooterView = UIView()

    presenter.getServices() {
      let servicesNames = self.presenter.labRadServices.map() { labRadService in labRadService.name }
      self.servicesSearchTextField.filterStrings(servicesNames)
      self.indicator.stopAnimating()
      self.servicesSearchTextField.isEnabled = true
    }
    servicesSearchTextField.itemSelectionHandler = { filteredResults, itemPosition in
      let serviceId = self.presenter.labRadServices[itemPosition].id
      self.presenter.validateServiceRow(withNewServiceId: serviceId) {
        self.servicesSearchTextField.text = ""
        self.servicesSearchTextField.resignFirstResponder()
        self.tableView.reloadData()
      }
      //let item = filteredResults[itemPosition]
      //print("Item at position \(itemPosition): \(item.title)")
    }
  }
  
  @objc func warningTapped(_ sender: UITapGestureRecognizer) {
    print("warning")
  }
  
  @objc func cashTapped(_ sender: UITapGestureRecognizer) {
    guard let cashImageView = sender.view as? UIImageView else { return }
    cashImageView.image = cashImageView.image == #imageLiteral(resourceName: "cash_non_active") ? #imageLiteral(resourceName: "cash_active") : #imageLiteral(resourceName: "cash_non_active")
    self.presenter.servicesDetails[cashImageView.tag].cashPayment = (cashImageView.image == #imageLiteral(resourceName: "cash_active"))
  }
  
  @objc func notesTapped(_ sender: UITapGestureRecognizer) {
    guard let notesImageView = sender.view as? UIImageView else { return }
    let notesViewController = NotesPopup()
    let notesPopup = PopupDialog(viewController: notesViewController)
    let addNotesButton = PopupDialogButton(title: "Add Notes") {
      let notes = notesViewController.notesTextView.text!
      self.presenter.servicesDetails[notesImageView.tag].notes = notes
      notesImageView.image = notes.count != 0 ? #imageLiteral(resourceName: "notes_active") : #imageLiteral(resourceName: "notes_non_active")
    }
    let cancelButton = PopupDialogButton(title: "Cancel", action: nil)
    notesPopup.addButtons([addNotesButton, cancelButton])
    self.present(notesPopup, animated: true, completion: nil)
  }
  
  @objc func emergencyTapped(_ sender: UITapGestureRecognizer) {
    print("emergency")
  }
}

extension OrderCheckoutList {
  @IBAction func didPressSaveButton(sender: Any) {
    self.presenter.saveOrder { message in
      guard message.code == 1 else { return }
      for controller in self.navigationController!.viewControllers as Array {
        if controller.isKind(of: OverviewCollectionViewController.self) {
          _ =  self.navigationController!.popToViewController(controller, animated: true)
          self.navigationCoordinator?.movingBack()
          break
        }
      }
    }
  }
}

extension OrderCheckoutList: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.servicesDetails.count
  }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = orderCheckoutCellMaker(tableView, indexPath, presenter.servicesDetails[indexPath.row])    
    cell.warning.tag = indexPath.row
    cell.cash.tag = indexPath.row
    cell.notes.tag = indexPath.row
    cell.emergencyLevel.tag = indexPath.row
    cell.serviceQuantity.tag = indexPath.row
    cell.serviceQuantity.delegate = self
    cell.warning.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(warningTapped(_:))))
    cell.cash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cashTapped(_:))))
    cell.notes.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notesTapped(_:))))
    cell.emergencyLevel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emergencyTapped(_:))))
    
    cell.bmb.buttonEnum = .simpleCircle
    cell.bmb.piecePlaceEnum = .dot_3_1
    cell.bmb.buttonPlaceEnum = .sc_3_1
    cell.bmb.hasBackground = false
    for i in 0..<cell.bmb.piecePlaceEnum.pieceNumber() {
      let builder = SimpleCircleButtonBuilder.init()
      switch i {
      case 0: builder.normalImage = #imageLiteral(resourceName: "urgent_non_active")
      case 1: builder.normalImage = #imageLiteral(resourceName: "urgent_active")
      case 2: builder.normalImage = #imageLiteral(resourceName: "urgent_active_2")
      default: break
      }
      builder.pieceColor = UIColor.clear
      builder.normalColor = .white
      builder.round = false
      builder.imageSize = CGSize(width: 30, height: 30)
      builder.rotateImage = false
      builder.clickedClosure = { (index: Int) -> Void in
        switch index {
        case 0: cell.emergencyLevel.image = #imageLiteral(resourceName: "urgent_non_active")
        case 1: cell.emergencyLevel.image = #imageLiteral(resourceName: "urgent_active")
        case 2: cell.emergencyLevel.image = #imageLiteral(resourceName: "urgent_active_2")
        default: break
        }
        self.presenter.servicesDetails[indexPath.row].emergencyLevel = index
      }

      cell.bmb.addBuilder(builder)
    }
    return cell
  }
}

extension OrderCheckoutList: UITextFieldDelegate {
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return !textField.text!.isEmpty
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    presenter.servicesDetails[textField.tag].amount = textField.text!
  }
}
