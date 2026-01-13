//
//  seachModel.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/23/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct searchModel: Codable {
    let items: Items
    
    enum CodingKeys: String, CodingKey {
        case items = "ITEMS"
    }
}

// MARK: - Items
struct Items: Codable {
    let itemsRow: [ItemsRow]
    
    enum CodingKeys: String, CodingKey {
        case itemsRow = "ITEMS_ROW"
    }
}

// MARK: - ItemsRow
struct ItemsRow: Codable {
    let id: String
    let supplierBarcode: String?
    let nameAr, nameEn: String?
    let itemNeedMessage, otherFilter: String?
    let pagesCount:String
    let shortListFlag, posIndex, recNo: String?
    let hasBalance: String?
//    var isSelected:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case supplierBarcode = "SUPPLIER_BARCODE"
        case nameAr = "NAME_AR"
        case nameEn = "NAME_EN"
        case itemNeedMessage = "ITEM_NEED_MESSAGE"
        case otherFilter = "OTHER_FILTER"
        case shortListFlag = "SHORT_LIST_FLAG"
        case posIndex = "POS_INDEX"
        case recNo = "REC_NO"
        case pagesCount = "PAGES_COUNT"
        case hasBalance = "HAS_BALANCE"
    }
}

// MARK: - Encode/decode helpers


