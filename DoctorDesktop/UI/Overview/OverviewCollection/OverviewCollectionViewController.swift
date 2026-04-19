//
//  OverviewCollectionViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/15/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import SideMenu
import Toastlity
import NVActivityIndicatorView

class OverviewCollectionViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var historyCollectionView: UICollectionView!
    @IBOutlet weak var summaryCollectionView: UICollectionView!
    lazy var toastBar: ToastBar = .init(settings: .agent, in: parent?.view)

    private var presenter: OverviewPresenter!
    private var selectIndex:Int = .zero
    private weak var navigationCoordinator: NavigationCoordinator?
    private var patientHistoryFiltrationCellMaker: DependencyRegistry.PatientHistoryFiltrationCellMaker!
    private var overviewSectionCellMaker: DependencyRegistry.OverviewSectionCellMaker!

    // Patient header
    private var patientHeaderView: PatientHeaderView!
    /// Keeps the header flush with the bottom of the navigation bar.
    private var headerTopConstraint: NSLayoutConstraint!

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
    setupPatientHeader()
  }

  // MARK: - Patient Header

  private func setupPatientHeader() {
    patientHeaderView = PatientHeaderView()
    view.addSubview(patientHeaderView)

    // Pin to the top of the view (constant updated once safe-area is known)
    headerTopConstraint = patientHeaderView.topAnchor.constraint(equalTo: view.topAnchor)
    NSLayoutConstraint.activate([
      headerTopConstraint,
      patientHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      patientHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      patientHeaderView.heightAnchor.constraint(equalToConstant: PatientHeaderView.preferredHeight),
    ])

    // Push the storyboard collection views below the header.
    // This works when the storyboard views are constrained to the safe area top.
    additionalSafeAreaInsets.top = PatientHeaderView.preferredHeight

    // Populate immediately with data already in the presenter
    patientHeaderView.configure(patient: presenter.patient)

    // Keep the header visually above the collection views
    view.bringSubview(toFront: patientHeaderView)
  }

  /// Called by UIKit whenever the safe-area insets change (e.g. on first layout,
  /// device rotation).  We reposition the header to stay just below the nav bar.
  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    // safeAreaInsets.top = navBarHeight + additionalSafeAreaInsets.top
    // → navBarHeight = safeAreaInsets.top − additionalSafeAreaInsets.top
    let navBarHeight = view.safeAreaInsets.top - additionalSafeAreaInsets.top
    headerTopConstraint.constant = max(navBarHeight, 0)
  }

  @IBAction func didPressMenu(_ sender: Any) {
      if let menu = SideMenuManager.default.rightMenuNavigationController {
          present(menu , animated: true, completion: nil)
      }else if let menu = SideMenuManager.default.leftMenuNavigationController {
          present(menu , animated: true, completion: nil)
      }
 //     present(SideMenuManager.default.menuRightNavigationController! , animated: true, completion: nil)
  }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)

      // Load visit detail (blood type, phone, allergy, etc.)
      presenter.getVisitsDetail {
        if let detail = self.presenter.visitDetail {
          self.patientHeaderView.updateFromVisitDetail(detail)
        }
      }

      presenter.getPatientHistory {
          let history = self.presenter.patientHistory

          // Specialty chip
          let specialtyName = history?.currentSpeciality.name ?? ""
          self.patientHeaderView.updateSpecialty(specialtyName)

          // Insurance — find current visit and read CONTRACT_NAME_EN
          let contractName = history?.patientVisits
              .first(where: { $0.id == self.presenter.patient.visitId })?
              .contractNameEn ?? ""
          self.patientHeaderView.updateInsurance(contractName)

          self.historyCollectionView.reloadSections(IndexSet(integer: 0))
          self.historyCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [.centeredHorizontally])
          self.collectionView(self.historyCollectionView, didSelectItemAt : IndexPath(item: 0, section: 0))
        }
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
        let cell = patientHistoryFiltrationCellMaker(collectionView, indexPath, patientType)
        cell.selectItem(indexPath.row == selectIndex)
      return cell
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
        selectIndex = indexPath.row
        historyCollectionView.reloadData()
      startAnimating(message: "Loading...")
      presenter.getPatientSummary(filtrationType: filtrationType) {
          if let msg = self.presenter.patientSummary?.message {
              self.toastBar.show(with: msg)
          }
        self.stopAnimating()
        self.summaryCollectionView.reloadData()
      }
    } else {
      guard let overviewSection = OverviewSection(rawValue: indexPath.row) else { return }
        presenter.getArguments(overviewSection)
        navigationCoordinator?.setNavigationStatus(.atOverviewCollection)
        navigationCoordinator?.next(arguments: presenter.arguments)
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
