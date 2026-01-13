//
//  ListPopupViewController.swift
//  nasTrends
//
//  Created by Mohamed Elmaazy on 2/5/19.
//  Copyright © 2019 Mohamed Elmaazy. All rights reserved.
//

import UIKit
import MZFormSheetController

protocol ListPopupDelegate {
    func listPopupDidSelect(index: Int, type: String)
}

class ListPopupViewController: UIViewController {

    @IBOutlet weak var viewClose: UIView!
    @IBOutlet weak var constraintTopImageViewClose: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailingImageViewClose: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintTopLabelSeparator: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    
    var arrayNames = [String]()
    var header = ""
    var listPopupDelegate : ListPopupDelegate?
    var type = ""
    
    init(arrayNames: [String], header: String, type: String) {
        super.init(nibName: "ListPopupViewController", bundle: nil)
        self.arrayNames = arrayNames
        self.header = header
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        disableDarkMode()
        initTableView()
        labelTitle.text = header
        initConstraints()
        labelTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        viewClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func initConstraints() {
//        constraintTopImageViewClose.update(15)
//        constraintTrailingImageViewClose.update(15)
//        constraintTopLabelSeparator.update(15)
    }

    @objc func close() {
         mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
}
