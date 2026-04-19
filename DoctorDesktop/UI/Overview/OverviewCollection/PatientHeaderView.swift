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

    static let preferredHeight: CGFloat = 154

    // MARK: - Background

    private let gradientLayer = CAGradientLayer()

    // MARK: - Avatar

    private let avatarContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
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

    // MARK: - Name / ID

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

    private let idBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v.layer.cornerRadius = 9
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let idLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.95)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Info chips

    private let chipsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private let ageChip       = PatientHeaderView.makeInfoChip(sfSymbol: "person.circle.fill")
    private let dateChip      = PatientHeaderView.makeInfoChip(sfSymbol: "calendar")
    private let specialtyChip = PatientHeaderView.makeInfoChip(sfSymbol: "cross.case.fill")

    // MARK: - Dividers

    private let dividerTop    = PatientHeaderView.makeDivider()
    private let dividerBottom = PatientHeaderView.makeDivider()

    // MARK: - Doctor / Nationality row

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
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let flagView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 3
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let nationalityLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

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

        // Round only the bottom two corners
        layer.cornerRadius = 22
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    // MARK: - Public API

    /// Populate the header with patient data.
    /// Call once in `viewDidLoad`; call `updateSpecialty` after async history load.
    func configure(patient: Patient, specialty: String? = nil) {
        // ── Avatar colour based on gender ───────────────────────────────
        let gender = patient.genderAge.uppercased()
        let isMale = gender.hasPrefix("M") || gender == "1"
        if #available(iOS 13.0, *) {
            avatarIconView.image = UIImage(systemName: "person.fill")
        }
        let avatarC1: UIColor = isMale
            ? UIColor(red: 0.09, green: 0.47, blue: 0.83, alpha: 1)
            : UIColor(red: 0.76, green: 0.23, blue: 0.55, alpha: 1)
        let avatarC2: UIColor = isMale
            ? UIColor(red: 0.04, green: 0.30, blue: 0.62, alpha: 1)
            : UIColor(red: 0.55, green: 0.10, blue: 0.44, alpha: 1)
        avatarGradient.colors = [avatarC1.cgColor, avatarC2.cgColor]

        // ── Name & ID ───────────────────────────────────────────────────
        nameLabel.text = patient.name
        idLabel.text   = "ID  \(patient.id.trimmingCharacters(in: .whitespaces))"

        // ── Age chip — supported by InpatientPatient and OutpatientPatient ──
        let age: String
        if      let ip = patient as? InpatientPatient  { age = ip.age }
        else if let op = patient as? OutpatientPatient { age = op.age }
        else                                           { age = "" }
        setChipText(ageChip, age.isEmpty ? "—" : age)

        // ── Date chip — show date portion only ─────────────────────────
        let datePart = patient.date.components(separatedBy: " ").first ?? patient.date
        setChipText(dateChip, datePart.isEmpty ? "—" : datePart)

        // ── Specialty chip ─────────────────────────────────────────────
        setChipText(specialtyChip, specialty ?? "—")

        // ── Doctor label ───────────────────────────────────────────────
        let doctorName: String
        if      let ip = patient as? InpatientPatient  { doctorName = ip.doctorName }
        else if let op = patient as? OutpatientPatient { doctorName = op.empNameEn ?? "" }
        else                                           { doctorName = "" }
        doctorLabel.text = doctorName.isEmpty ? "—" : doctorName

        // ── Nationality + flag ─────────────────────────────────────────
        nationalityLabel.text = patient.nationality.isEmpty ? "—" : patient.nationality
        flagView.image   = patient.countyFlag
        flagView.isHidden = (patient.countyFlag == nil)
    }

    /// Update the specialty chip after the async `getPatientHistory` completes.
    func updateSpecialty(_ text: String) {
        setChipText(specialtyChip, text.isEmpty ? "—" : text)
    }

    // MARK: - Private helpers

    private func setChipText(_ chip: UIView, _ text: String) {
        (chip.viewWithTag(99) as? UILabel)?.text = text
    }

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

        // ── Background gradient ─────────────────────────────────────────
        gradientLayer.colors = [
            UIColor(red: 0.04, green: 0.24, blue: 0.39, alpha: 1).cgColor,
            UIColor(red: 0.05, green: 0.42, blue: 0.57, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        // ── Avatar inner gradient (colours updated per-patient) ─────────
        avatarGradient.startPoint = CGPoint(x: 0, y: 0)
        avatarGradient.endPoint   = CGPoint(x: 1, y: 1)
        avatarContainer.layer.insertSublayer(avatarGradient, at: 0)
        avatarContainer.addSubview(avatarIconView)

        // ── ID badge ────────────────────────────────────────────────────
        idBadge.addSubview(idLabel)

        // ── Chips ───────────────────────────────────────────────────────
        [ageChip, dateChip, specialtyChip].forEach { chipsStack.addArrangedSubview($0) }

        // ── Top-level subviews ──────────────────────────────────────────
        [avatarContainer, nameLabel, idBadge,
         dividerTop, chipsStack, dividerBottom,
         doctorIconView, doctorLabel, flagView, nationalityLabel
        ].forEach { addSubview($0) }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // ── Avatar (56 × 56) ────────────────────────────────────────
            avatarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarContainer.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            avatarContainer.widthAnchor.constraint(equalToConstant: 56),
            avatarContainer.heightAnchor.constraint(equalToConstant: 56),

            avatarIconView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarIconView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarIconView.widthAnchor.constraint(equalToConstant: 28),
            avatarIconView.heightAnchor.constraint(equalToConstant: 28),

            // ── Patient name ────────────────────────────────────────────
            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarContainer.topAnchor, constant: 2),

            // ── ID badge ────────────────────────────────────────────────
            idBadge.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idBadge.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            idLabel.topAnchor.constraint(equalTo: idBadge.topAnchor, constant: 3),
            idLabel.bottomAnchor.constraint(equalTo: idBadge.bottomAnchor, constant: -3),
            idLabel.leadingAnchor.constraint(equalTo: idBadge.leadingAnchor, constant: 8),
            idLabel.trailingAnchor.constraint(equalTo: idBadge.trailingAnchor, constant: -8),

            // ── Divider (top) ───────────────────────────────────────────
            dividerTop.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 10),
            dividerTop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dividerTop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dividerTop.heightAnchor.constraint(equalToConstant: 0.5),

            // ── Chips row ───────────────────────────────────────────────
            chipsStack.topAnchor.constraint(equalTo: dividerTop.bottomAnchor, constant: 8),
            chipsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chipsStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            // ── Divider (bottom) ────────────────────────────────────────
            dividerBottom.topAnchor.constraint(equalTo: chipsStack.bottomAnchor, constant: 8),
            dividerBottom.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dividerBottom.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dividerBottom.heightAnchor.constraint(equalToConstant: 0.5),

            // ── Doctor icon ─────────────────────────────────────────────
            doctorIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            doctorIconView.topAnchor.constraint(equalTo: dividerBottom.bottomAnchor, constant: 8),
            doctorIconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            doctorIconView.widthAnchor.constraint(equalToConstant: 14),
            doctorIconView.heightAnchor.constraint(equalToConstant: 14),

            // ── Doctor name ─────────────────────────────────────────────
            doctorLabel.leadingAnchor.constraint(equalTo: doctorIconView.trailingAnchor, constant: 5),
            doctorLabel.centerYAnchor.constraint(equalTo: doctorIconView.centerYAnchor),

            // ── Nationality label ───────────────────────────────────────
            nationalityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nationalityLabel.centerYAnchor.constraint(equalTo: doctorIconView.centerYAnchor),

            // ── Flag ────────────────────────────────────────────────────
            flagView.trailingAnchor.constraint(equalTo: nationalityLabel.leadingAnchor, constant: -5),
            flagView.centerYAnchor.constraint(equalTo: doctorIconView.centerYAnchor),
            flagView.widthAnchor.constraint(equalToConstant: 20),
            flagView.heightAnchor.constraint(equalToConstant: 14),
        ])
    }
}
