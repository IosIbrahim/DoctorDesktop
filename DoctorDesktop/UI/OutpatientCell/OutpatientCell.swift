//
//  OutpatientCell.swift
//  DoctorDesktop
//
//  Programmatic redesign — replaces the XIB-based layout that had
//  overlapping "Call Patient" button and empty Age field.
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

    // MARK: - Avatar / queue badge

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 64/255, green: 178/255, blue: 178/255, alpha: 1)
        v.layer.cornerRadius = 24
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

    private let queueBadge: UILabel = {
        let l = UILabel()
        l.backgroundColor = UIColor(red: 1, green: 0.78, blue: 0.0, alpha: 1)   // amber
        l.textColor = .white
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Text

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

    private let clinicLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(white: 0.45, alpha: 1)
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

    // MARK: - Buttons

    private let statusButton: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        b.layer.cornerRadius = 6
        b.setTitleColor(.white, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(checkoutOnTap), for: .touchUpInside)
        return b
    }()

    private let callButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Call Patient", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0.2, green: 0.55, blue: 0.95, alpha: 1)
        b.layer.cornerRadius = 8
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(callOnTap), for: .touchUpInside)
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
        card.addSubview(clinicLabel)
        card.addSubview(ageLabel)
        card.addSubview(statusButton)
        card.addSubview(callButton)

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Avatar
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            avatarView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            avatarView.widthAnchor.constraint(equalToConstant: 48),
            avatarView.heightAnchor.constraint(equalToConstant: 48),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 28),
            avatarImageView.heightAnchor.constraint(equalToConstant: 28),

            // Queue badge — top right
            queueBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            queueBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            queueBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            queueBadge.heightAnchor.constraint(equalToConstant: 22),

            // Name + doctor + clinic stack — right of avatar
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: queueBadge.leadingAnchor, constant: -8),

            doctorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            doctorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            doctorLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            clinicLabel.topAnchor.constraint(equalTo: doctorLabel.bottomAnchor, constant: 2),
            clinicLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            clinicLabel.trailingAnchor.constraint(equalTo: statusButton.leadingAnchor, constant: -8),

            // Age — bottom-left of text section
            ageLabel.topAnchor.constraint(equalTo: clinicLabel.bottomAnchor, constant: 4),
            ageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            // Status button — right of card, vertically centered with clinic line
            statusButton.centerYAnchor.constraint(equalTo: clinicLabel.centerYAnchor),
            statusButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            statusButton.heightAnchor.constraint(equalToConstant: 28),
            statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            // Call button — full width along bottom, well below text
            callButton.topAnchor.constraint(greaterThanOrEqualTo: ageLabel.bottomAnchor, constant: 8),
            callButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            callButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            callButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            callButton.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        doctorLabel.text = ""
        clinicLabel.text = ""
        ageLabel.text = ""
        avatarImageView.image = nil
        statusButton.isUserInteractionEnabled = true
    }

    @objc private func checkoutOnTap() {
        delegade?.changeStatus(selectIndex)
    }

    @objc private func callOnTap() {
        guard !mobile.isEmpty, let url = URL(string: "tel://\(mobile)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - Configure

extension OutpatientCell {
    func configure(with presenter: OutpatientCellPresenter) {
        avatarImageView.image = presenter.genderAgeImage
        nameLabel.text = presenter.patientName
        doctorLabel.text = "DR/ \(presenter.doctorName)"
        clinicLabel.text = presenter.clinicTitle
        let ageText = presenter.age.trimmingCharacters(in: .whitespaces)
        let genderText = presenter.gender.trimmingCharacters(in: .whitespaces)
        let parts = [ageText, genderText].filter { !$0.isEmpty }
        ageLabel.text = parts.isEmpty ? "" : "Age: " + parts.joined(separator: " · ")
        queueBadge.text = "  \(selectIndex + 1)  "
        mobile = presenter.patMobile
        applyStatus(presenter.servStatus)
    }

    private func applyStatus(_ status: String) {
        statusButton.isHidden = false
        switch status {
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

// MARK: - Helpers (kept from old file)

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
        let dateString = self
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
            if let d = f.date(from: dateString) { return d }
        }
        return Date()
    }
}
