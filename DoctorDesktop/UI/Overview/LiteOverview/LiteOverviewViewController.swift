//
//  LiteOverviewViewController.swift
//  DoctorDesktop
//
//  Lite-mode patient overview.
//
//  Layout (top → bottom):
//    • PatientHeaderView — the same rich patient banner used in the full overview.
//    • ProgressNotesViewController — embedded as a child VC directly below
//      the header. Its own compact header card is hidden (`isEmbedded = true`).
//
//  API calls: only getVisitsDetail + getPatientHistory (populates the header
//  chips). The heavy getPatientSummary (18 sections) is intentionally skipped.
//
//  Built programmatically — no XIB / storyboard.
//

import UIKit
import NVActivityIndicatorView

final class LiteOverviewViewController: UIViewController, NVActivityIndicatorViewable {

    // MARK: - Dependencies

    private var presenter: OverviewPresenter!
    private weak var navigationCoordinator: NavigationCoordinator?
    private var notesViewController: ProgressNotesViewController!

    // MARK: - Patient Header

    private var patientHeaderView: PatientHeaderView!
    private var headerTopConstraint: NSLayoutConstraint!

    // MARK: - Configure (method injection — matches project pattern)

    func configure(with presenter: OverviewPresenter,
                   notesViewController: ProgressNotesViewController,
                   navigationCoordinator: NavigationCoordinator) {
        self.presenter = presenter
        self.notesViewController = notesViewController
        self.navigationCoordinator = navigationCoordinator
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        setupPatientHeader()
        embedNotesViewController()
        startAnimating(message: "Loading...")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.getVisitsDetail {
            if let detail = self.presenter.visitDetail {
                self.patientHeaderView.updateFromVisitDetail(detail)
            }
        }

        presenter.getPatientHistory {
            let history = self.presenter.patientHistory
            let specialtyName = history?.currentSpeciality.name ?? ""
            self.patientHeaderView.updateSpecialty(specialtyName)

            let contractName = history?.patientVisits
                .first(where: { $0.id == self.presenter.patient.visitId })?
                .contractNameEn ?? ""
            self.patientHeaderView.updateInsurance(contractName)

            self.stopAnimating()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            navigationCoordinator?.movingBack()
        }
    }

    // MARK: - Patient Header

    private func setupPatientHeader() {
        patientHeaderView = PatientHeaderView()
        view.addSubview(patientHeaderView)

        headerTopConstraint = patientHeaderView.topAnchor.constraint(equalTo: view.topAnchor)
        NSLayoutConstraint.activate([
            headerTopConstraint,
            patientHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            patientHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            patientHeaderView.heightAnchor.constraint(equalToConstant: PatientHeaderView.preferredHeight),
        ])

        patientHeaderView.configure(patient: presenter.patient)
        view.bringSubview(toFront: patientHeaderView)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Keep the header flush with the navigation bar bottom.
        // additionalSafeAreaInsets.top is NOT used here (unlike the full overview)
        // because the child notes VC is constrained to patientHeaderView.bottomAnchor,
        // so it naturally starts below the header without any extra inset.
        let navBarHeight = view.safeAreaInsets.top
        headerTopConstraint.constant = max(navBarHeight, 0)
    }

    // MARK: - Embed Notes VC

    private func embedNotesViewController() {
        // Set before accessing `.view` so buildUI() inside viewDidLoad sees it.
        notesViewController.isEmbedded = true

        addChildViewController(notesViewController)
        let notesView = notesViewController.view!
        notesView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(notesView, belowSubview: patientHeaderView)

        // The notes view fills the area below the header down to the screen bottom.
        // Because this view starts below the nav bar + header, the child VC's own
        // safeAreaInsets.top will be 0 — so its internal layout correctly anchors
        // content from the top of this subview.
        NSLayoutConstraint.activate([
            notesView.topAnchor.constraint(equalTo: patientHeaderView.bottomAnchor),
            notesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            notesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        notesViewController.didMove(toParentViewController: self)
    }
}
