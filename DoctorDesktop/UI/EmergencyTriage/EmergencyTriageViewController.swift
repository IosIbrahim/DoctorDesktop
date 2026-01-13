//
//  EmergencyTriageViewController.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/19/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import PopupDialog
import SideMenu

class EmergencyTriageViewController: UIViewController {
  private var presenter: EmergencyTriagePresenter!
  private var vitalCellMaker: DependencyRegistry.VitalCellMaker!
  private var diagnosisCategoriesPopupMaker: DependencyRegistry.DiagnosisCategoryPopUpMaker!
  private var symptomCellMaker: DependencyRegistry.SymptomCellMaker!
  private var symptomCategoryCellMaker: DependencyRegistry.SymptomCategoryCellMaker!
  private var pediatricsScorePopUpMaker: DependencyRegistry.PediatricsScorePopUpMaker!
  private weak var navigationCoordinator: NavigationCoordinator?
  
  @IBOutlet weak var vitalCellsView: UICollectionView!
  @IBOutlet weak var painScaleView: UIView!
  @IBOutlet weak var pediatricPainScoreView: UIView!
  @IBOutlet weak var selectedDiagnosisCategory: UILabel!
  @IBOutlet weak var symptomCategoriesTable: UITableView!
  @IBOutlet weak var symptomsTable: UITableView!
  @IBOutlet weak var painSlider: UISlider!
  @IBOutlet weak var painLevel: UILabel!
  @IBOutlet weak var painIcon: UIImageView!
  @IBOutlet weak var triageNumber: UIButton!
  @IBOutlet weak var accuteCondition: UILabel!
  @IBOutlet weak var urgencyLevel: UILabel!
  
  init() {
    super.init(nibName: "EmergencyTriageView", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with presenter: EmergencyTriagePresenter, navigationCoordinator: NavigationCoordinator,
    symptomCategoryCellMaker: @escaping DependencyRegistry.SymptomCategoryCellMaker,
    symptomCellMaker: @escaping DependencyRegistry.SymptomCellMaker,
    vitalCellMaker: @escaping DependencyRegistry.VitalCellMaker,
    diagnosisCategoryPopUpMaker: @escaping DependencyRegistry.DiagnosisCategoryPopUpMaker,
    pediatricsScorePopUpMaker: @escaping DependencyRegistry.PediatricsScorePopUpMaker) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
    self.vitalCellMaker = vitalCellMaker
    self.diagnosisCategoriesPopupMaker = diagnosisCategoryPopUpMaker
    self.symptomCellMaker = symptomCellMaker
    self.symptomCategoryCellMaker = symptomCategoryCellMaker
    self.pediatricsScorePopUpMaker = pediatricsScorePopUpMaker
  }
  
  @IBAction func didMovePainSlider(_ sender: UISlider) {
    sender.setValue(round(sender.value), animated: true)
    self.painLevel.text = "\(sender.value)"
    self.presenter.painLevel = Int(sender.value)
    self.painIcon.image = setPainIcon(painLevel: self.presenter.painLevel)
  }
  
  @IBAction func didClickSetPediatricPainScore(_ sender: Any) {
    if let pediatricsScoreCategories = self.presenter.currentScore?.details.firstLevelScore?.pediatricsScoreCategories {
      let pediatricPainScorePopupPresenter = PediatricsScorePopUpPresenterImpl(pediatricsScoreCategories, selectedScoreChoices: self.presenter.selectedPediatricChoices)
      let pediatricPainScorePopup = PediatricsScorePopUp(with: pediatricPainScorePopupPresenter )
      pediatricPainScorePopup.delegate = self
      self.present(pediatricPainScorePopup, animated: true, completion: nil)
      UIApplication.shared.isStatusBarHidden = true
    }
  }
  
