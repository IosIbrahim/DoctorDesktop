//
//  OperationCell.swift
//  DoctorDesktop
//
//  Modern view-only card for a single OR (operation room) patient row.
//
//  ┌──────────────────────────────────────────────────────────────────┐
//  │ │  ╭───╮  PATID - PATIENT NAME           [ Status ]               │
//  │ │  │ A │  🩺 Surgeon name                                         │
//  │ │  ╰───╯  💉 Anesthesia · Anesthesia type                         │
//  │           ─────────────────────────────────────────               │
//  │           🛏  Suite/Room  ·  Bed                                  │
//  │           🗓  Expected:  13/05/2026 23:20  ·  ⏱ 39 minute          │
//  │           SRV: Service name                                       │
//  └──────────────────────────────────────────────────────────────────┘
//
//  No action buttons — this is a view-only summary for the doctor.
//

import UIKit

class OperationCell: UITableViewCell {

    // MARK: - Theme

    private static let teal       = UIColor(red: 0.04, green: 0.51, blue: 0.61, alpha: 1)
    private static let cardBG     = UIColor.white
    private static let chipBG     = UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1)
    private static let chipText   = UIColor(red: 0.04, green: 0.42, blue: 0.65, alpha: 1)
    private static let chipBorder = UIColor(red: 0.74, green: 0.83, blue: 0.95, alpha: 1)
    private static let labelGray  = UIColor(white: 0.42, alpha: 1)
    private static let titleDark  = UIColor(white: 0.08, alpha: 1)
    private static let bodyDark   = UIColor(white: 0.22, alpha: 1)
    private static let divider    = UIColor(white: 0.88, alpha: 1)

    // Per-row accent colours — every metadata row gets its own tint so the
    // doctor can scan the card by colour without reading every line:
    //   • Surgeon       — teal   (matches the brand stethoscope colour)
    //   • Anesthesia    — purple (matches the syringe / pharma palette)
    //   • OR Suite/Room — indigo (the operation theatre)
    //   • Patient bed   — slate  (where the patient is physically housed)
    //   • Insurance     — emerald (financial / category — money association)
    //   • Expected date — amber  (calendar / time)
    //   • Duration      — green  (clock / progress)
    //   • Procedure     — coral  (the procedure name itself is the headline metric)
    private static let surgeonColor   = UIColor(red: 0.04, green: 0.51, blue: 0.61, alpha: 1)
    private static let anesthColor    = UIColor(red: 0.55, green: 0.30, blue: 0.78, alpha: 1)
    private static let roomColor      = UIColor(red: 0.27, green: 0.42, blue: 0.78, alpha: 1)
    private static let placeColor     = UIColor(red: 0.36, green: 0.48, blue: 0.58, alpha: 1)
    private static let insuranceColor = UIColor(red: 0.13, green: 0.55, blue: 0.45, alpha: 1)
    private static let dateColor      = UIColor(red: 0.91, green: 0.55, blue: 0.10, alpha: 1)
    private static let durationColor  = UIColor(red: 0.18, green: 0.65, blue: 0.36, alpha: 1)
    private static let procedureColor = UIColor(red: 0.86, green: 0.30, blue: 0.34, alpha: 1)

    // MARK: - Card

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = OperationCell.cardBG
        v.layer.cornerRadius = 16
        // Layered, slightly teal-tinted shadow — reads as a card that's
        // floating one full step above the gray canvas behind it.
        // (UIView only supports one shadow layer natively, so we use a
        // wider radius + larger offset + teal-mixed colour to fake the
        // "ambient + key" lighting feel.)
        v.layer.shadowColor   = UIColor(red: 0.07, green: 0.22, blue: 0.34, alpha: 1).cgColor
        v.layer.shadowOpacity = 0.16
        v.layer.shadowRadius  = 14
        v.layer.shadowOffset  = CGSize(width: 0, height: 6)
        // `shadowPath` keeps rendering on the GPU instead of forcing
        // off-screen compositing for every scroll frame — important for
        // long OR-schedule tables.
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// Coloured left-edge bar — its colour mirrors the workflow status so
    /// the doctor can scan the screen and tell at a glance which rooms are
    /// Booked / In Preparation / In Progress / Done.
    private let statusBar: UIView = {
        let v = UIView()
        v.backgroundColor = OperationCell.teal
        v.layer.cornerRadius = 14
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Avatar

    private let avatarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let monogramLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Top row: patient name + status chip

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = OperationCell.titleDark
        l.numberOfLines = 2
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private final class PaddedLabel: UILabel {
        var insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        override func drawText(in rect: CGRect) {
            super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        }
        override var intrinsicContentSize: CGSize {
            let s = super.intrinsicContentSize
            return CGSize(width: s.width + insets.left + insets.right,
                          height: s.height + insets.top + insets.bottom)
        }
    }

    private let statusChip: PaddedLabel = {
        let l = PaddedLabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.layer.cornerRadius = 11
        l.layer.masksToBounds = true
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    // MARK: - Surgeon / anesthesia rows

    private let surgeonRow  = OperationCell.makeIconRow(
        systemIcon: "stethoscope",
        tint: OperationCell.surgeonColor)
    private let anesthRow   = OperationCell.makeIconRow(
        systemIcon: "syringe.fill",
        tint: OperationCell.anesthColor)

    // MARK: - Divider + meta block

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = OperationCell.divider
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let roomRow     = OperationCell.makeIconRow(
        systemIcon: "bed.double.fill",
        tint: OperationCell.roomColor)
    /// Patient's physical location (floor / room / bed) — different from
    /// the OR suite above. Sourced from BED_FULL_DESC_EN.
    private let placeRow    = OperationCell.makeIconRow(
        systemIcon: "building.2.fill",
        tint: OperationCell.placeColor)
    /// Insurance contract / category — matches the web dashboard's
    /// "Category" column. Falls back to PATFINANACCOUNT when no
    /// contract name is returned.
    private let insuranceRow = OperationCell.makeIconRow(
        systemIcon: "creditcard.fill",
        tint: OperationCell.insuranceColor)
    private let dateRow     = OperationCell.makeIconRow(
        systemIcon: "calendar",
        tint: OperationCell.dateColor)
    private let durationRow = OperationCell.makeIconRow(
        systemIcon: "clock.fill",
        tint: OperationCell.durationColor)
    /// The procedure / operation being performed — coral tint so it stands
    /// out as the headline data point of the card.
    private let serviceRow  = OperationCell.makeIconRow(
        systemIcon: "cross.case.fill",
        tint: OperationCell.procedureColor)

    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    /// Caches the shadow path so the renderer doesn't recompute it from
    /// the alpha mask every frame while scrolling — keeps the operations
    /// list buttery on older devices.
    override func layoutSubviews() {
        super.layoutSubviews()
        card.layer.shadowPath = UIBezierPath(
            roundedRect: card.bounds,
            cornerRadius: card.layer.cornerRadius
        ).cgPath
    }

    private func buildUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(card)
        card.addSubview(statusBar)
        card.addSubview(avatarView)
        avatarView.addSubview(monogramLabel)
        card.addSubview(nameLabel)
        card.addSubview(statusChip)
        card.addSubview(surgeonRow)
        card.addSubview(anesthRow)
        card.addSubview(divider)
        card.addSubview(roomRow)
        card.addSubview(placeRow)
        card.addSubview(insuranceRow)
        card.addSubview(dateRow)
        card.addSubview(durationRow)
        card.addSubview(serviceRow)

        NSLayoutConstraint.activate([
            // Card — generous vertical padding so the wider shadow has
            // room to render without being clipped by the next row.
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            // Status accent bar
            statusBar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            statusBar.topAnchor.constraint(equalTo: card.topAnchor),
            statusBar.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            statusBar.widthAnchor.constraint(equalToConstant: 5),

            // Avatar
            avatarView.leadingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: 12),
            avatarView.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            avatarView.widthAnchor.constraint(equalToConstant: 52),
            avatarView.heightAnchor.constraint(equalToConstant: 52),
            monogramLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            monogramLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            // Status chip (top-right)
            statusChip.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            statusChip.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            statusChip.heightAnchor.constraint(equalToConstant: 22),

            // Name (between avatar and status chip)
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: statusChip.leadingAnchor, constant: -8),

            // Surgeon row
            surgeonRow.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            surgeonRow.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            surgeonRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            // Anesthesia row
            anesthRow.topAnchor.constraint(equalTo: surgeonRow.bottomAnchor, constant: 4),
            anesthRow.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            anesthRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            // Divider — full-width below the avatar block.
            divider.topAnchor.constraint(greaterThanOrEqualTo: anesthRow.bottomAnchor, constant: 10),
            divider.topAnchor.constraint(greaterThanOrEqualTo: avatarView.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            // Meta block — vertical stack: OR room → patient bed →
            // insurance → date + duration → procedure.
            roomRow.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 8),
            roomRow.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            roomRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            placeRow.topAnchor.constraint(equalTo: roomRow.bottomAnchor, constant: 4),
            placeRow.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            placeRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            insuranceRow.topAnchor.constraint(equalTo: placeRow.bottomAnchor, constant: 4),
            insuranceRow.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            insuranceRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            dateRow.topAnchor.constraint(equalTo: insuranceRow.bottomAnchor, constant: 4),
            dateRow.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            dateRow.trailingAnchor.constraint(lessThanOrEqualTo: durationRow.leadingAnchor, constant: -8),

            durationRow.centerYAnchor.constraint(equalTo: dateRow.centerYAnchor),
            durationRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            serviceRow.topAnchor.constraint(equalTo: dateRow.bottomAnchor, constant: 4),
            serviceRow.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            serviceRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            serviceRow.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        monogramLabel.text = nil
        avatarView.backgroundColor = OperationCell.teal
        statusChip.text = nil
        statusChip.backgroundColor = .clear
        statusChip.textColor = .white
        OperationCell.setText(surgeonRow,    "")
        OperationCell.setText(anesthRow,     "")
        OperationCell.setText(roomRow,       "")
        OperationCell.setText(placeRow,      "")
        OperationCell.setText(insuranceRow,  "")
        OperationCell.setText(dateRow,       "")
        OperationCell.setText(durationRow,   "")
        OperationCell.setText(serviceRow,    "")
    }
}

