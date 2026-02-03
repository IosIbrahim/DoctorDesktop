//
//  NewOrderCell.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 03/02/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

class NewOrderCell: UICollectionViewCell {

    @IBOutlet weak var clcServices: UICollectionView!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var btnChecked: UIButton!
    
    var isSelectedServices:Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    @IBAction func checkOnTap(_ sender: Any) {
        isSelectedServices = !isSelectedServices
        btnChecked.setImage(UIImage(named: isSelectedServices ? "checked":"rightIconn"), for: .normal)
    }
    
    @IBAction func viewAllOnTap(_ sender: Any) {
        print("View All")
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
