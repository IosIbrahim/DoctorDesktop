//
//  PatientViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/18/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit
import DropDown
import PopupDialog
import SideMenu
import NVActivityIndicatorView

class PatientsViewController: UIViewController, NVActivityIndicatorViewable {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dropDownView: UIView!
  @IBOutlet weak var countView: UIView!
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var selectionTitleLabel: UILabel!
  @IBOutlet weak var dateView: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var tabbar: UITabBar!

  @IBOutlet weak var triagedTabView: UIView!
  @IBOutlet weak var triagedLabel: UILabel!
  @IBOutlet weak var triagedView: UIView!
  @IBOutlet weak var triagedCountLabel: UILabel!

  @IBOutlet weak var notTriagedTabView: UIView!
  @IBOutlet weak var notTriagedLabel: UILabel!
  @IBOutlet weak var notTriagedView: UIView!
  @IBOutlet weak var notTriagedCountLabel: UILabel!

  @IBOutlet weak var emergencyControl: UIStackView!

  private var inpatientCellMaker: DependencyRegistry.InpatientCellMaker!
  private var outpatientCellMaker: DependencyRegistry.OutpatientCellMaker!
  private var emergencyCellMaker: DependencyRegistry.EmergencyCellMaker!
  private var clinicalAlertCellMaker: DependencyRegistry.ClinicalAlertCellMaker!
  private var patientOverviewViewControllerMaker: DependencyRegistry.PatientOverviewViewControllerMaker!
  private var unitsPopupMaker: DependencyRegistry.UnitsPopupMaker!
  private var clinicalInfoPopupMaker: DependencyRegistry.ClinicalInfoPopupMaker!
  private weak var navigationCoordinator: NavigationCoordinator?

  var presenter: PatientsPresenter!
  let dropDown = DropDown()
  var popupDialog: PopupDialog?
  var dateFormatter = DateFormatter()
  var selectedUnitIndex: Int?
  var selectedDate = Date()
  var isTriagedSelected: Bool = true

  func configure(with presenter: PatientsPresenter,
                 inpatientCellMaker: @escaping DependencyRegistry.InpatientCellMaker,
                 outpatientCellMaker: @escaping DependencyRegistry.OutpatientCellMaker,
                 emergencyCellMaker: @escaping DependencyRegistry.EmergencyCellMaker,
                 clinicalAlertCellMaker: @escaping DependencyRegistry.ClinicalAlertCellMaker,
                 patientOverviewViewControllerMaker: @escaping DependencyRegistry.PatientOverviewViewControllerMaker,
                 unitsPopupMaker: @escaping DependencyRegistry.UnitsPopupMaker,
                 clinicalInfoPopupMaker: @escaping DependencyRegistry.ClinicalInfoPopupMaker,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.inpatientCellMaker = inpatientCellMaker
    self.outpatientCellMaker = outpatientCellMaker
    self.emergencyCellMaker = emergencyCellMaker
    self.clinicalAlertCellMaker = clinicalAlertCellMaker
    self.patientOverviewViewControllerMaker = patientOverviewViewControllerMaker
    self.unitsPopupMaker = unitsPopupMaker
    self.clinicalInfoPopupMaker = clinicalInfoPopupMaker
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
    self.title = presenter.title
    tableView.estimatedRowHeight = 130
    registerCell()
      
  //  navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
      
    let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
    navigationController?.navigationBar.titleTextAttributes = textAttributes

    self.navigationController?.navigationBar.tintColor = UIColor.green
    //self.navigationController?.navigationBar.backgroundColor = UIColor.blue
    countView.layer.cornerRadius = countView.bounds.width/2
    dropDownView.layer.cornerRadius = 10
    dateView.layer.cornerRadius = 10

    if presenter.componentType == .inpatient {
      dateView.isHidden = true
    }
    
    dateFormatter.dateFormat = "dd/MM/yyyy"
    dateLabel.text = dateFormatter.string(from: selectedDate)

    triagedTabView.layer.borderWidth = 1
    triagedTabView.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.4784313725, blue: 0.6117647059, alpha: 1)
    triagedView.layer.cornerRadius = triagedView.bounds.width/2

