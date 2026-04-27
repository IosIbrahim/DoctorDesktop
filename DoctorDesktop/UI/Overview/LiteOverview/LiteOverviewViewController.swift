//
//  LiteOverviewViewController.swift
//  DoctorDesktop
//
//  Lite-mode patient overview.
//
//  Layout (top → bottom):
//    • PatientHeaderView — the same rich patient banner used in the full overview.
//    • A single "Remarks" card — tapping it pushes ProgressNotesViewController
//      through the normal coordinator flow (no child-VC embedding).
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

    // MARK: - Patient Header

    private var patientHeaderView: PatientHeaderView!
    private var headerTopConstraint: NSLayoutConstraint!

    // MARK: - Configure (method injection — matches project pattern)

    func configure(with presenter: OverviewPresenter,
                   navigationCoordinator: NavigationCoordinator) {
        self.presenter = presenter
        self.navigationCoordinator = navigationCoordinator
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        setupPatientHeader()
        setupRemarksCard()
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
        let navBarHeight = view.safeAreaInsets.top
        headerTopConstraint.constant = max(navBarHeight, 0)
    }

    // MARK: - Remarks Card

    private func setupRemarksCard() {
        let teal = UIColor(red: 0.34, green: 0.66, blue: 0.82, alpha: 1)

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(card, belowSubview: patientHeaderView)

        // Icon circle
        let iconCircle = UIView()
        iconCircle.backgroundColor = teal.withAlphaComponent(0.15)
        iconCircle.layer.cornerRadius = 28
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconCircle)

        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = teal
        iconImageView.image = UIImage(named: "notes")
        if #available(iOS 13, *) {
            if iconImageView.image == nil {
                iconImageView.image = UIImage(systemName: "note.text")
            }
        }
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconImageView)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Remarks"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.20, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        // Chevron
        let chevron = UIImageView()
        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = UIColor(white: 0.70, alpha: 1)
        if #available(iOS 13, *) {
            chevron.image = UIImage(systemName: "chevron.right")
        }
        chevron.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            // Card: sits just below the header
            card.topAnchor.constraint(equalTo: patientHeaderView.bottomAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.heightAnchor.constraint(equalToConstant: 72),

            // Icon circle
            iconCircle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconCircle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 56),
            iconCircle.heightAnchor.constraint(equalToConstant: 56),

            // Icon image inside circle
            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            // Title
            titleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            // Chevron
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            chevron.heightAnchor.constraint(equalToConstant: 16),
        ])

        // Tap recogniser
        let tap = UITapGestureRecognizer(target: self, action: #selector(remarksTapped))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
    }

    @objc private func remarksTapped() {
        let visitIdArray = presenter.currentVisitIds.joined(separator: ",")
        let args: [String: Any] = [
            "overviewSection": OverviewSection.progressNotes,
            "patient":         presenter.patient,
            "user":            presenter.user,
            "visitIdArray":    visitIdArray,
        ]
        navigationCoordinator?.next(arguments: args)
    }
}
