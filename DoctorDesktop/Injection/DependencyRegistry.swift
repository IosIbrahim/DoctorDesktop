import UIKit
import Swinject
import SwinjectStoryboard

protocol DependencyRegistry {
  var container: Container { get }
  var navigationCoordinator: NavigationCoordinator! { get }

  func makeRootNavigationCoordinator(rootViewController: UIViewController) -> NavigationCoordinator
  func makeComponentCollectionViewController(with components: Components, user: User) -> ComponentCollectionViewController
  func makePatientsViewController(with componentType: ComponentType, user: User) -> PatientsViewController
  func makePatientOverviewViewController(with patient: Patient, user: User) -> PatientOverviewViewController
  func makeUnitsPopup(with title: String, patientUnits: PatientUnits) -> UnitsPopup
  func makeOrderCollectionViewController(with patient: Patient, templateType: TemplateType, user: User) -> OrderCollectionViewController
  func makeOrderServiceList(with patient: Patient, serviceCategory: ServiceCategory, templateType: TemplateType, generalParams: GeneralParams, user: User) -> OrderServiceList
  func makeOrderCheckoutList(with serviceDetails: ServicesDetails, templateType: TemplateType, user: User, labOrderServiceListPresenter: OrderServiceListPresenter?, patient: Patient, requestDoctor: String) -> OrderCheckoutList
  func makeOverviewCollectionViewController(with patient: Patient, user: User) -> OverviewCollectionViewController
  func makeOverviewSectionDetailsViewController(overviewSection: OverviewSection, patientSummary: PatientSummary, user: User) -> OverviewSectionDetailsViewController
  func makeWebViewerViewController(url: URL) -> WebViewerViewController
  func makeEmergencyTriageViewController(with patient: EmergencyPatient, user: User) -> EmergencyTriageViewController

  typealias rootNavigationCoordinatorMaker = (UIViewController) -> NavigationCoordinator
  typealias ComponentCellMaker = (UICollectionView, IndexPath, Component, ColorAndImageTuple) -> ComponentCell
  typealias InpatientCellMaker = (UITableView, IndexPath, InpatientPatient) -> InpatientCell
  typealias OutpatientCellMaker = (UITableView, IndexPath, OutpatientPatient) -> OutpatientCell
  typealias EmergencyCellMaker = (UITableView, IndexPath, EmergencyPatient) -> EmergencyCell
  typealias ClinicalAlertCellMaker = (UITableView, IndexPath, ClinicalPatient) -> ClinicalAlertCell
  typealias ClinicalInfoPopupMaker = (ClinicalPatient) -> ClinicalInfoPopup
  typealias ClinicalInfoPopupCellMaker = (UITableView, IndexPath, ClinicalPatientInfo) -> ClinicalInfoPopupCell
  typealias PatientOverviewViewControllerMaker = (Patient, User) -> PatientOverviewViewController
  typealias UnitsPopupMaker = (String, PatientUnits) -> UnitsPopup
  typealias OrderCellMaker = (UICollectionView, IndexPath, ServiceCategory) -> OrderCell
  typealias OrderServiceCellMaker = (UITableView, IndexPath, Service) -> OrderServiceCell
  typealias OrderCheckoutCellMaker = (UITableView, IndexPath, ServiceDetails) -> OrderCheckoutCell
  typealias OverviewSectionCellMaker = (UICollectionView, IndexPath, String, String, UIColor, Int) -> OverviewSectionCell
  typealias PatientHistoryFiltrationCellMaker = (UICollectionView, IndexPath, PatientHistoryFiltrationType) -> PatientHistoryFiltrationCell
  typealias VitalSignCellMaker = (UITableView, IndexPath, VitalSign) -> VitalSignCell
  typealias MedicationCellMaker = (UITableView, IndexPath, Medication) -> MedicationCell
  typealias DiagnosisCellMaker = (UITableView, IndexPath, Diagnosis) -> DiagnosisCell
  typealias AllergyFindingComplaintHistoryCellMaker = (UITableView, IndexPath, AllergyFindingComplaintHistory) -> AllergyFindingComplaintHistoryCell
  typealias RadTestCellMaker = (UITableView, IndexPath, Rad) -> RadTestCell
  typealias ScoringCellMaker = (UITableView, IndexPath, Scoring) -> ScoringCell
  typealias OperationCatheterizationEndoscopyCellMaker = (UITableView, IndexPath, OperationCatherEndoscopy) -> OperationCatheterizationEndoscopyCell
  typealias ClinicalServiceCellMaker = (UITableView, IndexPath, ClinicService) -> ClinicServiceCell
  typealias DietaryCellMaker = (UITableView, IndexPath, Dietary) -> DietaryCell
  typealias SymptomCategoryCellMaker = (UITableView, IndexPath, EmergencyPatient) -> SymptomCategoryCell
  typealias SymptomCellMaker = (UITableView, IndexPath, EmergencyPatient) -> SymptomCell
  typealias VitalCellMaker = (UICollectionView, IndexPath, String?, Vital) -> VitalCell
  typealias DiagnosisCategoryPopUpMaker = (DiagnosisCategories) -> DiagnosisCategoryPopUp
  typealias PediatricsScorePopUpMaker = (PediatricsScoreElements, [PediatricsScoreChoice]) -> PediatricsScorePopUp
}

