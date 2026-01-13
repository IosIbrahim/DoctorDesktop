//
//  InpatientUnit.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/11/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

struct PatientUnit: Decodable {
  let id: String
  private let arabicName: String
  private let englishName: String
  var name: String { return englishName }
  var patientsCount: String
  var shiftFlag: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case arabicName = "NAME_AR"
    case englishName = "NAME_EN"
    case patientsCount = "PAT_COUNT"
    case shiftFlag = "SHIFT_FLAG"
    
    case clinicPatient = "CLINIC_PATIENTS"
  }
  
  enum ClinicPatientCodingKeys: String, CodingKey {
    case clinicPatientRow = "CLINIC_PATIENTS_ROW"
  }
}

extension PatientUnit {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(String.self, forKey: .id)
    let arabicName = try container.decode(String.self, forKey: .arabicName)
    let englishName = try container.decode(String.self, forKey: .englishName)
    let shiftFlag = try? container.decode(String.self, forKey: .shiftFlag)
    
    var patientCount = "0"
    if let count = try? container.decode(String.self, forKey: .patientsCount) {
      patientCount = count
    } else  {
      if let _ = try? container.decode(String.self, forKey: .clinicPatient) {
        patientCount = "0"
      } else {
        let clinicPatientContainer = try! container.nestedContainer(keyedBy: ClinicPatientCodingKeys.self, forKey: .clinicPatient)
        if let _ = try? clinicPatientContainer.nestedContainer(keyedBy: ClinicPatientCodingKeys.self, forKey: .clinicPatientRow) {
          patientCount = "1"
        } else if let count = try? clinicPatientContainer.nestedUnkeyedContainer(forKey: .clinicPatientRow).count {
          patientCount = "\(count ?? 0)"
        }
      }
    }
    
    self.init(id: id,
              arabicName: arabicName,
              englishName: englishName,
              patientsCount: patientCount,
              shiftFlag: shiftFlag)
  }
}
