//
//  precriptionDetailsCell.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/22/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit

class precriptionDetailsCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var doseLabel: UILabel!
    @IBOutlet weak var checkBoxIcon: subclassedUIButton!
    @IBOutlet weak var extradoseLabel: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(vc : UIViewController , data: ItemsDataRow)
    {
        print("from cell")
        print(data)
        name.text  = data.itemenname
        
        //        name.text = data.
        
    }
}