    notTriagedTabView.layer.borderWidth = 1
    notTriagedTabView.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.4784313725, blue: 0.6117647059, alpha: 1)
    notTriagedView.layer.cornerRadius = notTriagedView.bounds.width/2

    if presenter.componentType != .emergency {
      emergencyControl.removeFromSuperview()
    }

    switch presenter.componentType {
  //  case .emergency, .clinicalAlert:
    case .emergency :
      getPatientsDetails(withSelectedUnitIndex: -1)
  //  case .outpatient, .inpatient, .ICU, .nicu:
    case .outpatient, .inpatient:
      // Hide content — UnitsPopup is about to be pushed immediately on top.
      setContentVisible(false)
      getPatientsUnits()
    default:
      getPatientsUnits()
    }
  }

  // MARK: - Content visibility helper

  /// Hides/shows the main content area (table + selector bar).
  /// Called with `false` before UnitsPopup appears, and `true` after a clinic is selected.
  fileprivate func setContentVisible(_ visible: Bool) {
    tableView.isHidden          = !visible
    dropDownView.isHidden       = !visible
    countView.isHidden          = !visible
    selectionTitleLabel.isHidden = !visible
  }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)
        navigationCoordinator?.setNavigationStatus(.atPatientList)
    }

    
  @IBAction func didPressDownArrow(sender: Any) {
    dropDown.show()
  }
  
  @IBAction func didPressDateView(_ sender: Any) {
    showDatePopupDialog()
  }

  @IBAction func didClickTriagedTab(_ sender: Any) {
    if !self.isTriagedSelected {
      self.isTriagedSelected = true
      UIView.animate(withDuration: 0.25, animations: {
        self.triagedTabView.backgroundColor = #colorLiteral(red: 0.03529411765, green: 0.5058823529, blue: 0.6039215686, alpha: 1)
        self.triagedLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.notTriagedTabView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.notTriagedLabel.textColor = #colorLiteral(red: 0.03529411765, green: 0.5058823529, blue: 0.6039215686, alpha: 1)
      })
      self.tableView.reloadData()
    }
  }

  @IBAction func didClickNotTriagedTab(_ sender: Any) {
    if self.isTriagedSelected {
      self.isTriagedSelected = false
      UIView.animate(withDuration: 0.25, animations: {
        self.notTriagedTabView.backgroundColor = #colorLiteral(red: 0.03529411765, green: 0.5058823529, blue: 0.6039215686, alpha: 1)
        self.notTriagedLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.triagedTabView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.triagedLabel.textColor = #colorLiteral(red: 0.03529411765, green: 0.5058823529, blue: 0.6039215686, alpha: 1)
      })
      self.tableView.reloadData()
    }
  }
}