class DependencyRegistryImpl: DependencyRegistry {
  var container: Container
  var navigationCoordinator: NavigationCoordinator!

  init(container: Container) {
    Container.loggingFunction = nil
    
    self.container = container
    
    registerDependencies()
    registerPresenters()
    registerViewControllers()
  }
  
  func registerDependencies() {
    container.register(NavigationCoordinator.self) { (r, rootViewController: UIViewController) in
      RootNavigationCoordinatorImpl(with: rootViewController, registry: self)
    }.inObjectScope(.container)
    
    container.register(NetworkLayer.self    ) { _ in NetworkLayerImpl()    }.inObjectScope(.container)
    container.register(TranslationLayer.self) { _ in TranslationLayerImpl()}.inObjectScope(.container)
    
    container.register(ModelLayer.self){ r in
      ModelLayerImpl(networkLayer:     r.resolve(NetworkLayer.self)!,
                     translationLayer: r.resolve(TranslationLayer.self)!)
      }.inObjectScope(.container)
  }
  
  func registerPresenters() {
    container.register(LoginPresenter.self) { r in LoginPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!) }
    container.register(ComponentCollectionPresenter.self) { (r, components: Components, user: User) in
      ComponentCollectionPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!, components: components, user: user)
    }
    container.register(ComponentCellPresenter.self) { (_, component: Component, colorAndImage: ColorAndImageTuple) in
      ComponentCellPresenterImpl(withComponent: component, colorAndImage: colorAndImage)
    }
    container.register(PatientsPresenter.self) { (r, componentType: ComponentType, user: User) in
        
      PatientsPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!, componentType: componentType, user: user)
    }
    container.register(InpatientCellPresenter.self) { (r, inpatientPatient: InpatientPatient) in
      InpatientCellPresenterImpl(with: inpatientPatient)
    }
    container.register(OutpatientCellPresenter.self) { (r, outpatientPatient: OutpatientPatient) in
      OutpatientCellPresenterImpl(with: outpatientPatient)
    }
    container.register(EmergencyCellPresenter.self) { (r, emergencyPatient: EmergencyPatient) in
      EmergencyCellPresenterImpl(with: emergencyPatient)
    }
    container.register(ClinicalAlertCellPresenter.self) { (r, clinicalPatient: ClinicalPatient) in
      ClinicalAlertCellPresenterImpl(with: clinicalPatient)
    }
    container.register(ClinicalInfoPopupPresenter.self) { (r, clinicalPatient: ClinicalPatient) in
      ClinicalInfoPopupPresenterImpl(clinicalPatient: clinicalPatient)
    }
    container.register(ClinicalInfoPopupCellPresenter.self) { (r, clinicalPatientInfo: ClinicalPatientInfo) in
      ClinicalInfoPopupCellPresenterImpl(with: clinicalPatientInfo)
    }
    container.register(PatientOverviewPresenter.self) { (r, patient: Patient, user: User) in
      PatientOverviewPresenterImpl(patient: patient, user: user)
    }
    container.register(UnitsPopupPresenter.self) { (r, title: String, patientUnits: PatientUnits) in
      UnitsPopupPresenterImpl(withTitle: title, patientUnits: patientUnits)
    }
    container.register(OrderCollectionPresenter.self) { (r, patient: Patient, templateType: TemplateType, user: User) in
      OrderCollectionPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!, patient: patient, templateType: templateType, user: user)
    }
    container.register(OrderServiceListPresenter.self) { (r, patient: Patient, serviceCategory: ServiceCategory, templateType: TemplateType, generalParams: GeneralParams, user: User) in
      OrderServiceListPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!, patient: patient, serviceCategory: serviceCategory, templateType: templateType, generalParams: generalParams, user: user)
    }
    container.register(OrderCellPresenter.self) { (r, serviceCategory: ServiceCategory) in
      OrderCellPresenterImpl(withSericeCategory: serviceCategory)
    }
    container.register(OrderServiceCellPresenter.self) { (r, service: Service) in
      OrderServiceCellPresenterImpl(withService: service)
    }
    container.register(OrderCheckoutListPresenter.self.self) { (r, serviceDetails: ServicesDetails, templateType: TemplateType, user: User, labOrderServiceListPresenter: OrderServiceListPresenter?, patient: Patient, requestDoctor: String) in
      OrderCheckoutListPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!,servicesDetails: serviceDetails, templateType: templateType, user: user, labOrderServiceListPresenter: labOrderServiceListPresenter, patient: patient, requestDoctor: requestDoctor)
    }
    container.register(OrderCheckoutCellPresenter.self) { (r, serviceDetails: ServiceDetails) in
      OrderCheckoutCellPresenterImpl(withServiceDetails: serviceDetails)
    }

    registerOverviewPresenter()
    registerPatientHistoryFiltrationCellPresenter()
    registerOverviewSectionCellPresenter()
    registerOverviewSectionDetailsPresenter()
    registerVitalSignCellPresenter()
    registerMedicationCellPresenter()
    registerDiagnosisCellPresenter()
    registerAllergyFindingComplaintHistoryCellPresenter()
    registerRadTestCellPresenter()
    registerWebViewerPresenter()
    registerScoringCellPresenter()
    registerOperationCatherEndoscopyCellPresenter()
    registerClinicalServiceCellPresenter()
    registerDietaryCellPresenter()
    registerEmergencyTriagePresenter()
    registerVitalCellPresenter()
  }
  
  func registerViewControllers() {
    container.register(ComponentCollectionViewController.self) { (r, components: Components, user: User) in
      let presenter = r.resolve(ComponentCollectionPresenter.self, arguments: components, user)!
      //NOTE: We don't have access to the constructor for this VC so we are using method injection
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ComponentCollectionViewController") as! ComponentCollectionViewController
      vc.configure(with: presenter,
                   componentCellMaker: self.makeComponentCell,
                   navigationCoordinator: self.navigationCoordinator)
      return vc
    }
    
    container.register(PatientsViewController.self) { (r, componentType: ComponentType, user: User) in
      let presenter = r.resolve(PatientsPresenter.self, arguments: componentType, user)!
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PatientsViewController") as! PatientsViewController
      vc.configure(with: presenter,
                   inpatientCellMaker: self.makeInpatientCell,
                   outpatientCellMaker: self.makeOutpatientCell,
                   emergencyCellMaker: self.makeEmergencyCell,
                   clinicalAlertCellMaker: self.makeClinicalAlertCell,
                   patientOverviewViewControllerMaker: self.makePatientOverviewViewController,
                   unitsPopupMaker: self.makeUnitsPopup,
                   clinicalInfoPopupMaker: self.makeClinicalInfoPopup,
                   navigationCoordinator: self.navigationCoordinator)
      return vc
    }
    
    container.register(PatientOverviewViewController.self) { (r, patient: Patient, user: User) in
      let presenter = r.resolve(PatientOverviewPresenter.self, arguments: patient, user)!
      let vc = PatientOverviewViewController()
      vc.configure(with: presenter,
                   navigationCoordinator: self.navigationCoordinator)
      return vc
    }
    
    container.register(UnitsPopup.self) { (r, title: String, patientUnits: PatientUnits) in
      let presenter = r.resolve(UnitsPopupPresenter.self, arguments: title, patientUnits)!
      let vc = UnitsPopup(with: presenter)
      return vc
    }
    
    container.register(OrderCollectionViewController.self) { (r, patient: Patient, templateType: TemplateType, user: User) in
      let presenter = r.resolve(OrderCollectionPresenter.self, arguments: patient, templateType, user)!
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderCollectionViewController") as! OrderCollectionViewController
      vc.configure(with: presenter,
                   orderCellMaker: self.makeOrderCell,
                   navigationCoordinator: self.navigationCoordinator)
      return vc
    }
    
    container.register(OrderServiceList.self) { (r, patient: Patient, serviceCategory: ServiceCategory, templateType: TemplateType, generalParams: GeneralParams, user: User) in
      let presenter = r.resolve(OrderServiceListPresenter.self, arguments: patient, serviceCategory, templateType, generalParams, user)!
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderServiceList") as! OrderServiceList
      vc.configure(with: presenter,
                   orderServiceCellMaker: self.makeOrderServiceCell,
                   navigationCoordinator: self.navigationCoordinator)
      return vc
    }
    
    container.register(OrderCheckoutList.self) { (r, serviceDetails: ServicesDetails, templateType: TemplateType, user: User, labOrderServiceListPresenter: OrderServiceListPresenter?, patient: Patient, requestDoctor: String) in
      let presenter = r.resolve(OrderCheckoutListPresenter.self, arguments: serviceDetails, templateType, user, labOrderServiceListPresenter, patient, requestDoctor)!
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderCheckoutList") as! OrderCheckoutList
      vc.configure(with: presenter,
                   orderCheckoutCellMaker: self.makeOrderCheckoutCell,
                   navigationCoordinator: self.navigationCoordinator)
      return vc
    }

    registerOverviewCollectionViewController()
    registerOverviewSectionDetailsViewController()
    registerWebViewerViewController()
    registerEmergencyTriageViewController()
  }
  
  //MARK: - Maker Methods
  
  func makeRootNavigationCoordinator(rootViewController: UIViewController) -> NavigationCoordinator {
    navigationCoordinator = container.resolve(NavigationCoordinator.self, argument: rootViewController)!
    return navigationCoordinator
  }
  
  func makeComponentCollectionViewController(with components: Components, user: User) -> ComponentCollectionViewController {
    return container.resolve(ComponentCollectionViewController.self, arguments: components, user)!
  }
  
  func makeComponentCell(for collectionView: UICollectionView, at indexPath: IndexPath, component: Component, colorAndImage: ColorAndImageTuple) -> ComponentCell {
    let presenter = container.resolve(ComponentCellPresenter.self, arguments: component, colorAndImage)!
    return ComponentCell.dequeue(from: collectionView, for: indexPath, with: presenter)
  }
  
  func makePatientsViewController(with componentType: ComponentType, user: User) -> PatientsViewController {
    return container.resolve(PatientsViewController.self, arguments: componentType, user)!
  }
  
  func makeInpatientCell(for tableView: UITableView, at indexPath: IndexPath, inpatientPatient: InpatientPatient) -> InpatientCell {
    let presenter = container.resolve(InpatientCellPresenter.self, argument: inpatientPatient)!
    return InpatientCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }

  func makeOutpatientCell(for tableView: UITableView, at indexPath: IndexPath, outpatientPatient: OutpatientPatient) -> OutpatientCell {
    let presenter = container.resolve(OutpatientCellPresenter.self, argument: outpatientPatient)!
    return OutpatientCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }

  func makeEmergencyCell(for tableView: UITableView, at indexPath: IndexPath, emergencyPatient: EmergencyPatient) -> EmergencyCell {
    let presenter = container.resolve(EmergencyCellPresenter.self, argument: emergencyPatient)!
    return EmergencyCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }

  func makeClinicalAlertCell(for tableView: UITableView, at indexPath: IndexPath, clinicalPatient: ClinicalPatient) -> ClinicalAlertCell {
    let presenter = container.resolve(ClinicalAlertCellPresenter.self, argument: clinicalPatient)!
    return ClinicalAlertCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }

  func makeClinicalInfoPopup(clinicalPatient: ClinicalPatient) -> ClinicalInfoPopup {
    let presenter = container.resolve(ClinicalInfoPopupPresenter.self, argument: clinicalPatient)!
    return ClinicalInfoPopup(with: presenter, clinicalInfoPopupCellMaker: makeClinicalInfoPopupCell)
  }

  func makeClinicalInfoPopupCell(for tableView: UITableView, at indexPath: IndexPath, clinicalPatientInfo: ClinicalPatientInfo) -> ClinicalInfoPopupCell {
    let presenter = container.resolve(ClinicalInfoPopupCellPresenter.self, argument: clinicalPatientInfo)!
    return ClinicalInfoPopupCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }

  func makePatientOverviewViewController(with patient: Patient, user: User) -> PatientOverviewViewController {
    return container.resolve(PatientOverviewViewController.self, arguments: patient, user)!
  }
  
  func makeUnitsPopup(with title: String, patientUnits: PatientUnits) -> UnitsPopup {
    return container.resolve(UnitsPopup.self, arguments: title, patientUnits)!
  }
  
  func makeOrderCollectionViewController(with patient: Patient, templateType: TemplateType, user: User) -> OrderCollectionViewController {
    return container.resolve(OrderCollectionViewController.self, arguments: patient, templateType, user)!
  }
  
  func makeOrderServiceList(with patient: Patient, serviceCategory: ServiceCategory, templateType: TemplateType, generalParams: GeneralParams, user: User) -> OrderServiceList {
    return container.resolve(OrderServiceList.self, arguments: patient, serviceCategory, templateType, generalParams, user)!
  }
  
  func makeOrderCell(for collectionView: UICollectionView, at indexPath: IndexPath, serviceCategory: ServiceCategory) -> OrderCell {
    let presenter = container.resolve(OrderCellPresenter.self, argument: serviceCategory)!
    return OrderCell.dequeue(from: collectionView, for: indexPath, with: presenter)
  }
  
  func makeOrderServiceCell(for tableView: UITableView, at indexPath: IndexPath, service: Service) -> OrderServiceCell {
    let presenter = container.resolve(OrderServiceCellPresenter.self, argument: service)!
    return OrderServiceCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  
  func makeOrderCheckoutList(with serviceDetails: ServicesDetails, templateType: TemplateType, user: User, labOrderServiceListPresenter: OrderServiceListPresenter?, patient: Patient, requestDoctor: String) -> OrderCheckoutList {
    return container.resolve(OrderCheckoutList.self, arguments: serviceDetails, templateType, user, labOrderServiceListPresenter, patient, requestDoctor)!
  }
  
  func makeOrderCheckoutCell(for tableView: UITableView, at indexPath: IndexPath, serviceDetails: ServiceDetails) -> OrderCheckoutCell {
    let presenter = container.resolve(OrderCheckoutCellPresenter.self, argument: serviceDetails)!
    return OrderCheckoutCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
}


extension DependencyRegistryImpl {
  func registerOverviewCollectionViewController() {
    container.register(OverviewCollectionViewController.self) { (r, patient: Patient, user: User) in
      let presenter = r.resolve(OverviewPresenter.self, arguments: patient, user)!
      //NOTE: We don't have access to the constructor for this VC so we are using method injection
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OverviewCollectionViewController") as! OverviewCollectionViewController
      vc.configure(with: presenter,
                   patientHistoryFiltrationCellMaker: self.makePatientHistoryFiltrationCell,
                   overviewSectionCellMaker: self.makeOverViewSectionCell,
                   navigationCoordinator: self.navigationCoordinator)
      return vc
    }
  }

  func registerOverviewPresenter() {
    container.register(OverviewPresenter.self) { (r, patient: Patient, user: User) in
      OverviewPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!, patient: patient, user: user)
    }
  }

  func registerOverviewSectionCellPresenter() {
    container.register(OverviewSectionCellPresenter.self) { (r, sectionImageName: String, sectionTitle: String, sectionColor: UIColor, counter: Int) in
      OverviewSectionCellPresenterImpl(sectionImageName: sectionImageName, sectionTitle: sectionTitle, sectionColor: sectionColor, counter: counter)
    }
  }

  func registerPatientHistoryFiltrationCellPresenter() {
    container.register(PatientHistoryFiltrationCellPresenter.self) { (r, patientHistoryFiltrationType: PatientHistoryFiltrationType) in
      PatientHistoryFiltrationCellPresenterImpl(patientHistoryFiltrationType: patientHistoryFiltrationType)
    }
  }

  func makeOverviewCollectionViewController(with patient: Patient, user: User) -> OverviewCollectionViewController {
    return container.resolve(OverviewCollectionViewController.self, arguments: patient, user)!
  }

  func makeOverViewSectionCell(for collectionView: UICollectionView, at indexPath: IndexPath, sectionImageName: String, sectionTitle: String, sectionColor: UIColor, counter: Int) -> OverviewSectionCell {
    let presenter = container.resolve(OverviewSectionCellPresenter.self, arguments: sectionImageName, sectionTitle, sectionColor, counter)!
    return OverviewSectionCell.dequeue(from: collectionView, for: indexPath, with: presenter)
  }

  func makePatientHistoryFiltrationCell(for collectionView: UICollectionView, at indexPath: IndexPath, patientHistoryFiltrationType: PatientHistoryFiltrationType) -> PatientHistoryFiltrationCell {
    let presenter = container.resolve(PatientHistoryFiltrationCellPresenter.self, argument: patientHistoryFiltrationType)!
    return PatientHistoryFiltrationCell.dequeue(from: collectionView, for: indexPath, with: presenter)
  }
}

