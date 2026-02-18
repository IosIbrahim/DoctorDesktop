//
//  OverviewSectionDetailsTableViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/21/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class OverviewSectionDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    
    
  var presenter: OverviewSectionDetailsPresenter!
  private weak var navigationCoordinator: NavigationCoordinator?
  private var vitalSignCellMaker: DependencyRegistry.VitalSignCellMaker!
  private var medicationCellMaker: DependencyRegistry.MedicationCellMaker!
  private var diagnosisCellMaker: DependencyRegistry.DiagnosisCellMaker!
  private var allergyFindingComplaintHistoryCellMaker: DependencyRegistry.AllergyFindingComplaintHistoryCellMaker!
  private var radTestCellMaker: DependencyRegistry.RadTestCellMaker!
  private var scoringCellMaker: DependencyRegistry.ScoringCellMaker!
  private var operationCatherEndoscopyCellMaker: DependencyRegistry.OperationCatheterizationEndoscopyCellMaker!
  private var clinicalServiceCellMaker: DependencyRegistry.ClinicalServiceCellMaker!
  private var dietaryCellMaker: DependencyRegistry.DietaryCellMaker!
    private var labCellMaker: DependencyRegistry.LabCellMaker!

  struct Constant {
    static let headerHeight: CGFloat = 40
    static let rowHeight: CGFloat = 80
  }
    var patient:Patient!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    plusButton.layer.cornerRadius = 25

    tableView.tableFooterView = UIView()
    VitalSignCell.register(with: tableView)
    MedicationCell.register(with: tableView)
    DiagnosisCell.register(with: tableView)
    AllergyFindingComplaintHistoryCell.register(with: tableView)
    RadTestCell.register(with: tableView)
    ScoringCell.register(with: tableView)
    DietaryCell.register(with: tableView)
    LabsCell.register(with: tableView)
    OperationCatheterizationEndoscopyCell.register(with: tableView)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }
    
    @IBAction func addOntap(_ sender: Any) {
      //  navigationController?.pushViewController(patientlis, animated: <#T##Bool#>)
       // let storyboard = UIStoryboard(name: "Main", bundle: nil)
      //  let vc = storyboard.instantiateViewController(withIdentifier: "prescriptionListVC")
     //   navigationController?.pushViewController(vc, animated: true)
        navigationCoordinator?.setNavigationStatus(.atPatientList)
        var template = TemplateType.labOrder
        if presenter.overviewSection == .labExamination {
            let args = ["viewType":"order",
                        "templateType":template,
                        "patient":patient,
                        "user":presenter.user] as [String : Any]
            navigationCoordinator?.next(arguments: args)
        }else if presenter.overviewSection == .radTest {
            template = .radOrder
            let args = ["viewType":"order",
                        "patient":patient,
                        "templateType":template,
                        "user":presenter.user] as [String : Any]
            navigationCoordinator?.next(arguments: args)
        }
        
    }
    

  func configure(with presenter: OverviewSectionDetailsPresenter,
                 navigationCoordinator: NavigationCoordinator,
                 vitalSignCellMaker: @escaping DependencyRegistry.VitalSignCellMaker,
                 medicationCellMaker: @escaping DependencyRegistry.MedicationCellMaker,
                 diagnosisCellMaker: @escaping DependencyRegistry.DiagnosisCellMaker,
                 allergyFindingComplaintHistoryCellMaker: @escaping DependencyRegistry.AllergyFindingComplaintHistoryCellMaker,
                 radTestCellMaker: @escaping DependencyRegistry.RadTestCellMaker,
                 scoringCellMaker: @escaping DependencyRegistry.ScoringCellMaker,
                 operationCatherEndoscopyCellMaker:  @escaping DependencyRegistry.OperationCatheterizationEndoscopyCellMaker,
                 clinicalServiceCellMaker: @escaping DependencyRegistry.ClinicalServiceCellMaker,
                 dietaryCellMaker: @escaping DependencyRegistry.DietaryCellMaker) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
    self.vitalSignCellMaker = vitalSignCellMaker
    self.medicationCellMaker = medicationCellMaker
    self.diagnosisCellMaker = diagnosisCellMaker
    self.allergyFindingComplaintHistoryCellMaker = allergyFindingComplaintHistoryCellMaker
    self.radTestCellMaker = radTestCellMaker
    self.scoringCellMaker = scoringCellMaker
    self.operationCatherEndoscopyCellMaker = operationCatherEndoscopyCellMaker
    self.clinicalServiceCellMaker = clinicalServiceCellMaker
    self.dietaryCellMaker = dietaryCellMaker
  }
}

