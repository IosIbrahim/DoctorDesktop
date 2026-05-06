//
//  InpatientCell.swift
//  DoctorDesktop
//
//  Programmatic redesign matching OutpatientCell / EmergencyCell language:
//  ┌───────────────────────────────────────────────────────────┐
//  │ │ ╭──╮  Patient name                       🛏 Bed-103     │
//  │ │ │A │  DR/ Doctor name                     12/05/2026    │
//  │ │ ╰──╯  Age · Gender                                      │
//  └───────────────────────────────────────────────────────────┘
//  Left red strip + soft pink card when `highLight == "1"`.
//

import UIKit

class InpatientCell: UITableViewCell {

    // MARK: - Card

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 4
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// Vertical accent strip on the leading edge — surfaces only when the
    /// patient is flagged (`highLight == "1"`).
    private let highlightStrip: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Avatar

    private let avatarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        i.tintColor = .white
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    // MARK: - Text

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = UIColor(white: 0.10, alpha: 1)
        l.numberOfLines = 2
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    private let doctorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(white: 0.35, alpha: 1)
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let ageLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(white: 0.45, alpha: 1)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Right side: bed badge + date

    private let bedBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1)
        v.layer.cornerRadius = 11
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentHuggingPriority(.required, for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        return v
    }()

    private let bedLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor(red: 0.04, green: 0.42, blue: 0.65, alpha: 1)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor = UIColor(white: 0.55, alpha: 1)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(card)
        card.addSubview(highlightStrip)
        card.addSubview(avatarView)
        avatarView.addSubview(avatarImageView)
        card.addSubview(nameLabel)
        card.addSubview(doctorLabel)
        card.addSubview(ageLabel)
        card.addSubview(bedBadge)
        bedBadge.addSubview(bedLabel)
        card.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Highlight strip
            highlightStrip.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            highlightStrip.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            highlightStrip.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 6),
            highlightStrip.widthAnchor.constraint(equalToConstant: 4),

            // Avatar
            avatarView.leadingAnchor.constraint(equalTo: highlightStrip.trailingAnchor, constant: 10),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 52),
            avatarView.heightAnchor.constraint(equalToConstant: 52),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),

            // Bed badge — top-right
            bedBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            bedBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            bedBadge.heightAnchor.constraint(equalToConstant: 22),
            bedLabel.topAnchor.constraint(equalTo: bedBadge.topAnchor),
            bedLabel.bottomAnchor.constraint(equalTo: bedBadge.bottomAnchor),
            bedLabel.leadingAnchor.constraint(equalTo: bedBadge.leadingAnchor, constant: 10),
            bedLabel.trailingAnchor.constraint(equalTo: bedBadge.trailingAnchor, constant: -10),

            // Date — under the bed badge, right-aligned
            dateLabel.topAnchor.constraint(equalTo: bedBadge.bottomAnchor, constant: 6),
            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Name
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: bedBadge.leadingAnchor, constant: -8),

            // Doctor
            doctorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            doctorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            doctorLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),

            // Age
            ageLabel.topAnchor.constraint(equalTo: doctorLabel.bottomAnchor, constant: 4),
            ageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ageLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        doctorLabel.text = nil
        ageLabel.attributedText = nil
        ageLabel.text = nil
        bedLabel.text = nil
        dateLabel.text = nil
        avatarImageView.image = nil
        highlightStrip.backgroundColor = .clear
        card.backgroundColor = .white
    }
}

// MARK: - Configure

extension InpatientCell {
    func configure(with presenter: InpatientCellPresenter) {
        nameLabel.text   = presenter.patientName
        doctorLabel.text = "DR/ \(presenter.doctorName)"
        bedLabel.text    = "🛏 \(presenter.bedNumberName)"
        dateLabel.text   = presenter.date.components(separatedBy: .whitespaces).first
        avatarImageView.image = presenter.genderAgeImage?.withRenderingMode(.alwaysOriginal)
        avatarView.backgroundColor = presenter.avatarTint

        // Age + Gender line — colored gender suffix when known.
        let ageText = presenter.age.trimmingCharacters(in: .whitespaces)
        let gender  = presenter.gender
        if !ageText.isEmpty && !gender.isEmpty {
            let s = NSMutableAttributedString(
                string: "Age: \(ageText) · ",
                attributes: [.foregroundColor: UIColor(white: 0.45, alpha: 1)]
            )
            s.append(NSAttributedString(
                string: gender,
                attributes: [.foregroundColor: presenter.genderColor]
            ))
            ageLabel.attributedText = s
        } else if !ageText.isEmpty {
            ageLabel.text = "Age: \(ageText)"
            ageLabel.textColor = UIColor(white: 0.45, alpha: 1)
        } else {
            ageLabel.text = gender
            ageLabel.textColor = presenter.genderColor
        }

        // High-priority highlight: red strip + soft pink card.
        if presenter.highLight == "1" {
            highlightStrip.backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.34, alpha: 1)
            card.backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.97, alpha: 1)
        }
    }
}

// MARK: - Registration helpers

extension InpatientCell {
    public static var cellId: String { return "InpatientCell" }

    public static func register(with tableView: UITableView) {
        tableView.register(InpatientCell.self, forCellReuseIdentifier: InpatientCell.cellId)
    }

    public static func dequeue(from tableView: UITableView,
                               for indexPath: IndexPath,
                               with presenter: InpatientCellPresenter) -> InpatientCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: InpatientCell.cellId, for: indexPath) as! InpatientCell
        cell.configure(with: presenter)
        return cell
    }
}