  @IBAction func didClickRegisteredComplaints(_ sender: Any) {
    let historySymptomsPopupPresenter = HistorySymptomsPopUpPresenterImpl(presenter.historySymptomCategories)
    let historySymptomsPopup = HistorySymptomsPopUp(with: historySymptomsPopupPresenter)
    historySymptomsPopup.delegate = self
    self.present(PopupDialog(viewController: historySymptomsPopup), animated: true, completion: nil)
    //self.present(historySymptomsPopup, animated: true, completion: nil)
    UIApplication.shared.isStatusBarHidden = true
  }
  
  @IBAction func didPressArrow(_ sender: Any) {
    let diagnosisCategoriesPopupPresenter = DiagnosisCategoryPopUpPresenterImpl(presenter.diagnosisCategories)
    let diagnosisCategoriesPopup = DiagnosisCategoryPopUp(with: diagnosisCategoriesPopupPresenter)
    diagnosisCategoriesPopup.delegate = self
    self.present(PopupDialog(viewController: diagnosisCategoriesPopup), animated: true, completion: nil)
    UIApplication.shared.isStatusBarHidden = true
  }
  
  @IBAction func didClickDiagnosisCategory(_ sender: Any) {
    let diagnosisCategoriesPopupPresenter = DiagnosisCategoryPopUpPresenterImpl(presenter.diagnosisCategories)
    let diagnosisCategoriesPopup = DiagnosisCategoryPopUp(with: diagnosisCategoriesPopupPresenter)
    diagnosisCategoriesPopup.delegate = self
    self.present(diagnosisCategoriesPopup, animated: true, completion: nil)
    UIApplication.shared.isStatusBarHidden = true
  }
  
  @IBAction func didClickConfirmTriage(_ sender: Any) {
    self.collectUpdatedVitals()
    self.presenter.saveTriageInfo {}
  }

  @objc func didPressMenu() {
    present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
  }

