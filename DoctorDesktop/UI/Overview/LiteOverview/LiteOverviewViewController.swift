//
//  LiteOverviewViewController.swift
//  DoctorDesktop
//
//  Lite-mode patient overview.
//
//  Layout (top → bottom):
//    • PatientHeaderView in COMPACT mode by default — only shows avatar +
//      name + ID/Phone/Nationality. A chevron button on the right expands
//      it to the full data set (blood / allergy / age / date / specialty /
//      doctor / room / insurance) and back.
//    • Embedded ProgressNotesViewController as a child VC, fills the rest
//      of the screen. Same business logic as the standalone screen — just
//      hosted inline so the doctor stays on one screen.
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
    /// Closure injected by `DependencyRegistry.registerLiteOverviewViewController`.
    /// Returns a fully wired ProgressNotesViewController for the given visit ID
    /// list — keeps Swinject out of this VC.
    private var progressNotesMaker: ((String) -> ProgressNotesViewController)!

    // MARK: - Patient Header

    private var patientHeaderView: PatientHeaderView!
    private var headerTopConstraint: NSLayoutConstraint!
    private var headerHeightConstraint: NSLayoutConstraint!

    // MARK: - Embedded child

    private var progressNotesVC: ProgressNotesViewController?

    // MARK: - Configure (method injection — matches project pattern)

    func configure(with presenter: OverviewPresenter,
                   navigationCoordinator: NavigationCoordinator,
                   progressNotesMaker: @escaping (String) -> ProgressNotesViewController) {
        self.presenter = presenter
        self.navigationCoordinator = navigationCoordinator
        self.progressNotesMaker = progressNotesMaker
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        setupPatientHeader()
        embedProgressNotes()
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

        // Start in compact mode — full data is one tap away.
        patientHeaderView.setCompact(true, animated: false)

        headerTopConstraint = patientHeaderView.topAnchor.constraint(equalTo: view.topAnchor)
        headerHeightConstraint = patientHeaderView.heightAnchor.constraint(
            equalToConstant: PatientHeaderView.compactPreferredHeight)

        NSLayoutConstraint.activate([
            headerTopConstraint,
            patientHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            patientHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerHeightConstraint,
        ])

        patientHeaderView.configure(patient: presenter.patient)

        // Chevron toggle — animate header height + child VC follows via Auto Layout.
        patientHeaderView.onToggleExpand = { [weak self] in
            self?.toggleHeader()
        }
    }

    private func toggleHeader() {
        let willExpand = patientHeaderView.isCompact
        patientHeaderView.setCompact(!willExpand, animated: true)
        headerHeightConstraint.constant = willExpand
            ? PatientHeaderView.preferredHeight
            : PatientHeaderView.compactPreferredHeight
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let navBarHeight = view.safeAreaInsets.top
        headerTopConstraint.constant = max(navBarHeight, 0)
    }

    // MARK: - Embedded ProgressNotes child VC

    /// Hosts the same Remarks UI inline (instead of pushing a new screen)
    /// so doctors can read / send notes without leaving the patient header.
    private func embedProgressNotes() {
        let visitIdArray = presenter.currentVisitIds.joined(separator: ",")
        let child = progressNotesMaker(visitIdArray)
        // Tells the embedded VC to skip its own patient banner and to NOT
        // call `movingBack()` on disappear (parent owns navigation).
        child.isEmbedded = true

        addChildViewController(child)
        view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: patientHeaderView.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        child.didMove(toParentViewController: self)
        progressNotesVC = child

        // Header must sit above the embedded child so the chevron stays tappable.
        view.bringSubview(toFront: patientHeaderView)
    }
}
