//
//  HelpCell.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 26/03/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

class HelpCell: UITableViewCell {

    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var pickerContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func drawCell(_ title:String) {
        lblHelp.text = title
        pickerContainer.layer.cornerRadius = 8
    }
}