  func setAcuteConditionStats() {
    if let accute =  self.presenter.patient.accuteCondition {
      triageNumber.setTitle(accute, for: .normal)
      switch (accute) {
      case "1":
        accuteCondition.text = "Immediate"
        urgencyLevel.text = "Resuscitation"
        break;
        
      case "2":
        accuteCondition.text = "< = 15 min"
        urgencyLevel.text = "Emergent"
        break;
        
      case "3":
        accuteCondition.text = "<= 30 min"
        urgencyLevel.text = "Urgent"
        break;
        
      case "4":
        accuteCondition.text = "<= 1 hour"
        urgencyLevel.text = "Less Urgent"
        break;
        
      case "5":
        accuteCondition.text = "<= 2 hours"
        urgencyLevel.text = "Non Urgent"
        break;
        
      default:
        break;
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu_icon"), style: .plain, target: self, action: #selector(didPressMenu))

    VitalCell.register(with: self.vitalCellsView)
    SymptomCategoryCell.register(with: self.symptomCategoriesTable)
    SymptomCell.register(with: self.symptomsTable)
    self.painLevel.text = "\(self.painSlider.value)"
    self.setAcuteConditionStats()
    presenter.getTriageInfo {
      self.vitalCellsView.reloadData()
      if let scoreType = self.presenter.vitals?.scoreType {
        if scoreType == "9" {
          self.pediatricPainScoreView.isHidden = true
          self.painScaleView.isHidden = false
        } else {
          self.pediatricPainScoreView.isHidden = false
          self.painScaleView.isHidden = true
        }
        self.presenter.currentScore = self.presenter.scores[self.presenter.scores.index { score in return score.details.id == scoreType }!]
        if scoreType == "9", let scoreValue = self.presenter.currentScore?.details.value {
          self.painSlider.setValue(Float(scoreValue)!, animated: true)
          self.painLevel.text = "\(self.painSlider.value)"
        } else {
          if let pediatricsScoreCategories = self.presenter.currentScore?.details.firstLevelScore?.pediatricsScoreCategories {
            for pediatricScoreCategory in pediatricsScoreCategories {
              if let pediatricsScoreChoices = pediatricScoreCategory.secondLevelScore?.secondLevelElements {
                let selectedChoices = pediatricsScoreChoices.filter { choice in return choice.SER != nil }
                self.presenter.selectedPediatricChoices.append(contentsOf: selectedChoices)
              }
            }
          }
        }
      }
    }
  }
}

extension EmergencyTriageViewController: PediatricsScorePopUpDelegate {
  func didClickSave(_ pediatricsScorePopUp: PediatricsScorePopUp, totalScore: Int, selectedChoices: [PediatricsScoreChoice]) {
    self.presenter.selectedPediatricChoices = selectedChoices
    self.painIcon.image = setPainIcon(painLevel: totalScore)
  }
}

extension EmergencyTriageViewController: DiagnosisCategoryPopUpDelegate {
  func didSelectDiagnosisCategory(atIndex index: Int){
    let selectedCategory: DiagnosisCategory = self.presenter.diagnosisCategories[index]
    self.selectedDiagnosisCategory.text = selectedCategory.arabicName
    self.presenter.selectedDiagnosisCategory = selectedCategory
    self.presenter.getSymptomCategories {
      self.symptomCategoriesTable.reloadData()
      self.presenter.selectedSymptomCategory = self.presenter.regularSymptomCategories[0]
      self.symptomsTable.cellForRow(at: IndexPath(row: 0, section: 0))?.setSelected(true, animated: true)
      self.updateSymptoms(forSymptomCategoryAt: 0)
    }
  }
  
  func diagnosisCateogryPopUp(_ diagnosisCateogryPopUp: DiagnosisCategoryPopUp, didSelectCategoryAt index: Int) {
    self.dismiss(animated: true) {
      self.didSelectDiagnosisCategory(atIndex: index)
    }
    UIApplication.shared.isStatusBarHidden = false
  }
}

extension EmergencyTriageViewController: HistorySymptomsPopUpDelegate {
  func historySymptomsPopUp(_ historySymptomsPopUp: HistorySymptomsPopUp, didSelectCategory historySymptomCategory: HistorySymptomCategory) {
    self.presenter.getHistorySymptoms(historySymptomCategory: historySymptomCategory) { symptoms in
      historySymptomsPopUp.presenter.historySymptoms = symptoms
      historySymptomsPopUp.symptomsTable.reloadData()
    }
  }
}

extension EmergencyTriageViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.symptomCategoriesTable { return self.presenter.regularSymptomCategories.count }
    else if tableView == self.symptomsTable { return self.presenter.symptoms.count }
    else { return 0 }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == self.symptomCategoriesTable {
      let symptomCategoryCell = SymptomCategoryCellPresenterImpl(with: presenter.regularSymptomCategories[indexPath.row])
      return SymptomCategoryCell.dequeue(from: tableView, for: indexPath, with: symptomCategoryCell)
    } else if tableView == self.symptomsTable {
      let symptomCellPresenter = SymptomCellPresenterImpl(with: presenter.symptoms[indexPath.row])
      let symptomCell = SymptomCell.dequeue(from: tableView, for: indexPath, with: symptomCellPresenter)
      if self.presenter.selectedSymptoms.contains(symptomCellPresenter.symptom.id) {
        symptomCell.accessoryType = self.presenter.unselectedSymptoms.keys.contains(symptomCellPresenter.symptom.id) ? .none : .checkmark
      } else {
        symptomCell.accessoryType = self.presenter.newlySelectedSymptoms.contains(symptomCellPresenter.symptom.id) ? .checkmark : .none
      }
      return symptomCell
    } else { return UITableViewCell() }
  }
}

