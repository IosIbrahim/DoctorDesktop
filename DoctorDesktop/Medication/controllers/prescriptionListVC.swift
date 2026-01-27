//
//  prescriptionListVC.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/18/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit

class prescriptionListVC: UIViewController {
    
    var user = User.self
    var processinfocode1 = 0

    var precrilist = [precrition]()
    
    @IBOutlet weak var precritionTableView: UITableView!
    let params = ["USER_ID":"khabeer","BRANCH_ID":"1","PROCESS_ID":"99086","OBJECT_ID":"4157"]
    override func viewDidLoad() {
        

        precritionTableView.delegate = self
        precritionTableView.dataSource = self
        
        print()
        
        apis.getPrescriptionDate(params: params) { data in
            
//            print(data)
            self.precrilist = data
            print(self.precrilist.count)
            self.precritionTableView.reloadData()

        }
    }
    
    
}
extension prescriptionListVC:UITableViewDelegate ,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("sssss")
        print(precrilist)
     return   self.precrilist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
           let cell = tableView.dequeueReusableCell(withIdentifier: "precriotionCell", for: indexPath) as? precriotionCell
        print(precrilist[indexPath.row])
        cell?.configureCell(vc: self,data: precrilist[indexPath.row])

        cell?.name.text = precrilist[indexPath.row].englishName
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "prescriptionDetails") as? prescriptionDetails
        if let model = precrilist[indexPath.row].processinfocode {
            processinfocode1 = model
            vc?.processinfocode1 = model
        }
        self.navigationController?.pushViewController(vc!, animated: true)
        
      
        
    }
    
    
    
    
    
}
