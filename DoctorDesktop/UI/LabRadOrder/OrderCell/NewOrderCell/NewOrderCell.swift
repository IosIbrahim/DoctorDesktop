//
//  NewOrderCell.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 03/02/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

protocol ServiceCategorySelectProtocol {
    func setServiceCategorySelect(_ index:Int,services:[Service])
    func showServiceInstruction( _ info:String)
    func setExpanded(_ index:Int)
}

class NewOrderCell: UICollectionViewCell {

    @IBOutlet weak var clcServices: UICollectionView!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var btnChecked: UIButton!
    
    var isSelectedServices:Bool = false
    var dataSources = [Service]()
    var prsernter:OrderCellPresenter!
    var itemIndex:Int = .zero
    var delegate:ServiceCategorySelectProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clcServices.delegate = self
        clcServices.dataSource = self
        InnerServiceCell.register(with: clcServices)

    }
    
    @IBAction func checkOnTap(_ sender: Any) {
        isSelectedServices = !isSelectedServices
        setSelect()
        delegate?.setServiceCategorySelect(itemIndex,services: dataSources)
    }
    
    func setSelect() {
        btnChecked.setImage(UIImage(named: isSelectedServices ? "checked":"unchecked"), for: .normal)
        for (i,item) in dataSources.enumerated() {
            dataSources[i].isSelected = isSelectedServices
            print(item)
        }
    }
    
    @IBAction func viewAllOnTap(_ sender: Any) {
        print("View All")
        delegate?.setExpanded(itemIndex)
    }
    
    
    
    
    func drawCell(with presenter: OrderCellPresenter) {
        lblService.text = presenter.title
        isSelectedServices = presenter.isSelected
        setSelect()
        dataSources = presenter.services
        self.prsernter = presenter
        btnViewAll.isHidden = dataSources.isEmpty
        clcServices.isHidden = dataSources.isEmpty
        clcServices.reloadData()
    }
    
}


class OrderPicker:UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
    }
}


class ServicePicker:UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blue.withAlphaComponent(0.8).cgColor
    }
}


extension NewOrderCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return dataSources.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let labOrderCellPresenter = OrderIneerCellPresenterImpl(withSerice: dataSources[indexPath.row])
      let cell = InnerServiceCell.dequeue(from: collectionView, for: indexPath, with: labOrderCellPresenter)
      cell.delegate = self
      return cell
  }
}

extension NewOrderCell: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.bounds.width / 2) - 10, height: 60)
  }
}

extension NewOrderCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let args = ["patient": presenter.patient,
//                "serviceCategory": self.presenter.template!.servicesCategories[indexPath.row],
//                "templateType": self.presenter.templateType,
//                "generalParams": self.presenter.template!.generalParams,
//                "user": presenter.user] as [String : Any]
//    
//    navigationCoordinator?.next(arguments: args)
  }
}

extension NewOrderCell: ServiceSelectProtocol {
    func setServiceSelect(_ index:Int) {
        dataSources[index].isSelected = !dataSources[index].isSelected
        clcServices.reloadData()
        delegate?.setServiceCategorySelect(itemIndex,services: dataSources)
    }
    
    func showInstruction(_ hint:String) {
        delegate?.showServiceInstruction(hint)
    }
}



//MARK: - Helper Methods
extension NewOrderCell {
  public static var cellId: String {
    return "NewOrderCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: NewOrderCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: NewOrderCell.cellId, bundle: NewOrderCell.bundle)
  }
  
  public static func register(with collectionView: UICollectionView) {
    collectionView.register(NewOrderCell.nib, forCellWithReuseIdentifier: NewOrderCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> NewOrderCell {
    return bundle.loadNibNamed(NewOrderCell.cellId, owner: owner, options: nil)?.first as! NewOrderCell
  }
  
  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: OrderCellPresenter) -> NewOrderCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewOrderCell.cellId, for: indexPath) as! NewOrderCell
    cell.drawCell(with: presenter)
    return cell
  }
}
