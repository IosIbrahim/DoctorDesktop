//
//  PatientCounts.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/10/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

struct ErrorModel: Decodable {
    var error:String?
    enum CodingKeys: String, CodingKey {
      case error = "Message"
    }
}
struct PatientCount: Decodable {
  var inpatientFloor: String = ""
  var inpatientCare: String = ""
  var outpatient: String = ""
  var emergency: String = ""
  var emergencyOverstaying: String = ""
  var operation: String = ""
  var physiology: String = ""
  var triage: String = ""
  var cosultationFromDoctor: String = ""
  var cosultationToDoctor: String = ""
  var clinicalAlert: String = ""
  var doctorRemarks: String = ""
  var notSeenResults: String = ""
  var pendingOrders: String = ""
  var pendingDosages: String = ""
  var rejectionCount: String = ""
  var sickLeave: String = ""
  var dischargeRequest: String = ""
  var planFollowupChemo: String = ""
  var planFollowupRad: String = ""
  var planFollowupRenal: String = ""
  var notSampledOrder: String = ""
  var patientVentilator: String = ""
  var pendingAdverseEvents: String = ""
  var inpatientNICU: String = ""
  var ClinicPharmacy: String = ""
    var error:String? = nil
    var permissions: DoctorPermissions?

  enum CodingKeys: String, CodingKey {
    case inpatientFloor = "INPAT_FLOOR"
    case inpatientCare = "INPAT_CARE"
    case outpatient = "OUTPAT"
    case emergency = "ER"
    case emergencyOverstaying = "ER_OVERSTAYING_COUNT"
    case operation = "OPER"
    case physiology = "PHYSIO"
    case triage = "TR"
    case cosultationFromDoctor = "V_CONSULTATION_FROM_DOC_COUNT"
    case cosultationToDoctor = "V_CONSULTATION_TO_DOC_COUNT"
    case clinicalAlert = "CLINICAL_ALERTS"
    case doctorRemarks = "DOC_REMARKS"
    case notSeenResults = "NOT_SEEN_RESULT"
    case pendingOrders = "PENDING_ORDERS"
    case pendingDosages = "PENDING_DOSAGES"
    case rejectionCount = "REJECTION_COUNT"
    case sickLeave = "SICK_LEAVE"
    case dischargeRequest = "OUTPATIENT_DISCHARGE_REQUEST"
    case planFollowupChemo = "PLAN_FOLLOWUP_CHEMO"
    case planFollowupRad = "PLAN_FOLLOWUP_RAD"
    case planFollowupRenal = "PLAN_FOLLOWUP_RENAL"
    case notSampledOrder = "NOT_SAMPLED_ORDER"
    case patientVentilator = "PAT_VENTILATOR_COUNT"
    case pendingAdverseEvents = "PENDING_ADVERSE_EVENTS"
    case inpatientNICU = "INPAT_NICU_COUNT"
    case ClinicPharmacy = "COUNT_CLINIC_PHARM"
    case error = "Error"
      case permissions = "Permissions"
  }
}
