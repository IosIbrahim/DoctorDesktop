//
//  editVC.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/25/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit

class editVC: UIViewController {

    
    var ItemsDataRowlist = [ItemsDataRow]()
    @IBOutlet weak var itemRowsList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        print(ItemsDataRowlist)
        itemRowsList.delegate = self
        itemRowsList.dataSource = self
        itemRowsList.reloadData()
        
    }

}
extension editVC:UITableViewDelegate ,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return     self.ItemsDataRowlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as? editCell

        cell?.cLal.text = ItemsDataRowlist[indexPath.row].itemenname
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cell = tableView.cellForRow(at: indexPath) as! editCell
        if cell.backgview.isHidden == true
        {
            cell.backgview.isHidden == false
        }
        else
        {
            cell.backgview.isHidden == true

        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @objc func  chechBoxClikced (sender:UIButton){
        
        if sender.isSelected{
            
            sender.isSelected = false
            
        }
        else{
            
            sender.isSelected = true
        }
        self.itemRowsList.reloadData()
    }
    
}
