//
//  NotesViewController+TableView.swift
//  DoctorDesktop
//
//  Created by Khabber on 22/11/2021.
//  Copyright © 2021 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as? ChatCell else {
            return UITableViewCell()
        }
        cell.configure(messages[indexPath.row])
        return cell
    }

    func setupUi() {
        initTable()
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "ic-more"), for: .normal)
        button.addTarget(self, action:#selector(callMethod), for: .touchDragInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barButton]

    }
    
    @objc func callMethod() {
        //do stuff here
       // self.navigationController?.pushViewController(HTMLEditController(), animated: true)
        let vc = NotScrollableEditorViewController()
        vc.html = "you want to change"
        self.navigationController?.pushViewController(vc, animated: true)

        
     }

    
    func initTable() {
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight       = UITableViewAutomaticDimension
        tableView.reloadData()
    }
}
