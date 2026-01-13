//
//  NotesViewController.swift
//  DoctorDesktop
//
//  Created by Khabber on 22/11/2021.
//  Copyright © 2021 khabeer Group. All rights reserved.
//

import UIKit
import Reachability
import ObjectMapper
class NotesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var viewSend: UIView!
    @IBOutlet weak var viewUrgent: UIView!
    @IBOutlet weak var viewMediciese: UIView!

    var messages = [ListOfDoctorNurseMessages]()
    var NURSE_REMARKS_PRIORITY_List = [NURSE_REMARKS_PRIORITY_ROW]()
    var NURSE_REMARKS_SHOW_D_N_List = [NURSE_REMARKS_SHOW_D_N]()

    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUi()
        callAPI()
   
        viewUrgent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewUrgentFunc)))
        
        viewMediciese.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMedicieseFunc)))
        viewSend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSendFunc)))
    }

    @objc func viewUrgentFunc(sender : UITapGestureRecognizer) {
        AppPopUpHandler.instance.initListPopup( container: self, arrayNames: self.NURSE_REMARKS_PRIORITY_List.map{$0.NAME_AR}, title: "اختار نوع الشكوي", type: "complaintTypeList")
    }
    
    @objc func viewMedicieseFunc(sender : UITapGestureRecognizer) {
        AppPopUpHandler.instance.initListPopup( container: self, arrayNames: self.NURSE_REMARKS_SHOW_D_N_List.map{$0.NAME_AR}, title: "اختار نوع الشكوي", type: "complaintTypeList")
    }
    
    
    @objc func viewSendFunc(sender : UITapGestureRecognizer) {
       send()
        
    }
    
    func callAPI(){

        guard let branch_id: String = UserDefaults.standard.string(forKey: "branch_id")as? String else {

            return
        }
        guard let user_id: String = UserDefaults.standard.string(forKey: "userName")as? String else {
            
            return
        }
        guard let visit_id: String = UserDefaults.standard.string(forKey: "visit_id")as? String else {
            
            return
        }
        
        guard let patient_id: String =  UserDefaults.standard.string(forKey: "patient_id")  as? String else {
            
            return
        }
        
//    http://192.168.1.203/MobileApi/api/MedicalRcordController/DDDocNurseNotesLoad?PATIENT_ID=552             &USER_ID=KHABEER&BRANCH_ID=1&COMPUTER_NAME=ios&USER_OPEN_FLAG=D&TYPE_FLAG=1&Lang=en"
        let pars = "PATIENT_ID="+"\(patient_id)"+"&USER_ID=\(user_id)" + "&BRANCH_ID=\(branch_id)" + "&COMPUTER_NAME=ios" + "&USER_OPEN_FLAG=D" + "&TYPE_FLAG=1" + "&Lang=en"
      
        var urlString = Constants.APIProvider.DDDocNurseNotesLoad+pars
        urlString =   urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!

        
    
        
        WebserviceMananger.sharedInstance.makeCall(method: .get, url: urlString, parameters: nil, vc: self) { (data, error) in
            
            if error == nil
            {
                 if let root = ((data as! [String: AnyObject])["Root"] as! [String:AnyObject])["DOCTOR_NURSE_REMARKS"] as? [String:AnyObject]
                {
                    
               
                    
                    if root["DOCTOR_NURSE_REMARKS_ROW"] is [[String:AnyObject]]
                    {
                    
                    let appoins = root["DOCTOR_NURSE_REMARKS_ROW"] as! [[String: AnyObject]]
                    for i in appoins
                    {
                        print(i)
                        self.messages.append(ListOfDoctorNurseMessages(JSON: i)!)
                      
                        
                    }
                    }
                    else if root["DOCTOR_NURSE_REMARKS_ROW"] is [String:AnyObject]
                    {
                        self.messages.append(ListOfDoctorNurseMessages(JSON:root["DOCTOR_NURSE_REMARKS_ROW"] as![String:AnyObject] )!)
                     
                    }
                   
                     self.tableView.reloadData()
                }
             
                else
                 {
                }
                
                
                if let root = ((data as! [String: AnyObject])["Root"] as! [String:AnyObject])["NURSE_REMARKS_PRIORITY"] as? [String:AnyObject]
               {
                   
              
                   
                   if root["NURSE_REMARKS_PRIORITY_ROW"] is [[String:AnyObject]]
                   {
                   
                   let appoins = root["NURSE_REMARKS_PRIORITY_ROW"] as! [[String: AnyObject]]
                   for i in appoins
                   {
                       print(i)
                       self.NURSE_REMARKS_PRIORITY_List.append(NURSE_REMARKS_PRIORITY_ROW(JSON: i)!)
                     
                       
                   }
                   }
                   else if root["NURSE_REMARKS_PRIORITY_ROW"] is [String:AnyObject]
                   {
                       self.NURSE_REMARKS_PRIORITY_List.append(NURSE_REMARKS_PRIORITY_ROW(JSON:root["NURSE_REMARKS_PRIORITY_ROW"] as![String:AnyObject] )!)
                    
                   }
                  
               }
            
               else
                {
               }
                
              
                
                if let root = ((data as! [String: AnyObject])["Root"] as! [String:AnyObject])["NURSE_REMARKS_SHOW_D_N"] as? [String:AnyObject]
               {
                   
              
                   
                   if root["NURSE_REMARKS_SHOW_D_N_ROW"] is [[String:AnyObject]]
                   {
                   
                   let appoins = root["NURSE_REMARKS_SHOW_D_N_ROW"] as! [[String: AnyObject]]
                   for i in appoins
                   {
                       print(i)
                       self.NURSE_REMARKS_SHOW_D_N_List.append(NURSE_REMARKS_SHOW_D_N(JSON: i)!)
                     
                       
                   }
                   }
                   else if root["NURSE_REMARKS_SHOW_D_N_ROW"] is [String:AnyObject]
                   {
                       self.NURSE_REMARKS_SHOW_D_N_List.append(NURSE_REMARKS_SHOW_D_N(JSON:root["NURSE_REMARKS_SHOW_D_N_ROW"] as![String:AnyObject] )!)
                    
                   }
                  
               }
            
               else
                {
               }
                
                
                
                
                
                
               
            }

        }
    }
    func sendMessage() {
        
        guard let branch_id: String = UserDefaults.standard.string(forKey: "branch_id")as? String else {

            return
        }
        guard let user_id: String = UserDefaults.standard.string(forKey: "userName")as? String else {
            
            return
        }
        guard let visit_id: String = UserDefaults.standard.string(forKey: "visit_id")as? String else {
            
            return
        }
        
        guard let patient_id: String =  UserDefaults.standard.string(forKey: "patient_id")  as? String else {
            
            return
        }
        
  
        
        let pars = ["SI":["BranchID":branch_id,"ComputerName":"android","LanguageID":2,"UserID":user_id],"DD_UC_PARMS":["PATIENT_ID":patient_id,"VISIT_ID":visit_id,"PROCESS_ID":"994","TRACER_PLACE_ID":"98","USER_OPEN_FLAG":"D"],"DOCTOR_NURSE_REMARKS":["BUFFER_STATUS":"1","PRIORITY_TYPE":2,"SHOW_D_N":1,"VISIT_ID":"4","DESC_EN":textView.text ?? ""]]
                    as! [String : Any]
        
      
        let urlString = Constants.APIProvider.sendMessage
        let url = URL(string: urlString)
        let parseUrl = Constants.APIProvider.sendMessage + Constants.getoAuthValue(url: url!, method: "POST")
        WebserviceMananger.sharedInstance.makeCall(method: .post, url: urlString, parameters: pars, vc: self) { (data, error) in
            let root = (data as! [String:AnyObject])["Root"] as! [String: AnyObject]
            if root.keys.contains("OUT_PARMS")
            {
                let messageRow = (root["OUT_PARMS"] as! [String: AnyObject])["OUT_PARMS_ROW"] as! [String : AnyObject]
                
//                let englishMsg = messageRow["SER"] as! String
                Utilities.showSuccessAlert(self, messageToDisplay:"Appointment has been cancelled successfuly")
                
            }
        }
    }
    
    
    func send() {
        guard let branch_id: String = UserDefaults.standard.string(forKey: "branch_id")as? String else {

            return
        }
        guard let user_id: String = UserDefaults.standard.string(forKey: "userName")as? String else {
            
            return
        }
        guard let visit_id: String = UserDefaults.standard.string(forKey: "visit_id")as? String else {
            
            return
        }
        
        guard let patient_id: String =  UserDefaults.standard.string(forKey: "patient_id")  as? String else {
            
            return
        }
        
        let pars = ["SI":["BranchID":branch_id,"ComputerName":"android","LanguageID":2,"UserID":user_id],"DD_UC_PARMS":["PATIENT_ID":patient_id,"VISIT_ID":visit_id,"PROCESS_ID":"994","TRACER_PLACE_ID":"98","USER_OPEN_FLAG":"D"],"DOCTOR_NURSE_REMARKS":["BUFFER_STATUS":"1","PRIORITY_TYPE":2,"SHOW_D_N":1,"VISIT_ID":"4","DESC_EN":textView.text ?? ""]]
                    as! [String : Any]
        
      
        let urlString = Constants.APIProvider.sendMessage
        AppConnectionsHandler.post(url: urlString, params: pars, type: String.self) { (status, model, error) in
            switch status {
            case .sucess:
              
                break
            case .error:
              
                break
            }
        }
    }

}

