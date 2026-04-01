//
//  HelpController.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 26/03/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

class HelpController: UIViewController {

    @IBOutlet weak var tblHelp: UITableView!
    @IBOutlet weak var pickerUrgent: UIView!
    @IBOutlet weak var pickerNormal: UIView!
    @IBOutlet weak var stkStatus: UIStackView!
    
    var dataSources = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pickerNormal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(normalOnTap)))
        pickerUrgent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(urgentOnTap)))
        tblHelp.isHidden = dataSources.isEmpty
        stkStatus.isHidden = !dataSources.isEmpty
        self.view.backgroundColor = .clear
        initTableView()

    }

    @objc func normalOnTap(sender : UITapGestureRecognizer) {
        
    }
    
    @objc func urgentOnTap(sender : UITapGestureRecognizer) {
        
    }
}

extension HelpController: UITableViewDelegate, UITableViewDataSource {
    
    func initTableView() {
        tblHelp.register("HelpCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 55
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "HelpCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HelpCell
        cell.selectionStyle = .none
        cell.drawCell(dataSources[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

