//
//  searchVC.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/23/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class searchVC: UIViewController ,NVActivityIndicatorViewable{

    @IBOutlet weak var selectedItemsButtonCount: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minsButton: UIButton!
    @IBOutlet weak var pageCountLal: UILabel!
    @IBOutlet weak var tableViewSearch: UITableView!
    @IBOutlet weak var maniView: UIView!
    
    var selectedItemsIDs = [String]()
    var processinfocode1 = 0
    var ItemsRowlist = [ItemsRow]()
    var selectedItemsRowlist = [ItemsRow]()

    var doseowlist = [DosesRow]()
    var indexFrom = 0
    var indexTo = 15
    var pageNumber = 1
    
    var params:[String:Any] = [:]
 
    override func viewWillAppear(_ animated: Bool) {
        
        
self.setCountSelectElementButton()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCountSelectElementButton()
      

        tableViewSearch.delegate = self
        tableViewSearch.dataSource = self
        tableViewSearch.rowHeight = UITableViewAutomaticDimension
        tableViewSearch.estimatedRowHeight = 600
//        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

   
        self.loadDate()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func plusPage(_ sender: Any) {

        self.indexFrom += 15
        self.indexTo += 15
    self.pageNumber += 1

        self.loadDate()

   
    }
    
    @IBAction func minsPage(_ sender: Any) {
        self.indexFrom -= 15
        self.indexTo -= 15
     self.pageNumber -= 1

        self.loadDate()

    }
    
    @IBAction func closeCliked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

        
    }
    func loadDate()  {
        
        guard let branch_id: String = UserDefaults.standard.string(forKey: "branch_id") else {
            
            return
        }
        guard let user_id: String = UserDefaults.standard.string(forKey: "userName") else {
            
            return
        }
        guard let visit_id: String = UserDefaults.standard.string(forKey: "visit_id") else {
            
            return
        }
        
        guard let patient_id: String =  UserDefaults.standard.string(forKey: "patient_id") else {
            
            return
        }
        guard let searchText: String = self.searchTextField.text else {
            
            return
        }
        
        self.startAnimating(message: "Looding.....")
        
        
        
        if self.searchTextField.text == ""
        {
            params = ["INDEX_FROM":self.indexFrom,"INDEX_TO":self.indexTo,"ORDERBY":2,"USER_ID":user_id,"BRANCH_ID":branch_id,"PATIENT_ID":
                patient_id,"PRESC_ITEM":1,"SEARCH_TEXT":" ","VISIT_ID":visit_id] as [String : Any]
            
        }
        else{
            
            print(searchText)
            params = ["INDEX_FROM":self.indexFrom,"INDEX_TO":self.indexTo,"ORDERBY":2,"USER_ID":user_id,"BRANCH_ID":branch_id,"PATIENT_ID":
                patient_id,"PRESC_ITEM":1,"SEARCH_TEXT":searchText,"VISIT_ID":visit_id] as [String : Any]
        }
 
        apis.getSearchResultInprecription(params: params ) { data in
            
         
            if self.indexFrom <= 0 {
                
                self.minsButton.isHidden = true
            }
            else {
                
                self.minsButton.isHidden = false

            }

            self.stopAnimating()
            if let dataConstant = data{
            self.ItemsRowlist  = dataConstant.items.itemsRow
            self.pageCountLal.text = String( self.pageNumber) + " Of " +    Float(Int(self.ItemsRowlist[0].pagesCount)! / 15 + 1) .clean

            print(self.ItemsRowlist[0].pagesCount)
            if self.indexTo >= Int(self.ItemsRowlist[0].pagesCount)!{
                
                self.plusButton.isHidden = true
            }
            else {
                
                self.plusButton.isHidden = false
                
            }

            self.tableViewSearch.reloadData()
        }
            else{
                self.pageCountLal.text = "No Data Found "
                self.ItemsRowlist  = []

                self.plusButton.isHidden = true
                self.minsButton.isHidden = true

                self.tableViewSearch.reloadData()

            }
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.loadDate()
    }
    
    @IBAction func selectedItemCountCliked(_ sender: Any) {
        print(selectedItemsRowlist)
        
        self.ItemsRowlist = selectedItemsRowlist
        tableViewSearch.reloadData()
    }
    func setCountSelectElementButton(){
        
        print(selectedItemsRowlist.count)
    

selectedItemsButtonCount.setTitle(String(selectedItemsRowlist.count), for: UIControlState.normal)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension searchVC:UITableViewDelegate ,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return     self.ItemsRowlist.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? searchCell
        print("asjfklakfdsk;fnsadknfklsdnfksdnfksnfksdnklvnsdlksdllsd")
        
        if selectedItemsIDs.contains(ItemsRowlist[indexPath.row].id)
        {
                        let backgroundView = UIView()
                        backgroundView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                        cell?.backgroundView = backgroundView
            
            cell?.button.isHidden = false
            
        }
        else{
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell?.backgroundView = backgroundView
//            cell?.button.isHidden = false

        }
      
        cell?.cLal.text = ItemsRowlist[indexPath.row].nameEn
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print(selectedItemsIDs)
        
        let cell = tableView.cellForRow(at: indexPath) as! searchCell
        
        if selectedItemsIDs.contains(ItemsRowlist[indexPath.row].id)
        {
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.backgroundView = backgroundView
            
            cell.button.isHidden = true

            let index = selectedItemsRowlist.index(where: {$0.id == ItemsRowlist[indexPath.row].id })
            
            if index!  >= 0
                        {
                            selectedItemsRowlist.remove(at: index!)

                            selectedItemsIDs.remove(at: index!)

                        }
            setCountSelectElementButton()
            

        }
        else{
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            cell.backgroundView = backgroundView
            self.selectedItemsRowlist.append(ItemsRowlist[indexPath.row])

            selectedItemsIDs.append(ItemsRowlist[indexPath.row].id)
            setCountSelectElementButton()
            cell.button.isHidden = false

            
        }
        

        
    }

    
}

@IBDesignable
class RoundUIView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}
extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
