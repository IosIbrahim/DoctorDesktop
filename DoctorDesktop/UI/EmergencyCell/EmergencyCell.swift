//
//  EmergencyCell.swift
//  DoctorDesktop
//
//  Programmatic redesign matching the Android emergency patient card:
//
//  ┌────────────────────────────────────────────────────────┐
//  │  [👤]  [ 10:28 AM ] 132872                             │
//  │        Abdulmohsen Mohammad Mohsen Katheer Albodour     │
//  │        ─────────────────────────────────────────────   │
//  │        Arrival Method   •   Arrival value              │
//  │        Gender           •   Age                        │
//  └────────────────────────────────────────────────────────┘
//

import UIKit
import Kingfisher

class EmergencyCell: UITableViewCell {

    static let cellId = "EmergencyCell"

    // MARK: - Colors
    private static let teal    = UIColor(red: 0.04, green: 0.51, blue: 0.61, alpha: 1)
    private static let labelGray = UIColor(white: 0.50, alpha: 1)

    // MARK: - Views
    private let card            = UIView()
    private let avatarCircle    = UIView()
    private let avatarImageView = UIImageView()
    private let timeLabel       = UILabel()
    private let nameLabel       = UILabel()
    private let divider         = UIView()
    private let arrivalKeyLabel = UILabel()
    private let arrivalValLabel = UILabel()
    private let genderKeyLabel  = UILabel()
    private let genderValLabel  = UILabel()

    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = UIColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1)
        contentView.backgroundColor = .clear
        selectionStyle              = .none
        buildUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build UI
    private func buildUI() {

        // ── Card ────────────────────────────────────────────────────────────────
        card.backgroundColor    = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor  = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius  = 6
        card.layer.shadowOffset  = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // ── Avatar circle ───────────────────────────────────────────────────────
        avatarCircle.backgroundColor    = Self.teal
        avatarCircle.layer.cornerRadius = 24
        avatarCircle.clipsToBounds      = true
        avatarCircle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(avatarCircle)

        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.tintColor   = .white
        if #available(iOS 13, *) {
            avatarImageView.image = UIImage(systemName: "person.fill")
        } else {
            avatarImageView.image = UIImage(named: "person_placeholder")
        }
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarCircle.addSubview(avatarImageView)

        // ── Time + MRN label ────────────────────────────────────────────────────
        timeLabel.font          = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor     = Self.labelGray
        timeLabel.numberOfLines = 1
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(timeLabel)

        // ── Patient name ────────────────────────────────────────────────────────
        nameLabel.font          = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor     = UIColor(white: 0.10, alpha: 1)
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        // ── Divider ─────────────────────────────────────────────────────────────
        divider.backgroundColor = UIColor(white: 0.88, alpha: 1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(divider)

        // ── Arrival key ─────────────────────────────────────────────────────────
        arrivalKeyLabel.font      = UIFont.systemFont(ofSize: 12, weight: .semibold)
        arrivalKeyLabel.textColor = Self.teal
        arrivalKeyLabel.text      = "Arrival Method"
        arrivalKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrivalKeyLabel)

        // ── Arrival value ───────────────────────────────────────────────────────
        arrivalValLabel.font      = UIFont.systemFont(ofSize: 12, weight: .regular)
        arrivalValLabel.textColor = UIColor(white: 0.25, alpha: 1)
        arrivalValLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrivalValLabel)

        // ── Gender key ──────────────────────────────────────────────────────────
        genderKeyLabel.font      = UIFont.systemFont(ofSize: 12, weight: .semibold)
        genderKeyLabel.textColor = Self.teal
        genderKeyLabel.text      = "Gender"
        genderKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(genderKeyLabel)

        // ── Gender value ─────────────────────────────────────────────────────────
        genderValLabel.font      = UIFont.systemFont(ofSize: 12, weight: .regular)
        genderValLabel.textColor = UIColor(white: 0.25, alpha: 1)
        genderValLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(genderValLabel)

        // ── Constraints ─────────────────────────────────────────────────────────
        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Avatar
            avatarCircle.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            avatarCircle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            avatarCircle.widthAnchor.constraint(equalToConstant: 48),
            avatarCircle.heightAnchor.constraint(equalToConstant: 48),
            avatarImageView.centerXAnchor.constraint(equalTo: avatarCircle.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarCircle.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 26),
            avatarImageView.heightAnchor.constraint(equalToConstant: 26),

            // Time + MRN
            timeLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            timeLabel.leadingAnchor.constraint(equalTo: avatarCircle.trailingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Name
            nameLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: avatarCircle.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Divider
            divider.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1),

            // Arrival row
            arrivalKeyLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 8),
            arrivalKeyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            arrivalKeyLabel.widthAnchor.constraint(equalToConstant: 110),

            arrivalValLabel.centerYAnchor.constraint(equalTo: arrivalKeyLabel.centerYAnchor),
            arrivalValLabel.leadingAnchor.constraint(equalTo: arrivalKeyLabel.trailingAnchor, constant: 6),
            arrivalValLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Gender row
            genderKeyLabel.topAnchor.constraint(equalTo: arrivalKeyLabel.bottomAnchor, constant: 6),
            genderKeyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            genderKeyLabel.widthAnchor.constraint(equalToConstant: 110),
            genderKeyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            genderValLabel.centerYAnchor.constraint(equalTo: genderKeyLabel.centerYAnchor),
            genderValLabel.leadingAnchor.constraint(equalTo: genderKeyLabel.trailingAnchor, constant: 6),
            genderValLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
        ])
    }

    // MARK: - Configure
    func configure(with presenter: EmergencyCellPresenter) {
        timeLabel.text       = "[ \(presenter.visitStartDate) ]  \(presenter.mrn)"
        nameLabel.text       = presenter.patientName
        arrivalValLabel.text = presenter.arrivalMethod?.isEmpty == false
            ? presenter.arrivalMethod
            : "—"
        genderValLabel.text  = presenter.ageGenderText.isEmpty ? "—" : presenter.ageGenderText

        // Avatar — gender icon when available, default person silhouette otherwise.
        if let img = presenter.genderAgeImage {
            avatarImageView.image = img
        }
        // Tint the avatar circle by gender for quick visual scanning.
        switch presenter.ageGenderText {
        case "Male":
            avatarCircle.backgroundColor = UIColor(red: 0.36, green: 0.62, blue: 0.95, alpha: 1)
            genderValLabel.textColor = UIColor(red: 0.18, green: 0.49, blue: 0.90, alpha: 1)
        case "Female":
            avatarCircle.backgroundColor = UIColor(red: 0.95, green: 0.50, blue: 0.66, alpha: 1)
            genderValLabel.textColor = UIColor(red: 0.91, green: 0.30, blue: 0.50, alpha: 1)
        default:
            avatarCircle.backgroundColor = Self.teal
            genderValLabel.textColor = UIColor(white: 0.25, alpha: 1)
        }
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text       = nil
        nameLabel.text       = nil
        arrivalValLabel.text = nil
        genderValLabel.text  = nil
    }
}

// MARK: - Registration helpers (kept for backward compatibility)
extension EmergencyCell {
    public static var bundle: Bundle { Bundle(for: EmergencyCell.self) }

    public static func register(with tableView: UITableView) {
        tableView.register(EmergencyCell.self, forCellReuseIdentifier: EmergencyCell.cellId)
    }

    public static func dequeue(from tableView: UITableView,
                               for indexPath: IndexPath,
                               with presenter: EmergencyCellPresenter) -> EmergencyCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EmergencyCell.cellId, for: indexPath) as! EmergencyCell
        cell.configure(with: presenter)
        return cell
    }
}
