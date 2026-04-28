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
    var error:String?

  enum CodingKeys: String, CodingKey {
      case patientVisits = "VISIT"
      case visitId = "VISIT_ID"
      case currentSpeciality = "CURRENT_SPECIALITY"
      case currentDoctor = "CURRENT_DOCTOR"
      case error
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
  // Identifiers
  let id: String                       // VISIT_ID — used for API filters
  let visitIdArray: String?            // VISIT_ID_ARRAY — comma-separated linked visit IDs
  let visitIdLetter: String?           // VISIT_ID_LETTER — human label e.g. "2 SKH"

  // Classification
  let classCode: String?               // CLASSCODE — "1"=Inpatient, "2"=Outpatient
  let classNameEn: String?             // CLASSNAME_EN — "Inpatient" / "Outpatient"

  // Dates
  let startDate: String?               // VISIT_START_DATE — "05/02/2025 05:05 pm"
  let endDateEn: String?               // VISIT_END_DATE_EN — "Opened" or actual date

  // Doctor / Specialty
  let doctorId: String                 // EMP_ID — used for currentDoctor filter
  let doctorNameEn: String?            // EMP_EN_DATA — display name
  let specialityId: String             // SPECIAL_SPEC_ID — used for currentSpeciality filter
  let specialityNameEn: String?        // SPECIALITY_NAME_EN — display name

  // Location
  let clinicNameEn: String?            // CLINIC_NAME_EN
  let placeNameEn: String?             // PLACE_NAME_EN — bed / room / ward

  // Contract / Insurance
  let contractNameEn: String?          // CONTRACT_NAME_EN — "Without Insurance" etc.

  // Case info
  let docCaseNameEn: String?           // DOC_CASE_NAME_EN — "Hosptial Case"
  let visitFollowEn: String?           // VISIT_FOLLOW_EN — "Consultaion"
  let diagText: String?                // DIAG_TEXT

  // Status flags ("0" / "1")
  let cancelledVisit: String?          // CANCLED_VISIT
  let tempDischargeFlag: String?       // TEMP_DISCHARGE_FLAG

  // Extras
  let pagesCount: String?              // PAGES_COUNT
  let erBounceBackFlag: String?        // ER_BOUNCE_BACK_FLAG

  enum CodingKeys: String, CodingKey {
    case id                = "VISIT_ID"
    case visitIdArray      = "VISIT_ID_ARRAY"
    case visitIdLetter     = "VISIT_ID_LETTER"
    case classCode         = "CLASSCODE"
    case classNameEn       = "CLASSNAME_EN"
    case startDate         = "VISIT_START_DATE"
    case endDateEn         = "VISIT_END_DATE_EN"
    case doctorId          = "EMP_ID"
    case doctorNameEn      = "EMP_EN_DATA"
    case specialityId      = "SPECIAL_SPEC_ID"
    case specialityNameEn  = "SPECIALITY_NAME_EN"
    case clinicNameEn      = "CLINIC_NAME_EN"
    case placeNameEn       = "PLACE_NAME_EN"
    case contractNameEn    = "CONTRACT_NAME_EN"
    case docCaseNameEn     = "DOC_CASE_NAME_EN"
    case visitFollowEn     = "VISIT_FOLLOW_EN"
    case diagText          = "DIAG_TEXT"
    case cancelledVisit    = "CANCLED_VISIT"
    case tempDischargeFlag = "TEMP_DISCHARGE_FLAG"
    case pagesCount        = "PAGES_COUNT"
    case erBounceBackFlag  = "ER_BOUNCE_BACK_FLAG"
  }

  // MARK: Computed helpers

  /// True when the visit is still open (VISIT_END_DATE_EN == "Opened").
  var isOpen: Bool { endDateEn?.lowercased() == "opened" }

  /// True when the visit is inpatient (CLASSCODE == "1").
  var isInpatient: Bool { classCode == "1" }
}
