//
//  OutpatientCell.swift
//  DoctorDesktop
//
//  Card layout (matches the new design screenshot):
//
//  ┌╶─────────────────────────────────────────────────────────────────────┐
//  │   ╭──╮  379060 - PATIENT NAME                       [👥  [#1]]      │
//  │   │A │  DR/ Doctor Name                                              │
//  │   ╰──╯  👤 57y │ 📅 8m │ 🕐 3d │ Female            ($)  [Check Out] │
//  └──────────────────────────────────────────────────────────────────────┘
//
//  • Avatar is a tinted circle with the patient name's first letter.
//    Tint comes from `presenter.avatarTint` (pink=female / blue=male /
//    teal=unknown).
//  • The top-right chip shows the row queue position as `[#N]` with a
//    `person.2.fill` icon. Light-blue background, blue text — fixed
//    intrinsic size (won't stretch when the patient name is short).
//  • The info row uses small icon-pills for the AGE_DESC_ROUND_EN
//    components (years/months/days) plus a coloured gender label.
//    Falls back to a single GENDER_AGE_NAME_EN pill ("Old Woman", "Man",
//    "Child") when the structured age components are missing.
//  • A red 4-pt left-edge bar + pale pink tint appears whenever
//    `presenter.isHighlighted == true` (HIGHLIGHT_FLAG="1"); otherwise
//    the card is plain white.
//  • Pay icon is a green/gray filled circle. Status button keeps the
//    Arrival/Check In/Check Out/Done colour logic.
//

import UIKit

protocol OutpatientStatus {
    func changeStatus(_ index: Int)
}

class OutpatientCell: UITableViewCell {

    // MARK: - Theme

    private static let teal       = UIColor(red: 64/255, green: 178/255, blue: 178/255, alpha: 1)
    private static let cardBG     = UIColor.white
    private static let cardBGHL   = UIColor(red: 1.00, green: 0.96, blue: 0.96, alpha: 1)   // pale pink
    private static let highlight  = UIColor(red: 0.94, green: 0.21, blue: 0.18, alpha: 1)   // red
    private static let normalBar  = UIColor(white: 0.85, alpha: 1)                          // soft gray
    private static let chipBG     = UIColor(red: 0.93, green: 0.96, blue: 1.00, alpha: 1)   // light blue
    private static let chipText   = UIColor(red: 0.27, green: 0.42, blue: 0.78, alpha: 1)   // blue
    private static let chipBorder = UIColor(red: 0.74, green: 0.83, blue: 0.95, alpha: 1)
    private static let payBG      = UIColor(red: 0.86, green: 0.96, blue: 0.91, alpha: 1)   // pale green
    private static let payTint    = UIColor(red: 0.18, green: 0.65, blue: 0.36, alpha: 1)
    private static let payBGOff   = UIColor(white: 0.92, alpha: 1)
    private static let payTintOff = UIColor(white: 0.55, alpha: 1)
    private static let pillIcon   = UIColor(white: 0.48, alpha: 1)
    private static let pillText   = UIColor(white: 0.30, alpha: 1)
    private static let separator  = UIColor(white: 0.82, alpha: 1)

