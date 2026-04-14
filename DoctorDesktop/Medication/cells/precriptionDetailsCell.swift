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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCell(vc: UIViewController, data: ItemsDataRow) {
        name.text = data.itemenname
    }
}
