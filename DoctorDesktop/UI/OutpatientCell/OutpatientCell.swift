//
//  OutpatientCell.swift
//  DoctorDesktop
//
//  Programmatic redesign matching the Android reference:
//  ┌─────────────────────────────────────────────────────┐
//  │ ╭──╮  Patient name                          [ 1 ]   │
//  │ │A │  DR/ Doctor name                    1 hours    │
//  │ ╰──╯  Age · Gender                  $   [ Arrival ] │
//  └─────────────────────────────────────────────────────┘
//  - No "Call Patient" button (removed per design).
//  - Status pill changes color: Arrival=green, Check In=baby blue,
//    Check Out=red, ✓ Done=green (disabled).
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

    private let queueBadge: UILabel = {
        let l = UILabel()
        l.backgroundColor = UIColor(red: 1, green: 0.78, blue: 0.0, alpha: 1)
        l.textColor = .white
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let waitingTimeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(red: 1.0, green: 0.20, blue: 0.16, alpha: 1)  // red
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }()

    // MARK: - Text stack

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .black
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
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
        b.layer.cornerRadius = 6
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
        card.addSubview(avatarView)
        avatarView.addSubview(avatarImageView)
        card.addSubview(queueBadge)
        card.addSubview(nameLabel)
        card.addSubview(doctorLabel)
        card.addSubview(ageLabel)
        card.addSubview(payIconLabel)
        card.addSubview(statusButton)
        card.addSubview(waitingTimeLabel)

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Avatar — vertically centered in the card
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 52),
            avatarView.heightAnchor.constraint(equalToConstant: 52),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),

            // Queue badge — top-right
            queueBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            queueBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            queueBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 26),
            queueBadge.heightAnchor.constraint(equalToConstant: 22),

            // Name — top, between avatar and queue badge
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: queueBadge.leadingAnchor, constant: -8),

            // Doctor
            doctorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            doctorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            doctorLabel.trailingAnchor.constraint(lessThanOrEqualTo: waitingTimeLabel.leadingAnchor, constant: -8),

            // Age
            ageLabel.topAnchor.constraint(equalTo: doctorLabel.bottomAnchor, constant: 4),
            ageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ageLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),

            // $ icon — left of status button on the bottom-right
            payIconLabel.centerYAnchor.constraint(equalTo: statusButton.centerYAnchor),
            payIconLabel.trailingAnchor.constraint(equalTo: statusButton.leadingAnchor, constant: -10),
            payIconLabel.widthAnchor.constraint(equalToConstant: 18),

            // Waiting time — above status button (where Android puts "1 hours")
            waitingTimeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            waitingTimeLabel.bottomAnchor.constraint(equalTo: statusButton.topAnchor, constant: -4),

            // Status button — bottom-right
            statusButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            statusButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            statusButton.heightAnchor.constraint(equalToConstant: 30),
            statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        doctorLabel.text = ""
        ageLabel.text = ""
        avatarImageView.image = nil
        waitingTimeLabel.text = nil
        statusButton.isUserInteractionEnabled = true
    }

    @objc private func checkoutOnTap() {
        delegade?.changeStatus(selectIndex)
    }
}

// MARK: - Configure

extension OutpatientCell {
    func configure(with presenter: OutpatientCellPresenter) {
        avatarImageView.image = presenter.genderAgeImage
        nameLabel.text = presenter.patientName
        doctorLabel.text = "DR/ \(presenter.doctorName)"

        // Age line — only show "Age:" prefix when there's an actual numeric
        // age string. The BHG test server omits AGE_DESC and only sends
        // GENDER_AGE_NAME_EN ("Old Woman", "Man", "Child"), in which case
        // "Age: Old Woman" reads weirdly — show the gender bare instead.
        let ageText = presenter.age.trimmingCharacters(in: .whitespaces)
        let genderText = presenter.gender.trimmingCharacters(in: .whitespaces)
        if !ageText.isEmpty {
            let suffix = genderText.isEmpty ? "" : " · \(genderText)"
            ageLabel.text = "Age: \(ageText)\(suffix)"
        } else {
            ageLabel.text = genderText
        }

        queueBadge.text = "  \(selectIndex + 1)  "
        mobile = presenter.patMobile
        applyStatus(presenter.servStatus, scheduled: presenter.time)
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
