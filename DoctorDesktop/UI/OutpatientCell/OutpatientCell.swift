//
//  OutpatientCell.swift
//  DoctorDesktop
//
//  Visual layout aligned with InpatientCell:
//  ┌─────────────────────────────────────────────────────────┐
//  │ │ ╭──╮  Patient name                       👥 #1         │
//  │ │ │A │  DR/ Doctor name                     1 hours      │
//  │ │ ╰──╯  Age · Gender                $   [ Arrival ]      │
//  └─────────────────────────────────────────────────────────┘
//  - Optional left accent strip (reserved for future flag).
//  - Queue badge: soft-tinted pill (matches inpatient bed badge style).
//  - Waiting time stacked under the queue badge (matches inpatient date).
//  - Status pill: Arrival=green, Check In=baby blue, Check Out=red,
//    ✓ Done=green (disabled).
//

import UIKit

protocol OutpatientStatus {
    func changeStatus(_ index: Int)
}

class OutpatientCell: UITableViewCell {

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

    // MARK: - Avatar

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 64/255, green: 178/255, blue: 178/255, alpha: 1)
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

    // MARK: - Top right (queue badge + waiting time)

    /// Insets-aware UILabel so the queue badge has proper horizontal padding
    /// without the old hack of wrapping the digits in spaces (`"  4  "`).
    /// `intrinsicContentSize` includes the insets so auto-layout can hug it.
    private final class BadgeLabel: UILabel {
        var insets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        override func drawText(in rect: CGRect) {
            super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        }
        override var intrinsicContentSize: CGSize {
            let s = super.intrinsicContentSize
            return CGSize(width:  s.width  + insets.left + insets.right,
                          height: s.height + insets.top  + insets.bottom)
        }
    }

    /// Queue badge — exact same visual language as InpatientCell's bed badge:
    /// light blue background, dark blue text, radius 11.
    private let queueBadge: BadgeLabel = {
        let l = BadgeLabel()
        l.backgroundColor = UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1)
        l.textColor       = UIColor(red: 0.04, green: 0.42, blue: 0.65, alpha: 1)
        l.textAlignment   = .center
        l.font            = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.layer.cornerRadius = 11
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    /// Waiting time — shown right under the queue badge, mirroring the
    /// "date under bed badge" placement in InpatientCell.
    private let waitingTimeLabel: UILabel = {
        let l = UILabel()
        l.font          = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor(white: 0.55, alpha: 1)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }()

    /// Optional accent strip on the leading edge — kept hidden for now,
    /// matches InpatientCell's `highlightStrip` so both cells share the
    /// same metric on the avatar offset.
    private let highlightStrip: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Text stack

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .black
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

    // MARK: - Right side icons / button

    private let payIconLabel: UILabel = {
        let l = UILabel()
        l.text = "$"
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = UIColor(white: 0.55, alpha: 1)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusButton: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        b.layer.cornerRadius = 15
        b.setTitleColor(.white, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.10
        b.layer.shadowRadius = 3
        b.layer.shadowOffset = CGSize(width: 0, height: 1)
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
        card.addSubview(highlightStrip)
        card.addSubview(avatarView)
        avatarView.addSubview(avatarImageView)
        card.addSubview(queueBadge)
        card.addSubview(waitingTimeLabel)
        card.addSubview(nameLabel)
        card.addSubview(doctorLabel)
        card.addSubview(ageLabel)
        card.addSubview(payIconLabel)
        card.addSubview(statusButton)

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Highlight strip (mirrors InpatientCell)
            highlightStrip.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            highlightStrip.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            highlightStrip.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 6),
            highlightStrip.widthAnchor.constraint(equalToConstant: 4),

            // Avatar — sits to the right of the strip, vertically centered
            avatarView.leadingAnchor.constraint(equalTo: highlightStrip.trailingAnchor, constant: 10),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 52),
            avatarView.heightAnchor.constraint(equalToConstant: 52),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),

            // Queue badge — top-right (same metric as inpatient bed badge)
            queueBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            queueBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            queueBadge.heightAnchor.constraint(equalToConstant: 22),

            // Waiting time — directly under the queue badge
            waitingTimeLabel.topAnchor.constraint(equalTo: queueBadge.bottomAnchor, constant: 6),
            waitingTimeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Name
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: queueBadge.leadingAnchor, constant: -8),

            // Doctor
            doctorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            doctorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            doctorLabel.trailingAnchor.constraint(lessThanOrEqualTo: waitingTimeLabel.leadingAnchor, constant: -8),

            // Age
            ageLabel.topAnchor.constraint(equalTo: doctorLabel.bottomAnchor, constant: 4),
            ageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ageLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),

            // $ icon — left of status button
            payIconLabel.centerYAnchor.constraint(equalTo: statusButton.centerYAnchor),
            payIconLabel.trailingAnchor.constraint(equalTo: statusButton.leadingAnchor, constant: -10),
            payIconLabel.widthAnchor.constraint(equalToConstant: 18),

            // Status button — bottom-right
            statusButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            statusButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            statusButton.heightAnchor.constraint(equalToConstant: 32),
            statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        doctorLabel.text = ""
        ageLabel.text = ""
        ageLabel.attributedText = nil
        avatarImageView.image = nil
        waitingTimeLabel.text = nil
        statusButton.isUserInteractionEnabled = true
        highlightStrip.backgroundColor = .clear
        card.backgroundColor = .white
    }

    @objc private func checkoutOnTap() {
        delegade?.changeStatus(selectIndex)
    }
}

