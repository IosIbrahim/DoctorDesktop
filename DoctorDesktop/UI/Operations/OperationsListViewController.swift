//
//  OperationsListViewController.swift
//  DoctorDesktop
//
//  View-only list of the doctor's OR (operation room) appointments.
//
//  Layout:
//    • Header card: title "Operations" + date pill (tap to change date)
//    • UITableView of OperationCells (view-only — no Pre-Op / Post-Op buttons,
//      no row taps)
//    • Empty state when no operations are scheduled
//    • Pull-to-refresh
//
//  Built programmatically — no XIB.
//

import UIKit
import NVActivityIndicatorView
import PopupDialog

final class OperationsListViewController: UIViewController, NVActivityIndicatorViewable {

    // MARK: - Dependencies

    private var presenter: OperationsListPresenter!
    private weak var navigationCoordinator: NavigationCoordinator?

    // MARK: - Subviews

    private let headerCard       = UIView()
    private let titleLabel       = UILabel()
    private let countBadge       = UILabel()
    private let dateButton       = UIButton(type: .system)
    private let tableView        = UITableView(frame: .zero, style: .plain)
    private let emptyView        = UIView()
    private let emptyIcon        = UIImageView()
    private let emptyLabel       = UILabel()
    private let refreshControl   = UIRefreshControl()

    /// Re-uses the existing DatePopup (auto-applies on select).
    private var popupDialog: PopupDialog?

    // MARK: - Theme

    private let bgColor   = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    private let teal      = UIColor(red: 0.04, green: 0.51, blue: 0.61, alpha: 1)
    private let chipBG    = UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1)
    private let chipText  = UIColor(red: 0.04, green: 0.42, blue: 0.65, alpha: 1)

    private let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    // MARK: - Configure

    func configure(with presenter: OperationsListPresenter,
                   navigationCoordinator: NavigationCoordinator) {
        self.presenter = presenter
        self.navigationCoordinator = navigationCoordinator
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Operations"
        view.backgroundColor = bgColor
        buildUI()
        startAnimating(message: "Loading...")
        reload()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            navigationCoordinator?.movingBack()
        }
    }

    // MARK: - Load

    @objc private func reload() {
        presenter.load { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.stopAnimating()
                self.refreshControl.endRefreshing()
                self.applyState()
            }
        }
    }

    private func applyState() {
        let count = presenter.patients.count
        countBadge.text = " \(count) "
        emptyView.isHidden = count > 0
        tableView.isHidden = count == 0
        tableView.reloadData()
    }

    // MARK: - UI

    private func buildUI() {
        // Header card
        headerCard.backgroundColor = .white
        headerCard.layer.cornerRadius = 14
        headerCard.layer.shadowColor = UIColor.black.cgColor
        headerCard.layer.shadowOpacity = 0.06
        headerCard.layer.shadowRadius = 4
        headerCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerCard)

        titleLabel.text = "Today's Operations"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(white: 0.10, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(titleLabel)

        countBadge.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        countBadge.textColor = chipText
        countBadge.backgroundColor = chipBG
        countBadge.layer.cornerRadius = 10
        countBadge.layer.masksToBounds = true
        countBadge.textAlignment = .center
        countBadge.text = "  "
        countBadge.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(countBadge)

        // Date pill (rebuilt as a real button so it's tappable).
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        dateButton.setTitleColor(teal, for: .normal)
        dateButton.tintColor = teal
        dateButton.backgroundColor = .white
        dateButton.layer.cornerRadius = 11
        dateButton.layer.borderColor = teal.withAlphaComponent(0.30).cgColor
        dateButton.layer.borderWidth = 1
        dateButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            dateButton.setImage(UIImage(systemName: "calendar", withConfiguration: cfg), for: .normal)
            dateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        }
        dateButton.setTitle(dateFmt.string(from: presenter.selectedDate), for: .normal)
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.addTarget(self, action: #selector(didTapDate), for: .touchUpInside)
        headerCard.addSubview(dateButton)

        // Table
        tableView.backgroundColor = bgColor
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // View-only: rows aren't tappable, no selection feedback.
        tableView.allowsSelection = false
        OperationCell.register(with: tableView)
        view.addSubview(tableView)

        refreshControl.tintColor = teal
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // Empty state
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.isHidden = true
        view.addSubview(emptyView)

        emptyIcon.tintColor = UIColor(white: 0.72, alpha: 1)
        emptyIcon.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
            // Operating bed — the most direct visual for "no scheduled
            // operations": the room is empty, the bed is unoccupied.
            emptyIcon.image = UIImage(systemName: "bed.double.fill", withConfiguration: cfg)
        }
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyView.addSubview(emptyIcon)

        emptyLabel.text = "No operations scheduled\nfor this date"
        emptyLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        emptyLabel.textColor = UIColor(white: 0.50, alpha: 1)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyView.addSubview(emptyLabel)

        // Layout
        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            headerCard.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),

            countBadge.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            countBadge.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            countBadge.heightAnchor.constraint(equalToConstant: 20),
            countBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),

            dateButton.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -12),
            dateButton.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),

            tableView.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyIcon.topAnchor.constraint(equalTo: emptyView.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 64),
            emptyIcon.heightAnchor.constraint(equalToConstant: 64),
            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 14),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -24),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor),
        ])
    }

    // MARK: - Date picker

    @objc private func didTapDate() {
        let datePopup = DatePopup()
        datePopup.datePicker.date = presenter.selectedDate
        let popup = PopupDialog(viewController: datePopup)
        // Auto-apply on selection — no Done button. The picker uses
        // `onDateSelected` which we wired up in the DatePopup refresh.
        datePopup.onDateSelected = { [weak self, weak popup] date in
            guard let self = self else { return }
            popup?.dismiss(animated: true) {
                self.presenter.selectedDate = date
                self.dateButton.setTitle(self.dateFmt.string(from: date), for: .normal)
                self.startAnimating(message: "Loading...")
                self.reload()
            }
        }
        popup.addButton(PopupDialogButton(title: "Cancel", action: nil))
        present(popup, animated: true)
        popupDialog = popup
    }
}

// MARK: - UITableViewDataSource

extension OperationsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.patients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < presenter.patients.count else { return UITableViewCell() }
        return OperationCell.dequeue(from: tableView,
                                     for: indexPath,
                                     with: presenter.patients[indexPath.row])
    }
}
