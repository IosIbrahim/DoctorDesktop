//
//  ProgressNoteRowCell.swift
//  DoctorDesktop
//
//  Programmatic card cell for the Progress Notes list.
//
//  Lite redesign — cleaner, lighter, more readable:
//    • Left accent bar (4 pt, teal / red) signals priority at a glance.
//    • Card uses a subtle 1 px border + minimal shadow instead of heavy drop shadow.
//    • Initials badge replaces the generic placeholder avatar.
//    • Date displayed inline with the author name (• separator).
//    • Body text at 14 pt for comfortable reading.
//    • Priority chip uses an outlined style (no filled background).
//
//  Data source fields (from DOCTOR_NURSE_REMARKS_ROW):
//    EMP_NAME_EN / EMP_NAME_AR  → nameLabel + initialsView
//    SPECIALITY_NAME_EN/AR      → subtitleLabel
//    CATEGORY_NAME_EN/AR        → appended to subtitle
//    TRANSDATE                  → dateLabel (inline with name)
//    DESC_EN / NURSE_NOTES      → bodyLabel
//    PRIORITY_TYPE              → accentBar + priorityChip ("1"=Normal, "2"=Urgent)
//    DELETE_UPDATE_FLAG         → strikethrough body + dim card
//

import UIKit

final class ProgressNoteRowCell: UITableViewCell {

    static let reuseId = "ProgressNoteRowCell"

    // MARK: Colours

