//
//  ViewController.swift
//  DoctorDesktop
//
//  Created by mac-pc on 12/23/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

class ClinicalInfoPopup: UIViewController {
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var patientNameLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!

  var presenter: ClinicalInfoPopupPresenter!
  private var clinicalInfoPopupCellMaker: DependencyRegistry.ClinicalInfoPopupCellMaker!

  override func viewDidLoad() {
    super.viewDidLoad()
    patientNameLabel.text = presenter.patientName
    ClinicalInfoPopupCell.register(with: tableView)
    tableView.tableFooterView = UIView()

    var segmentedControlTitles = [String]()
    if presenter.scores != nil { segmentedControlTitles.append("Scores") }
    if presenter.panicLabResults != nil { segmentedControlTitles.append("Panic Lab") }
    if presenter.panicRadResults != nil { segmentedControlTitles.append("Panic Rad") }
    segmentedControl.replaceSegments(segments: segmentedControlTitles)
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.sendActions(for: .valueChanged)
  }

  init(with presenter: ClinicalInfoPopupPresenter,
       clinicalInfoPopupCellMaker: @escaping DependencyRegistry.ClinicalInfoPopupCellMaker) {
    self.presenter = presenter
    self.clinicalInfoPopupCellMaker = clinicalInfoPopupCellMaker
    super.init(nibName: "ClinicalInfoPopup", bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func didChangeTab(_ sender: Any) {
    tableView.reloadData()
  }
}

extension ClinicalInfoPopup: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) {
    case "Scores": return presenter.scores!.count
    case "Panic Lab": return presenter.panicLabResults!.count
    case "Panic Rad": return presenter.panicRadResults!.count
    default: return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) {
    case "Scores": return clinicalInfoPopupCellMaker(tableView, indexPath, presenter.scores![indexPath.row])
    case "Panic Lab": return clinicalInfoPopupCellMaker(tableView, indexPath, presenter.panicLabResults![indexPath.row])
    case "Panic Rad": return clinicalInfoPopupCellMaker(tableView, indexPath, presenter.panicRadResults![indexPath.row])
    default: return UITableViewCell()
    }
  }
}

extension ClinicalInfoPopup: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
