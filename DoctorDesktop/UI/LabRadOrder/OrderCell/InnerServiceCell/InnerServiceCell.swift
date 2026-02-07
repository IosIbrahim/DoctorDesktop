//
//  InnerServiceCell.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 03/02/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit
protocol ServiceSelectProtocol {
    func setServiceSelect(_ index:Int)
    func showInstruction(_ hint:String)

}

class InnerServiceCell: UICollectionViewCell {

    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var btnSelected: UIButton!
    
    var itemIndex:Int = .zero
    var delegate:ServiceSelectProtocol?
    var isSelectedServices:Bool = false
    var hint:String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func selectOnTap(_ sender: Any) {
        isSelectedServices = !isSelectedServices
        setSelect()
        delegate?.setServiceSelect(itemIndex)
    }
    
    
    @IBAction func hintOnTap(_ sender: Any) {
        delegate?.showInstruction(hint)
    }
    
    func setSelect() {
        btnSelected.setImage(UIImage(named: isSelectedServices ? "checked":"unchecked"), for: .normal)
    }
    
    func drawCell(with presenter: InnerOrderCellPresenter) {
        lblService.text = presenter.title
        isSelectedServices = presenter.isSelect
        hint = presenter.hint
        btnHint.isHidden = hint.isEmpty
        lblService.adjustsFontSizeToFitWidth = true
        setSelect()
    }
    
}


//MARK: - Helper Methods
extension InnerServiceCell {
  public static var cellId: String {
    return "InnerServiceCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: InnerServiceCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: InnerServiceCell.cellId, bundle: InnerServiceCell.bundle)
  }
  
  public static func register(with collectionView: UICollectionView) {
    collectionView.register(InnerServiceCell.nib, forCellWithReuseIdentifier: InnerServiceCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> InnerServiceCell {
    return bundle.loadNibNamed(InnerServiceCell.cellId, owner: owner, options: nil)?.first as! InnerServiceCell
  }
  
  public static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath, with presenter: InnerOrderCellPresenter) -> InnerServiceCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InnerServiceCell.cellId, for: indexPath) as! InnerServiceCell
      cell.itemIndex = indexPath.row
    cell.drawCell(with: presenter)
    return cell
  }
}
