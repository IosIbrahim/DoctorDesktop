//
//  precriotionCell.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/18/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit

class precriotionCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCell(vc: UIViewController, data: precrition) {
        name.text = data.englishName
    }
}
