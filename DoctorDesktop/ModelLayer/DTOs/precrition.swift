//
//  precrition.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/18/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

//"ID": 121000,
//"PROCESS_INFO_CODE": 1697,
//"NAME_AR": "روشتة عادية",
//"NAME_EN": "Routine Rx",
//"PROCESS_SORT": 1,
//"SHORT_NAME_AR": null,
//"SHORT_NAME_EN": null,
//"PIC_NAME": null,
//"COLOR": null,
//"PROCESS_MANDATORY": 0,
//"PROCESS_ENABLED": 1,
//"OBJECT_ID": 4157,
//"PROCESS_CATEGORY": "tabs",
//"HAS_SHEET": 0,
//"SHEETID": null,
//"PARENT_PROCESS": 99086,
//"PARENT_PROCESS_INFO_CODE": 2963,
//"DAYS_COUNT": 0,
//"PROCESS_APPCODE": 0,
//"PROCESS_APPCODE_VAL": 0,
//"GENERAL_SETUP": 0,
//"MOBILE_FLAG": null

import Foundation
struct precrition: Decodable {
    let arabicName1: String?
     let englishName: String?
    let processinfocode: Int?
//    let id: Int?
//
//    let processinfocode: Int?
//    let procresssort: Int?

    enum CodingKeys: String, CodingKey {
//        case id = "ID"
        case arabicName1 = "NAME_AR"
        case englishName = "NAME_EN"
        
        case processinfocode = "PROCESS_INFO_CODE"
//
//        case procresssort  = "PROCESS_SORT"
//
    }
}
