//
//  UnitsPopup.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/14/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit
import PopupDialog

protocol UnitsPopupDelegate {
  func unitsPopup(_ unitsPopup: UnitsPopup, didSelectUnitAt index: Int)
}

class UnitsPopup: UIViewController {

  // MARK: - Public
  var presenter: UnitsPopupPresenter!
  var delegate: UnitsPopupDelegate?

  /// Set by PatientsViewController before pushing — drives the date shown in the nav bar.
  var selectedDate = Date()
  /// Called when the user picks a new date from the calendar inside this screen.
  var onDateChanged: ((Date) -> Void)?
  /// When true, this popup is showing inpatient floors (not outpatient clinics).
  /// Hides the date/calendar button and switches the header label to "Floors".
  var isInpatient = false

  // MARK: - Private helpers
  private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy"
    return f
  }()

  /// The label inside the nav-bar custom button that shows the current date.
  private lazy var navDateLabel: UILabel = {
    let l = UILabel()
    l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    l.textColor = UIColor(red: 0.18, green: 0.58, blue: 0.62, alpha: 1) // teal — matches header
    return l
  }()

  // MARK: - Private UI — loading / empty state
  private let spinner: UIActivityIndicatorView = {
      let s = UIActivityIndicatorView(activityIndicatorStyle: .large)
    s.color = UIColor(red: 0.18, green: 0.58, blue: 0.62, alpha: 1)
    s.hidesWhenStopped = true
    s.translatesAutoresizingMaskIntoConstraints = false
    return s
  }()

  private let emptyLabel: UILabel = {
    let l = UILabel()
    l.text = "No clinics available"
    l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    l.textColor = UIColor(white: 0.55, alpha: 1)
    l.textAlignment = .center
    l.isHidden = true
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  // MARK: - Private UI
  private let headerView: UIView = {
    let v = UIView()
    v.backgroundColor = UIColor(red: 0.18, green: 0.58, blue: 0.62, alpha: 1)
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()

  private let clinicsHeaderLabel: UILabel = {
    let l = UILabel()
    l.text = "Clinics"
    l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    l.textColor = .white
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  private let countHeaderLabel: UILabel = {
    let l = UILabel()
    l.text = "Patient Count"
    l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    l.textColor = .white
    l.textAlignment = .right
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  private let tableView: UITableView = {
    let tv = UITableView()
    tv.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tv.separatorStyle = .none
    tv.showsVerticalScrollIndicator = false
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  // MARK: - Init
  init(with presenter: UnitsPopupPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  /// Override loadView so UIKit never attempts to load UnitsPopup.xib.
  /// We build the entire view hierarchy here, exactly like DatePopup does.
  override func loadView() {
    let root = UIView()
    root.backgroundColor = UIColor(white: 0.95, alpha: 1)
    view = root
    buildLayout()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = presenter.title
    UnitsPopupCell.register(with: tableView)
    tableView.delegate   = self
    tableView.dataSource = self
    if isInpatient {
        // Inpatient floors are not date-scoped — hide the calendar entirely.
        clinicsHeaderLabel.text = "Floors"
        emptyLabel.text = "No floors available"
    } else {
        setupNavBarDateButton()
    }
    setupBackButton()

    // Add spinner and empty label over the table
    view.addSubview(spinner)
    view.addSubview(emptyLabel)
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
      emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
      emptyLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 32),
      emptyLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -32),
    ])

    // If pushed before data is ready, show spinner immediately
    if presenter.patientUnits.isEmpty {
      spinner.startAnimating()
      tableView.isHidden = true
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Disable swipe-back so it follows our custom back action (skip PatientsViewController)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
  }

  // MARK: - Custom back button
  private func setupBackButton() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "chevron.left"),
      style: .plain,
      target: self,
      action: #selector(didTapBack)
    )
  }

  @objc private func didTapBack() {
    guard let nav = navigationController else { return }
    // Skip PatientsViewController — go straight back to component selection screen
    if let target = nav.viewControllers.first(where: { $0 is ComponentCollectionViewController }) {
      nav.popToViewController(target, animated: true)
    } else {
      nav.popToRootViewController(animated: true)
    }
  }

  // MARK: - Nav bar date + calendar button (mirrors Android top bar)
  private func setupNavBarDateButton() {
    navDateLabel.text = dateFormatter.string(from: selectedDate)

    let rawImage = UIImage(named: "calendar_icon") ?? UIImage(systemName: "calendar")
    let calendarIcon = UIImageView(image: rawImage?.withRenderingMode(.alwaysOriginal))
    calendarIcon.contentMode = .scaleAspectFit
    calendarIcon.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      calendarIcon.widthAnchor.constraint(equalToConstant: 26),
      calendarIcon.heightAnchor.constraint(equalToConstant: 26),
    ])

    // StackView auto-sizes itself — no manual width needed
    let stack = UIStackView(arrangedSubviews: [navDateLabel, calendarIcon])
    stack.axis = .horizontal
    stack.spacing = 6
    stack.alignment = .center

    // Transparent tap overlay covering the whole stack
    let tapButton = UIButton(type: .custom)
    tapButton.translatesAutoresizingMaskIntoConstraints = false
    tapButton.addTarget(self, action: #selector(didTapCalendar), for: .touchUpInside)
    stack.addSubview(tapButton)
    NSLayoutConstraint.activate([
      tapButton.topAnchor.constraint(equalTo: stack.topAnchor),
      tapButton.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
      tapButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
      tapButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
    ])

    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stack)
  }

  @objc private func didTapCalendar() {
    let datePopup = DatePopup()
    datePopup.datePicker.date = selectedDate

    let popup = PopupDialog(viewController: datePopup)
    let doneButton = PopupDialogButton(title: "Done") { [weak self, weak datePopup] in
      guard let self = self, let picker = datePopup?.datePicker else { return }
      self.applyNewDate(picker.date)
    }
    let cancelButton = PopupDialogButton(title: "Cancel", action: nil)
    popup.addButtons([doneButton, cancelButton])
    present(popup, animated: true)
  }

  private func applyNewDate(_ date: Date) {
    let newStr = dateFormatter.string(from: date)
    guard newStr != dateFormatter.string(from: selectedDate) else { return }
    selectedDate = date
    navDateLabel.text = newStr
    // Tell PatientsViewController to fetch new clinics, then reload our table
    onDateChanged?(date)
  }

  /// Called by PatientsViewController after clinics are fetched (initial load or date change).
  func reloadWith(units: PatientUnits) {
    presenter.patientUnits = units
    spinner.stopAnimating()
    tableView.isHidden = false
    emptyLabel.isHidden = !units.isEmpty
    tableView.reloadData()
  }

  // MARK: - Layout
  private func buildLayout() {
    // Header strip
    view.addSubview(headerView)
    headerView.addSubview(clinicsHeaderLabel)
    headerView.addSubview(countHeaderLabel)
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      headerView.heightAnchor.constraint(equalToConstant: 52),

      clinicsHeaderLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
      clinicsHeaderLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),

      countHeaderLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
      countHeaderLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

      tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

// MARK: - UITableViewDataSource
extension UnitsPopup: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.patientUnits.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let p = UnitsPopupCellPresenterImpl(with: presenter.patientUnits[indexPath.row])
    return UnitsPopupCell.dequeue(from: tableView, for: indexPath, with: p)
  }
}

// MARK: - UITableViewDelegate
extension UnitsPopup: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    delegate?.unitsPopup(self, didSelectUnitAt: indexPath.row)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 76
  }
}