extension OverviewSectionDetailsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch presenter.overviewSection {
    case .vitalSigns: return presenter.patientSummary.vitalSigns?.count ?? 0
    case .progressNotes: return presenter.patientSummary.nurseRemarks?.count ?? 0
    case .medication: return presenter.patientSummary.medications?.count ?? 0
    case .diagnosis: return presenter.patientSummary.diagnosis?.count ?? 0
    case .labExamination: return presenter.patientSummary.labs?.count ?? 0
    case .radTest: return presenter.patientSummary.rads?.count ?? 0
    case .scoring: return presenter.patientSummary.scorings?.count ?? 0
    case .finding: return presenter.patientSummary.findings?.count ?? 0
    case .complaints: return presenter.patientSummary.complaints?.count ?? 0
    case .history: return presenter.patientSummary.history?.count ?? 0
    case .operation: return presenter.patientSummary.operations?.count ?? 0
    case .catheterization: return presenter.patientSummary.catheters?.count ?? 0
    case .endoscopy: return presenter.patientSummary.endoscopies?.count ?? 0
    case .dietary: return presenter.patientSummary.dietaries?.count ?? 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch presenter.overviewSection {
    case .vitalSigns: return vitalSignCellMaker(tableView, indexPath, presenter.patientSummary.vitalSigns![indexPath.row])
    case .progressNotes: break
    case .medication: return medicationCellMaker(tableView, indexPath, presenter.patientSummary.medications![indexPath.row])
    case .diagnosis: return diagnosisCellMaker(tableView, indexPath, presenter.patientSummary.diagnosis![indexPath.row])
    //case .allergies: return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.allergies![indexPath.row])
    case .finding: return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.findings![indexPath.row])
    case .complaints:  return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.findings![indexPath.row])
    case .history: return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.history![indexPath.row])
    case .labExamination:
        let labs = presenter.patientSummary.labs ?? []
        return labCellMaker(tableView,indexPath,labs[indexPath.row])
    case .radTest:
      let radTestCell = radTestCellMaker(tableView, indexPath, presenter.patientSummary.rads![indexPath.row])
      radTestCell.packsHistory.tag = indexPath.row
      radTestCell.preview.tag = indexPath.row
      radTestCell.packsHistory.addTarget(self, action: #selector(didTapRadPacksHistory), for: .touchUpInside)
      radTestCell.preview.addTarget(self, action: #selector(didTapRadPacksHistory), for: .touchUpInside)
    case .scoring: return scoringCellMaker(tableView, indexPath, presenter.patientSummary.scorings![indexPath.row])
    case .operation: return operationCatherEndoscopyCellMaker(tableView, indexPath, presenter.patientSummary.operations![indexPath.row])
    case .catheterization: return operationCatherEndoscopyCellMaker(tableView, indexPath, presenter.patientSummary.catheters![indexPath.row])
    case .endoscopy: return operationCatherEndoscopyCellMaker(tableView, indexPath, presenter.patientSummary.endoscopies![indexPath.row])
    //case .clinicServices: return clinicalServiceCellMaker(tableView, indexPath, presenter.patientSummary.clinicServices![indexPath.row])
    case .dietary: return dietaryCellMaker(tableView, indexPath, presenter.patientSummary.dietaries![indexPath.row])
    }
    return UITableViewCell()
  }
}

extension OverviewSectionDetailsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch presenter.overviewSection {
    case .vitalSigns: return VitalSignCell.dequeueHeader(from: tableView)
    case .progressNotes: break
    case .medication: return MedicationCell.dequeueHeader(from: tableView)
    case .diagnosis: return DiagnosisCell.dequeueHeader(from: tableView)
    case .finding, .complaints, .history: return AllergyFindingComplaintHistoryCell.dequeueHeader(from: tableView)
    case .labExamination: return LabsCell.dequeueHeader(from: tableView)
    case .radTest: return nil
    case .scoring: return ScoringCell.dequeueHeader(from: tableView)
    case .operation, .catheterization, .endoscopy: return OperationCatheterizationEndoscopyCell.dequeueHeader(from: tableView)
    //case .clinicServices: return ClinicServiceCell.dequeueHeader(from: tableView)
    case .dietary: return DietaryCell.dequeueHeader(from: tableView)
    }
    return nil
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      if presenter.overviewSection == .radTest ||   presenter.overviewSection == .labExamination {
          return .zero
      }
    return OverviewSectionDetailsViewController.Constant.headerHeight
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch presenter.overviewSection {
    case .medication, .diagnosis, .scoring, /*.allergies,*/ .finding, .complaints, .history,
         .operation, .catheterization, .endoscopy: return UITableViewAutomaticDimension
    default: return OverviewSectionDetailsViewController.Constant.rowHeight
    }
  }
}

extension OverviewSectionDetailsViewController {
  @objc func didTapRadPacksHistory(sender: UIButton) {
    presenter.getPacksURL(selectedRadRowIndex: sender.tag) { packsURL in
      guard let url = packsURL else { return }
      self.navigationCoordinator?.next(arguments: ["url": url])
    }
  }
  @objc func didTapRadPreview(sender: UIButton) {}
}
