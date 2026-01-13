//
//  OverviewSection.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/16/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

struct PatientHistory: Decodable {
  let patientVisits: [PatientVisit]
  let currentSpeciality: GeneralObejct
  let currentDoctor: GeneralObejct

  enum CodingKeys: String, CodingKey {
    case patientVisits = "VISIT"
    case visitId = "VISIT_ID"
    case currentSpeciality = "CURRENT_SPECIALITY"
    case currentDoctor = "CURRENT_DOCTOR"
  }

  enum CodingKeysRows: String, CodingKey {
    case patientVisitsRow = "VISIT_ROW"
    case currentSpecialityRow = "CURRENT_SPECIALITY_ROW"
    case currentDoctorRow = "CURRENT_DOCTOR_ROW"
  }
}

extension PatientHistory {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let patientVisitsRow = try container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .patientVisits)
    var visits: [PatientVisit] = []
    if let decodedPatientVisits = try? patientVisitsRow.decode([PatientVisit].self, forKey: .patientVisitsRow) {
      visits = decodedPatientVisits
    } else if let decodedPatientVisit = try? patientVisitsRow.decode(PatientVisit.self, forKey: .patientVisitsRow) {
      visits = [decodedPatientVisit]
    }
    let currentSpecialityRow = try container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .currentSpeciality)
    let currentSpeciality = try currentSpecialityRow.decode(GeneralObejct.self, forKey: .currentSpecialityRow)
    let currentDoctorRow = try container.nestedContainer(keyedBy: CodingKeysRows.self, forKey: .currentDoctor)
    let currentDoctor = try currentDoctorRow.decode(GeneralObejct.self, forKey: .currentDoctorRow)
    self.init(patientVisits: visits, currentSpeciality: currentSpeciality, currentDoctor: currentDoctor)
  }
}

struct PatientVisit: Decodable {
  let id: String
  let doctorId: String
  let specialityId: String

  enum CodingKeys: String, CodingKey {
    case id = "VISIT_ID"
    case doctorId = "EMP_ID"
    case specialityId = "SPECIAL_SPEC_ID"
  }
}
