//
//  PatientHeaderView.swift
//  DoctorDesktop
//
//  Created by Mahmoud Hamdi on 19/04/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

/// Premium patient-info banner between the navigation bar and the overview
/// collection views.  Fully programmatic — no XIB.
final class PatientHeaderView: UIView {

    // MARK: - Constants

    /// Tall enough to fit a 2-line patient name without overlapping the
    /// blood-type / allergy row (some BHG records wrap to two lines).
    static let preferredHeight: CGFloat = 232

    /// Compact mode: only avatar + name + ID/Phone/Nationality row + chevron.
    /// Used by `LiteOverviewViewController` so the embedded Remarks list can
    /// claim the rest of the screen until the user expands the header.
    /// Sized to fit the avatar (54pt) + small bottom padding.
    static let compactPreferredHeight: CGFloat = 100

    /// Tap target on the bottom-right of the header to toggle compact↔expanded.
    /// Set by the host view controller — the view itself just emits the event.
    var onToggleExpand: (() -> Void)?

    /// `true` when only the compact rows are visible. Bottom dividers, chip
    /// stacks, and the doctor/room/insurance footer are hidden.
    private(set) var isCompact: Bool = false

    // MARK: - Background

    private let gradientLayer = CAGradientLayer()

    // MARK: - Avatar

    private let avatarContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 27
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

    // MARK: - Row 1: ID | Phone | Nationality

    private let infoRowStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let idChip = PatientHeaderView.makeChip(sfSymbol: "creditcard.fill")

