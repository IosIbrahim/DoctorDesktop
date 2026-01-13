//
//  ChatCell.swift
//  DoctorDesktop
//
//  Created by Khabber on 22/11/2021.
//  Copyright © 2021 khabeer Group. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var LabelDoctorMessage: UILabel!
    
    @IBOutlet weak var labelDoctorName: UILabel!
    @IBOutlet weak var LabelNurseMessage: UILabel!
    
    @IBOutlet weak var labelNurseName: UILabel!
    
    
    @IBOutlet weak var nurseView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func configure (_ object:ListOfDoctorNurseMessages){
        
       
        print("object.REPLY")
        labelDoctorName.text = object.EMP_NAME_EN
        LabelDoctorMessage.text = object.DESC_EN
        print(object.REPLY)
        
 

       if object.REPLY != nil
        {
           nurseView.isHidden = false
           labelNurseName.text = object.REPLY?.REPLY_ROWOb?.USER_ENTER_NAME_EN ?? ""
           LabelNurseMessage.text = object.REPLY?.REPLY_ROWOb?.REPLY_DESC ?? ""
       }
        else
        {
            nurseView.isHidden = true

        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
