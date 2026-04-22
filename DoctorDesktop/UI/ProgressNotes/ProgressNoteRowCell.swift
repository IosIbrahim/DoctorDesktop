//
//  ProgressNoteRowCell.swift
//  DoctorDesktop
//
//  Programmatic cell for the redesigned progress-notes list.
//  Matches the Android layout: rounded white card, teal avatar bubble,
//  title row (name • speciality/category), small priority chip (Normal
//  green / Urgent red), date, multi-line note body, optional reply bar.
//

import UIKit

final class ProgressNoteRowCell: UITableViewCell {

    static let reuseId = "ProgressNoteRowCell"

    // MARK: Views

    private let card = UIView()
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let bodyLabel = UILabel()
    private let priorityChip = UILabel()
    private let replyStack = UIStackView()
    private let replyLabel = UILabel()
    private let voiceIcon = UIImageView()

    // MARK: Colours (kept in one place so both the cell and the VC stay in sync)

    private static let normalColor = UIColor(red: 0.22, green: 0.72, blue: 0.50, alpha: 1)
    private static let urgentColor = UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1)
    private static let teal        = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)

    // MARK: Init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        buildUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: UI

    private func buildUI() {
        // Card
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // Avatar
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = ProgressNoteRowCell.teal
        avatar.layer.cornerRadius = 18
        avatar.layer.masksToBounds = true
        avatar.contentMode = .center
        avatar.tintColor = .white
        if #available(iOS 13, *) {
            avatar.image = UIImage(systemName: "person.fill")
        }
        card.addSubview(avatar)

        // Name
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = UIColor(white: 0.15, alpha: 1)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        // Subtitle (speciality / category)
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.45, alpha: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)

        // Priority chip
        priorityChip.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        priorityChip.textColor = .white
        priorityChip.textAlignment = .center
        priorityChip.layer.cornerRadius = 8
        priorityChip.layer.masksToBounds = true
        priorityChip.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(priorityChip)

        // Date
        dateLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        dateLabel.textColor = UIColor(white: 0.55, alpha: 1)
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dateLabel)

        // Body
        bodyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor = UIColor(white: 0.20, alpha: 1)
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bodyLabel)

        // Voice icon (shown when this row has an attached voice note)
        voiceIcon.translatesAutoresizingMaskIntoConstraints = false
        voiceIcon.tintColor = ProgressNoteRowCell.teal
        voiceIcon.contentMode = .scaleAspectFit
        if #available(iOS 13, *) {
            voiceIcon.image = UIImage(systemName: "waveform.circle.fill")
        }
        voiceIcon.isHidden = true
        card.addSubview(voiceIcon)

        // Reply (optional)
        replyStack.axis = .horizontal
        replyStack.spacing = 6
        replyStack.alignment = .center
        replyStack.translatesAutoresizingMaskIntoConstraints = false
        replyStack.isHidden = true

        let replyDot = UIView()
        replyDot.backgroundColor = ProgressNoteRowCell.teal
        replyDot.layer.cornerRadius = 2
        replyDot.translatesAutoresizingMaskIntoConstraints = false
        replyDot.widthAnchor.constraint(equalToConstant: 4).isActive = true
        replyDot.heightAnchor.constraint(equalToConstant: 4).isActive = true

        replyLabel.font = UIFont.italicSystemFont(ofSize: 12)
        replyLabel.textColor = UIColor(white: 0.35, alpha: 1)
        replyLabel.numberOfLines = 0

        replyStack.addArrangedSubview(replyDot)
        replyStack.addArrangedSubview(replyLabel)
        card.addSubview(replyStack)

        // Layout
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            avatar.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            avatar.widthAnchor.constraint(equalToConstant: 36),
            avatar.heightAnchor.constraint(equalToConstant: 36),

            nameLabel.topAnchor.constraint(equalTo: avatar.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priorityChip.leadingAnchor, constant: -6),

            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: priorityChip.leadingAnchor, constant: -6),

            priorityChip.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            priorityChip.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            priorityChip.heightAnchor.constraint(equalToConstant: 18),
            priorityChip.widthAnchor.constraint(greaterThanOrEqualToConstant: 54),

            dateLabel.topAnchor.constraint(equalTo: priorityChip.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: priorityChip.trailingAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.trailingAnchor, constant: 6),

            bodyLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            bodyLabel.trailingAnchor.constraint(equalTo: voiceIcon.leadingAnchor, constant: -6),

            voiceIcon.topAnchor.constraint(equalTo: bodyLabel.topAnchor),
            voiceIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            voiceIcon.widthAnchor.constraint(equalToConstant: 22),
            voiceIcon.heightAnchor.constraint(equalToConstant: 22),

            replyStack.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 6),
            replyStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            replyStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            replyStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])

        // When there's no reply, bodyLabel needs to drive the card bottom.
        let bodyBottom = bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        bodyBottom.priority = .defaultLow
        bodyBottom.isActive = true
    }

    // MARK: Configure

    func configure(with note: DoctorNurseNote) {
        nameLabel.text = note.empNameEn?.trimmingCharacters(in: .whitespaces).isEmpty == false
            ? note.empNameEn
            : "—"

        // "<speciality> • <category>" with graceful fallback when either is missing.
        let spec = note.specialityEn?.trimmingCharacters(in: .whitespaces)
        let cat  = note.categoryEn?.trimmingCharacters(in: .whitespaces)
        switch (spec?.isEmpty == false, cat?.isEmpty == false) {
        case (true, true):   subtitleLabel.text = "\(spec!) • \(cat!)"
        case (true, false):  subtitleLabel.text = spec
        case (false, true):  subtitleLabel.text = cat
        default:             subtitleLabel.text = note.userOpenFlag == "N" ? "Nursing" : "Doctor"
        }

        dateLabel.text = note.transDate ?? ""
        bodyLabel.text = note.body.isEmpty ? "—" : note.body

        if note.isUrgent {
            priorityChip.text = "Urgent"
            priorityChip.backgroundColor = ProgressNoteRowCell.urgentColor
        } else {
            priorityChip.text = "Normal"
            priorityChip.backgroundColor = ProgressNoteRowCell.normalColor
        }
        // Pad the chip visually by using paddingText trick.
        priorityChip.text = "  \(priorityChip.text ?? "")  "

        if let reply = note.reply?.trimmingCharacters(in: .whitespaces), !reply.isEmpty {
            replyStack.isHidden = false
            replyLabel.text = reply
        } else {
            replyStack.isHidden = true
            replyLabel.text = nil
        }

        // No server flag for attached voice notes yet — kept hidden until the
        // backend adds one. Shown for the optimistic local voice-note row when
        // the presenter sets `nurseNotes` to the "[Voice note]" marker.
        voiceIcon.isHidden = !(note.nurseNotes?.contains("[Voice note]") ?? false)
    }
}
