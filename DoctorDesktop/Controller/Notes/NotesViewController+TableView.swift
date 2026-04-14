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
    }

    func initTable() {
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight       = UITableView.automaticDimension
        tableView.reloadData()
    }
}
