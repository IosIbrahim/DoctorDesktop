//
//  OutpatientCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/18/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol OutpatientCellPresenter {
    var genderAgeImage: UIImage? { get }
    var patientName: String { get }
    var nameInitial: String { get }
    var queue: String { get }
    var doctorName: String { get }
    var time: String { get }
    var clinicTitle: String { get }
    var age: String { get }
    var ageYears: String? { get }
    var ageMonths: String? { get }
    var ageDays: String? { get }
    /// Fallback "Old Woman" / "Man" / "Child" string from GENDER_AGE_NAME_EN.
    /// Shown as a single pill when the structured year/month/day breakdown is
    /// missing (BHG test sometimes ships AGE_DESC_ROUND_EN as null).
    var ageGenderName: String { get }
    var status: String { get }
    var statusColor: String { get }
    var gender: String { get }
    var genderColor: UIColor { get }
    var avatarTint: UIColor { get }
    var cashierFlag: String { get }
    var patMobile: String { get }
    var shift: String { get }
    var servStatus: String { set get }
    /// True when the server returns HIGHLIGHT_FLAG="1". The cell renders a red
    /// left-edge accent bar + pale pink tint to signal "needs attention".
    var isHighlighted: Bool { get }
}

class OutpatientCellPresenterImpl: OutpatientCellPresenter {
    var outpatientPatient: OutpatientPatient
    var servStatus: String

    var genderAgeImage: UIImage? {
        guard let genderAgeType = GenderAgeType(rawValue: outpatientPatient.genderAge) else { return nil }
        return getGenderAgeImage(genderAgeType: genderAgeType)
    }

    /// "PATID - NAME" — same format as InpatientCell.
    var patientName: String {
        let id = outpatientPatient.id.trimmingCharacters(in: .whitespaces)
        let n  = outpatientPatient.name.trimmingCharacters(in: .whitespaces)
        if id.isEmpty { return n }
        if n.isEmpty  { return id }
        return "\(id) - \(n)"
    }

    /// First letter of the name part (skips the leading PATID), uppercased.
    /// Used by the avatar circle's monogram.
    var nameInitial: String {
        let n = outpatientPatient.name.trimmingCharacters(in: .whitespaces)
        return String(n.prefix(1)).uppercased()
    }

    var queue: String        { return outpatientPatient.queSysSer ?? "" }
    var doctorName: String   { return outpatientPatient.empNameEn ?? "" }
    var time: String         { return outpatientPatient.serviceTime ?? "" }
    var clinicTitle: String  { return outpatientPatient.clinicNameEN ?? "" }
    var age: String          { return outpatientPatient.age }
    var status: String       { return outpatientPatient.serVStatusNameEn ?? "" }
    var statusColor: String  { return outpatientPatient.serColor ?? "" }
    var patMobile: String    { return outpatientPatient.patMobile ?? "" }
    var shift: String        { return outpatientPatient.shiftID ?? "" }
    var cashierFlag: String  { return outpatientPatient.cashierFlag ?? "0" }

    /// Resolves the patient's gender as the bare string `"Male"` / `"Female"`
    /// (or `""` if truly unknown). Tries three sources in order so we recover
    /// gender even when the API returns sparse data:
    ///
    ///   1. `GENDER_NAME_EN` — already "Male"/"Female" when populated.
    ///   2. `GENDER_AGE` numeric code (1/3/6 = Male, 2/4/5/7 = Female).
    ///   3. `GENDER_AGE_NAME_EN` keyword sniff — "Man"/"Boy"/"Male" → Male,
    ///      "Woman"/"Girl"/"Female"/"Pregnant" → Female. The age modifier
    ///      ("Old", "Child") is dropped — manager only wants the bare gender.
    var gender: String {
        let g = (outpatientPatient.genderNameEn ?? "").trimmingCharacters(in: .whitespaces)
        if !g.isEmpty { return g }

        switch GenderAgeType(rawValue: outpatientPatient.genderAge) {
        case .male, .oldMale, .childMale:                  return "Male"
        case .female, .oldFemale, .childFemale, .pregnant: return "Female"
        default: break
        }

        let h = (outpatientPatient.genderAgeNameEn ?? "").lowercased()
        if h.contains("woman") || h.contains("girl") ||
           h.contains("female") || h.contains("pregnant") {
            return "Female"
        }
        if h.contains("man") || h.contains("boy") || h.contains("male") {
            return "Male"
        }
        return ""
    }

    var genderColor: UIColor {
        switch gender.lowercased() {
        case "male":   return UIColor(red: 0.18, green: 0.49, blue: 0.90, alpha: 1)  // blue
        case "female": return UIColor(red: 0.91, green: 0.30, blue: 0.50, alpha: 1)  // rose
        default:       return UIColor(white: 0.45, alpha: 1)
        }
    }

    /// Soft tint for the avatar circle background.
    var avatarTint: UIColor {
        switch gender.lowercased() {
        case "male":   return UIColor(red: 0.36, green: 0.62, blue: 0.95, alpha: 1)
        case "female": return UIColor(red: 0.95, green: 0.50, blue: 0.66, alpha: 1)
        default:       return UIColor(red: 64/255, green: 178/255, blue: 178/255, alpha: 1)
        }
    }

    // MARK: Age components
    //
    // The API ships AGE_DESC_ROUND_EN as a free-form Arabic-or-English string
    // like "57سنة - 8شهر - 3يوم" (or "57Y - 8M - 3D"). We extract the three
    // numeric components in order so the UI can render them as separate icon-
    // labeled pills (years / months / days). Components missing from the
    // source string come back nil and the cell drops their pill.

    private var ageNumbers: [String] {
        // Match runs of digits — works for both Arabic numerals and Western.
        let pattern = "[0-9\\u0660-\\u0669]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let s = outpatientPatient.age
        let range = NSRange(s.startIndex..., in: s)
        return regex.matches(in: s, range: range).compactMap {
            Range($0.range, in: s).map { String(s[$0]) }
        }
    }

    var ageYears:  String? { ageNumbers.indices.contains(0) ? ageNumbers[0] : nil }
    var ageMonths: String? { ageNumbers.indices.contains(1) ? ageNumbers[1] : nil }
    var ageDays:   String? { ageNumbers.indices.contains(2) ? ageNumbers[2] : nil }

    /// `GENDER_AGE_NAME_EN` (e.g. "Old Woman", "Man", "Child") — used as the
    /// info-row fallback when AGE_DESC_ROUND_EN is missing entirely.
    var ageGenderName: String {
        return (outpatientPatient.genderAgeNameEn ?? "").trimmingCharacters(in: .whitespaces)
    }

    /// Server-driven HIGHLIGHT_FLAG — "1" means render the red accent.
    var isHighlighted: Bool {
        return (outpatientPatient.highLightFlag ?? "").trimmingCharacters(in: .whitespaces) == "1"
    }

    init(with outpatientPatient: OutpatientPatient) {
        self.outpatientPatient = outpatientPatient
        self.servStatus = outpatientPatient.serVStatus ?? ""
    }
}
