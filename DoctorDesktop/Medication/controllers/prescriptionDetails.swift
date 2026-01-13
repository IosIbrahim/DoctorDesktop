//
//  prescriptionDetails.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/21/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class prescriptionDetails: UIViewController,NVActivityIndicatorViewable {

        var processinfocode1 = 0
    var ItemsDataRowlist = [ItemsDataRow]()
    var ItemsDataRowlistOfEditScreen = [ItemsDataRow]()

    var doseowlist = [DosesRow]()
    

    
    @IBOutlet weak var precritionDetailsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        precritionDetailsTableView.delegate = self
        precritionDetailsTableView.dataSource = self

//        let patient_id =  UserDefaults.standard.string(forKey: "patient_id")
//        let branch_id =  UserDefaults.standard.string(forKey: "branch_id")
        
//        let user_id = UserDefaults.standard.string(forKey: "userName")
        
//        let visit_id = UserDefaults.standard.string(forKey: "visit_id")
  
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
 
        let params = ["USER_ID":user_id,"BRANCH_ID":branch_id,"FLAG":"1","PATIENT_ID":
            patient_id,"PRESC_TYPE":self.processinfocode1,"VISIT_ID":visit_id] as [String : Any]

//                let params = ["USER_ID":"KHABEER","BRANCH_ID":"1","FLAG":"1","PATIENT_ID":
//                    "569","PRESC_TYPE":"1697","VISIT_ID":"3","HOSP_ID":"1"]
        
        print(params)
        
        
        apis.getPrescriptiondetails(params: params ) { data in

            print(data)
            print(data.root?.loadParams)
            
            self.ItemsDataRowlist =     (data.root?.itemsData?.itemsDataRow)!
//            self.doseowlist = data.root.itemsData.itemsDataRow.
            
            
//            self.precrilist = data
//            print(self.precrilist.count)
            self.precritionDetailsTableView.reloadData()
            
        }
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func searchAction(_ sender: Any) {
        
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchVC") as! searchVC
        self.present(vc, animated: false, completion: nil)
        
//        self.startAnimating( message: "Loading")


        
        
    }
    
    @IBAction func editAction(_ sender: Any) {

        
        if ItemsDataRowlistOfEditScreen.count > 0
        
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "editVC") as! editVC
            vc.ItemsDataRowlist = self.ItemsDataRowlistOfEditScreen
            self.present(vc, animated: false, completion: nil)

        }
        else{
            
            self.createAlert(title: "Waring", message: "Please Select an Item")
            
        }
        
        
        
    }
}
extension prescriptionDetails:UITableViewDelegate ,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
 return     self.ItemsDataRowlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "precriptionDetailsCell", for: indexPath) as? precriptionDetailsCell
        print("asjfklakfdsk;fnsadknfklsdnfksdnfksnfksdnklvnsdlksdllsd")
        print(self.ItemsDataRowlist[indexPath.row].itemenname)
        cell?.configureCell(vc: self,data: ItemsDataRowlist[indexPath.row])

        if  Int(ItemsDataRowlist[indexPath.row].hasBalance! ) == 0
        {
            cell?.extradoseLabel.isHidden = false
            cell?.name.textColor = #colorLiteral(red: 1, green: 0.2562306327, blue: 0.1151451593, alpha: 1)
        }
//        ItemsDataRowlist[indexPath.row].itemdosages?.itemdosagesRow?.id
        cell?.doseLabel.text = ItemsDataRowlist[indexPath.row].doses?.dosesRow?.dose
        cell?.checkBoxIcon.addTarget(self, action: #selector(chechBoxClikced(sender:)), for: .touchUpInside)
        cell?.checkBoxIcon.tag = (indexPath.section*100)+indexPath.row

        
        cell?.name.text = ItemsDataRowlist[indexPath.row].itemenname
        return cell!
    }
    
    @objc func  chechBoxClikced (sender:UIButton){
        
        
        let section = sender.tag / 100
        let row = sender.tag % 100
        let indexPath = NSIndexPath(row: row, section: section)
        if sender.isSelected{
            
            sender.isSelected = false
            
            
            let index = ItemsDataRowlistOfEditScreen.index(where: {$0.itemcode == ItemsDataRowlist[indexPath.row].itemcode })
            
            if index!  >= 0
            {
                ItemsDataRowlistOfEditScreen.remove(at: index!)
                
                
            }
            
        }
        else{
            
            sender.isSelected = true
          
            ItemsDataRowlistOfEditScreen.append(ItemsDataRowlist[indexPath.row])

        }
        self.precritionDetailsTableView.reloadData()
    }

}
class subclassedUIButton: UIButton {
    var indexPath: Int?
    var urlString: String?
}
extension UIViewController {
    
    func createAlert (title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        //CREATING ON BUTTON
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            print ("YES")
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
