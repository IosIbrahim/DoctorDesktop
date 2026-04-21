//
//  OverviewSectionDetailsTableViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/21/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class OverviewSectionDetailsViewController: UIViewController {
    @IBOutlet weak var txfNote: UITextField!
    @IBOutlet weak var stkAddNote: UIStackView!
    @IBOutlet weak var lblReplyDes: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var stkReply: UIStackView!
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

    tableView.tableFooterView = UIView()
    addTableViewHorizontalPadding(12)
    VitalSignCell.register(with: tableView)
    MedicationCell.register(with: tableView)
    DiagnosisCell.register(with: tableView)
    AllergyFindingComplaintHistoryCell.register(with: tableView)
    RadTestCell.register(with: tableView)
    ScoringCell.register(with: tableView)
    DietaryCell.register(with: tableView)
    LabsCell.register(with: tableView)
    OperationCatheterizationEndoscopyCell.register(with: tableView)

    plusButton.isHidden = true
    stkAddNote.isHidden = true
    stkReply.isHidden = true

    let showPlus = presenter.overviewSection == .vitalSigns
                || presenter.overviewSection == .labExamination
                || presenter.overviewSection == .radTest
    plusButton.isHidden = !showPlus

    if presenter.overviewSection == .progressNotes {
        stkAddNote.isHidden = false
    }

    styleFAB()
    insertPatientHeaderCard()
  }

  // MARK: - Patient header card

  private var patientHeaderContainer: UIView?

  /// Builds a teal patient-header card identical to the one in
  /// VitalSignsEntryViewController and pins it as the tableHeaderView so it
  /// scrolls with the content.
  private func insertPatientHeaderCard() {
    let teal = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)

    // Container — frame will be corrected in viewDidLayoutSubviews
    let container = UIView()
    container.backgroundColor = tableView.backgroundColor ?? view.backgroundColor ?? .clear

    // Card
    let card = UIView()
    card.backgroundColor = teal
    card.layer.cornerRadius = 10
    card.layer.masksToBounds = true
    card.translatesAutoresizingMaskIntoConstraints = false

    // Person icon
    let icon = UIImageView()
    icon.tintColor = .white
    icon.contentMode = .scaleAspectFit
    if #available(iOS 13, *) {
      icon.image = UIImage(systemName: "person.crop.circle.fill")
    }
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.widthAnchor.constraint(equalToConstant: 36).isActive = true
    icon.heightAnchor.constraint(equalToConstant: 36).isActive = true
    icon.setContentHuggingPriority(.required, for: .horizontal)

    // Name
    let nameLabel = UILabel()
    nameLabel.text = patient.name.isEmpty ? "-" : patient.name
    nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    nameLabel.textColor = .white
    nameLabel.numberOfLines = 1

    // Subtitle: nationality • date
    let nat  = patient.nationality
    let date = patient.date
    let subtitle: String
    if !nat.isEmpty && !date.isEmpty { subtitle = "\(nat) • \(date)" }
    else if !nat.isEmpty             { subtitle = nat }
    else                             { subtitle = date }

    let subLabel = UILabel()
    subLabel.text = subtitle
    subLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    subLabel.textColor = UIColor.white.withAlphaComponent(0.9)
    subLabel.numberOfLines = 1

    // Text stack
    let textStack = UIStackView(arrangedSubviews: [nameLabel, subLabel])
    textStack.axis = .vertical
    textStack.spacing = 2

    // Horizontal row
    let row = UIStackView(arrangedSubviews: [icon, textStack])
    row.axis = .horizontal
    row.spacing = 12
    row.alignment = .center
    row.translatesAutoresizingMaskIntoConstraints = false

    card.addSubview(row)
    NSLayoutConstraint.activate([
      row.topAnchor.constraint(equalTo: card.topAnchor,    constant:  14),
      row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
      row.leadingAnchor.constraint(equalTo: card.leadingAnchor,  constant:  14),
      row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
    ])

    // Card inside container (12pt top, 8pt bottom gap before the table)
    container.addSubview(card)
    NSLayoutConstraint.activate([
      card.topAnchor.constraint(equalTo: container.topAnchor,    constant:  12),
      card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
    ])

    patientHeaderContainer = container
    tableView.tableHeaderView = container
    refreshHeaderFrame()
  }

  /// Recalculates and applies the tableHeaderView frame height so Auto Layout
  /// children size correctly. Called from viewDidLayoutSubviews.
  private func refreshHeaderFrame() {
    guard let header = patientHeaderContainer else { return }
    let w = tableView.bounds.width > 0 ? tableView.bounds.width : UIScreen.main.bounds.width - 24
    header.frame.size.width = w
    header.setNeedsLayout()
    header.layoutIfNeeded()
    let h = header.systemLayoutSizeFitting(
      CGSize(width: w, height: UILayoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: UILayoutPriority(rawValue: 50)
    ).height
    if abs(header.frame.size.height - h) > 0.5 {
      header.frame.size.height = h
      tableView.tableHeaderView = header   // re-assign triggers UITableView reflow
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    refreshHeaderFrame()
  }

  // MARK: - Layout helpers

  /// Shrinks the tableView horizontally by updating its storyboard leading/trailing
  /// constraints, so every cell gets natural side margins without touching any XIB.
  private func addTableViewHorizontalPadding(_ padding: CGFloat) {
    for constraint in view.constraints {
      if constraint.firstItem as? UIView == tableView {
        if constraint.firstAttribute == .leading  { constraint.constant =  padding }
        if constraint.firstAttribute == .trailing { constraint.constant = -padding }
      } else if constraint.secondItem as? UIView == tableView {
        if constraint.secondAttribute == .leading  { constraint.constant =  padding }
        if constraint.secondAttribute == .trailing { constraint.constant = -padding }
      }
    }
  }

  // MARK: - FAB styling
  private func styleFAB() {
    plusButton.layer.cornerRadius  = 28
    plusButton.clipsToBounds       = false
    plusButton.backgroundColor     = UIColor(red: 0.24, green: 0.74, blue: 0.64, alpha: 1) // teal
    plusButton.tintColor           = .white
    plusButton.setTitle("+", for: .normal)
    plusButton.titleLabel?.font    = UIFont.systemFont(ofSize: 32, weight: .light)
    plusButton.setTitleColor(.white, for: .normal)

    // Drop shadow
    plusButton.layer.shadowColor   = UIColor.black.cgColor
    plusButton.layer.shadowOffset  = CGSize(width: 0, height: 4)
    plusButton.layer.shadowRadius  = 8
    plusButton.layer.shadowOpacity = 0.25
  }
    
    
    
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }
    
    @IBAction func addNoteOnTap(_ sender: Any) {
        // add new note or reply to note
    }
    
    @IBAction func sufferOnTap(_ sender: Any) {
        // help popup
        openHelpScreen(["dd","sdsd","asdsd"])
    }
    
    @IBAction func statusNoteOnTap(_ sender: Any) {
        // status popup
        openHelpScreen([])
    }
    
    func openHelpScreen(_ dataSources:[String]) {
        let vc = HelpController()
        vc.dataSources = dataSources
        present(vc, animated: true)
    }
    
    @IBAction func addOntap(_ sender: Any) {
        if presenter.overviewSection == .vitalSigns {
            // Reuse EmergencyTriageViewController for vital-sign entry
            navigationCoordinator?.setNavigationStatus(.atOverviewSectionDetails)
            let args: [String: Any] = [
                "viewType": "vitalSigns",
                "patient" : patient,
                "user"    : presenter.user
            ]
            navigationCoordinator?.next(arguments: args)
            return
        }

        navigationCoordinator?.setNavigationStatus(.atPatientList)
        var template = TemplateType.labOrder
        if presenter.overviewSection == .labExamination {
            let args = ["viewType":"order",
                        "templateType":template,
                        "patient":patient,
                        "user":presenter.user] as [String : Any]
            navigationCoordinator?.next(arguments: args)
        } else if presenter.overviewSection == .radTest {
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
    case .pathology, .operationRequest, .bloodBank, .medicalReport: return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch presenter.overviewSection {
    case .vitalSigns: return vitalSignCellMaker(tableView, indexPath, presenter.patientSummary.vitalSigns![indexPath.row])
    case .progressNotes:
        let cell = tableView.dequeueReusableCell(withIdentifier: NotesCell.cellId, for: indexPath) as! NotesCell
        if let model = presenter.patientSummary.nurseRemarks?[indexPath.row] {
            cell.drawCell(model)
        }
        return cell
    case .medication: return medicationCellMaker(tableView, indexPath, presenter.patientSummary.medications![indexPath.row])
    case .diagnosis: return diagnosisCellMaker(tableView, indexPath, presenter.patientSummary.diagnosis![indexPath.row])
    //case .allergies: return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.allergies![indexPath.row])
    case .finding: return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.complaints![indexPath.row])
    case .complaints:  return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.complaints![indexPath.row])
    case .history: return allergyFindingComplaintHistoryCellMaker(tableView, indexPath, presenter.patientSummary.complaints![indexPath.row])
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
    case .pathology, .operationRequest, .bloodBank, .medicalReport: break
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
    case .pathology, .operationRequest, .bloodBank, .medicalReport: break
    }
    return nil
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      if presenter.overviewSection == .radTest ||   presenter.overviewSection == .labExamination {
          return .zero
      }
     if presenter.overviewSection == .complaints  {
          return .zero
      }
    return OverviewSectionDetailsViewController.Constant.headerHeight
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch presenter.overviewSection {
    case .medication, .diagnosis, .scoring, /*.allergies,*/ .finding, .complaints, .history,
         .operation, .catheterization, .endoscopy: return UITableViewAutomaticDimension
    case .vitalSigns:return UITableViewAutomaticDimension
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