// MARK: - Configure

extension OperationCell {

    func configure(with patient: OperationPatient, indexPath: IndexPath) {
        // Avatar — gender-tinted with the patient's name initial.
        let name = (patient.cOMPLETEPATNAME_EN ?? patient.cOMPLETEPATNAME_AR ?? "").trimmingCharacters(in: .whitespaces)
        let id   = (patient.pATIENTID ?? "").trimmingCharacters(in: .whitespaces)
        let displayName: String = {
            if id.isEmpty && name.isEmpty { return "—" }
            if id.isEmpty { return name }
            if name.isEmpty { return id }
            return "\(id) - \(name)"
        }()
        nameLabel.text = displayName
        monogramLabel.text = name.isEmpty
            ? "?"
            : String(name.prefix(1)).uppercased()

        avatarView.backgroundColor = avatarTint(forGenderAge: patient.gENDER_AGE)

        // Status chip — colour pulled from the workflow action.
        let statusText = (patient.sERVSTATUS_NAME_EN ?? "").trimmingCharacters(in: .whitespaces)
        statusChip.text = statusText.isEmpty ? "—" : statusText
        let palette = statusPalette(for: statusText)
        statusChip.backgroundColor = palette.bg
        statusChip.textColor       = palette.fg
        statusBar.backgroundColor  = palette.fg

        // Surgeon + Anesthesia
        let surgeon = (patient.sURGEON_NAME_EN ?? "").trimmingCharacters(in: .whitespaces)
        OperationCell.setText(surgeonRow, surgeon.isEmpty ? "—" : "DR/ \(surgeon)")

        let anesth = (patient.aNTHESIA_NAME_EN ?? "").trimmingCharacters(in: .whitespaces)
        let anesthType = (patient.aNESTHESIA_TYPE_NAME_EN ?? "").trimmingCharacters(in: .whitespaces)
        let anesthLine: String
        switch (anesth.isEmpty, anesthType.isEmpty) {
        case (true, true):   anesthLine = "—"
        case (false, true):  anesthLine = "DR/ \(anesth)"
        case (true, false):  anesthLine = "Type: \(anesthType)"
        case (false, false): anesthLine = "DR/ \(anesth) · \(anesthType)"
        }
        OperationCell.setText(anesthRow, anesthLine)

        // OR Suite / Room (where the operation happens)
        let suite = (patient.sUITE_NAME_EN ?? "").trimmingCharacters(in: .whitespaces)
        let room  = (patient.rOOM_NAME_EN ?? "").trimmingCharacters(in: .whitespaces)
        let roomLine: String
        if !suite.isEmpty && !room.isEmpty { roomLine = "\(suite) — \(room)" }
        else if !suite.isEmpty             { roomLine = suite }
        else if !room.isEmpty              { roomLine = room }
        else                                { roomLine = "—" }
        OperationCell.setText(roomRow, roomLine)

        // Patient's physical location (floor / room / bed) — different
        // from the OR suite. BED_FULL_DESC_EN sometimes comes back with
        // leading separators (e.g. " -  - Emergency") when only the unit
        // is populated; trim them for a clean display.
        let bedRaw = (patient.bED_FULL_DESC_EN ?? "").trimmingCharacters(in: .whitespaces)
        let cleanedBed = bedRaw
            .replacingOccurrences(of: "^[\\s\\-]+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "[\\s\\-]+$", with: "", options: .regularExpression)
        OperationCell.setText(placeRow, cleanedBed.isEmpty ? "—" : cleanedBed)

        // Insurance / Category — try multiple fields the server may use,
        // fall back to the financial-account number when nothing else is
        // populated.
        let contract = (patient.cONTRACT_NAME_EN
                        ?? patient.cATEGORY_NAME_EN
                        ?? patient.cONTRACT_NAME_AR
                        ?? patient.cATEGORY_NAME_AR
                        ?? "").trimmingCharacters(in: .whitespaces)
        let acct = (patient.pATFINANACCOUNT ?? "").trimmingCharacters(in: .whitespaces)
        let insuranceLine: String
        if !contract.isEmpty       { insuranceLine = contract }
        else if !acct.isEmpty      { insuranceLine = "Account: \(acct)" }
        else                       { insuranceLine = "—" }
        OperationCell.setText(insuranceRow, insuranceLine)

        // Date + duration
        let date = (patient.eXPECTEDDONEDATE ?? "").trimmingCharacters(in: .whitespaces)
        OperationCell.setText(dateRow, date.isEmpty ? "—" : date)

        let duration = (patient.oPER_DURATION_DESC_EN ?? "").trimmingCharacters(in: .whitespaces)
        OperationCell.setText(durationRow, duration.isEmpty ? "—" : duration)

        // Service / procedure name — full text, no truncation, since this
        // is the headline data point of the card.
        let srv = (patient.sRV_NAME_EN ?? "").trimmingCharacters(in: .whitespaces)
        OperationCell.setText(serviceRow, srv.isEmpty ? "—" : srv)
        OperationCell.setUnlimitedLines(serviceRow)
    }

    /// Lifts the row's text label out of the default 2-line cap so long
    /// procedure descriptions render in full instead of getting "…"-truncated.
    fileprivate static func setUnlimitedLines(_ row: UIStackView) {
        if let label = row.arrangedSubviews.last(where: { $0 is UILabel }) as? UILabel {
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
        }
    }

    // MARK: Style helpers

    /// Maps GENDER_AGE numeric code (1/3/6 = male, 2/4/5/7 = female) to a
    /// soft avatar tint. Falls back to the brand teal when unknown.
    private func avatarTint(forGenderAge code: String?) -> UIColor {
        switch code {
        case "3", "6", "1": return UIColor(red: 0.36, green: 0.62, blue: 0.95, alpha: 1)
        case "4", "7", "2", "5": return UIColor(red: 0.95, green: 0.50, blue: 0.66, alpha: 1)
        default: return OperationCell.teal
        }
    }

    private func statusPalette(for raw: String) -> (bg: UIColor, fg: UIColor) {
        // Tints mirror the workflow stages: Booked → blue, At preparation /
        // patient arrival → amber, In progress → red, Done / discharged →
        // green, anything else → grey.
        let key = raw.lowercased()
        if key.contains("done")     { return (UIColor(red: 0.86, green: 0.96, blue: 0.91, alpha: 1),
                                              UIColor(red: 0.18, green: 0.65, blue: 0.36, alpha: 1)) }
        if key.contains("prepar")   { return (UIColor(red: 1.00, green: 0.96, blue: 0.85, alpha: 1),
                                              UIColor(red: 0.78, green: 0.55, blue: 0.0, alpha: 1)) }
        if key.contains("arrival")  { return (UIColor(red: 1.00, green: 0.96, blue: 0.85, alpha: 1),
                                              UIColor(red: 0.78, green: 0.55, blue: 0.0, alpha: 1)) }
        if key.contains("progress") { return (UIColor(red: 1.00, green: 0.93, blue: 0.92, alpha: 1),
                                              UIColor(red: 0.86, green: 0.20, blue: 0.16, alpha: 1)) }
        if key.contains("book")     { return (OperationCell.chipBG, OperationCell.chipText) }
        return (UIColor(white: 0.92, alpha: 1), UIColor(white: 0.30, alpha: 1))
    }

    // MARK: Icon row factory + setter

    /// Builds an icon + label row. The icon takes the full `tint`; the label
    /// gets a softened (60% alpha) variant of the same tint blended over
    /// the standard body text colour — keeps the row scannable by colour
    /// while staying readable for long surgeon/service names.
    private static func makeIconRow(systemIcon: String, tint: UIColor) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 6
        row.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView()
        icon.tintColor = tint
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            icon.image = UIImage(systemName: systemIcon, withConfiguration: cfg)
        }
        icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        // Mix the row's tint with the dark body colour to keep the row
        // visually anchored to its icon without being a wall of black text.
        label.textColor = blend(tint, with: bodyDark, ratio: 0.55)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.tag = 99

