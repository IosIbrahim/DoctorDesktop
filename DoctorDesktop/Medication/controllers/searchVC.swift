//
//  searchVC.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/23/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class searchVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var selectedItemsButtonCount: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minsButton: UIButton!
    @IBOutlet weak var pageCountLal: UILabel!
    @IBOutlet weak var tableViewSearch: UITableView!
    @IBOutlet weak var maniView: UIView!

    var selectedItemsIDs: [String]  = []
    var processinfocode1 = 0
    var ItemsRowlist: [ItemsRow]         = []
    var selectedItemsRowlist: [ItemsRow] = []
    var doseowlist: [DosesRow] = []

    var indexFrom = 0
    var indexTo   = 15
    var pageNumber = 1
    var params: [String: Any] = [:]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectionButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectionButton()
        tableViewSearch.delegate        = self
        tableViewSearch.dataSource      = self
        tableViewSearch.rowHeight       = UITableViewAutomaticDimension
        tableViewSearch.estimatedRowHeight = 60
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        loadData()
    }

    // MARK: - Pagination

    @IBAction func plusPage(_ sender: Any) {
        indexFrom  += 15
        indexTo    += 15
        pageNumber += 1
        loadData()
    }

    @IBAction func minsPage(_ sender: Any) {
        indexFrom  -= 15
        indexTo    -= 15
        pageNumber -= 1
        loadData()
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func selectedItemCountTapped(_ sender: Any) {
        ItemsRowlist = selectedItemsRowlist
        tableViewSearch.reloadData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }

    // MARK: - Data loading

    func loadData() {
        guard
            let branch_id  = UserDefaults.standard.string(forKey: "branch_id"),
            let user_id    = UserDefaults.standard.string(forKey: "userName"),
            let visit_id   = UserDefaults.standard.string(forKey: "visit_id"),
            let patient_id = UserDefaults.standard.string(forKey: "patient_id")
        else { return }

        startAnimating(message: "Loading...")

        let searchText = searchTextField.text?.isEmpty == false ? searchTextField.text! : " "
        params = [
            "INDEX_FROM": indexFrom,
            "INDEX_TO":   indexTo,
            "ORDERBY":    2,
            "USER_ID":    user_id,
            "BRANCH_ID":  branch_id,
            "PATIENT_ID": patient_id,
            "PRESC_ITEM": 1,
            "SEARCH_TEXT": searchText,
            "VISIT_ID":   visit_id
        ]

        apis.getSearchResultInprecription(params: params) { [weak self] data in
            guard let self = self else { return }
            self.stopAnimating()
            self.minsButton.isHidden = self.indexFrom <= 0

            if let data = data {
                self.ItemsRowlist = data.items.itemsRow
                let totalPages = (Int(self.ItemsRowlist.first?.pagesCount ?? "1") ?? 1) / 15 + 1
                self.pageCountLal.text = "\(self.pageNumber) Of \(totalPages)"
                self.plusButton.isHidden = self.indexTo >= (Int(self.ItemsRowlist.first?.pagesCount ?? "0") ?? 0)
            } else {
                self.ItemsRowlist      = []
                self.pageCountLal.text = "No Data Found"
                self.plusButton.isHidden = true
                self.minsButton.isHidden = true
            }
            self.tableViewSearch.reloadData()
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        loadData()
    }

    func updateSelectionButton() {
        selectedItemsButtonCount.setTitle(String(selectedItemsRowlist.count), for: .normal)
    }
}

// MARK: - UITableView

extension searchVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemsRowlist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? searchCell
        else { return UITableViewCell() }

        let item = ItemsRowlist[indexPath.row]
        let isSelected = selectedItemsIDs.contains(item.id)
        let bg = UIView()
        bg.backgroundColor = isSelected ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : .white
        cell.backgroundView  = bg
        cell.button.isHidden = !isSelected
        cell.cLal.text       = item.nameEn
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? searchCell else { return }
        let item = ItemsRowlist[indexPath.row]
        let bg   = UIView()

        if selectedItemsIDs.contains(item.id) {
            bg.backgroundColor  = .white
            cell.backgroundView = bg
            cell.button.isHidden = true
            if let index = selectedItemsRowlist.firstIndex(where: { $0.id == item.id }) {
                selectedItemsRowlist.remove(at: index)
                selectedItemsIDs.remove(at: index)
            }
        } else {
            bg.backgroundColor  = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            cell.backgroundView = bg
            cell.button.isHidden = false
            selectedItemsRowlist.append(item)
            selectedItemsIDs.append(item.id)
        }
        updateSelectionButton()
    }
}

// MARK: - Helpers

@IBDesignable
class RoundUIView: UIView {
    @IBInspectable var borderColor: UIColor = .white {
        didSet { layer.borderColor = borderColor.cgColor }
    }
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet { layer.borderWidth = borderWidth }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
}

extension Float {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