extension EmergencyTriageViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == self.symptomCategoriesTable {
      self.updateSymptoms(forSymptomCategoryAt: indexPath.row)
    } else if tableView == self.symptomsTable {
      tableView.deselectRow(at: indexPath, animated: true)
      if let cell = self.symptomsTable.cellForRow(at: indexPath as IndexPath) as? SymptomCell {
        let wasSelected: Bool = cell.accessoryType == .checkmark
        cell.accessoryType = wasSelected ?  .none : .checkmark
        if wasSelected { // if the cell was selected, check if it is newly selected or came selected from server
          if let index = self.presenter.newlySelectedSymptoms.index(of: cell.id) {
            self.presenter.newlySelectedSymptoms.remove(at: index)
          } else { self.presenter.unselectedSymptoms[cell.id] = cell.ser! }
        } else { // if the cell wasn't selected then it is a newly selected one or it was selected from server and deselected on device
          if let index = self.presenter.unselectedSymptoms.keys.index(of: cell.id) {
            self.presenter.unselectedSymptoms.remove(at: index)
          } else { self.presenter.newlySelectedSymptoms.append(cell.id) }
        }
      }
    }
  }
}

extension EmergencyTriageViewController {
  func updateSymptoms(forSymptomCategoryAt index: Int) -> Void {
    self.presenter.selectedSymptomCategory = self.presenter.regularSymptomCategories[index]
    self.presenter.getSymptoms {
      self.symptomsTable.reloadData()
      self.symptomsTable.scrollToRow(at: IndexPath(row:0, section: 0), at: .top, animated: true)
    }
  }
}

extension EmergencyTriageViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(
      width: (collectionView.bounds.width / 3.0) - 3.0,
      height: (collectionView.bounds.height / 3.0) - 3.0
    )
  }
}

extension EmergencyTriageViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 9
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.row {
      case 0:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.temp, Vital.temp)
      case 1:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.pulse, Vital.pulse)
      case 2:
        var bp: String?
        if let bloodPressureHigh: String = presenter.vitals?.bloodPressureHigh,
          let bloodPressureLow: String = presenter.vitals?.bloodPressureLow {
          bp = "\(bloodPressureHigh)/\(bloodPressureLow)"
        }
        return vitalCellMaker(collectionView, indexPath, bp , Vital.bloodPressure)
      case 3:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.respiratoryRate, Vital.respiratoryRate)
      case 4:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.o2Sat, Vital.o2Sat)
      case 5:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.bloodSugar, Vital.bloodSugar)
      case 6:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.weight, Vital.weight)
      case 7:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.height, Vital.height)
      case 8:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.sIndex, Vital.sIndex)
      default:
        return vitalCellMaker(collectionView, indexPath, presenter.vitals?.temp, Vital.temp)
    }
  }
}

extension EmergencyTriageViewController {
  func collectUpdatedVitals() {
    for cell in self.vitalCellsView.visibleCells {
      if let cell = cell as? VitalCell, let text = cell.vitalValue.text {
        let key = cell.getJSONKey()
        if cell.getVitalType() == .bloodPressure {
          if text != "/" {
            let bp = text.split(separator: "/")
            self.presenter.updatedVitals.merge(["BP": "\(bp[0])", "PB_2": "\(bp[1])"]){ oldValue, newValue in return newValue }
          }
        } else {
          if !text.contains("-") {
            self.presenter.updatedVitals[key] = cell.vitalValue.text
          }
        }
      }
    }
  }
}

extension EmergencyTriageViewController {
  func setPainIcon(painLevel: Int) -> UIImage {
    switch painLevel {
    case 0: return #imageLiteral(resourceName: "face1")
    case 1,2: return #imageLiteral(resourceName: "face2")
    case 3,4: return #imageLiteral(resourceName: "face3")
    case 5,6: return #imageLiteral(resourceName: "face4")
    case 7,8: return #imageLiteral(resourceName: "face5")
    case 9,10: return #imageLiteral(resourceName: "face6")
    default: return #imageLiteral(resourceName: "face1")
    }
  }
}
