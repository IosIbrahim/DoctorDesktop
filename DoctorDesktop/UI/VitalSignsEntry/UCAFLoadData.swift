//
//  UCAFLoadData.swift
//  DoctorDesktop
//
//  DTO for the `MedicalRecord/loadUcaf` response. Mirrors the Android
//  contract. Intentionally separate from the leaner `UCAFData` used by
//  EmergencyTriageViewController so we don't destabilize that screen.
//
//  Only the fields the VitalSignsEntry screen actually renders are mapped —
//  everything else in the payload is ignored.
//

import Foundation

struct UCAFLoadData: Decodable {
  // Vitals
  var bp: String?                  // systolic
  var pb2: String?                 // diastolic (Android sends PB_2)
  var pulse: String?
  var temp: String?
  var respiratoryRate: String?
  var o2Sat: String?
  var bloodGlucose: String?
  var bloodKetones: String?
  var weight: String?
  var height: String?
  var headDiameter: String?
  var bmi: String?
  var bsa: String?
  var shockIndex: String?

  // Pain
  var painScaleAdultScore: String?
  var painFrequency: String?
  var painRadiatingFlag: String?

  // Special needs (all "0"/"1" strings)
  var muteFlag: String?
  var deafFlag: String?           // Android uses DEAF for "Blind"? we keep raw name
  var handicappedFlag: String?
  var abuseFlag: String?
  var neglectFlag: String?
  var selfHarmFlag: String?
  var suicideFlag: String?
  var safetyFlag: String?

  // Meta
  var ser: String?
  var scoreType: String?
  var painScoreSer: String?
  var vlsRemarks: String?

  enum CodingKeys: String, CodingKey {
    case bp                  = "BP"
    case pb2                 = "PB_2"
    case pulse               = "PULSE"
    case temp                = "TEMP"
    case respiratoryRate     = "RESPIRATORY_RATE"
    case o2Sat               = "O2SAT"
    case bloodGlucose        = "BLOOD_GLUCOSE"
    case bloodKetones        = "BLOOD_KETONES"
    case weight              = "WEIGHT"
    case height              = "HEIGHT"
    case headDiameter        = "HEAD_DIAMETER"
    case bmi                 = "BMI"
    case bsa                 = "BSA"
    case shockIndex          = "SHOCK_INDEX"
    case painScaleAdultScore = "PAIN_SCALE_ADULT_SCORE"
    case painFrequency       = "PAIN_FREQUENCY"
    case painRadiatingFlag   = "PAIN_RADIATING_FLAG"
    case muteFlag            = "MUTE_FLAG"
    case deafFlag            = "DEAF_FLAG"
    case handicappedFlag     = "HANDICAPPED_FLAG"
    case abuseFlag           = "ABUSE_FLAG"
    case neglectFlag         = "NEGLECT_FLAG"
    case selfHarmFlag        = "SELF_HARM_FLAG"
    case suicideFlag         = "SUICIDE_FLAG"
    case safetyFlag          = "SAFETY_FLAG"
    case ser                 = "SER"
    case scoreType           = "SCORE_TYPE"
    case painScoreSer        = "PAIN_SCORE_SER"
    case vlsRemarks          = "VLS_REMARKS"
  }
}

/// Server-computed CTAS (optional). Lives at `Root.CTAS.CTAS_DATA.CTAS_DATA_ROW`
/// in the response.
struct UCAFCTASServer: Decodable {
  var totalItemDesc: String?
  var totalItemScore: String?     // CTAS level "1".."5"
  var conclusionDesc: String?     // e.g. "[Less Urgent]"
  var conclusionColor: String?    // e.g. "#27AE60"

  enum CodingKeys: String, CodingKey {
    case totalItemDesc   = "TOT_ITEM_DESC"
    case totalItemScore  = "TOT_ITEM_SCORE"
    case conclusionDesc  = "CONCULSION_DESC"
    case conclusionColor = "CONCULSION_COLOR"
  }
}