struct ListOfDoctorNurseMessages : Mappable {
    var DESC_EN : String = ""
    var EMP_NAME_EN : String = ""
    var REPLY :nurseMessage?
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        
        DESC_EN <- map["DESC_EN"]
        REPLY <- map["REPLY"]
        
        EMP_NAME_EN <- map["EMP_NAME_EN"]

    }
    
}


struct nurseMessage : Mappable {
    var REPLY_ROWOb:REPLY_ROW?
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        REPLY_ROWOb <- map["REPLY_ROW"]
  
    }
    
}

struct REPLY_ROW : Mappable {
    var REPLY_DESC : String = ""
    var USER_ENTER_NAME_EN : String = ""
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        REPLY_DESC <- map["REPLY_DESC"]
        USER_ENTER_NAME_EN <- map["USER_ENTER_NAME_EN"]
     
    }
}




struct NURSE_REMARKS_PRIORITY_ROW : Mappable {
    var NAME_EN : String = ""
    var ID : String = ""

    var NAME_AR : String = ""
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        NAME_EN <- map["NAME_EN"]
        NAME_AR <- map["NAME_AR"]
        ID <- map["ID"]

    }
}

struct NURSE_REMARKS_SHOW_D_N : Mappable {
    var NAME_EN : String = ""
    var ID : String = ""

    var NAME_AR : String = ""
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        NAME_EN <- map["NAME_EN"]
        NAME_AR <- map["NAME_AR"]
        ID <- map["ID"]

    }
}


