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
    var queue: String { get }
    var doctorName: String { get }
    var time: String { get }
    var clinicTitle: String { get }
    var age: String { get }
    var status: String { get }
    var statusColor: String { get }
    var gender: String { get }
    var genderColor: UIColor { get }
    var avatarTint: UIColor { get }
    var cashierFlag: String { get }
    var patMobile: String { get }
    var shift: String { get }
    var servStatus: String { set get }
}

class OutpatientCellPresenterImpl: OutpatientCellPresenter {
    var outpatientPatient: OutpatientPatient
    var servStatus: String

    var genderAgeImage: UIImage? {
        guard let genderAgeType = GenderAgeType(rawValue: outpatientPatient.genderAge) else { return nil }
        return getGenderAgeImage(genderAgeType: genderAgeType)
    }

    /// "PATID - NAME" — same format InpatientCell uses, so the two cell
    /// types read identically.
    var patientName: String {
        let id = outpatientPatient.id.trimmingCharacters(in: .whitespaces)
        let n  = outpatientPatient.name.trimmingCharacters(in: .whitespaces)
        if id.isEmpty { return n }
        if n.isEmpty  { return id }
        return "\(id) - \(n)"
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

    // Use GENDER_NAME_EN ("Male" / "Female") — not GENDER_AGE_NAME_EN.
    var gender: String {
        let g = (outpatientPatient.genderNameEn ?? "").trimmingCharacters(in: .whitespaces)
        return g.isEmpty ? (outpatientPatient.genderAgeNameEn ?? "") : g
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

    init(with outpatientPatient: OutpatientPatient) {
      self.outpatientPatient = outpatientPatient
        self.servStatus = outpatientPatient.serVStatus ?? ""
    }

}
