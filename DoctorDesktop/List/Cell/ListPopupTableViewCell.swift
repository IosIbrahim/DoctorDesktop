//
//  ListPopupTableViewCell.swift
//  nasTrends
//
//  Created by Mohamed Elmaazy on 2/5/19.
//  Copyright © 2019 Mohamed Elmaazy. All rights reserved.
//

import UIKit

class ListPopupTableViewCell: UITableViewCell {

    @IBOutlet weak var constraintLeadingLabel: NSLayoutConstraint!
    @IBOutlet weak var labelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        labelName.font = UIFont.systemFont(ofSize: 18, weight: .regular)
//        constraintLeadingLabel.update(15)
    }
    
    func setData(name: String) {
        labelName.text = name
    }
}
