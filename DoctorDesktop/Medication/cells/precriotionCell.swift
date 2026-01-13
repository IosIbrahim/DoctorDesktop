//
//  precriotionCell.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/18/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit

class precriotionCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 
    @IBOutlet weak var name: UILabel!


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(vc : UIViewController , data: precrition)
    {
      print("from cell")
        print(data)
//        name.text = data.
        
    }

}