extension PatientsViewController {
  fileprivate func initializePatientOverviewSideMenu(patient: Patient) {
    let patientOverviewViewController = patientOverviewViewControllerMaker(patient, presenter.user)
    // Define the menus
    let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: patientOverviewViewController)
    SideMenuManager.default.menuPresentMode = .menuDissolveIn
    SideMenuManager.default.rightMenuNavigationController = menuLeftNavigationController
//    SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
    SideMenuManager.default.menuWidth = self.view.frame.width - 80
//    SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
  }

  /// Creates and pushes UnitsPopup immediately, then returns it so the caller
  /// can call reloadWith(units:) once the API finishes.
  @discardableResult
  fileprivate func showUnitsPopupDialog() -> UnitsPopup {
    let unitsPopup = unitsPopupMaker(presenter.title, self.presenter.patientUnits)
    unitsPopup.delegate = self
    unitsPopup.selectedDate = selectedDate

    unitsPopup.onDateChanged = { [weak self, weak unitsPopup] newDate in
      guard let self = self, let popup = unitsPopup else { return }
      self.selectedDate = newDate
      self.dateLabel.text = self.dateFormatter.string(from: newDate)
      self.selectedUnitIndex = nil
      self.presenter.clearData()
      self.presenter.getOutpatientClinics(withDate: newDate) {
        popup.reloadWith(units: self.presenter.patientUnits)
      }
    }

    navigationController?.pushViewController(unitsPopup, animated: true)
    return unitsPopup
  }
  
  fileprivate func showDatePopupDialog() {
    let datePopup = DatePopup()
    self.popupDialog = PopupDialog(viewController: datePopup)
    
    let doneButton = PopupDialogButton(title: "Done") {
      self.didSelectDate(date: datePopup.datePicker.date)
    }
    let cancelButton = PopupDialogButton(title: "Cancel", action: nil)
    
    self.popupDialog?.addButtons([doneButton, cancelButton])
    self.present(popupDialog!, animated: true, completion: nil)
  }
  
  fileprivate func setupDropDownMenu(dropDown: DropDown) {
    // The view to which the drop down will appear on
    dropDown.anchorView = dropDownView // UIView or UIBarButtonItem
    // The list of items to display. Can be changed dynamically
    dropDown.dataSource = presenter.patientUnits.compactMap() {
      patientUnits in
      return patientUnits.name
    }
    // Action triggered on selection
    dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
      self.didSelectPatientUnit(atIndex: index)
    }
    dropDown.direction = .bottom
    // Top of drop down will be below the anchorView
    dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
    
    // Custom nib removed — clinic selection is handled by the pushed UnitsPopup
    
    dropDown.backgroundColor = .white
    dropDown.selectionBackgroundColor = .lightGray
  }
}

extension PatientsViewController {
  
  fileprivate func registerCell() {
    switch presenter.componentType {
  //  case .inpatient, .ICU ,.nicu, .operations: InpatientCell.register(with: tableView)
    case .inpatient: InpatientCell.register(with: tableView)
    case .outpatient: OutpatientCell.register(with: tableView)
    case .emergency: EmergencyCell.register(with: tableView)
  //  case .clinicalAlert: ClinicalAlertCell.register(with: tableView)
    default: break
    }
  }

  fileprivate func getPatientsUnits() {
    switch presenter.componentType {
    case .inpatient:
      let popup = showUnitsPopupDialog()
      presenter.getInpatientUnits(isICU: 0) {
        self.setupDropDownMenu(dropDown: self.dropDown)
        popup.reloadWith(units: self.presenter.patientUnits)
      }
//    case .ICU:
//      let popup = showUnitsPopupDialog()
//      presenter.getInpatientUnits(isICU: 1) {
//        self.setupDropDownMenu(dropDown: self.dropDown)
//        popup.reloadWith(units: self.presenter.patientUnits)
//      }
    case .outpatient:
      // Push UnitsPopup immediately (shows spinner) — no waiting, no white flash.
      // Populate it once the API responds.
      let popup = showUnitsPopupDialog()
      presenter.getOutpatientClinics(withDate: selectedDate) {
        self.setupDropDownMenu(dropDown: self.dropDown)
        popup.reloadWith(units: self.presenter.patientUnits)
      }
//    case .operations:
//        presenter.getOperationPatients(withDate: selectedDate) {
//            self.tableView.reloadData()
//        }
    case .emergency:
      getPatientsDetails(withSelectedUnitIndex: -1)
//    case .clinicalAlert:
//      break
//    case .nicu:
//      let popup = showUnitsPopupDialog()
//      presenter.getInpatientUnits(isICU: 2) {
//        self.setupDropDownMenu(dropDown: self.dropDown)
//        popup.reloadWith(units: self.presenter.patientUnits)
//      }
    default: break
    }
  }
  
