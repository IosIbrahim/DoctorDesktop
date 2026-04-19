//
//  PatientHeaderView.swift
//  DoctorDesktop
//
//  Created by Mahmoud Hamdi on 19/04/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

/// A premium patient-info banner placed between the navigation bar and the
/// overview collection views.  All layout is done programmatically — no XIB.
final class PatientHeaderView: UIView {

    // MARK: - Constants

    static let preferredHeight: CGFloat = 170

    // MARK: - Background

    private let gradientLayer = CAGradientLayer()

    // MARK: - Avatar

    private let avatarContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let avatarGradient = CAGradientLayer()
    private let avatarIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Name

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.8
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - ID / Phone / Nationality chips row

    private let infoRowStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        sv.distribution = .fillProportionally   // no spacer — chips sit together
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // ID chip (creditcard icon + id text)
    private let idChip      = PatientHeaderView.makeInfoChip(sfSymbol: "creditcard.fill")

    // Phone chip — chip container wrapping a UIButton so the whole chip is tappable
    private let phoneChipContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let phoneButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = .white
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // Nationality chip (flag image + nationality text)
    private let natChipContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let flagView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 2
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let nationalityLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var phoneNumber: String = ""

    // MARK: - Dividers

    private let dividerTop    = PatientHeaderView.makeDivider()
    private let dividerBottom = PatientHeaderView.makeDivider()

    // MARK: - Chips row  (Age | Adm Date | Specialty)

    private let chipsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private let ageChip      = PatientHeaderView.makeInfoChip(sfSymbol: "person.circle.fill")
    private let dateChip     = PatientHeaderView.makeInfoChip(sfSymbol: "calendar")
    private let specialtyChip = PatientHeaderView.makeInfoChip(sfSymbol: "cross.case.fill")

    // MARK: - Bottom section  (Doctor row + Insurance row)

    private let doctorIconView: UIImageView = {
        let iv = UIImageView()
        if #available(iOS 13.0, *) { iv.image = UIImage(systemName: "stethoscope") }
        iv.tintColor = UIColor.white.withAlphaComponent(0.75)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let doctorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let insuranceIconView: UIImageView = {
        let iv = UIImageView()
        if #available(iOS 13.0, *) { iv.image = UIImage(systemName: "creditcard.fill") }
        iv.tintColor = UIColor.white.withAlphaComponent(0.70)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let insuranceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var cachedDoctorName: String  = ""
    private var cachedInsurance: String   = ""   // patient.financialAccount
    private var cachedSpecialty: String   = ""   // set async after history load

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        avatarGradient.frame = avatarContainer.bounds
        layer.cornerRadius = 22
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    // MARK: - Public API

    func configure(patient: Patient, specialty: String? = nil) {

        // ── Avatar colour ────────────────────────────────────────────────
        let gender = patient.genderAge.uppercased()
        let isMale = gender.hasPrefix("M") || gender == "1"
        if #available(iOS 13.0, *) {
            avatarIconView.image = UIImage(systemName: "person.fill")
        }
        avatarGradient.colors = isMale
            ? [UIColor(red: 0.09, green: 0.47, blue: 0.83, alpha: 1).cgColor,
               UIColor(red: 0.04, green: 0.30, blue: 0.62, alpha: 1).cgColor]
            : [UIColor(red: 0.76, green: 0.23, blue: 0.55, alpha: 1).cgColor,
               UIColor(red: 0.55, green: 0.10, blue: 0.44, alpha: 1).cgColor]

        // ── Name ─────────────────────────────────────────────────────────
        nameLabel.text = patient.name

        // ── ID chip ──────────────────────────────────────────────────────
        setChipText(idChip, patient.id.trimmingCharacters(in: .whitespaces))

        // ── Phone chip (tappable) ────────────────────────────────────────
        let phone: String
        if let op = patient as? OutpatientPatient { phone = op.patMobile ?? "" }
        else                                      { phone = "" }
        if phone.isEmpty {
            phoneChipContainer.isHidden = true
        } else {
            phoneNumber = phone
            phoneChipContainer.isHidden = false
            configurePhoneButton(phone)
        }

        // ── Nationality chip ─────────────────────────────────────────────
        nationalityLabel.text = patient.nationality.isEmpty ? "—" : patient.nationality
        flagView.image        = patient.countyFlag
        flagView.isHidden     = (patient.countyFlag == nil)

        // ── Age chip ─────────────────────────────────────────────────────
        let age: String
        if      let ip = patient as? InpatientPatient  { age = ip.age }
        else if let op = patient as? OutpatientPatient { age = op.age }
        else                                           { age = "" }
        setChipText(ageChip, age.isEmpty ? "—" : age)

        // ── Date chip ────────────────────────────────────────────────────
        setChipText(dateChip, formatAdmDate(patient.date))

        // ── Specialty chip (placeholder — filled async via updateSpecialty) ──
        setChipText(specialtyChip, specialty ?? "—")

        // ── Doctor (insurance filled async via updateInsurance) ───────────
        if      let ip = patient as? InpatientPatient  { cachedDoctorName = ip.doctorName }
        else if let op = patient as? OutpatientPatient { cachedDoctorName = op.empNameEn ?? "" }
        else                                           { cachedDoctorName = "" }
        cachedInsurance = ""   // will be set by updateInsurance() after history loads
        refreshDoctorLabel()
    }

    /// Called after `getPatientHistory` completes — fills the specialty chip.
    func updateSpecialty(_ text: String) {
        cachedSpecialty = text
        setChipText(specialtyChip, text.isEmpty ? "—" : text)
    }

    /// Called after `getPatientHistory` completes — replaces numeric account
    /// with the human-readable contract name e.g. "Without Insurance".
    func updateInsurance(_ text: String) {
        cachedInsurance = text
        refreshDoctorLabel()
    }

    // MARK: - Private helpers

    private func configurePhoneButton(_ number: String) {
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
            phoneButton.setImage(UIImage(systemName: "phone.fill", withConfiguration: cfg), for: .normal)
            phoneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
            phoneButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        }
        phoneButton.setTitle(number, for: .normal)
    }

