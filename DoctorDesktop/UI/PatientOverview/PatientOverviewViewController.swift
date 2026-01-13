//
//  PatientOverviewViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/17/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

class PatientOverviewViewController: UIViewController {
  private var presenter: PatientOverviewPresenter!
  private weak var navigationCoordinator: NavigationCoordinator?

  init() {
    super.init(nibName: "PatientOverviewViewController", bundle: nil)
  }
  
  func configure(with presenter: PatientOverviewPresenter, navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBOutlet var result1LAbel: UILabel!
  @IBOutlet var resultLAbel: UILabel!
  
  // patient Info   OutLet
  @IBOutlet weak var patientImage: UIImageView!
  @IBOutlet weak var patientName: UILabel!
  @IBOutlet weak var specialite: UILabel!
  @IBOutlet weak var nationality: UILabel!
  @IBOutlet weak var patientID: UILabel!
  
  // Views OutLets
  @IBOutlet var ScrollView: UIScrollView!
  @IBOutlet weak var headerInfoView: UIView!
  @IBOutlet weak var firstView: UIView!
  @IBOutlet weak var bloodInfoView: UIView!
  
  @IBOutlet weak var exView: UIView!
  @IBOutlet weak var noteView: UIView!
  @IBOutlet weak var othersVew: UIView!
  @IBOutlet weak var result2View: UIView!
  @IBOutlet weak var result1View: UIView!
  @IBOutlet weak var orderView: UIView!
  @IBOutlet weak var subOrder1: UIView!
  @IBOutlet weak var subOrder2: UIView!
  @IBOutlet weak var servicesView: UIView!
  @IBOutlet weak var raysBtn: UIButton!

  // tabel patient Out let
  @IBOutlet weak var bas: UILabel!
  @IBOutlet weak var bmi: UILabel!
  @IBOutlet weak var blood: UILabel!
  @IBOutlet weak var weight: UILabel!
  @IBOutlet weak var height: UILabel!
  @IBOutlet weak var age: UILabel!
  
  @IBOutlet weak var seviceBtn: UIButton!
  @IBOutlet weak var others: UIButton!
  @IBOutlet weak var suborder: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.resultLAbel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    self.result1LAbel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    self.patientID.text = self.presenter.patient.id
    self.patientName.text = self.presenter.patient.name
    self.nationality.text = self.presenter.patient.nationality
  }

  @IBAction func emergencyTriagePressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    let args = ["viewType":"emergency",
                "patient":presenter.patient,
                "user":presenter.user] as [String : Any]
    navigationCoordinator?.next(arguments: args)
  }

  @IBAction func labRadResultPressed(_ sender: Any) {
    //let Reslut = ResultVC(nibName: "ResultVC", bundle: nil)
    //self.navigationController?.pushViewController(Reslut, animated: true)
  }

  @IBAction func labOrderPressed(_ sender: Any) {
    labRadOrderAction(templateType: .labOrder)
  }
  
  @IBAction func radOrderPressed(_ sender: Any) {
    labRadOrderAction(templateType: .radOrder)
  }
    @IBAction func OpenNotes(_ sender: Any) {
        self.navigationController?.pushViewController(NotesViewController(), animated: true)
    }
  
  func labRadOrderAction(templateType: TemplateType) {
    dismiss(animated: true, completion: nil)
    let args = ["viewType":"order",
                "patient":presenter.patient,
                "templateType":templateType,
                "user":presenter.user] as [String : Any]
    navigationCoordinator?.next(arguments: args)
  }

  @IBAction func overviewPressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    let args = ["viewType":"overview",
                "patient":presenter.patient,
                "user":presenter.user] as [String : Any]
    navigationCoordinator?.next(arguments: args)
  }

  @IBAction func backToHomePressed(_ sender: Any) {
    self.navigationController?.dismiss(animated: true, completion: nil)
    
//    self.navigationCoordinator?.movingBack()
//    let appdelegate = UIApplication.shared.delegate as! AppDelegate
//    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//    let patientsViewController = mainStoryboard.instantiateViewController(withIdentifier: "PatientsViewController") as! PatientsViewController
//    let navigationVC = UINavigationController(rootViewController: patientsViewController)
//    appdelegate.window!.rootViewController = navigationVC
  }
}