    // MARK: - Card + highlight bar

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = OutpatientCell.cardBG
        v.layer.cornerRadius = 14
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.07
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// 5-pt accent bar pinned to the card's left edge. Always visible —
    /// soft gray on regular rows, red on highlighted ones. Same corner
    /// radius as the card with the leading corners masked so the rounded
    /// card edge stays clean.
    private let highlightBar: UIView = {
        let v = UIView()
        v.backgroundColor = OutpatientCell.normalBar
        v.layer.cornerRadius = 14
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Avatar

    private let avatarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26   // matches 52x52 size
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let monogramLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Top stack

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor(white: 0.08, alpha: 1)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    private let doctorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(white: 0.40, alpha: 1)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    /// Horizontal stack that we rebuild on every `configure(...)`. Holds
    /// icon-pills (years / months / days) interleaved with thin vertical
    /// separators, then a coloured gender label. Falls back to a single
    /// "Old Woman"-style pill when AGE_DESC components aren't present.
    private let infoStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 8
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Top-right queue chip

    private let queueChip: UIView = {
        let v = UIView()
        v.backgroundColor = OutpatientCell.chipBG
        v.layer.cornerRadius = 11
        v.layer.borderColor = OutpatientCell.chipBorder.cgColor
        v.layer.borderWidth = 1
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentHuggingPriority(.required, for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        return v
    }()
    private let queueIcon: UIImageView = {
        let i = UIImageView()
        i.tintColor = OutpatientCell.chipText
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            i.image = UIImage(systemName: "person.2.fill",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
        }
        return i
    }()
    private let queueLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = OutpatientCell.chipText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Bottom-right (pay icon + status)

    /// Pale green/gray circle holding the `$` glyph. Active (green) for
    /// rows with a pending status; inactive (gray) for rows with no
    /// actionable status — matches the screenshot's grey `$` on the
    /// AMINAH card.
    private let payChip: UIView = {
        let v = UIView()
        v.backgroundColor = OutpatientCell.payBG
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let payLabel: UILabel = {
        let l = UILabel()
        l.text = "$"
        l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        l.textColor = OutpatientCell.payTint
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusButton: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        b.layer.cornerRadius = 14
        b.setTitleColor(.white, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(checkoutOnTap), for: .touchUpInside)
        return b
    }()

    // MARK: - Public state

    var mobile: String = ""
    var delegade: OutpatientStatus?
    var selectIndex: Int = 0

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
        card.addSubview(highlightBar)
        card.addSubview(avatarView)
        avatarView.addSubview(monogramLabel)
        card.addSubview(nameLabel)
        card.addSubview(doctorLabel)
        card.addSubview(infoStack)
        card.addSubview(queueChip)
        queueChip.addSubview(queueIcon)
        queueChip.addSubview(queueLabel)
        card.addSubview(payChip)
        payChip.addSubview(payLabel)
        card.addSubview(statusButton)

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Accent bar
            highlightBar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            highlightBar.topAnchor.constraint(equalTo: card.topAnchor),
            highlightBar.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            highlightBar.widthAnchor.constraint(equalToConstant: 4),

            // Avatar (52x52)
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 52),
            avatarView.heightAnchor.constraint(equalToConstant: 52),

            monogramLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            monogramLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            // Queue chip — top-right
            queueChip.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            queueChip.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            queueChip.heightAnchor.constraint(equalToConstant: 22),

            queueIcon.leadingAnchor.constraint(equalTo: queueChip.leadingAnchor, constant: 8),
            queueIcon.centerYAnchor.constraint(equalTo: queueChip.centerYAnchor),
            queueIcon.widthAnchor.constraint(equalToConstant: 12),
            queueIcon.heightAnchor.constraint(equalToConstant: 12),

            queueLabel.leadingAnchor.constraint(equalTo: queueIcon.trailingAnchor, constant: 5),
            queueLabel.trailingAnchor.constraint(equalTo: queueChip.trailingAnchor, constant: -10),
            queueLabel.centerYAnchor.constraint(equalTo: queueChip.centerYAnchor),

            // Name
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 11),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: queueChip.leadingAnchor, constant: -8),

            // Doctor
            doctorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            doctorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            doctorLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Info row
            infoStack.topAnchor.constraint(equalTo: doctorLabel.bottomAnchor, constant: 6),
            infoStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: payChip.leadingAnchor, constant: -8),
            infoStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -10),

            // Pay chip (28x28)
            payChip.widthAnchor.constraint(equalToConstant: 28),
            payChip.heightAnchor.constraint(equalToConstant: 28),
            payChip.centerYAnchor.constraint(equalTo: statusButton.centerYAnchor),
            payChip.trailingAnchor.constraint(equalTo: statusButton.leadingAnchor, constant: -8),
            payLabel.centerXAnchor.constraint(equalTo: payChip.centerXAnchor),
            payLabel.centerYAnchor.constraint(equalTo: payChip.centerYAnchor),

            // Status button
            statusButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            statusButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            statusButton.heightAnchor.constraint(equalToConstant: 28),
            statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        doctorLabel.text = ""
        monogramLabel.text = ""
        avatarView.backgroundColor = OutpatientCell.teal
        // Reset bar to its default gray state — never hidden.
        highlightBar.backgroundColor = OutpatientCell.normalBar
        card.backgroundColor = OutpatientCell.cardBG
        statusButton.isUserInteractionEnabled = true
        statusButton.isHidden = false
        // Wipe and rebuild on every configure — old age-pill subviews go away.
        infoStack.arrangedSubviews.forEach {
            infoStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    @objc private func checkoutOnTap() {
        delegade?.changeStatus(selectIndex)
    }
}