    private static let normalColor  = UIColor(red: 0.17, green: 0.63, blue: 0.40, alpha: 1)
    private static let urgentColor  = UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1)
    private static let teal         = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
    private static let cardBorder   = UIColor(red: 0.88, green: 0.91, blue: 0.94, alpha: 1)

    // MARK: Callbacks

    var onDeleteTapped: (() -> Void)?
    var onReplyTapped:  (() -> Void)?

    // MARK: Views

    private let card          = UIView()
    private let accentBar     = UIView()
    private let initialsView  = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel     = UILabel()
    private let dotLabel      = UILabel()
    private let dateLabel     = UILabel()
    private let subtitleLabel = UILabel()
    private let bodyLabel     = UILabel()
    private let priorityChip  = PaddedLabel()
    private let deleteButton  = UIButton(type: .system)
    private let replyButton   = UIButton(type: .system)
    private let voiceIcon     = UIImageView()

    // Toggled based on the note's deleted state.
    private var chipTrailingToDeleteBtn: NSLayoutConstraint!
    private var chipTrailingToCardEdge:  NSLayoutConstraint!

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
        card.layer.cornerRadius = 14
        card.layer.borderWidth  = 1
        card.layer.borderColor  = Self.cardBorder.cgColor
        card.layer.shadowColor   = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.04
        card.layer.shadowRadius  = 4
        card.layer.shadowOffset  = CGSize(width: 0, height: 1)
        card.clipsToBounds = false
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // ── Left accent bar ─────────────────────────────────────────────────────
        accentBar.layer.cornerRadius = 3
        accentBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        accentBar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(accentBar)

        // ── Initials badge ──────────────────────────────────────────────────────
        initialsView.layer.cornerRadius = 17
        initialsView.clipsToBounds = true
        initialsView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(initialsView)

        initialsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsView.addSubview(initialsLabel)

        // ── Name ────────────────────────────────────────────────────────────────
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = UIColor(red: 0.10, green: 0.13, blue: 0.18, alpha: 1)
        nameLabel.numberOfLines = 1
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        // ── Dot separator ────────────────────────────────────────────────────────
        dotLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dotLabel.textColor = UIColor(white: 0.65, alpha: 1)
        dotLabel.text = "·"
        dotLabel.setContentHuggingPriority(.required, for: .horizontal)
        dotLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dotLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dotLabel)

        // ── Date ────────────────────────────────────────────────────────────────
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = UIColor(white: 0.55, alpha: 1)
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dateLabel)

        // ── Subtitle ────────────────────────────────────────────────────────────
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.50, alpha: 1)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)

        // ── Priority chip (outlined) ─────────────────────────────────────────────
        priorityChip.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        priorityChip.textAlignment = .center
        priorityChip.layer.cornerRadius = 8
        priorityChip.layer.masksToBounds = true
        priorityChip.layer.borderWidth = 1
        priorityChip.insets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        priorityChip.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(priorityChip)

        // ── Delete button ───────────────────────────────────────────────────────
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            deleteButton.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        }
        deleteButton.tintColor = Self.urgentColor.withAlphaComponent(0.75)
        deleteButton.backgroundColor = .clear
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(deleteButton)

        // ── Body ────────────────────────────────────────────────────────────────
        bodyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = UIColor(red: 0.14, green: 0.17, blue: 0.22, alpha: 1)
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

        // ── Reply pill ──────────────────────────────────────────────────────────
        replyButton.setTitle("Reply", for: .normal)
        replyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        replyButton.setTitleColor(Self.teal, for: .normal)
        replyButton.backgroundColor = Self.teal.withAlphaComponent(0.08)
        replyButton.layer.cornerRadius = 12
        replyButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            replyButton.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill",
                                         withConfiguration: cfg),
                                 for: .normal)
            replyButton.tintColor = Self.teal
            replyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            replyButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        }
        replyButton.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        replyButton.titleLabel?.lineBreakMode = .byClipping
        replyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        replyButton.setContentHuggingPriority(.required, for: .horizontal)
        card.addSubview(replyButton)

        // ── Layout ──────────────────────────────────────────────────────────────
        NSLayoutConstraint.activate([
            // Card fills contentView with insets
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Accent bar — full card height, left edge
            accentBar.topAnchor.constraint(equalTo: card.topAnchor),
            accentBar.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            accentBar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            accentBar.widthAnchor.constraint(equalToConstant: 4),

            // Initials badge — top-left (right of accent bar)
            initialsView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            initialsView.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 10),
            initialsView.widthAnchor.constraint(equalToConstant: 34),
            initialsView.heightAnchor.constraint(equalToConstant: 34),
            initialsLabel.centerXAnchor.constraint(equalTo: initialsView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: initialsView.centerYAnchor),

            // Priority chip — top-right
            priorityChip.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),

            // Delete button — far top-right
            deleteButton.centerYAnchor.constraint(equalTo: priorityChip.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            deleteButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 26),

            // Name row — right of initials badge (name + dot + date all inline)
            nameLabel.leadingAnchor.constraint(equalTo: initialsView.trailingAnchor, constant: 9),
            nameLabel.topAnchor.constraint(equalTo: initialsView.topAnchor, constant: 1),

            dotLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4),
            dotLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            dateLabel.leadingAnchor.constraint(equalTo: dotLabel.trailingAnchor, constant: 4),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: priorityChip.leadingAnchor, constant: -8),

            // Subtitle — below name
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: priorityChip.leadingAnchor, constant: -8),

            // Body — below initials badge, full width
            bodyLabel.topAnchor.constraint(equalTo: initialsView.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 14),
            bodyLabel.trailingAnchor.constraint(equalTo: voiceIcon.leadingAnchor, constant: -6),

            // Voice icon
            voiceIcon.topAnchor.constraint(equalTo: bodyLabel.topAnchor),
            voiceIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            voiceIcon.widthAnchor.constraint(equalToConstant: 20),
            voiceIcon.heightAnchor.constraint(equalToConstant: 20),

            // Reply pill — bottom-trailing, closes the card
            replyButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 10),
            replyButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            replyButton.heightAnchor.constraint(equalToConstant: 24),
            replyButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
        ])

        chipTrailingToDeleteBtn = priorityChip.trailingAnchor.constraint(
            equalTo: deleteButton.leadingAnchor, constant: -6)
        chipTrailingToCardEdge  = priorityChip.trailingAnchor.constraint(
            equalTo: card.trailingAnchor, constant: -12)
        chipTrailingToDeleteBtn.isActive = true
    }

    // MARK: - Configure

    func configure(with note: DoctorNurseNote) {

        let isArabic  = Locale.current.languageCode == "ar"
        let isDeleted = note.deleteUpdateFlag == "1"
        let isUrgent  = note.isUrgent

        // ── Priority color (used for accent bar, chip, initials) ─────────────────
        let priorityColor = isUrgent ? Self.urgentColor : Self.normalColor

        // ── Left accent bar ──────────────────────────────────────────────────────
        accentBar.backgroundColor = isDeleted
            ? UIColor(white: 0.80, alpha: 1)
            : priorityColor

        // ── Initials badge ───────────────────────────────────────────────────────
        let nameEn = note.empNameEn?.trimmingCharacters(in: .whitespaces)
        let nameAr = note.empNameAr?.trimmingCharacters(in: .whitespaces)
        let name   = (isArabic ? (nameAr ?? nameEn) : (nameEn ?? nameAr)) ?? ""
        nameLabel.text = name.isEmpty ? "—" : name

        let initials = name
            .components(separatedBy: .whitespaces)
            .compactMap { $0.first.map { String($0) } }
            .prefix(2)
            .joined()
            .uppercased()
        initialsLabel.text = initials.isEmpty ? "?" : initials
        initialsView.backgroundColor = isDeleted
            ? UIColor(white: 0.75, alpha: 1)
            : priorityColor.withAlphaComponent(0.85)

        // ── Date (inline) ────────────────────────────────────────────────────────
        dateLabel.text = note.transDate ?? ""

        // ── Subtitle ─────────────────────────────────────────────────────────────
        let spec = note.specialityEn?.trimmingCharacters(in: .whitespaces)
        let cat  = note.categoryEn?.trimmingCharacters(in: .whitespaces)
        let hasSpec = spec?.isEmpty == false
        let hasCat  = cat?.isEmpty == false
        switch (hasSpec, hasCat) {
        case (true, true):  subtitleLabel.text = "\(spec!) · \(cat!)"
        case (true, false): subtitleLabel.text = spec
        case (false, true): subtitleLabel.text = cat
        default:
            subtitleLabel.text = (note.userOpenFlag ?? "D") == "N" ? "Nursing" : "Doctor"
        }

        // ── Body ─────────────────────────────────────────────────────────────────
        let bodyText: String
        if let n = note.nurseNotes, !n.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bodyText = n
        } else if let d = note.descEn, !d.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bodyText = d
        } else {
            bodyText = "—"
        }

        if isDeleted {
            let attr = NSAttributedString(
                string: bodyText,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue,
                    .strikethroughColor: UIColor(white: 0.45, alpha: 1),
                    .foregroundColor:    UIColor(white: 0.55, alpha: 1)
                ])
            bodyLabel.attributedText = attr
        } else {
            bodyLabel.attributedText = nil
            bodyLabel.text = bodyText
        }

        // ── Priority chip (outlined) ──────────────────────────────────────────────
        if isUrgent {
            priorityChip.text            = "Urgent"
            priorityChip.textColor       = Self.urgentColor
            priorityChip.layer.borderColor = Self.urgentColor.withAlphaComponent(0.6).cgColor
            priorityChip.backgroundColor = Self.urgentColor.withAlphaComponent(0.06)
        } else {
            priorityChip.text            = "Normal"
            priorityChip.textColor       = Self.normalColor
            priorityChip.layer.borderColor = Self.normalColor.withAlphaComponent(0.5).cgColor
            priorityChip.backgroundColor = Self.normalColor.withAlphaComponent(0.06)
        }

        // ── Deleted state ────────────────────────────────────────────────────────
        card.alpha            = isDeleted ? 0.70 : 1.0
        deleteButton.isHidden = isDeleted
        let hasServerSer = !(note.ser ?? "").isEmpty && (note.ser ?? "") != "0"
        replyButton.isHidden  = isDeleted || !hasServerSer
        chipTrailingToDeleteBtn.isActive = !isDeleted
        chipTrailingToCardEdge.isActive  = isDeleted

        // ── Voice note icon ───────────────────────────────────────────────────────
        voiceIcon.isHidden = !(note.nurseNotes?.contains("[Voice note]") ?? false)
    }

    // MARK: - Reuse reset

    override func prepareForReuse() {
        super.prepareForReuse()
        bodyLabel.attributedText     = nil
        bodyLabel.text               = nil
        card.alpha                   = 1.0
        deleteButton.isHidden        = false
        replyButton.isHidden         = false
        chipTrailingToDeleteBtn.isActive = true
        chipTrailingToCardEdge.isActive  = false
        onDeleteTapped               = nil
        onReplyTapped                = nil
        voiceIcon.isHidden           = true
    }

    // MARK: - Actions

    @objc private func didTapDelete() { onDeleteTapped?() }
    @objc private func didTapReply()  { onReplyTapped?()  }
}

// MARK: - PaddedLabel

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
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
