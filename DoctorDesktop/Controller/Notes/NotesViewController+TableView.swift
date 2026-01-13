//
//  NotesViewController+TableView.swift
//  DoctorDesktop
//
//  Created by Khabber on 22/11/2021.
//  Copyright © 2021 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

extension NotesViewController :UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "ChatCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ChatCell
        cell.configure(messages[indexPath.row])
        return cell
    }
    
    func setupUi()
    {
        initTable()
    }
    
    func initTable() {


        let nib1 = UINib(nibName: "ChatCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "ChatCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()


       
    }
    
    
    
    
}