// MARK: - Configure

extension OutpatientCell {
    func configure(with presenter: OutpatientCellPresenter) {

        // ── Accent bar + card tint ──────────────────────────────────────
        // The bar is ALWAYS visible — it's gray on regular rows and red on
        // highlighted ones (HIGHLIGHT_FLAG="1"). Highlighted rows also tint
        // the card pale pink.
        let isHL = presenter.isHighlighted
        highlightBar.backgroundColor = isHL ? OutpatientCell.highlight : OutpatientCell.normalBar
        card.backgroundColor         = isHL ? OutpatientCell.cardBGHL  : OutpatientCell.cardBG

        // ── Avatar ──────────────────────────────────────────────────────
        avatarView.backgroundColor = presenter.avatarTint
        let initial = presenter.nameInitial.isEmpty ? "?" : presenter.nameInitial
        monogramLabel.text = initial

        // ── Name + doctor ───────────────────────────────────────────────
        nameLabel.text   = presenter.patientName
        doctorLabel.text = "DR/ \(presenter.doctorName)"

        // ── Queue chip "[#N]" ──────────────────────────────────────────
        queueLabel.text = "[#\(selectIndex + 1)]"

        // ── Info row: rebuild from age components / fallback ───────────
        rebuildInfoRow(presenter: presenter)

        // ── Status button (existing colour logic) ───────────────────────
        // Run this BEFORE styling the pay chip — `applyStatus` may hide the
        // button when the status is unknown, and the chip mirrors that.
        applyStatus(presenter.servStatus, scheduled: presenter.time)

        // ── Pay icon active vs disabled ─────────────────────────────────
        // Mirror the status button: green/active when there's a button to
        // tap (Arrival / Check In / Check Out / Done), grey when there
        // isn't (e.g. the AMINAH row in the screenshot has no actionable
        // status, so its `$` is rendered grey).
        let active = !statusButton.isHidden
        payChip.backgroundColor = active ? OutpatientCell.payBG     : OutpatientCell.payBGOff
        payLabel.textColor      = active ? OutpatientCell.payTint   : OutpatientCell.payTintOff

        mobile = presenter.patMobile
    }