    private let phoneChipContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        // Refuse to shrink below intrinsic size — full digits stay visible.
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        return v
    }()
    private let phoneButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = .white
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        // Default UIButton truncation is `.byTruncatingMiddle` which produces
        // "50…2461". Tail truncation is more readable, and combined with the
        // higher compression-resistance on the chip it shouldn't truncate
        // for normal phone numbers anyway.
        b.titleLabel?.lineBreakMode = .byTruncatingTail
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let natChipContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        // Lowest priority so it absorbs the squeeze when the chip row
        // doesn't fit — phone digits get to stay intact.
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
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
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .white
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var phoneNumber: String = ""

    // MARK: - Row 2: Blood | Allergy  (full-width, equal halves, always visible)

    private let medicalRowStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fillEqually       // each chip gets exactly half the width
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let bloodChip   = PatientHeaderView.makeMedicalChip(
        sfSymbol: "drop.fill",
        tint: UIColor(red: 1.0, green: 0.30, blue: 0.30, alpha: 1),
        bg:   UIColor(red: 0.75, green: 0.10, blue: 0.10, alpha: 0.30))

    private let allergyChip = PatientHeaderView.makeMedicalChip(
        sfSymbol: "exclamationmark.triangle.fill",
        tint: UIColor.white.withAlphaComponent(0.5),
        bg:   UIColor.white.withAlphaComponent(0.10))

    // MARK: - Dividers

    private let dividerTop    = PatientHeaderView.makeDivider()
    private let dividerBottom = PatientHeaderView.makeDivider()

    // MARK: - Expand / collapse chevron (bottom-right of compact area)

    private let expandButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            b.setImage(UIImage(systemName: "chevron.down", withConfiguration: cfg), for: .normal)
        }
        return b
    }()

    // MARK: - Row 3: Age | Adm Date | Specialty

    private let chipsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private let ageChip       = PatientHeaderView.makeChip(sfSymbol: "person.circle.fill")
    private let dateChip      = PatientHeaderView.makeChip(sfSymbol: "calendar")
    private let specialtyChip = PatientHeaderView.makeChip(sfSymbol: "cross.case.fill")

    // MARK: - Bottom: Doctor + Insurance

    private let doctorIconView: UIImageView = {
        let iv = UIImageView()
        if #available(iOS 13.0, *) { iv.image = UIImage(systemName: "stethoscope") }
        iv.tintColor = UIColor.white.withAlphaComponent(0.70)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let doctorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let roomIconView: UIImageView = {
        let iv = UIImageView()
        if #available(iOS 13.0, *) { iv.image = UIImage(systemName: "bed.double.fill") }
        iv.tintColor = UIColor.white.withAlphaComponent(0.60)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let roomLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.80)
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let insuranceIconView: UIImageView = {
        let iv = UIImageView()
        if #available(iOS 13.0, *) { iv.image = UIImage(systemName: "creditcard.fill") }
        iv.tintColor = UIColor.white.withAlphaComponent(0.60)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let insuranceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.80)
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var cachedDoctorName: String = ""
    private var cachedInsurance:  String = ""

    // MARK: - Init

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame  = bounds
        avatarGradient.frame = avatarContainer.bounds
        layer.cornerRadius   = 24
        layer.maskedCorners  = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    // MARK: - Public API

    func configure(patient: Patient, specialty: String? = nil) {

        // Avatar colour by gender
        let gender = patient.genderAge.uppercased()
        let isMale = gender.hasPrefix("M") || gender == "1"
        if #available(iOS 13.0, *) {
            avatarIconView.image = UIImage(systemName: "person.fill")
        }
        avatarGradient.colors = isMale
            ? [UIColor(red: 0.10, green: 0.48, blue: 0.84, alpha: 1).cgColor,
               UIColor(red: 0.04, green: 0.28, blue: 0.60, alpha: 1).cgColor]
            : [UIColor(red: 0.76, green: 0.22, blue: 0.54, alpha: 1).cgColor,
               UIColor(red: 0.52, green: 0.08, blue: 0.40, alpha: 1).cgColor]

        // Name — strip trailing " -" artifacts from incomplete data; fall
        // back to a placeholder so the layout never collapses to zero height
        // (some BHG records ship `nameInEnglish=null`).
        let displayName = patient.name
            .replacingOccurrences(of: "\\s*-\\s*$", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        nameLabel.text = displayName.isEmpty ? "—" : displayName

        // ID
        setChipText(idChip, patient.id.trimmingCharacters(in: .whitespaces))

        // Phone
        let phone: String
        if let op = patient as? OutpatientPatient { phone = op.patMobile ?? "" }
        else { phone = "" }
        phoneChipContainer.isHidden = phone.isEmpty
        if !phone.isEmpty { phoneNumber = phone; configurePhoneButton(phone) }

        // Nationality
        nationalityLabel.text = patient.nationality.isEmpty ? "—" : patient.nationality
        flagView.image  = patient.countyFlag
        flagView.isHidden = (patient.countyFlag == nil)

        // Blood — placeholder until API responds
        let blood = patient.bloodType.trimmingCharacters(in: .whitespaces)
        applyBloodState(blood.isEmpty ? nil : blood)

        // Allergy — placeholder until API responds
        applyAllergyState(nil)

        // Age / Date / Specialty
        let age: String
        if let ip = patient as? InpatientPatient        { age = ip.age }
        else if let op = patient as? OutpatientPatient  { age = op.age }
        else                                             { age = "" }
        setChipText(ageChip, normalizeAge(age))
        setChipText(dateChip, formatAdmDate(patient.date))
        setChipText(specialtyChip, specialty ?? "—")

        // Doctor
        if let ip = patient as? InpatientPatient        { cachedDoctorName = ip.doctorName }
        else if let op = patient as? OutpatientPatient  { cachedDoctorName = op.empNameEn ?? "" }
        else                                             { cachedDoctorName = "" }
        cachedInsurance = ""
        refreshBottomLabels()
    }

    /// Called after `getVisitsDetail`.
    func updateFromVisitDetail(_ detail: VisitDetail) {
        // Blood
        let blood = (detail.bloodTypeEn ?? detail.bloodTypeAr ?? "").trimmingCharacters(in: .whitespaces)
        applyBloodState(blood.isEmpty ? nil : blood)

        // Allergy
        let allergy = (detail.allergyStatusEn ?? detail.allergyStatusAr ?? "").trimmingCharacters(in: .whitespaces)
        let hasAllergy = !allergy.isEmpty && allergy.lowercased() != "no allergy"
        applyAllergyState(hasAllergy ? allergy : nil)

        // Phone (inpatient fallback)
        if phoneChipContainer.isHidden {
            let tel = (detail.patientTel ?? "").trimmingCharacters(in: .whitespaces)
            if !tel.isEmpty {
                phoneNumber = tel
                phoneChipContainer.isHidden = false
                configurePhoneButton(tel)
            }
        }

        // Insurance
        let contract = (detail.contractNameEn ?? "").trimmingCharacters(in: .whitespaces)
        if !contract.isEmpty { updateInsurance(contract) }

        // Room / Unit
        let unit = (detail.unitNameEn ?? "").trimmingCharacters(in: .whitespaces)
        let room = (detail.roomNameEn ?? "").trimmingCharacters(in: .whitespaces)
        let roomText: String
        if !unit.isEmpty && !room.isEmpty { roomText = "\(unit) - \(room)" }
        else if !unit.isEmpty             { roomText = unit }
        else if !room.isEmpty             { roomText = room }
        else                              { roomText = "" }
        roomLabel.text   = roomText.isEmpty ? "—" : roomText
        roomIconView.isHidden = false

        // Civil ID — update ID chip with the national identity number
        let civilId = (detail.identTypeValue ?? "").trimmingCharacters(in: .whitespaces)
        if !civilId.isEmpty { setChipText(idChip, civilId) }
    }

    /// Called after `getPatientSummary` — fills allergy chip from ALLERGY_TYPE_NAME_EN.
    func updateAllergyFromSummary(_ allergyTypeName: String?) {
        let hasAllergy = allergyTypeName != nil
            && !allergyTypeName!.isEmpty
            && allergyTypeName!.lowercased() != "no known allergy"
        applyAllergyState(hasAllergy ? allergyTypeName : nil)
    }

    func updateSpecialty(_ text: String) {
        setChipText(specialtyChip, text.isEmpty ? "—" : text)
    }

    func updateInsurance(_ text: String) {
        cachedInsurance = text
        refreshBottomLabels()
    }

    // MARK: - Medical chip state helpers

    private func applyBloodState(_ value: String?) {
        setChipText(bloodChip, value ?? "No Blood Type")
        setMedicalChipStyle(
            bloodChip,
            iconTint: UIColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 1),   // always red
            bg: value != nil
                ? UIColor(red: 0.75, green: 0.10, blue: 0.10, alpha: 0.30)
                : UIColor.white.withAlphaComponent(0.08))
    }

    private func applyAllergyState(_ value: String?) {
        if let v = value {
            setChipText(allergyChip, v)
            setMedicalChipStyle(
                allergyChip,
                iconTint: UIColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1),
                bg: UIColor(red: 0.70, green: 0.45, blue: 0.0, alpha: 0.30))
        } else {
            setChipText(allergyChip, "No Known Allergy")
            setMedicalChipStyle(
                allergyChip,
                iconTint: UIColor.white.withAlphaComponent(0.40),
                bg: UIColor.white.withAlphaComponent(0.08))
        }
    }

    // MARK: - Private helpers

    private func setMedicalChipStyle(_ chip: UIView, iconTint: UIColor, bg: UIColor) {
        chip.backgroundColor = bg
        guard #available(iOS 13.0, *) else { return }
        if let row  = chip.subviews.first as? UIStackView,
           let icon = row.arrangedSubviews.first as? UIImageView {
            icon.tintColor = iconTint
        }
    }

    private func setChipText(_ chip: UIView, _ text: String) {
        (chip.viewWithTag(99) as? UILabel)?.text = text
    }

    private func configurePhoneButton(_ number: String) {
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            phoneButton.setImage(UIImage(systemName: "phone.fill", withConfiguration: cfg), for: .normal)
            phoneButton.imageEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
            phoneButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        }
        phoneButton.setTitle(number, for: .normal)
    }

    @objc private func phoneTapped() {
        guard !phoneNumber.isEmpty,
              let url = URL(string: "tel://\(phoneNumber)") else { return }
        if #available(iOS 10, *) { UIApplication.shared.open(url) }
        else { UIApplication.shared.openURL(url) }
    }

    private func refreshBottomLabels() {
        doctorLabel.text    = cachedDoctorName.isEmpty ? "—" : cachedDoctorName
        insuranceLabel.text = cachedInsurance.isEmpty  ? "—" : cachedInsurance
    }

    private func formatAdmDate(_ raw: String) -> String {
        let parts = raw.components(separatedBy: " ")
        guard parts.count >= 2 else { return parts.first ?? raw }
        let hhmm = parts[1].components(separatedBy: ":").prefix(2).joined(separator: ":")
        return "\(parts[0]) \(hhmm)"
    }

    /// Converts the API's free-form age string ("67سنة - 8شهر - 3يوم" or
    /// "67Y - 8M - 3D") into a compact English form: `"67y · 8m · 3d"`.
    /// Falls back to the original string when no numeric components can be
    /// extracted.
    private func normalizeAge(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "—" }

        // Pull out runs of digits (Western or Arabic-Indic).
        let pattern = "[0-9\\u0660-\\u0669]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return trimmed }
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        let nums = regex.matches(in: trimmed, range: range).compactMap {
            Range($0.range, in: trimmed).map { String(trimmed[$0]) }
        }
        guard !nums.isEmpty else { return trimmed }

        let suffixes = ["y", "m", "d"]
        return nums.prefix(3).enumerated()
            .map { i, n in "\(n)\(suffixes[i])" }
            .joined(separator: " · ")
    }

    // MARK: - Factory methods

    /// Standard info chip (ID / age / date / specialty).
    private static func makeChip(sfSymbol: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        container.layer.cornerRadius = 12
        container.layer.borderWidth  = 0.5
        container.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        // Refuse to shrink below intrinsic size so the full ID number renders.
        container.setContentCompressionResistancePriority(.required, for: .horizontal)

        let icon = UIImageView()
        if #available(iOS 13.0, *) { icon.image = UIImage(systemName: sfSymbol) }
        icon.tintColor = UIColor.white.withAlphaComponent(0.85)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 13),
            icon.heightAnchor.constraint(equalToConstant: 13),
        ])

        let label = UILabel()
        label.tag   = 99
        label.font  = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal; row.spacing = 5; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
        ])
        return container
    }

    /// Medical chip (blood / allergy) — larger, accent-tinted, no border (bg carries the colour).
    private static func makeMedicalChip(sfSymbol: String, tint: UIColor, bg: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = bg
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView()
        if #available(iOS 13.0, *) { icon.image = UIImage(systemName: sfSymbol) }
        icon.tintColor = tint
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14),
        ])

        let label = UILabel()
        label.tag   = 99
        label.font  = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal; row.spacing = 6; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 7),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -7),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
        ])
        return container
    }

    private static func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        // Background gradient
        gradientLayer.colors = [
            UIColor(red: 0.04, green: 0.22, blue: 0.38, alpha: 1).cgColor,
            UIColor(red: 0.06, green: 0.40, blue: 0.55, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        // Avatar
        avatarGradient.startPoint = CGPoint(x: 0, y: 0)
        avatarGradient.endPoint   = CGPoint(x: 1, y: 1)
        avatarContainer.layer.insertSublayer(avatarGradient, at: 0)
        avatarContainer.addSubview(avatarIconView)

        // Phone chip
        phoneButton.addTarget(self, action: #selector(phoneTapped), for: .touchUpInside)
        phoneChipContainer.addSubview(phoneButton)
        NSLayoutConstraint.activate([
            phoneButton.topAnchor.constraint(equalTo: phoneChipContainer.topAnchor, constant: 6),
            phoneButton.bottomAnchor.constraint(equalTo: phoneChipContainer.bottomAnchor, constant: -6),
            phoneButton.leadingAnchor.constraint(equalTo: phoneChipContainer.leadingAnchor, constant: 10),
            phoneButton.trailingAnchor.constraint(equalTo: phoneChipContainer.trailingAnchor, constant: -10),
        ])

        // Nat chip
        let natRow = UIStackView(arrangedSubviews: [flagView, nationalityLabel])
        natRow.axis = .horizontal; natRow.spacing = 5; natRow.alignment = .center
        natRow.translatesAutoresizingMaskIntoConstraints = false
        natChipContainer.addSubview(natRow)
        NSLayoutConstraint.activate([
            flagView.widthAnchor.constraint(equalToConstant: 18),
            flagView.heightAnchor.constraint(equalToConstant: 13),
            natRow.topAnchor.constraint(equalTo: natChipContainer.topAnchor, constant: 6),
            natRow.bottomAnchor.constraint(equalTo: natChipContainer.bottomAnchor, constant: -6),
            natRow.leadingAnchor.constraint(equalTo: natChipContainer.leadingAnchor, constant: 10),
            natRow.trailingAnchor.constraint(equalTo: natChipContainer.trailingAnchor, constant: -10),
        ])

        // Row 1: ID | Phone | Nat
        [idChip, phoneChipContainer, natChipContainer]
            .forEach { infoRowStack.addArrangedSubview($0) }

        // Row 2: Blood | Allergy  (full-width)
        [bloodChip, allergyChip]
            .forEach { medicalRowStack.addArrangedSubview($0) }

        // Row 3: Age | Date | Specialty
        [ageChip, dateChip, specialtyChip]
            .forEach { chipsStack.addArrangedSubview($0) }

        // Room hidden until VisitDetail loads
        roomLabel.text    = "—"
        roomIconView.isHidden = false

        // Subviews
        [avatarContainer, nameLabel,
         infoRowStack, medicalRowStack,
         dividerTop, chipsStack, dividerBottom,
         doctorIconView, doctorLabel,
         roomIconView, roomLabel,
         insuranceIconView, insuranceLabel,
         expandButton
        ].forEach { addSubview($0) }

        expandButton.addTarget(self, action: #selector(expandTapped), for: .touchUpInside)

        setupConstraints()
    }

    @objc private func expandTapped() {
        onToggleExpand?()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // Avatar 54 × 54
            avatarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarContainer.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            avatarContainer.widthAnchor.constraint(equalToConstant: 54),
            avatarContainer.heightAnchor.constraint(equalToConstant: 54),
            avatarIconView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarIconView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarIconView.widthAnchor.constraint(equalToConstant: 28),
            avatarIconView.heightAnchor.constraint(equalToConstant: 28),

            // Name
            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: avatarContainer.topAnchor),

            // Row 1: ID | Phone | Nat  (right of avatar — stops before the chevron)
            infoRowStack.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            infoRowStack.trailingAnchor.constraint(lessThanOrEqualTo: expandButton.leadingAnchor, constant: -8),
            infoRowStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),

            // Row 2: Blood | Allergy  (full-width — spanning under avatar too)
            // Anchor below BOTH the avatar and the info-chip row so a
            // 2-line patient name (which pushes infoRowStack down) doesn't
            // overlap the medical row.
            medicalRowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            medicalRowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            medicalRowStack.topAnchor.constraint(greaterThanOrEqualTo: avatarContainer.bottomAnchor, constant: 8),
            medicalRowStack.topAnchor.constraint(greaterThanOrEqualTo: infoRowStack.bottomAnchor, constant: 8),

            // Divider top
            dividerTop.topAnchor.constraint(equalTo: medicalRowStack.bottomAnchor, constant: 8),
            dividerTop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dividerTop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dividerTop.heightAnchor.constraint(equalToConstant: 0.5),

            // Row 3: Age | Date | Specialty
            chipsStack.topAnchor.constraint(equalTo: dividerTop.bottomAnchor, constant: 8),
            chipsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chipsStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            // Divider bottom
            dividerBottom.topAnchor.constraint(equalTo: chipsStack.bottomAnchor, constant: 8),
            dividerBottom.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dividerBottom.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dividerBottom.heightAnchor.constraint(equalToConstant: 0.5),

            // Doctor
            doctorIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            doctorIconView.topAnchor.constraint(equalTo: dividerBottom.bottomAnchor, constant: 7),
            doctorIconView.widthAnchor.constraint(equalToConstant: 13),
            doctorIconView.heightAnchor.constraint(equalToConstant: 13),
            doctorLabel.leadingAnchor.constraint(equalTo: doctorIconView.trailingAnchor, constant: 5),
            doctorLabel.centerYAnchor.constraint(equalTo: doctorIconView.centerYAnchor),
            doctorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Room
            roomIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            roomIconView.topAnchor.constraint(equalTo: doctorIconView.bottomAnchor, constant: 5),
            roomIconView.widthAnchor.constraint(equalToConstant: 13),
            roomIconView.heightAnchor.constraint(equalToConstant: 13),
            roomLabel.leadingAnchor.constraint(equalTo: roomIconView.trailingAnchor, constant: 5),
            roomLabel.centerYAnchor.constraint(equalTo: roomIconView.centerYAnchor),
            roomLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Insurance — NOTE: the bottom-pin is intentionally omitted from
            // the `activate(...)` block below. It's installed separately with
            // a low priority so it doesn't fight the external compact-height
            // constraint set by LiteOverviewViewController.
            insuranceIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            insuranceIconView.topAnchor.constraint(equalTo: roomIconView.bottomAnchor, constant: 5),
            insuranceIconView.widthAnchor.constraint(equalToConstant: 13),
            insuranceIconView.heightAnchor.constraint(equalToConstant: 13),
            insuranceLabel.leadingAnchor.constraint(equalTo: insuranceIconView.trailingAnchor, constant: 5),
            insuranceLabel.centerYAnchor.constraint(equalTo: insuranceIconView.centerYAnchor),
            insuranceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Expand chevron — anchored to the avatar row so it stays at a
            // fixed position regardless of name length / chip wrap. Sits to
            // the right of the chip row, vertically centered with the avatar.
            expandButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            expandButton.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            expandButton.widthAnchor.constraint(equalToConstant: 32),
            expandButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        // Insurance bottom pin — installed at low priority so the external
        // compact-height constraint (100pt, set by LiteOverviewViewController)
        // can win without an Auto Layout conflict warning. In expanded mode
        // (232pt) the constraint still wins over content compression.
        let insuranceBottom = insuranceIconView.bottomAnchor
            .constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        insuranceBottom.priority = .defaultLow
        insuranceBottom.isActive = true
    }

    // MARK: - Compact / expanded mode

    /// Hides everything below the avatar / name / chips row. Also hides the
    /// nationality chip in compact mode so the ID + Phone chips have room to
    /// display in full (otherwise three chips fight for the same row width
    /// and all three truncate). The view's height constraint must be
    /// updated by the host — this only flips subview visibility, rotates
    /// the chevron, and toggles the nationality chip in the chip stack.
    func setCompact(_ compact: Bool, animated: Bool) {
        isCompact = compact
        let hide = compact

        // Nationality chip is in `infoRowStack`, which uses
        // `.fillProportionally` distribution — `alpha = 0` would still
        // reserve space, so we toggle `isHidden` instead. UIStackView
        // animates that smoothly inside a UIView animation block.
        natChipContainer.isHidden = hide

        let updates = {
            self.medicalRowStack.alpha   = hide ? 0 : 1
            self.dividerTop.alpha        = hide ? 0 : 1
            self.chipsStack.alpha        = hide ? 0 : 1
            self.dividerBottom.alpha     = hide ? 0 : 1
            self.doctorIconView.alpha    = hide ? 0 : 1
            self.doctorLabel.alpha       = hide ? 0 : 1
            self.roomIconView.alpha      = hide ? 0 : 1
            self.roomLabel.alpha         = hide ? 0 : 1
            self.insuranceIconView.alpha = hide ? 0 : 1
            self.insuranceLabel.alpha    = hide ? 0 : 1

            // Rotate chevron: down when compact (tap to expand), up when expanded.
            let angle: CGFloat = hide ? 0 : .pi
            self.expandButton.transform = CGAffineTransform(rotationAngle: angle)

            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: updates)
        } else {
            updates()
        }
    }
}
