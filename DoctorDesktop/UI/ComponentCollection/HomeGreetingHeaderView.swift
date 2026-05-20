//
//  HomeGreetingHeaderView.swift
//  DoctorDesktop
//
//  Personalised home-screen header with a medical identity.
//
//  ┌────────────────────────────────────────────────────────────┐
//  │                                                            │
//  │  Good morning, 👋                              🔔   ╭──╮   │
//  │  Dr. Khabeer  🩺                                     │K │   │
//  │  Wednesday, 20 May 2026                              ╰──╯   │
//  │                                                            │
//  └────────────────────────────────────────────────────────────┘
//
//  – First-name only.
//  – Time-of-day greeting (morning / afternoon / evening).
//  – Decorative stethoscope sticker so the screen reads as a *doctor's*
//    home (not a generic dashboard).
//

import UIKit

final class HomeGreetingHeaderView: UIView {

    // MARK: - Subviews

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor(white: 0.40, alpha: 1)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        l.textColor = UIColor(white: 0.06, alpha: 1)
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(red: 0.04, green: 0.51, blue: 0.61, alpha: 0.9)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bellButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .white
        b.layer.cornerRadius = 22
        b.layer.shadowColor   = UIColor(red: 0.07, green: 0.22, blue: 0.34, alpha: 1).cgColor
        b.layer.shadowOpacity = 0.10
        b.layer.shadowRadius  = 8
        b.layer.shadowOffset  = CGSize(width: 0, height: 3)
        b.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
            b.setImage(UIImage(systemName: "bell.fill", withConfiguration: cfg), for: .normal)
        }
        b.tintColor = UIColor(white: 0.22, alpha: 1)
        return b
    }()

    private let bellDot: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1)
        v.layer.cornerRadius = 4
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// Doctor avatar — gradient circle with the first letter of the name
    /// + a small stethoscope sticker pinned to the bottom-right corner so
    /// the avatar reads as a doctor instead of just any user.
    private let avatarCircle: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = false   // sticker can poke past the circle
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let avatarMask: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let avatarGradient = CAGradientLayer()
    private let avatarLetterLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let avatarBadge: UILabel = {
        let l = UILabel()
        l.text = "🩺"
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        l.backgroundColor = .white
        l.layer.cornerRadius = 11
        l.layer.masksToBounds = true
        l.layer.borderColor = UIColor.white.cgColor
        l.layer.borderWidth = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarGradient.frame = avatarMask.bounds
    }

    private func buildUI() {
        addSubview(greetingLabel)
        addSubview(nameLabel)
        addSubview(dateLabel)
        addSubview(bellButton)
        bellButton.addSubview(bellDot)
        addSubview(avatarCircle)
        avatarCircle.addSubview(avatarMask)
        avatarMask.layer.addSublayer(avatarGradient)
        avatarMask.addSubview(avatarLetterLabel)
        avatarCircle.addSubview(avatarBadge)

        avatarGradient.colors = [
            UIColor(red: 0.10, green: 0.61, blue: 0.72, alpha: 1).cgColor,
            UIColor(red: 0.04, green: 0.34, blue: 0.55, alpha: 1).cgColor,
        ]
        avatarGradient.startPoint = CGPoint(x: 0, y: 0)
        avatarGradient.endPoint   = CGPoint(x: 1, y: 1)

        NSLayoutConstraint.activate([
            // Avatar (top-right, 48pt)
            avatarCircle.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarCircle.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            avatarCircle.widthAnchor.constraint(equalToConstant: 48),
            avatarCircle.heightAnchor.constraint(equalToConstant: 48),

            // Avatar mask fills the circle
            avatarMask.topAnchor.constraint(equalTo: avatarCircle.topAnchor),
            avatarMask.leadingAnchor.constraint(equalTo: avatarCircle.leadingAnchor),
            avatarMask.trailingAnchor.constraint(equalTo: avatarCircle.trailingAnchor),
            avatarMask.bottomAnchor.constraint(equalTo: avatarCircle.bottomAnchor),
            avatarLetterLabel.centerXAnchor.constraint(equalTo: avatarMask.centerXAnchor),
            avatarLetterLabel.centerYAnchor.constraint(equalTo: avatarMask.centerYAnchor),

            // Stethoscope sticker badge — bottom-right corner of avatar
            avatarBadge.trailingAnchor.constraint(equalTo: avatarCircle.trailingAnchor, constant: 4),
            avatarBadge.bottomAnchor.constraint(equalTo: avatarCircle.bottomAnchor, constant: 4),
            avatarBadge.widthAnchor.constraint(equalToConstant: 22),
            avatarBadge.heightAnchor.constraint(equalToConstant: 22),

            // Notification bell
            bellButton.trailingAnchor.constraint(equalTo: avatarCircle.leadingAnchor, constant: -12),
            bellButton.centerYAnchor.constraint(equalTo: avatarCircle.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 44),
            bellButton.heightAnchor.constraint(equalToConstant: 44),
            bellDot.topAnchor.constraint(equalTo: bellButton.topAnchor, constant: 10),
            bellDot.trailingAnchor.constraint(equalTo: bellButton.trailingAnchor, constant: -10),
            bellDot.widthAnchor.constraint(equalToConstant: 8),
            bellDot.heightAnchor.constraint(equalToConstant: 8),

            // Text block — left column
            greetingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            greetingLabel.topAnchor.constraint(equalTo: topAnchor),
            greetingLabel.trailingAnchor.constraint(lessThanOrEqualTo: bellButton.leadingAnchor, constant: -8),

            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: bellButton.leadingAnchor, constant: -8),

            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: avatarCircle.leadingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Public API

    /// Updates greeting + first-name + initial. Strips the doctor's
    /// long company-style name down to the first word so the header
    /// reads "Dr. Khabeer" instead of "Dr. Khabeer Software Industries".
    func configure(doctorName raw: String) {
        let first = firstName(from: raw)
        greetingLabel.text = "\(timeBasedGreeting()) 👋"
        // Use NSAttributedString so we can put "Dr." in a lighter weight
        // and the first name in a bolder one — gives the row a clear hierarchy.
        let attr = NSMutableAttributedString(
            string: "Dr. ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 22, weight: .regular),
                .foregroundColor: UIColor(white: 0.35, alpha: 1),
            ]
        )
        attr.append(NSAttributedString(
            string: first,
            attributes: [
                .font: UIFont.systemFont(ofSize: 26, weight: .heavy),
                .foregroundColor: UIColor(white: 0.06, alpha: 1),
            ]
        ))
        nameLabel.attributedText = attr
        dateLabel.text = todaysDate()
        avatarLetterLabel.text = String(first.prefix(1)).uppercased()
    }

    // MARK: - Helpers

    private func timeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning,"
        case 12..<17: return "Good afternoon,"
        case 17..<22: return "Good evening,"
        default:      return "Hello,"
        }
    }

    private func todaysDate() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f.string(from: Date())
    }

    private func firstName(from raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "\\s*-+\\s*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        return cleaned.components(separatedBy: " ").first ?? cleaned
    }
}
