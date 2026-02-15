//
//  OrderCollectionViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/6/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import DropDown
import SideMenu
import Toastlity
import NVActivityIndicatorView

class OrderCollectionViewController: UIViewController, NVActivityIndicatorViewable {
  @IBOutlet weak var collectioView: UICollectionView!
  @IBOutlet weak var dropDownView: UIView!
  @IBOutlet weak var selectionTitleLabel: UILabel!
  
    @IBOutlet weak var btnNext: UIButton!
    private var presenter: OrderCollectionPresenter!
  private var orderCellMaker: DependencyRegistry.OrderCellMaker!
  private weak var navigationCoordinator: NavigationCoordinator?
  lazy var toastBar: ToastBar = .init(settings: .agent, in: parent?.view)
    
  let dropDown = DropDown()
  var selectedTemplateIndex = 0
    var expandedItemIndex:Int = 200

  func configure(with presenter: OrderCollectionPresenter,
                 orderCellMaker: @escaping DependencyRegistry.OrderCellMaker,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.orderCellMaker = orderCellMaker
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
//    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu_icon"), style: .plain, target: self, action: #selector(didPressMenu))

    switch presenter.templateType {
        case .labOrder: title = "Lab Order"
        case .radOrder: title = "Rad Order"
    }
      OrderCell.register(with: collectioView)
      NewOrderCell.register(with: collectioView)
    dropDownView.layer.cornerRadius = 10
    startAnimating(message: "Load Template...")
    btnNext.layer.cornerRadius = 10
    presenter.getTemplate() {
      self.setupDropDownMenu(dropDown: self.dropDown)
      self.selectionTitleLabel.text = self.presenter.template?.serviceTemplates.first?.name
      self.collectioView.reloadData()
      self.stopAnimating()
    }
  }

  @objc func didPressMenu() {
    self.navigationController?.popViewController(animated: true)
//    present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
  }

  @IBAction func didPressDownArrow(sender: Any) {
    dropDown.show()
  }
    
    @IBAction func nextOnTap(_ sender: Any) {
        if let tem  = presenter.template {
            if var first = tem.servicesCategories.first {
                for item in tem.servicesCategories {
                    if item.isSelect {
                        first = item
                        break
                    }
                }
                var servises = [Service]()
                for item in tem.servicesCategories {
                    for ser in item.services ?? [] {
                        if ser.isSelected {
                            servises.append(ser)
                        }
                    }
                }
                first.services = servises
                if !servises.isEmpty {
                    let args = ["patient": presenter.patient,
                                "serviceCategory": first,
                                "templateType": self.presenter.templateType,
                                "generalParams": tem.generalParams,
                                "user": presenter.user] as [String : Any]
                    navigationCoordinator?.next(arguments: args)
                }else {
                    toastBar.show(with: "Please Choose Services")
                }
            }
            
        }
       
    }
    
}

extension OrderCollectionViewController {
  fileprivate func setupDropDownMenu(dropDown: DropDown) {
    // The view to which the drop down will appear on
    dropDown.anchorView = dropDownView // UIView or UIBarButtonItem
    // The list of items to display. Can be changed dynamically
    if let serviceTemplates = presenter.template?.serviceTemplates {
      dropDown.dataSource = serviceTemplates.compactMap() { template in
        return template.name
      }
    }
    // Action triggered on selection
    dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
      self.didSelectTemplate(atIndex: index)
    }
    dropDown.direction = .bottom
    // Top of drop down will be below the anchorView
    dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
    dropDown.backgroundColor = .white
    dropDown.selectionBackgroundColor = .lightGray
  }
}

extension OrderCollectionViewController {
    fileprivate func didSelectTemplate(atIndex index: Int) {
      guard selectedTemplateIndex != index else { return }
      selectionTitleLabel.text = self.presenter.template?.serviceTemplates[index].name
      self.selectedTemplateIndex = index
      
      if let templateId = presenter.template?.serviceTemplates[index].id {
        presenter.getTemplate(withTemplateId: templateId) {
          self.collectioView.reloadData()
        }
      }
      
    }
}

extension OrderCollectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return presenter.template?.servicesCategories.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let labOrderCellPresenter = OrderCellPresenterImpl(withSericeCategory: presenter.template!.servicesCategories[indexPath.row])
      let cell = NewOrderCell.dequeue(from: collectionView, for: indexPath, with: labOrderCellPresenter)
      cell.itemIndex = indexPath.row
      cell.delegate = self
    return cell
  }
}

extension OrderCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let labOrderCellPresenter = OrderCellPresenterImpl(withSericeCategory: presenter.template!.servicesCategories[indexPath.row])
      let width = collectionView.bounds.width - 10
      if labOrderCellPresenter.services.isEmpty {
          return CGSize(width: (collectionView.bounds.width) - 10, height: 60)
      }else {
          if indexPath.row == expandedItemIndex {
              let hight = CGFloat (labOrderCellPresenter.services.count  * 35 + 60 )
              return CGSize(width: width, height: hight)
          }else {
              return CGSize(width: width, height: 130)
          }
      }
  }
}

extension OrderCollectionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let args = ["patient": presenter.patient,
//                "serviceCategory": self.presenter.template!.servicesCategories[indexPath.row],
//                "templateType": self.presenter.templateType,
//                "generalParams": self.presenter.template!.generalParams,
//                "user": presenter.user] as [String : Any]
//    
   // navigationCoordinator?.next(arguments: args)
  }
}

extension OrderCollectionViewController:ServiceCategorySelectProtocol {
    func setServiceCategorySelect(_ index:Int,services:[Service]) {
        var isServicesSelect = true
        for item in services {
            if !item.isSelected {
                isServicesSelect = false
                break
            }
        }
        let isselect = isServicesSelect
        presenter.template?.servicesCategories[index].isSelect = isServicesSelect
        presenter.template?.servicesCategories[index].services = services
        
        collectioView.reloadData()
    }
    
    func showServiceInstruction( _ info:String) {
        // show info
        toastBar.show(with: info)
    }
    
    func setExpanded(_ index:Int) {
        if index != expandedItemIndex {
            expandedItemIndex = index
        }else {
            expandedItemIndex = 200
        }
        collectioView.reloadData()
    }
}
