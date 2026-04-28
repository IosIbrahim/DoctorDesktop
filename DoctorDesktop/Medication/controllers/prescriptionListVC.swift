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

    override func viewDidLoad() {
        precritionTableView.delegate   = self
        precritionTableView.dataSource = self

        let params = ["USER_ID": "khabeer", "BRANCH_ID": "1", "PROCESS_ID": "99086", "OBJECT_ID": "4157"]
        apis.getPrescriptionDate(params: params) { [weak self] data in
            self?.precrilist = data
            self?.precritionTableView.reloadData()
        }
    }
}

extension prescriptionListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return precrilist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "precriotionCell", for: indexPath) as? precriotionCell else {
            return UITableViewCell()
        }
        let item = precrilist[indexPath.row]
        cell.configureCell(vc: self, data: item)
        cell.name.text = item.englishName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "prescriptionDetails") as? prescriptionDetails
        else { return }

        if let code = precrilist[indexPath.row].processinfocode {
            processinfocode1   = code
            vc.processinfocode1 = code
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
