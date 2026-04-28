//
//  editVC.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/25/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit

class editVC: UIViewController {

    var ItemsDataRowlist: [ItemsDataRow] = []

    @IBOutlet weak var itemRowsList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        itemRowsList.delegate   = self
        itemRowsList.dataSource = self
        itemRowsList.reloadData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}

extension editVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 40 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemsDataRowlist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as? editCell
        else { return UITableViewCell() }
        cell.cLal.text = ItemsDataRowlist[indexPath.row].itemenname
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? editCell else { return }
        // BUG FIX: was using == (comparison) instead of = (assignment)
        cell.backgview.isHidden = !cell.backgview.isHidden
    }

    @objc func checkBoxClicked(sender: UIButton) {
        sender.isSelected.toggle()
        itemRowsList.reloadData()
    }
}
