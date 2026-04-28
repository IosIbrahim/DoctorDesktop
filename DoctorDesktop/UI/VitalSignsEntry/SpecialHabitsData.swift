//
//  SpecialHabitsData.swift
//  DoctorDesktop
//
//  DTO for the `MedicalRecord/loadSpecialHappits` response.
//  Note: the server endpoint name contains a typo ("Happits") — kept as-is
//  to match the real URL.
//
//  Response lives at Root.SPECIAL_HABITS in the JSON body.
//  STATUS_FLAG "1" = patient has recorded habits (show checkboxes).
//  STATUS_FLAG "2" / nil = no known habits.
//
//  All flag fields are "0" (off) or "1" (on).
//

import Foundation

struct SpecialHabitsData: Decodable {
  var statusFlag:      String?   // "1" = Has Special Habits, "2" = No Known
  var alcoholFlag:     String?   // ALCOHOL_FLAG
  var alcoholText:     String?   // ALCOHOL_TEXT
  var smokerFlag:      String?   // SMOKER_FLAG
  var smokerText:      String?   // SMOKER_TEXT
  var morphineFlag:    String?   // MORPHINE_FLAG
  var morphineText:    String?   // MORPHINE_TEXT
  var cannabinoidFlag: String?   // CANNABINOID_FLAG
  var cannabinoidText: String?   // CANNABINOID_TEXT
  var drugsFlag:       String?   // DRUGS_FLAG  (Substance use / Illicit drugs)
  var drugsText:       String?   // DRUGS_TEXT
  var shishaFlag:      String?   // SHISHA_FLAG
  var shishaText:      String?   // SHISHA_TEXT
  var vapeFlag:        String?   // VAPE_FLAG
  var vapeText:        String?   // VAPE_TEXT
  var otherFlag:       String?   // OTHER_FLAG
  var otherText:       String?   // OTHER_TEXT
  var maritalStatusEn: String?   // MARTIAL_STATUS_EN
  var maritalStatusAr: String?   // MARTIAL_STATUS_AR
  var socioeconomic:   String?   // SOCIOECONOMIC

  enum CodingKeys: String, CodingKey {
    case statusFlag      = "STATUS_FLAG"
    case alcoholFlag     = "ALCOHOL_FLAG"
    case alcoholText     = "ALCOHOL_TEXT"
    case smokerFlag      = "SMOKER_FLAG"
    case smokerText      = "SMOKER_TEXT"
    case morphineFlag    = "MORPHINE_FLAG"
    case morphineText    = "MORPHINE_TEXT"
    case cannabinoidFlag = "CANNABINOID_FLAG"
    case cannabinoidText = "CANNABINOID_TEXT"
    case drugsFlag       = "DRUGS_FLAG"
    case drugsText       = "DRUGS_TEXT"
    case shishaFlag      = "SHISHA_FLAG"
    case shishaText      = "SHISHA_TEXT"
    case vapeFlag        = "VAPE_FLAG"
    case vapeText        = "VAPE_TEXT"
    case otherFlag       = "OTHER_FLAG"
    case otherText       = "OTHER_TEXT"
    case maritalStatusEn = "MARTIAL_STATUS_EN"
    case maritalStatusAr = "MARTIAL_STATUS_AR"
    case socioeconomic   = "SOCIOECONOMIC"
  }

  /// True when the server says the patient has recorded habits (STATUS_FLAG == "1").
  var hasHabits: Bool { statusFlag == "1" }
}