    @objc private func phoneTapped() {
        guard !phoneNumber.isEmpty,
              let url = URL(string: "tel://\(phoneNumber)") else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    private func refreshDoctorLabel() {
        doctorLabel.text    = cachedDoctorName.isEmpty ? "—" : cachedDoctorName
        insuranceLabel.text = cachedInsurance.isEmpty  ? "—" : cachedInsurance
    }

    private func formatAdmDate(_ raw: String) -> String {
        let parts = raw.components(separatedBy: " ")
        guard parts.count >= 2 else { return parts.first ?? raw }
        let hhmm = parts[1].components(separatedBy: ":").prefix(2).joined(separator: ":")
        return "\(parts[0]) \(hhmm)"
    }

    private func setChipText(_ chip: UIView, _ text: String) {
        (chip.viewWithTag(99) as? UILabel)?.text = text
    }

    // MARK: - Factory methods

    private static func makeInfoChip(sfSymbol: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView()
        if #available(iOS 13.0, *) { icon.image = UIImage(systemName: sfSymbol) }
        icon.tintColor = UIColor.white.withAlphaComponent(0.9)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 13),
            icon.heightAnchor.constraint(equalToConstant: 13),
        ])

        let label = UILabel()
        label.tag = 99
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.spacing = 4
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
        ])
        return container
    }

    private static func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        // Background gradient
        gradientLayer.colors = [
            UIColor(red: 0.04, green: 0.24, blue: 0.39, alpha: 1).cgColor,
            UIColor(red: 0.05, green: 0.42, blue: 0.57, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        // Avatar gradient
        avatarGradient.startPoint = CGPoint(x: 0, y: 0)
        avatarGradient.endPoint   = CGPoint(x: 1, y: 1)
        avatarContainer.layer.insertSublayer(avatarGradient, at: 0)
        avatarContainer.addSubview(avatarIconView)

        // ── Phone chip: button inside a chip container ────────────────────
        phoneButton.addTarget(self, action: #selector(phoneTapped), for: .touchUpInside)
        phoneChipContainer.addSubview(phoneButton)
        NSLayoutConstraint.activate([
            phoneButton.topAnchor.constraint(equalTo: phoneChipContainer.topAnchor, constant: 5),
            phoneButton.bottomAnchor.constraint(equalTo: phoneChipContainer.bottomAnchor, constant: -5),
            phoneButton.leadingAnchor.constraint(equalTo: phoneChipContainer.leadingAnchor, constant: 8),
            phoneButton.trailingAnchor.constraint(equalTo: phoneChipContainer.trailingAnchor, constant: -8),
        ])

        // ── Nationality chip: flag + label inside a chip container ────────
        let natRow = UIStackView(arrangedSubviews: [flagView, nationalityLabel])
        natRow.axis = .horizontal
        natRow.spacing = 5
        natRow.alignment = .center
        natRow.translatesAutoresizingMaskIntoConstraints = false
        natChipContainer.addSubview(natRow)
        NSLayoutConstraint.activate([
            flagView.widthAnchor.constraint(equalToConstant: 18),
            flagView.heightAnchor.constraint(equalToConstant: 13),
            natRow.topAnchor.constraint(equalTo: natChipContainer.topAnchor, constant: 5),
            natRow.bottomAnchor.constraint(equalTo: natChipContainer.bottomAnchor, constant: -5),
            natRow.leadingAnchor.constraint(equalTo: natChipContainer.leadingAnchor, constant: 8),
            natRow.trailingAnchor.constraint(equalTo: natChipContainer.trailingAnchor, constant: -8),
        ])

        // ── Info row: ID chip | Phone chip | Nat chip ─────────────────────
        [idChip, phoneChipContainer, natChipContainer]
            .forEach { infoRowStack.addArrangedSubview($0) }

        // ── Chips row ────────────────────────────────────────────────────
        [ageChip, dateChip, specialtyChip].forEach { chipsStack.addArrangedSubview($0) }

        // ── Top-level subviews ────────────────────────────────────────────
        [avatarContainer, nameLabel, infoRowStack,
         dividerTop, chipsStack, dividerBottom,
         doctorIconView, doctorLabel,
         insuranceIconView, insuranceLabel
        ].forEach { addSubview($0) }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // ── Avatar (52 × 52) ────────────────────────────────────────
            avatarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarContainer.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            avatarContainer.widthAnchor.constraint(equalToConstant: 52),
            avatarContainer.heightAnchor.constraint(equalToConstant: 52),

            avatarIconView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarIconView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarIconView.widthAnchor.constraint(equalToConstant: 26),
            avatarIconView.heightAnchor.constraint(equalToConstant: 26),

            // ── Patient name ────────────────────────────────────────────
            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarContainer.topAnchor),

            // ── Info row: [ID chip] [Phone chip] [Nat chip] ──────────────
            // Sits below the name, same left edge as name
            infoRowStack.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            infoRowStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            infoRowStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),

            // ── Divider (top) ───────────────────────────────────────────
            dividerTop.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 10),
            dividerTop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dividerTop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dividerTop.heightAnchor.constraint(equalToConstant: 0.5),

            // ── Chips row  (Age | Adm Date | Contract) ──────────────────
            chipsStack.topAnchor.constraint(equalTo: dividerTop.bottomAnchor, constant: 8),
            chipsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chipsStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            // ── Divider (bottom) ────────────────────────────────────────
            dividerBottom.topAnchor.constraint(equalTo: chipsStack.bottomAnchor, constant: 8),
            dividerBottom.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dividerBottom.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dividerBottom.heightAnchor.constraint(equalToConstant: 0.5),

            // ── Doctor icon + name ──────────────────────────────────────
            doctorIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            doctorIconView.topAnchor.constraint(equalTo: dividerBottom.bottomAnchor, constant: 7),
            doctorIconView.widthAnchor.constraint(equalToConstant: 13),
            doctorIconView.heightAnchor.constraint(equalToConstant: 13),

            doctorLabel.leadingAnchor.constraint(equalTo: doctorIconView.trailingAnchor, constant: 5),
            doctorLabel.centerYAnchor.constraint(equalTo: doctorIconView.centerYAnchor),
            doctorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // ── Insurance icon + label ──────────────────────────────────
            insuranceIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            insuranceIconView.topAnchor.constraint(equalTo: doctorIconView.bottomAnchor, constant: 5),
            insuranceIconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            insuranceIconView.widthAnchor.constraint(equalToConstant: 13),
            insuranceIconView.heightAnchor.constraint(equalToConstant: 13),

            insuranceLabel.leadingAnchor.constraint(equalTo: insuranceIconView.trailingAnchor, constant: 5),
            insuranceLabel.centerYAnchor.constraint(equalTo: insuranceIconView.centerYAnchor),
            insuranceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
