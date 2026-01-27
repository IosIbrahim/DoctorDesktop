//
//  Component.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/10/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

enum ComponentType: Int {
  case inpatient = 68 // 68
  case outpatient = 69 // 69
  case emergency = 71
  case consultation = 576
  case clinicalAlert = 1020 // 1020  X
  case ICU = 2284 // 2665 X
  case operations = 70 // 70 X
  case nicu = 2260
 // case nurseTL = 1478
}

class Component: Decodable {
  let id: Int
  let processInfoCode: Int
  private let arabicName: String
  private let englishName: String
  private let shortNameInArabic: String?
  private let shortNameInEnglish: String?

  var name: String { return englishName }
  var shortName: String? { return shortNameInEnglish }
  var type: ComponentType? = nil
  let mobileFlag : Int?
  var patientsCount = "0"
  
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case processInfoCode = "PROCESS_INFO_CODE"
    case arabicName = "NAME_AR"
    case englishName = "NAME_EN"
    case shortNameInArabic = "SHORT_NAME_AR"
    case shortNameInEnglish = "SHORT_NAME_EN"

    case mobileFlag = "MOBILE_FLAG"
  }
}
