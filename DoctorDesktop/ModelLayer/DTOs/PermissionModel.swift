//
//  PermissionModel.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 08/03/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import Foundation

struct PermissionModel:Decodable {
    var id:UInt64?
    var processInfoCode:UInt64?
    var arabicName:String?
    var englishName:String?
    var proscessSort:Int?
    var processMandatory:Int?
    var processEnable:Int?
    var objectId:UInt64?
    var category:String?
    var parentProcess:UInt64?
    var parentProcessInfo:UInt64?
    var days:Int?
    var processAppCode:Int?
    var general:Int?
    var mobileFlag:Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case processInfoCode = "PROCESS_INFO_CODE"
        case arabicName = "NAME_AR"
        case englishName = "NAME_EN"
        case proscessSort = "PROCESS_SORT"
        case processMandatory = "PROCESS_MANDATORY"
        case processEnable = "PROCESS_ENABLED"
        case objectId = "OBJECT_ID"
        case category = "PROCESS_CATEGORY"
        case parentProcess = "PARENT_PROCESS"
        case parentProcessInfo = "PARENT_PROCESS_INFO_CODE"
        case days = "DAYS_COUNT"
        case processAppCode = "PROCESS_APPCODE"
        case general = "GENERAL_SETUP"
        case mobileFlag = "MOBILE_FLAG"
    }
}

