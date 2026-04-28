//
//  prescriptionDetails.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/21/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class prescriptionDetails: UIViewController, NVActivityIndicatorViewable {

    var processinfocode1 = 0
    var ItemsDataRowlist: [ItemsDataRow] = []
    var ItemsDataRowlistOfEditScreen: [ItemsDataRow] = []
    var doseowlist: [DosesRow] = []

    @IBOutlet weak var precritionDetailsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        precritionDetailsTableView.delegate   = self
        precritionDetailsTableView.dataSource = self

        guard
            let branch_id  = UserDefaults.standard.string(forKey: "branch_id"),
            let user_id    = UserDefaults.standard.string(forKey: "userName"),
            let visit_id   = UserDefaults.standard.string(forKey: "visit_id"),
            let patient_id = UserDefaults.standard.string(forKey: "patient_id")
        else { return }

        let params: [String: Any] = [
            "USER_ID": user_id,
            "BRANCH_ID": branch_id,
            "FLAG": "1",
            "PATIENT_ID": patient_id,
            "PRESC_TYPE": processinfocode1,
            "VISIT_ID": visit_id
        ]

        apis.getPrescriptiondetails(params: params) { [weak self] data in
            guard let self = self else { return }
            self.ItemsDataRowlist = data.root?.itemsData?.itemsDataRow ?? []
            self.precritionDetailsTableView.reloadData()
        }
    }

    @IBAction func searchAction(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "searchVC") as? searchVC else { return }
        present(vc, animated: false)
    }

    @IBAction func editAction(_ sender: Any) {
        guard !ItemsDataRowlistOfEditScreen.isEmpty else {
            createAlert(title: "Warning", message: "Please Select an Item")
            return
        }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "editVC") as? editVC else { return }
        vc.ItemsDataRowlist = ItemsDataRowlistOfEditScreen
        present(vc, animated: false)
    }
}

extension prescriptionDetails: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 40 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemsDataRowlist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "precriptionDetailsCell", for: indexPath) as? precriptionDetailsCell
        else { return UITableViewCell() }

        let item = ItemsDataRowlist[indexPath.row]
        cell.configureCell(vc: self, data: item)

        if Int(item.hasBalance ?? "") == 0 {
            cell.extradoseLabel.isHidden = false
            cell.name.textColor = #colorLiteral(red: 1, green: 0.2562306327, blue: 0.1151451593, alpha: 1)
        }
        cell.doseLabel.text  = item.doses?.dosesRow?.dose
        cell.name.text       = item.itemenname
        cell.checkBoxIcon.addTarget(self, action: #selector(checkBoxClicked(sender:)), for: .touchUpInside)
        cell.checkBoxIcon.tag = (indexPath.section * 100) + indexPath.row
        return cell
    }

    @objc func checkBoxClicked(sender: UIButton) {
        let row  = sender.tag % 100
        let indexPath = IndexPath(row: row, section: sender.tag / 100)

        if sender.isSelected {
            sender.isSelected = false
            if let index = ItemsDataRowlistOfEditScreen.firstIndex(where: { $0.itemcode == ItemsDataRowlist[row].itemcode }) {
                ItemsDataRowlistOfEditScreen.remove(at: index)
            }
        } else {
            sender.isSelected = true
            ItemsDataRowlistOfEditScreen.append(ItemsDataRowlist[indexPath.row])
        }
        precritionDetailsTableView.reloadData()
    }
}

// MARK: - Reusable alert helper

class subclassedUIButton: UIButton {
    var indexPath: Int?
    var urlString: String?
}

extension UIViewController {
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
}
