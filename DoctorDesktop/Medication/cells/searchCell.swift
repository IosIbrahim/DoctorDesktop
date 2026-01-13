//
//  searchCell.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/23/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit

class searchCell: UITableViewCell {

    @IBOutlet weak var cLal: UILabel!
    @IBOutlet weak var backgroundManiView: UIView!
    @IBOutlet weak var button: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