extension DependencyRegistryImpl {
  func registerOverviewSectionDetailsPresenter() {
    container.register(OverviewSectionDetailsPresenter.self) { (r, overviewSection: OverviewSection, patientSummary: PatientSummary, user: User) in
      OverviewSectionDetailsPresenterImpl(modelLayer: r.resolve(ModelLayer.self)!, overviewSection: overviewSection,patientSummary: patientSummary, user: user)
    }
  }
  func registerOverviewSectionDetailsViewController() {
    container.register(OverviewSectionDetailsViewController.self) { (r, overviewSection: OverviewSection, patientSummary: PatientSummary, user: User) in
      let presenter = r.resolve(OverviewSectionDetailsPresenter.self, arguments: overviewSection, patientSummary, user)!
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OverviewSectionDetailsViewController") as! OverviewSectionDetailsViewController
      vc.configure(with: presenter,
                   navigationCoordinator: self.navigationCoordinator,
                   vitalSignCellMaker: self.makeVitalSignCell,
                   medicationCellMaker: self.makeMedicationCell,
                   diagnosisCellMaker: self.makeDiagnosisCell,
                   allergyFindingComplaintHistoryCellMaker: self.makeAllergyFindingComplaintHistoryCell,
                   radTestCellMaker: self.makeRadCell,
                   scoringCellMaker: self.makeScoringCell,
                   operationCatherEndoscopyCellMaker: self.makeOperationCatheterizationEndoscopyCell,
                   clinicalServiceCellMaker: self.makeClinicalServiceCell,
                   dietaryCellMaker: self.makeDietaryCell)
      return vc
    }
  }
  func registerVitalSignCellPresenter() {
    container.register(VitalSignCellPresenter.self) { (r, vitalSign: VitalSign) in
      VitalSignCellPresenterImpl(withVitalSign: vitalSign)
    }
  }
  func registerMedicationCellPresenter() {
    container.register(MedicationCellPresenter.self) { (r, medication: Medication) in
      MedicationCellPresenterImpl(with: medication)
    }
  }
  func registerDiagnosisCellPresenter() {
    container.register(DiagnosisCellPresenter.self) { (r, diagnosis: Diagnosis) in
      DiagnosisCellPresenterImpl(with: diagnosis)
    }
  }
  func registerAllergyFindingComplaintHistoryCellPresenter() {
    container.register(AllergyFindingComplaintHistoryCellPresenter.self) { (r, allergyFindingComplaintHistory: AllergyFindingComplaintHistory) in
      AllergyFindingComplaintHistoryCellPresenterImpl(with: allergyFindingComplaintHistory)
    }
  }
  func registerRadTestCellPresenter() {
    container.register(RadTestCellPresenter.self) { (r, radTest: Rad) in
      RadTestCellPresenterImpl(with: radTest)
    }
  }
  func registerScoringCellPresenter() {
    container.register(ScoringCellPresenter.self) { (r, scoring: Scoring) in
      ScoringCellPresenterImpl(with: scoring)
    }
  }
  func registerOperationCatherEndoscopyCellPresenter() {
    container.register(OperationCatheterizationEndoscopyCellPresenter.self) { (r, operationCatherEndoscopy: OperationCatherEndoscopy) in
      OperationCatheterizationEndoscopyCellPresenterImpl(with: operationCatherEndoscopy)
    }
  }
  func registerClinicalServiceCellPresenter() {
    container.register(ClinicServiceCellPresenter.self) { (r, clinicService: ClinicService) in
      ClinicServiceCellPresenterImpl(with: clinicService)
    }
  }
  func registerDietaryCellPresenter() {
    container.register(DietaryCellPresenter.self) { (r, dietary: Dietary) in
      DietaryCellPresenterImpl(with: dietary)
    }
  }

