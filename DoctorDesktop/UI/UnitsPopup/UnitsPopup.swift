//
//  UnitsPopup.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/14/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

protocol UnitsPopupDelegate {
  func unitsPopup(_ unitsPopup: UnitsPopup, didSelectUnitAt index: Int)
}

class UnitsPopup: UIViewController {

  // MARK: - Public
  var presenter: UnitsPopupPresenter!
  var delegate: UnitsPopupDelegate?

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
  override func viewDidLoad() {
    super.viewDidLoad()
    title = presenter.title
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)

    buildLayout()
    UnitsPopupCell.register(with: tableView)
    tableView.delegate   = self
    tableView.dataSource = self
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