  fileprivate func getPatientsDetails(withSelectedUnitIndex index: Int) {
    startAnimating(message: "Load Patients Details...")
    
    switch presenter.componentType {
//    case .nicu:
//        presenter.getInpatientPatients(withSelectedUnitIndex: index, isICU: 2) {
//          self.stopAnimating()
//          self.tableView.reloadData()
//        }
    case .inpatient:
      presenter.getInpatientPatients(withSelectedUnitIndex: index, isICU: 0) {
        self.stopAnimating()
        self.tableView.reloadData()
      }
//    case .ICU:
//      presenter.getInpatientPatients(withSelectedUnitIndex: index, isICU: 1) {
//        self.stopAnimating()
//        self.tableView.reloadData()
//      }
    case .outpatient:
      presenter.getOutpatientPatients(withDate: selectedDate, selectedClinicIndex: index) {
        self.stopAnimating()
        self.tableView.reloadData()
      }
    case .emergency:
      presenter.getEmergencyPatients(withDate: selectedDate) {
        self.stopAnimating()
        self.triagedCountLabel.text = "\(self.presenter.triagedEmergencyPatients.count)"
        self.notTriagedCountLabel.text = "\(self.presenter.notTriagedEmergencyPatients.count)"
        self.tableView.reloadData()
      }
//    case .clinicalAlert:
//      presenter.getClinicalPatients(date: Date(), finished: {
//        self.stopAnimating()
//        self.tableView.reloadData()
//      })
//    case .operations:
//        presenter.getOperationPatients(withDate: Date(), finished: {
//            self.stopAnimating()
//            self.tableView.reloadData()
//        })
    default: break
    }
  }
}

extension PatientsViewController {
  fileprivate func didSelectPatientUnit(atIndex index: Int) {
    guard selectedUnitIndex != index else { return }
    setContentVisible(true)     // reveal UI now that a clinic has been chosen
    selectionTitleLabel.text = self.presenter.patientUnits[index].name
    self.selectedUnitIndex = index

    // Update the count badge (display only — never block loading)
    let count = presenter.patientUnits[index].patientsCount
    if count == "0" {
      countView.isHidden = true
    } else {
      countView.isHidden = false
      countLabel.text = count
    }

    // Always fetch patients regardless of cached count
    getPatientsDetails(withSelectedUnitIndex: index)
  }
  
  fileprivate func didSelectDate(date: Date) {
    let newDateString = self.dateFormatter.string(from: date)
    guard newDateString != dateFormatter.string(from: selectedDate) else { return }
    self.dateLabel.text = newDateString
    selectedDate = date
    selectedUnitIndex = nil   // allow re-selection of same clinic index on new date
    presenter.clearData()
    setContentVisible(false)  // hide content — UnitsPopup is about to appear again
    getPatientsUnits()
  }
}

extension PatientsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch presenter.componentType {
   // case .inpatient,.nicu, .ICU: return presenter.inpatientPatients.count
    case .inpatient: return presenter.inpatientPatients.count
    case .outpatient: return presenter.outpatientPatients.count
    case .emergency:
      if self.isTriagedSelected {
        return presenter.triagedEmergencyPatients.count
      } else {
        return presenter.notTriagedEmergencyPatients.count
      }
 //   case .clinicalAlert: return presenter.clinicalPatients.count
 //   case .operations: return presenter.operationPatients.count