        row.addArrangedSubview(icon)
        row.addArrangedSubview(label)
        return row
    }

    /// Linear blend between two UIColors. `ratio` is the weight of `a`.
    /// Used to tone down the row-tint colours so the body copy stays
    /// readable in white-card mode.
    private static func blend(_ a: UIColor, with b: UIColor, ratio: CGFloat) -> UIColor {
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        return UIColor(red:   ar * ratio + br * (1 - ratio),
                       green: ag * ratio + bg * (1 - ratio),
                       blue:  ab * ratio + bb * (1 - ratio),
                       alpha: aa * ratio + ba * (1 - ratio))
    }

    fileprivate static func setText(_ row: UIStackView, _ text: String) {
        if let label = row.arrangedSubviews.last(where: { $0 is UILabel }) as? UILabel {
            label.text = text
        }
    }
}

// MARK: - Registration helpers

extension OperationCell {
    public static var cellId: String { return "OperationCell" }

    public static func register(with tableView: UITableView) {
        tableView.register(OperationCell.self, forCellReuseIdentifier: OperationCell.cellId)
    }

    public static func dequeue(from tableView: UITableView,
                               for indexPath: IndexPath,
                               with patient: OperationPatient) -> OperationCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OperationCell.cellId, for: indexPath) as! OperationCell
        cell.configure(with: patient, indexPath: indexPath)
        return cell
    }
}