// MARK: - Configure

extension OutpatientCell {
    func configure(with presenter: OutpatientCellPresenter) {
        // Force `.alwaysOriginal` so the bitmap's own colors show through
        // — `tintColor = .white` on the imageView would otherwise paint a
        // white silhouette over template-rendered assets.
        avatarImageView.image = presenter.genderAgeImage?.withRenderingMode(.alwaysOriginal)
        avatarView.backgroundColor = presenter.avatarTint
        nameLabel.text = presenter.patientName
        doctorLabel.text = "DR/ \(presenter.doctorName)"

        // Age + Gender line. Gender uses GENDER_NAME_EN ("Male"/"Female") with color.
        let ageText    = presenter.age.trimmingCharacters(in: .whitespaces)
        let genderText = presenter.gender.trimmingCharacters(in: .whitespaces)
        if !ageText.isEmpty && !genderText.isEmpty {
            let base = NSMutableAttributedString(
                string: "Age: \(ageText) · ",
                attributes: [.foregroundColor: UIColor(white: 0.45, alpha: 1)]
            )
            base.append(NSAttributedString(
                string: genderText,
                attributes: [.foregroundColor: presenter.genderColor]
            ))
            ageLabel.attributedText = base
        } else if !ageText.isEmpty {
            ageLabel.attributedText = nil
            ageLabel.text = "Age: \(ageText)"
            ageLabel.textColor = UIColor(white: 0.45, alpha: 1)
        } else {
            ageLabel.attributedText = nil
            ageLabel.text = genderText
            ageLabel.textColor = presenter.genderColor
        }

        // $ icon: green when cashier confirmed, gray otherwise
        payIconLabel.textColor = presenter.cashierFlag == "1"
            ? UIColor(red: 0.13, green: 0.69, blue: 0.30, alpha: 1)
            : UIColor(white: 0.72, alpha: 1)

        // Match the InpatientCell bed-badge text format: "🛏 [ value ]".
        queueBadge.text = "👥 [ #\(selectIndex + 1) ]"
        mobile = presenter.patMobile
        applyStatus(presenter.servStatus, scheduled: presenter.time)

        // Red accent strip + soft pink card when payment isn't confirmed —
        // mirrors InpatientCell's `highLight == "1"` treatment so unpaid
        // outpatients are visually flagged before the doctor taps in.
        if presenter.cashierFlag != "1" {
            highlightStrip.backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.34, alpha: 1)
            card.backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.97, alpha: 1)
        } else {
            highlightStrip.backgroundColor = .clear
            card.backgroundColor = .white
        }
    }

    private func applyStatus(_ status: String, scheduled: String) {
        // Arrival(B)=green, Check In(A)=baby blue, Check Out(S)=red, Done(D)=green
        // BHG test server sends an empty status for fresh visits — default to
        // Arrival so the doctor can drive the workflow from the very first tap.
        let effective = status.trimmingCharacters(in: .whitespaces).isEmpty ? "B" : status

        statusButton.isHidden = false
        statusButton.isUserInteractionEnabled = true

        switch effective {
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
            // Truly unknown status string — hide as a last resort.
            statusButton.isHidden = true
        }

        // "1 hours" style waiting hint — show only for not-yet-arrived patients
        // when scheduled time is in the future.
        waitingTimeLabel.text = nil
        if effective == "B", let wait = humanWaitingTime(scheduled: scheduled) {
            waitingTimeLabel.text = wait
        }
    }

    /// Returns "Xm" or "X hours" if scheduled time is in the future, else nil.
    private func humanWaitingTime(scheduled: String) -> String? {
        let date = scheduled.ConvertToDate
        let diff = date.timeIntervalSinceNow
        guard diff > 30 else { return nil }
        let hrs = Int(diff / 3600)
        let mins = Int(diff / 60) % 60
        if hrs > 0 { return "\(hrs) hours" }
        if mins > 0 { return "\(mins) min" }
        return nil
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
