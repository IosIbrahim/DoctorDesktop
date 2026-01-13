//
//  ListPopupViewControllerExtensions.swift
//  nasTrends
//
//  Created by Mohamed Elmaazy on 2/5/19.
//  Copyright © 2019 Mohamed Elmaazy. All rights reserved.
//

import Foundation
import UIKit
import MZFormSheetController

extension ListPopupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func initTableView() {
        tableView.register("ListPopupTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNames.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 55
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "ListPopupTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ListPopupTableViewCell
        cell.selectionStyle = .none
        cell.setData(name: arrayNames[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mz_dismissFormSheetController(animated: true) { (_) in
            self.listPopupDelegate?.listPopupDidSelect(index: indexPath.row, type: self.type)
        }
    }
}


extension UITableView {
    
    func register(_ nibName: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: nibName)
    }
}