    /// Rebuilds the info row from the presenter's structured age data.
    /// The four pills (👤 years · 📅 months · 🕐 days · gender) ALWAYS render
    /// — when a value is missing the icon stays and the text becomes "—",
    /// so the row keeps a consistent skeleton regardless of server payload.
    private func rebuildInfoRow(presenter: OutpatientCellPresenter) {

        // Empty + rebuild from scratch.
        infoStack.arrangedSubviews.forEach {
            infoStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // The four pills (👤 years · 📅 months · 🕐 days · gender) ALWAYS
        // render — missing values become an em-dash placeholder so the row
        // keeps a consistent skeleton even when the server doesn't return
        // the data.
        let dash = "—"
        let yText = presenter.ageYears.map  { "\($0)y" } ?? dash
        let mText = presenter.ageMonths.map { "\($0)m" } ?? dash
        let dText = presenter.ageDays.map   { "\($0)d" } ?? dash

        var pills: [UIView] = [
            makePill(systemIcon: "person.fill", text: yText),
            makePill(systemIcon: "calendar",    text: mText),
            makePill(systemIcon: "clock",       text: dText),
        ]

        // Gender pill — coloured "Male"/"Female" when known, dashed grey
        // when all three gender sources came back empty.
        let g = presenter.gender
        if !g.isEmpty {
            pills.append(makeLabel(text: g, color: presenter.genderColor, weight: .semibold))
        } else {
            pills.append(makeLabel(text: dash,
                                   color: OutpatientCell.pillText,
                                   weight: .regular))
        }

        for (i, p) in pills.enumerated() {
            if i > 0 { infoStack.addArrangedSubview(makeSeparator()) }
            infoStack.addArrangedSubview(p)
        }
    }

    // MARK: - Info-row builders

    /// Icon (9pt SF Symbol) + label, no background, default colours.
    private func makePill(systemIcon: String, text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 4
        row.setContentHuggingPriority(.required, for: .horizontal)

        let icon = UIImageView()
        icon.tintColor = OutpatientCell.pillIcon
        icon.contentMode = .scaleAspectFit
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 9, weight: .regular)
            icon.image = UIImage(systemName: systemIcon, withConfiguration: cfg)
        }
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 12).isActive = true

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = OutpatientCell.pillText

        row.addArrangedSubview(icon)
        row.addArrangedSubview(label)
        return row
    }

    /// Plain coloured label used for the gender entry on the right-hand side
    /// of the info row.
    private func makeLabel(text: String, color: UIColor, weight: UIFont.Weight) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: 11, weight: weight)
        l.textColor = color
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }

    /// Thin 1-pt vertical line, 11pt tall — sits between info-row pills.
    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = OutpatientCell.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 1).isActive = true
        v.heightAnchor.constraint(equalToConstant: 11).isActive = true
        v.setContentHuggingPriority(.required, for: .horizontal)
        return v
    }

    private func applyStatus(_ status: String, scheduled: String) {
        // Mirrors the Android adapter's `serv_status` switch exactly:
        //   B → Arrival (green) → POST OutpatientController/arrivalResrvation
        //   A → Check In (blue) → POST OutpatientController/startResrvation
        //   S → Check Out (red) → POST OutpatientController/performResrvation
        //   D → ✓ Done (green, disabled — server-confirmed)
        //   any other code (CALL, C, R, "", null) → button HIDDEN
        //
        // Empty / unknown statuses intentionally have NO button — the doctor
        // shouldn't drive a workflow that the server didn't sanction. The pay
        // chip greys out alongside (handled by `applyPaymentState`).
        let trimmed = status.trimmingCharacters(in: .whitespaces)

        statusButton.isHidden = false
        statusButton.isUserInteractionEnabled = true

        switch trimmed {
        case "B":
            statusButton.setTitle("Arrival", for: .normal)
            statusButton.backgroundColor = UIColor(red: 37/255, green: 182/255, blue: 110/255, alpha: 1)
        case "A":
            statusButton.setTitle("Check In", for: .normal)
            statusButton.backgroundColor = UIColor(red: 28/255, green: 170/255, blue: 222/255, alpha: 1)
        case "S":
            statusButton.setTitle("Check Out", for: .normal)
            statusButton.backgroundColor = UIColor(red: 248/255, green: 38/255, blue: 7/255, alpha: 1)
        case "D":
            statusButton.setTitle("✓ Done", for: .normal)
            statusButton.backgroundColor = UIColor(red: 37/255, green: 182/255, blue: 110/255, alpha: 1)
            statusButton.isUserInteractionEnabled = false
        default:
            statusButton.isHidden = true
        }
    }
}

// MARK: - Registration helpers

extension OutpatientCell {
    public static var cellId: String { return "OutpatientCell" }

    public static func register(with tableView: UITableView) {
        tableView.register(OutpatientCell.self, forCellReuseIdentifier: OutpatientCell.cellId)
    }

    public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: OutpatientCellPresenter) -> OutpatientCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OutpatientCell.cellId, for: indexPath) as! OutpatientCell
        cell.selectIndex = indexPath.row
        cell.configure(with: presenter)
        return cell
    }
}

// MARK: - Helpers

extension UIColor {
    class func fromHex(hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        if cString.count != 6 {
            return #colorLiteral(red: 0, green: 0.702642262, blue: 0.6274331808, alpha: 1)
        }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1
        )
    }

    class func fromHex(hex: String, alpha: CGFloat) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        if cString.count != 6 { return UIColor.gray }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension String {
    var ConvertToDate: Date {
        let f = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SS",
            "yyyy-MM-dd'T'HH:mm:ss.SZ",
            "yyyy-MM-dd'T'HH:mm a",
            "yyyy-MM-dd'T'HH:mm:ss",
            "dd/MM/yyyy HH:mm:ss",
            "dd-MM-yyyy",
            "MM/dd/yyyy",
            "yyyy-MM-dd",
            "MMM d yyyy h:mm",
            "HH:mm:ss",
            "HH:mm a",
        ]
        for fmt in formats {
            f.dateFormat = fmt
            if let d = f.date(from: self) { return d }
        }
        return Date()
    }
}
