//
//  ProgressNoteRowCell.swift
//  DoctorDesktop
//
//  Programmatic card cell for the Progress Notes list.
//
//  Data source fields (from DOCTOR_NURSE_REMARKS_ROW):
//    EMP_NAME_EN / EMP_NAME_AR  → nameLabel         (locale-aware)
//    SPECIALITY_NAME_EN/AR      → subtitleLabel      (locale-aware)
//    CATEGORY_NAME_EN/AR        → appended to subtitle
//    TRANSDATE                  → dateLabel
//    DESC_EN / NURSE_NOTES      → bodyLabel          (NURSE_NOTES preferred)
//    PRIORITY_TYPE              → priorityChip       ("1"=Normal, "2"=Urgent)
//    REPLY                      → replyBar           (shown when non-empty)
//    DELETE_UPDATE_FLAG         → deleted overlay    ("1" = note was deleted)
//

import UIKit

final class ProgressNoteRowCell: UITableViewCell {

    static let reuseId = "ProgressNoteRowCell"

    // MARK: Colours

    private static let normalColor  = UIColor(red: 0.17, green: 0.63, blue: 0.40, alpha: 1)
    private static let urgentColor  = UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1)
    private static let teal         = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
    private static let deletedColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1)

    // MARK: Views

    private let card          = UIView()
    private let avatar        = UIImageView()
    private let nameLabel     = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel     = UILabel()
    private let bodyLabel     = UILabel()
    private let priorityChip  = PaddedLabel()
    private let deletedBadge  = PaddedLabel()   // shown when DELETE_UPDATE_FLAG == "1"
    private let voiceIcon     = UIImageView()

    // Reply row
    private let replyBar      = UIView()
    private let replyDot      = UIView()
    private let replyLabel    = UILabel()

    // MARK: Init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        buildUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build UI

    private func buildUI() {

        // ── Card ────────────────────────────────────────────────────────────────
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor   = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowRadius  = 5
        card.layer.shadowOffset  = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // ── Avatar ──────────────────────────────────────────────────────────────
        avatar.backgroundColor = Self.teal
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        avatar.contentMode = .center
        avatar.tintColor = .white
        if #available(iOS 13, *) {
            avatar.image = UIImage(systemName: "person.fill")
        }
        avatar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(avatar)

        // ── Priority chip ───────────────────────────────────────────────────────
        priorityChip.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        priorityChip.textColor = .white
        priorityChip.textAlignment = .center
        priorityChip.layer.cornerRadius = 8
        priorityChip.layer.masksToBounds = true
        priorityChip.insets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        priorityChip.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(priorityChip)

        // ── Deleted badge (hidden by default) ───────────────────────────────────
        deletedBadge.text = "Deleted"
        deletedBadge.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        deletedBadge.textColor = .white
        deletedBadge.textAlignment = .center
        deletedBadge.backgroundColor = Self.deletedColor
        deletedBadge.layer.cornerRadius = 7
        deletedBadge.layer.masksToBounds = true
        deletedBadge.insets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        deletedBadge.isHidden = true
        deletedBadge.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(deletedBadge)

        // ── Name ────────────────────────────────────────────────────────────────
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = UIColor(white: 0.12, alpha: 1)
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        // ── Subtitle (speciality • category) ────────────────────────────────────
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.45, alpha: 1)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)

        // ── Date ────────────────────────────────────────────────────────────────
        dateLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        dateLabel.textColor = UIColor(white: 0.55, alpha: 1)
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dateLabel)

        // ── Body ────────────────────────────────────────────────────────────────
        bodyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor = UIColor(white: 0.20, alpha: 1)
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bodyLabel)

        // ── Voice icon ──────────────────────────────────────────────────────────
        voiceIcon.tintColor = Self.teal
        voiceIcon.contentMode = .scaleAspectFit
        voiceIcon.isHidden = true
        voiceIcon.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            voiceIcon.image = UIImage(systemName: "waveform.circle.fill")
        }
        card.addSubview(voiceIcon)

        // ── Reply row ────────────────────────────────────────────────────────────
        replyBar.isHidden = true
        replyBar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(replyBar)

        replyDot.backgroundColor = Self.teal
        replyDot.layer.cornerRadius = 3
        replyDot.translatesAutoresizingMaskIntoConstraints = false
        replyBar.addSubview(replyDot)

        replyLabel.font = UIFont.italicSystemFont(ofSize: 12)
        replyLabel.textColor = UIColor(white: 0.35, alpha: 1)
        replyLabel.numberOfLines = 0
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        replyBar.addSubview(replyLabel)

        // ── Layout ──────────────────────────────────────────────────────────────
        NSLayoutConstraint.activate([

            // Card fills contentView with insets
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Avatar — top-left
            avatar.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40),

            // Priority chip — top-right
            priorityChip.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            priorityChip.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Deleted badge — sits to the left of priority chip (hidden when not deleted)
            deletedBadge.centerYAnchor.constraint(equalTo: priorityChip.centerYAnchor),
            deletedBadge.trailingAnchor.constraint(equalTo: priorityChip.leadingAnchor, constant: -6),

            // Name — right of avatar, left of priority chip
            nameLabel.topAnchor.constraint(equalTo: avatar.topAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priorityChip.leadingAnchor,
                                                constant: -8),

            // Subtitle — below name
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: priorityChip.leadingAnchor,
                                                    constant: -8),

            // Date — below priority chip
            dateLabel.topAnchor.constraint(equalTo: priorityChip.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: priorityChip.trailingAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.trailingAnchor,
                                               constant: 6),

            // Body — below avatar, full width
            bodyLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            bodyLabel.trailingAnchor.constraint(equalTo: voiceIcon.leadingAnchor, constant: -6),

            // Voice icon — right of body, same top
            voiceIcon.topAnchor.constraint(equalTo: bodyLabel.topAnchor),
            voiceIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            voiceIcon.widthAnchor.constraint(equalToConstant: 22),
            voiceIcon.heightAnchor.constraint(equalToConstant: 22),

            // Reply bar — below body
            replyBar.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            replyBar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            replyBar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            replyBar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            replyDot.leadingAnchor.constraint(equalTo: replyBar.leadingAnchor),
            replyDot.centerYAnchor.constraint(equalTo: replyLabel.firstBaselineAnchor,
                                              constant: -4),
            replyDot.widthAnchor.constraint(equalToConstant: 6),
            replyDot.heightAnchor.constraint(equalToConstant: 6),

            replyLabel.topAnchor.constraint(equalTo: replyBar.topAnchor),
            replyLabel.leadingAnchor.constraint(equalTo: replyDot.trailingAnchor, constant: 8),
            replyLabel.trailingAnchor.constraint(equalTo: replyBar.trailingAnchor),
            replyLabel.bottomAnchor.constraint(equalTo: replyBar.bottomAnchor),
        ])

        // When no reply bar, bodyLabel must close the card bottom.
        let bodyBottom = bodyLabel.bottomAnchor.constraint(
            equalTo: card.bottomAnchor, constant: -12)
        bodyBottom.priority = UILayoutPriority(rawValue: 749)
        bodyBottom.isActive = true
    }

    // MARK: - Configure

    func configure(with note: DoctorNurseNote) {

        let isArabic  = Locale.current.languageCode == "ar"
        let isDeleted = note.deleteUpdateFlag == "1"

        // ── Name (locale-aware) ──────────────────────────────────────────────────
        let nameEn = note.empNameEn?.trimmingCharacters(in: .whitespaces)
        let nameAr = note.empNameAr?.trimmingCharacters(in: .whitespaces)
        let name   = (isArabic ? (nameAr ?? nameEn) : (nameEn ?? nameAr)) ?? ""
        nameLabel.text = name.isEmpty ? "—" : name

        // ── Subtitle: Speciality • Category ─────────────────────────────────────
        // DoctorNurseNote carries EN fields; use them for both locales since the
        // server may return identical values for EN/AR (as in the sample data).
        let spec = note.specialityEn?.trimmingCharacters(in: .whitespaces)
        let cat  = note.categoryEn?.trimmingCharacters(in: .whitespaces)
        let hasSpec = spec?.isEmpty == false
        let hasCat  = cat?.isEmpty == false
        switch (hasSpec, hasCat) {
        case (true, true):  subtitleLabel.text = "\(spec!) · \(cat!)"
        case (true, false): subtitleLabel.text = spec
        case (false, true): subtitleLabel.text = cat
        default:
            // Fallback: derive label from USER_OPEN_FLAG
            subtitleLabel.text = (note.userOpenFlag ?? "D") == "N" ? "Nursing" : "Doctor"
        }

        // ── Date ────────────────────────────────────────────────────────────────
        dateLabel.text = note.transDate ?? ""

        // ── Body ────────────────────────────────────────────────────────────────
        // NURSE_NOTES preferred; fall back to DESC_EN.
        let bodyText: String
        if let n = note.nurseNotes, !n.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bodyText = n
        } else if let d = note.descEn, !d.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bodyText = d
        } else {
            bodyText = "—"
        }

        if isDeleted {
            // Strikethrough for deleted notes
            let attr = NSAttributedString(
                string: bodyText,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor(white: 0.45, alpha: 1),
                    .foregroundColor:    UIColor(white: 0.55, alpha: 1)
                ])
            bodyLabel.attributedText = attr
        } else {
            bodyLabel.attributedText = nil
            bodyLabel.text = bodyText
        }

        // ── Priority chip ────────────────────────────────────────────────────────
        // PRIORITY_TYPE: "1" = Normal, "2" = Urgent
        if note.isUrgent {
            priorityChip.text            = "Urgent"
            priorityChip.backgroundColor = Self.urgentColor
        } else {
            priorityChip.text            = "Normal"
            priorityChip.backgroundColor = Self.normalColor
        }

        // ── Deleted badge & card dimming ─────────────────────────────────────────
        deletedBadge.isHidden = !isDeleted
        card.alpha            = isDeleted ? 0.55 : 1.0

        // ── Voice note icon ──────────────────────────────────────────────────────
        let hasVoice = note.nurseNotes?.contains("[Voice note]") ?? false
        voiceIcon.isHidden = !hasVoice

        // ── Reply bar ────────────────────────────────────────────────────────────
        let reply = note.reply?.trimmingCharacters(in: .whitespaces) ?? ""
        if reply.isEmpty {
            replyBar.isHidden  = true
            replyLabel.text    = nil
        } else {
            replyBar.isHidden  = false
            replyLabel.text    = reply
        }
    }

    // MARK: - Reuse reset

    override func prepareForReuse() {
        super.prepareForReuse()
        bodyLabel.attributedText = nil
        bodyLabel.text           = nil
        card.alpha               = 1.0
        deletedBadge.isHidden    = true
        voiceIcon.isHidden       = true
        replyBar.isHidden        = true
        replyLabel.text          = nil
    }
}

// MARK: - PaddedLabel (replaces the string-padding hack for chips)

/// UILabel subclass that adds configurable insets around the text.
/// Used for priorityChip and deletedBadge so padding is layout-driven,
/// not embedded in the label's string content.
private final class PaddedLabel: UILabel {
    var insets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8) {
        didSet { invalidateIntrinsicContentSize() }
    }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width:  s.width  + insets.left + insets.right,
                      height: s.height + insets.top  + insets.bottom)
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
