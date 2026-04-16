//
//  UnitsPopupCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/14/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit
import DropDown

class UnitsPopupCell: DropDownCell {

  // MARK: - UI (programmatic — XIB is bypassed)
  private let card: UIView = {
    let v = UIView()
    v.backgroundColor = .white
    v.layer.cornerRadius = 12
    v.layer.shadowColor  = UIColor.black.cgColor
    v.layer.shadowOpacity = 0.07
    v.layer.shadowRadius  = 6
    v.layer.shadowOffset  = CGSize(width: 0, height: 2)
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()

  private let unitTitle: UILabel = {
    let l = UILabel()
    l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    l.textColor = UIColor(white: 0.15, alpha: 1)
    l.numberOfLines = 2
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  private let badgeView: UIView = {
    let v = UIView()
    v.backgroundColor = UIColor(red: 0.18, green: 0.58, blue: 0.62, alpha: 1)
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()

  private let countLabel: UILabel = {
    let l = UILabel()
    l.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    l.textColor = .white
    l.textAlignment = .center
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    badgeView.layer.cornerRadius = badgeView.bounds.width / 2
  }

  // MARK: - Setup
  private func setup() {
    backgroundColor = .clear
    selectedBackgroundView = UIView() // removes default highlight

    contentView.addSubview(card)
    card.addSubview(unitTitle)
    card.addSubview(badgeView)
    badgeView.addSubview(countLabel)

    NSLayoutConstraint.activate([
      card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
      card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

      badgeView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
      badgeView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
      badgeView.widthAnchor.constraint(equalToConstant: 40),
      badgeView.heightAnchor.constraint(equalToConstant: 40),

      countLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
      countLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),

      unitTitle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
      unitTitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
      unitTitle.trailingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: -12),
    ])
  }

  // MARK: - Configure
  func configure(with presenter: UnitsPopupCellPresenter) {
    unitTitle.text = presenter.unitTitle
    countLabel.text = presenter.patientsCount
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    unitTitle.text = nil
    countLabel.text = nil
  }
}

// MARK: - Helper Methods
extension UnitsPopupCell {
  static var cellId: String { return "UnitsPopupCell" }

  static func register(with tableView: UITableView) {
    tableView.register(UnitsPopupCell.self, forCellReuseIdentifier: cellId)
  }

  static func dequeue(from tableView: UITableView,
                      for indexPath: IndexPath,
                      with presenter: UnitsPopupCellPresenter) -> UnitsPopupCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: cellId, for: indexPath) as! UnitsPopupCell
    cell.configure(with: presenter)
    return cell
  }
}