  func makeOverviewSectionDetailsViewController(overviewSection: OverviewSection, patientSummary: PatientSummary, user: User) -> OverviewSectionDetailsViewController {
    return container.resolve(OverviewSectionDetailsViewController.self, arguments: overviewSection, patientSummary, user)!
  }
  func makeVitalSignCell(for tableView: UITableView, at indexPath: IndexPath, vitalSign: VitalSign) -> VitalSignCell {
    let presenter = container.resolve(VitalSignCellPresenter.self, argument: vitalSign)!
    return VitalSignCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeMedicationCell(for tableView: UITableView, at indexPath: IndexPath, medication: Medication) -> MedicationCell {
    let presenter = container.resolve(MedicationCellPresenter.self, argument: medication)!
    return MedicationCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeDiagnosisCell(for tableView: UITableView, at indexPath: IndexPath, diagnosis: Diagnosis) -> DiagnosisCell {
    let presenter = container.resolve(DiagnosisCellPresenter.self, argument: diagnosis)!
    return DiagnosisCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeAllergyFindingComplaintHistoryCell(for tableView: UITableView, at indexPath: IndexPath, allergy: Allergy) -> AllergyFindingComplaintHistoryCell {
    let presenter = container.resolve(AllergyFindingComplaintHistoryCellPresenter.self, argument: allergy)!
    return AllergyFindingComplaintHistoryCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeRadCell(for tableView: UITableView, at indexPath: IndexPath, radTest: Rad) -> RadTestCell {
    let presenter = container.resolve(RadTestCellPresenter.self, argument: radTest)!
    return RadTestCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeScoringCell(for tableView: UITableView, at indexPath: IndexPath, scoring: Scoring) -> ScoringCell {
    let presenter = container.resolve(ScoringCellPresenter.self, argument: scoring)!
    return ScoringCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeOperationCatheterizationEndoscopyCell(for tableView: UITableView, at indexPath: IndexPath, operationCatherEndoscopy: OperationCatherEndoscopy) -> OperationCatheterizationEndoscopyCell {
    let presenter = container.resolve(OperationCatheterizationEndoscopyCellPresenter.self, argument: operationCatherEndoscopy)!
    return OperationCatheterizationEndoscopyCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeClinicalServiceCell(for tableView: UITableView, at indexPath: IndexPath, clinicalService: ClinicService) -> ClinicServiceCell {
    let presenter = container.resolve(ClinicServiceCellPresenter.self, argument: clinicalService)!
    return ClinicServiceCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
  func makeDietaryCell(for tableView: UITableView, at indexPath: IndexPath, dietary: Dietary) -> DietaryCell {
    let presenter = container.resolve(DietaryCellPresenter.self, argument: dietary)!
    return DietaryCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }
}

extension DependencyRegistryImpl {
  func registerWebViewerViewController() {
    container.register(WebViewerViewController.self) { (r, url: URL) in
      let presenter = r.resolve(WebViewerPresenter.self, argument: url)!
      //NOTE: We don't have access to the constructor for this VC so we are using method injection
      let vc = WebViewerViewController()
      vc.configure(with: presenter, navigationCoordinator: self.navigationCoordinator)
      return vc
    }
  }

  func registerWebViewerPresenter() {
    container.register(WebViewerPresenter.self) { (r, url: URL) in
      WebViewerPresenterImpl(url: url)
    }
  }

  func makeWebViewerViewController(url: URL) -> WebViewerViewController {
    return container.resolve(WebViewerViewController.self, argument: url)!
  }
}

extension DependencyRegistryImpl {
  func registerEmergencyTriageViewController() {
    container.register(EmergencyTriageViewController.self) { (r, patient: EmergencyPatient, user: User) in
      let presenter = r.resolve(EmergencyTriagePresenter.self, arguments: patient, user)!
      let vc = EmergencyTriageViewController()
      vc.configure(
        with: presenter,
        navigationCoordinator: self.navigationCoordinator,
        symptomCategoryCellMaker: self.makeSymptomCategoryCell,
        symptomCellMaker: self.makeSymptomCell,
        vitalCellMaker: self.makeVitalCell,
        diagnosisCategoryPopUpMaker: self.makeDiagnosisCategoryPopUp,
        pediatricsScorePopUpMaker: self.makePediatricsScorePopUp
      )
      return vc
    }
  }

  func registerEmergencyTriagePresenter() {
    container.register(EmergencyTriagePresenter.self) { (r, patient: EmergencyPatient, user: User) in
    EmergencyTriagePresenterImpl(modelLayer: r.resolve(ModelLayer.self)!, patient: patient, user: user)
    }
  }

  func registerVitalCellPresenter() {
    container.register(VitalCellPresenter.self) { (r, value: String?, vital: Vital) in
      VitalCellPresenterImpl(with: vital, value: value)
    }
  }

  func makeEmergencyTriageViewController(with patient: EmergencyPatient, user: User) -> EmergencyTriageViewController {
    return container.resolve(EmergencyTriageViewController.self, arguments: patient, user)!
  }

  func makeSymptomCategoryCell(for tableView: UITableView, at indexPath: IndexPath, patient: EmergencyPatient) -> SymptomCategoryCell {
    let presenter = container.resolve(SymptomCategoryCellPresenter.self, argument: patient)!
    return SymptomCategoryCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }

  func makeSymptomCell(for tableView: UITableView, at indexPath: IndexPath, patient: EmergencyPatient) -> SymptomCell {
    let presenter = container.resolve(SymptomCellPresenter.self, argument: patient)!
    return SymptomCell.dequeue(from: tableView, for: indexPath, with: presenter)
  }

  func makeVitalCell(for collectionView: UICollectionView, at indexPath: IndexPath, value: String?, vital: Vital) -> VitalCell {
    let presenter = container.resolve(VitalCellPresenter.self, arguments: value, vital)!
    return VitalCell.dequeue(from: collectionView, for: indexPath, with: presenter)
  }

  func makeDiagnosisCategoryPopUp(with diagnosisCategories: DiagnosisCategories) -> DiagnosisCategoryPopUp {
    return container.resolve(DiagnosisCategoryPopUp.self, argument: diagnosisCategories)!
  }

  func makePediatricsScorePopUp(with pediatricsScoreElements: PediatricsScoreElements, selectedScoreChoices: [PediatricsScoreChoice]) -> PediatricsScorePopUp {
    return container.resolve(PediatricsScorePopUp.self, arguments: pediatricsScoreElements, selectedScoreChoices)!
  }
}
