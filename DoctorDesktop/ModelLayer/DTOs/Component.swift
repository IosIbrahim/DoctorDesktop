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
    case operations = 70 // 70 — OR (operation room) patient list, view-only
    case consultation = 576
//    case clinicalAlert = 1020 // 1020  X
    case ICU = 2284 // 2665 X
    case nicu = 2260
//    case notifications = 1
//    case search = 72
 // case nurseTL = 1478
}

struct Component: Decodable {
    var id: Int = 0
    var processInfoCode: Int = 0
    private var arabicName: String = ""
    private var englishName: String = ""
    private var shortNameInArabic: String?
    private var shortNameInEnglish: String?

    var name: String { return englishName }
    var shortName: String? { return shortNameInEnglish }
    var type: ComponentType? = nil
    var mobileFlag: Int?
    var patientsCount = "0"

    enum CodingKeys: String, CodingKey {
        case id           = "ID"
        case processInfoCode = "PROCESS_INFO_CODE"
        case arabicName   = "NAME_AR"
        case englishName  = "NAME_EN"
        case shortNameInArabic = "SHORT_NAME_AR"
        case shortNameInEnglish = "SHORT_NAME_EN"
        case mobileFlag   = "MOBILE_FLAG"
    }

    init() {}

    /// Tolerant decoder — every field uses `try?` and falls back through
    /// reasonable type coercions. A single type mismatch on one array item
    /// must NOT drop the entire `userComponent` array.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // Int — try Int, then Double (e.g. 1.0), then String → Int
        func intVal(_ key: CodingKeys) -> Int? {
            if let v = try? c.decode(Int.self,    forKey: key) { return v }
            if let v = try? c.decode(Double.self, forKey: key) { return Int(v) }
            if let s = try? c.decode(String.self, forKey: key), let v = Int(s) { return v }
            return nil
        }

        id              = intVal(.id) ?? 0
        processInfoCode = intVal(.processInfoCode) ?? 0
        arabicName      = (try? c.decode(String.self, forKey: .arabicName)) ?? ""
        englishName     = (try? c.decode(String.self, forKey: .englishName)) ?? ""
        shortNameInArabic  = try? c.decode(String.self, forKey: .shortNameInArabic)
        shortNameInEnglish = try? c.decode(String.self, forKey: .shortNameInEnglish)
        mobileFlag      = intVal(.mobileFlag)
    }

    mutating func updateName(_ title: String) {
        self.shortNameInEnglish = title
        if title == "Notifications" {
            patientsCount = "2762"
        }
    }
}