    default: return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch presenter.componentType {
 //   case .inpatient,.nicu, .ICU:
    case .inpatient:
      return self.inpatientCellMaker(tableView, indexPath, self.presenter.inpatientPatients[indexPath.row])
    case .outpatient:
        let cell = outpatientCellMaker(tableView, indexPath, presenter.outpatientPatients[indexPath.row])
        cell.selectIndex = indexPath.row
        cell.delegade = self
      return cell
    case .emergency:
      let emergencyCellPresenter = self.isTriagedSelected ?
        EmergencyCellPresenterImpl(with: presenter.triagedEmergencyPatients[indexPath.row]) :
        EmergencyCellPresenterImpl(with: presenter.notTriagedEmergencyPatients[indexPath.row])
      return EmergencyCell.dequeue(from: tableView, for: indexPath, with: emergencyCellPresenter)
//    case .clinicalAlert :
//      return clinicalAlertCellMaker(tableView, indexPath, presenter.clinicalPatients[indexPath.row])
//    case .operations:
//        let cell = UITableViewCell()
//        cell.backgroundColor = .black
//        cell.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
//        return cell
    default:
        
      return UITableViewCell()
    }
  }
}

extension PatientsViewController:OutpatientStatus {
    func changeStatus(_ index:Int) {
        presenter.changePatientStatus(index: index) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension PatientsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch presenter.componentType {
    case .emergency:    return UITableViewAutomaticDimension
  //  case .clinicalAlert: return 100
  //  case .inpatient, .ICU, .nicu, .operations: return 110
    case .inpatient: return 110
    case .outpatient:   return 160
    default:            return UITableViewAutomaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch presenter.componentType {
    case .outpatient:
        self.initializePatientOverviewSideMenu(patient: presenter.outpatientPatients[indexPath.row])
        let args = ["viewType":"overview",
                    "patient":presenter.outpatientPatients[indexPath.row],
                    "permission":presenter.permission,
                    "user":presenter.user] as [String : Any]
        
        print(presenter.outpatientPatients[indexPath.row].id)
        
        UserDefaults.standard.set(presenter.outpatientPatients[indexPath.row].id, forKey: "patient_id") //setObject

          UserDefaults.standard.set(presenter.outpatientPatients[indexPath.row].visitId, forKey: "visit_id") //setObject
        
       
        navigationCoordinator?.next(arguments: args)
        
 //   case .inpatient,.nicu, .ICU:
    case .inpatient:
        UserDefaults.standard.set(presenter.inpatientPatients[indexPath.row].id, forKey: "patient_id") //setObject

          UserDefaults.standard.set(presenter.inpatientPatients[indexPath.row].visitId, forKey: "visit_id") //setObject
      self.initializePatientOverviewSideMenu(patient: presenter.inpatientPatients[indexPath.row])
      //present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
      let args = ["viewType":"overview",
                  "patient":presenter.inpatientPatients[indexPath.row],
                  "permission":presenter.permission,
                  "user":presenter.user] as [String : Any]
      navigationCoordinator?.next(arguments: args)
    case .emergency:
      var args = ["viewType":"overview",
                  "user":presenter.user] as [String : Any]
      if self.isTriagedSelected {
        self.initializePatientOverviewSideMenu(patient: self.presenter.triagedEmergencyPatients[indexPath.row])
        args["patient"] = presenter.triagedEmergencyPatients[indexPath.row]
      } else {
        self.initializePatientOverviewSideMenu(patient: self.presenter.notTriagedEmergencyPatients[indexPath.row])
        args["patient"] = presenter.notTriagedEmergencyPatients[indexPath.row]
      }
        args["permission"] = presenter.permission
      navigationCoordinator?.next(arguments: args)
      //present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
//    case .clinicalAlert:
//      let clinicalInfoPopup = clinicalInfoPopupMaker(presenter.clinicalPatients[indexPath.row])
//      let popupDialog = PopupDialog(viewController: clinicalInfoPopup)
//      let cancelButton = PopupDialogButton(title: "Cancel", action: nil)
//      popupDialog.addButtons([cancelButton])
//      present(popupDialog, animated: true, completion: nil)
    default: break
    }
  }
}

extension PatientsViewController: UnitsPopupDelegate {
  func unitsPopup(_ unitsPopup: UnitsPopup, didSelectUnitAt index: Int) {
    navigationController?.popViewController(animated: true)
    didSelectPatientUnit(atIndex: index)
  }
}
