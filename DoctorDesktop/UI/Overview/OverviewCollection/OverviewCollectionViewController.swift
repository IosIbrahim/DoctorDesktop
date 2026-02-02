//
//  OverviewCollectionViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/15/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView

class OverviewCollectionViewController: UIViewController, NVActivityIndicatorViewable {
  @IBOutlet weak var historyCollectionView: UICollectionView!
  @IBOutlet weak var summaryCollectionView: UICollectionView!

  private var presenter: OverviewPresenter!
  private weak var navigationCoordinator: NavigationCoordinator?
  private var patientHistoryFiltrationCellMaker: DependencyRegistry.PatientHistoryFiltrationCellMaker!
  private var overviewSectionCellMaker: DependencyRegistry.OverviewSectionCellMaker!

  func configure(with presenter: OverviewPresenter,
                 patientHistoryFiltrationCellMaker: @escaping DependencyRegistry.PatientHistoryFiltrationCellMaker,
                 overviewSectionCellMaker: @escaping DependencyRegistry.OverviewSectionCellMaker,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.patientHistoryFiltrationCellMaker = patientHistoryFiltrationCellMaker
    self.overviewSectionCellMaker = overviewSectionCellMaker
    self.navigationCoordinator = navigationCoordinator
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    PatientHistoryFiltrationCell.register(with: historyCollectionView)
    OverviewSectionCell.register(with: summaryCollectionView)
    historyCollectionView.allowsMultipleSelection = false
    startAnimating(message: "Loading...")
    presenter.getPatientHistory {
      self.historyCollectionView.reloadSections(IndexSet(integer: 0))
      self.historyCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [.centeredHorizontally])
      self.collectionView(self.historyCollectionView, didSelectItemAt : IndexPath(item: 0, section: 0))
    }
  }

  @IBAction func didPressMenu(_ sender: Any) {
      if let menu = SideMenuManager.default.rightMenuNavigationController {
          present(menu , animated: true, completion: nil)
      }else if let menu = SideMenuManager.default.leftMenuNavigationController {
          present(menu , animated: true, completion: nil)
      }
 //     present(SideMenuManager.default.menuRightNavigationController! , animated: true, completion: nil)
  }
}

extension OverviewCollectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return collectionView == historyCollectionView ? presenter.patientHistoryTitles.count : OverviewSection.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == historyCollectionView {
      var patientType: PatientHistoryFiltrationType!
      switch indexPath.row {
      case 0: patientType = .currentVisit(presenter.patientHistoryTitles[indexPath.row])
      case 1: patientType = .allVisits(presenter.patientHistoryTitles[indexPath.row])
      case 2: patientType = .currentSpeciality(presenter.patientHistoryTitles[indexPath.row])
      case 3: patientType = .currentDoctor(presenter.patientHistoryTitles[indexPath.row])
      default: break
      }
      return patientHistoryFiltrationCellMaker(collectionView, indexPath, patientType)
    } else {
      guard let overviewSection = OverviewSection(rawValue: indexPath.row) else { return UICollectionViewCell() }
      return overviewSectionCellMaker(collectionView, indexPath, overviewSection.imageName, overviewSection.title, overviewSection.color, presenter.patientSummaryCounts[indexPath.row])
    }
  }
}

extension OverviewCollectionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let _ = collectionView.cellForItem(at: indexPath) as? PatientHistoryFiltrationCell,
      collectionView == historyCollectionView {
      var filtrationType: PatientHistoryFiltrationType!
      switch indexPath.row {
      case 0: filtrationType = .currentVisit("")
      case 1: filtrationType = .allVisits("")
      case 2: filtrationType = .currentSpeciality("")
      case 3: filtrationType = .currentDoctor("")
      default: break
      }
      startAnimating(message: "Loading...")
      presenter.getPatientSummary(filtrationType: filtrationType) {
        self.stopAnimating()
        self.summaryCollectionView.reloadData()
      }
    } else {
      guard let overviewSection = OverviewSection(rawValue: indexPath.row), let patientSummary = presenter.patientSummary else { return }
      navigationCoordinator?.next(arguments: ["overviewSection": overviewSection,
                                              "patientSummary": patientSummary,
                                              "user": presenter.user])
    }
  }
}

extension OverviewCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == historyCollectionView {
      return CGSize(width: (historyCollectionView.bounds.width / 4) - 10, height: 45)
    } else {
      return CGSize(width: (summaryCollectionView.bounds.width / 4) - 10,
                    height: (summaryCollectionView.bounds.width / 4))
    }
  }
}
