//
//  Template.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/8/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
enum TemplateType: Int {
  case labOrder = 1
  case radOrder
}

struct Template {
    var serviceTemplates: [GeneralObejct]
    var servicesCategories: [ServiceCategory]
    var generalParams: GeneralParams
    var frequency: [GeneralObejct]
    var labIntervalUnits: [GeneralObejct]
    var verbalOrderTypes: [GeneralObejct]
    var readBack: [GeneralObejct]
}

struct GeneralObejct: Decodable {
  var id: String
  private let arabicName: String
  private let englishName: String
//  var template:String?
    
  var name: String {return englishName}
  
  enum CodingKeys: String, CodingKey {
    case id = "ID"
//    case template = "TEMPLATE_USER"
    case customId = "CUSTOM_ID"
    case arabicName = "NAME_AR"
    case englishName = "NAME_EN"
  }
}

extension GeneralObejct {
    init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       var id = try? container.decode(String.self, forKey: .id)
       if id == nil {
         id = try? container.decode(String.self, forKey: .customId)
       }
       let arabicName = try container.decode(String.self, forKey: .arabicName)
       let englishName = try container.decode(String.self, forKey: .englishName)
       // let template = try container.decode(String.self, forKey: .template)
        self.init(id: id ?? "", arabicName: arabicName, englishName: englishName)
    }
}



struct ServiceCategory: Decodable {
    var id: String
    var arabicName: String
    var englishName: String
    var type: String?
    var templateId:String?
    var typeArabicTitle: String?
    var typeEnglishTitle: String?
    var isSelect:Bool = false
    
    var services: [Service]?
    
    var typeTitle: String? {return typeEnglishTitle}
    var name: String {return englishName}

  enum CodingKeys: String, CodingKey {
    case id = "PARENT_SERV_ID"
    case arabicName = "PARENT_SERV_NAME_AR"
    case englishName = "PARENT_SERV_NAME_EN"
    case type = "LAB_CAT_TYPE"
    case templateId = "TEMPLATE_ID"
    case typeArabicTitle = "LAB_CAT_TYPE_NAME_AR"
    case typeEnglishTitle = "LAB_CAT_TYPE_NAME_EN"
    case services = "DETAIL_SERVICE"
    case servicesRow = "DETAIL_SERVICE_ROW"
  }
    
    mutating func setModel(_ dic:[String:AnyObject],services:[Service])-> ServiceCategory {
        self.id = dic["PARENT_SERV_ID"] as? String ?? ""
        self.arabicName = dic["PARENT_SERV_NAME_AR"] as? String ?? ""
        self.englishName = dic["PARENT_SERV_NAME_EN"] as? String ?? ""
        self.type = dic["LAB_CAT_TYPE"] as? String ?? ""
        self.templateId = dic["TEMPLATE_ID"] as? String ?? ""
        self.typeArabicTitle = dic["LAB_CAT_TYPE_NAME_AR"] as? String ?? ""
        self.typeEnglishTitle = dic["LAB_CAT_TYPE_NAME_EN"] as? String ?? ""
        self.services = services
        return self
    }
}

extension ServiceCategory {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(String.self, forKey: .id)
    let arabicName = try container.decode(String.self, forKey: .arabicName)
    let englishName = try container.decode(String.self, forKey: .englishName)
    let type = try? container.decode(String.self, forKey: .type)
    let typeArabicTitle = try? container.decode(String.self, forKey: .typeArabicTitle)
    let typeEnglishTitle = try? container.decode(String.self, forKey: .typeEnglishTitle)
      
    let servicesContainer = try! container.nestedContainer(keyedBy: CodingKeys.self, forKey: .services)
    var services: [Service] = []
    if let decodedServices = try? servicesContainer.decode([Service].self, forKey: .servicesRow) {
      services = decodedServices
    } else if let decodedService = try? servicesContainer.decode(Service.self, forKey: .servicesRow) {
      services = [decodedService]
    }

    self.init(id: id,
              arabicName: arabicName,
              englishName: englishName,
              type: type,
              typeArabicTitle: typeArabicTitle,
              typeEnglishTitle: typeEnglishTitle,
              services: services)
  }
}



struct Service: Decodable {
  var id: String
  var arabicName: String
  var englishName: String
  var radPosition: String?
  var serviceLevel:String?
  var notUrgent:String?
  var prepareArabicInstructions: String?
  var prepareEnglishInstructions: String?
  var childIds:String?
  var isSelected:Bool = false
    
  var name: String {return englishName}
  var prepareInstructions: String? {return prepareEnglishInstructions}

  enum CodingKeys: String, CodingKey {
    case id = "SERVICE_ID"
    case arabicName = "SERV_NAME_AR"
    case englishName = "SERV_NAME_EN"
    case radPosition = "RAD_POSITION"
    case serviceLevel = "SERV_SEC_LEV"
    case notUrgent = "NOT_URGENT"
    case prepareArabicInstructions = "PREPARE_NAME_AR"
    case prepareEnglishInstructions = "PREPARE_NAME_EN"
    case childIds = "CHILD_SERVICE_ID"
  }
    
  
}

struct ServiceDetails: Decodable {
  let id: String
  private let arabicName: String
  private let englishName: String
  var name: String {return englishName}
  let price: String
  
  var cashPayment = false
  var notes = ""
  var emergencyLevel = 0
  var amount = "1"
  
  enum CodingKeys: String, CodingKey {
    case id = "SERVICE_CODE"
    case arabicName = "SERV_NAME_AR"
    case englishName = "SERV_NAME_EN"
    case price = "NETPRICE"
  }
}

struct GeneralParams: Decodable {
  let requestDoctor: String
  private let doctorArabicName: String
  private let doctorEnglishName: String
  var doctorName: String {return doctorEnglishName}
  let cashCharge: String
  
  enum CodingKeys: String, CodingKey {
    case requestDoctor = "RequestDoctor"
    case doctorArabicName = "DoctorNameAR"
    case doctorEnglishName = "DoctorNameEN"
    case cashCharge = "CASH_CHARGE"
  }
}
