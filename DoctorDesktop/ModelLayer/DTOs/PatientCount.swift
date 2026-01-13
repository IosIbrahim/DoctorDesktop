//
//  PatientCounts.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/10/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

struct PatientCount: Decodable {
  let inpatientFloor: String
  let inpatientCare: String
  let outpatient: String
  let emergency: String
  let emergencyOverstaying: String
  let operation: String
  let physiology: String
  let triage: String
  let cosultationFromDoctor: String
  let cosultationToDoctor: String
  let clinicalAlert: String
  let doctorRemarks: String
  let notSeenResults: String
  let pendingOrders: String
  let pendingDosages: String
  let rejectionCount: String
  let sickLeave: String
  let dischargeRequest: String
  let planFollowupChemo: String
  let planFollowupRad: String
  let planFollowupRenal: String
  let notSampledOrder: String
  let patientVentilator: String
  let pendingAdverseEvents: String
  let inpatientNICU: String
  let ClinicPharmacy: String

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
  }
}
