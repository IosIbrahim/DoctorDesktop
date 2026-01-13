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
  let serviceTemplates: [GeneralObejct]
  let servicesCategories: [ServiceCategory]
  let generalParams: GeneralParams
  let frequency: [GeneralObejct]
  let labIntervalUnits: [GeneralObejct]
  let verbalOrderTypes: [GeneralObejct]
  let readBack: [GeneralObejct]
}

struct GeneralObejct: Decodable {
  var id: String
  private let arabicName: String
  private let englishName: String
  
  var name: String {return englishName}
  
  enum CodingKeys: String, CodingKey {
    case id = "ID"
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
    self.init(id: id ?? "", arabicName: arabicName, englishName: englishName)
  }
}

struct ServiceCategory: Decodable {
  let id: String
  private let arabicName: String
  private let englishName: String
  var name: String {return englishName}
  let type: String?
  private let typeArabicTitle: String?
  private let typeEnglishTitle: String?
  var typeTitle: String? {return typeEnglishTitle}
  
  let services: [Service]
  
  enum CodingKeys: String, CodingKey {
    case id = "PARENT_SERV_ID"
    case arabicName = "PARENT_SERV_NAME_AR"
    case englishName = "PARENT_SERV_NAME_EN"
    case type = "LAB_CAT_TYPE"
    case typeArabicTitle = "LAB_CAT_TYPE_NAME_AR"
    case typeEnglishTitle = "LAB_CAT_TYPE_NAME_EN"
    case services = "DETAIL_SERVICE"
    case servicesRow = "DETAIL_SERVICE_ROW"
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
  let id: String
  private let arabicName: String
  private let englishName: String
  var name: String {return englishName}
  private let prepareArabicInstructions: String?
  private let prepareEnglishInstructions: String?
  var prepareInstructions: String? {return prepareEnglishInstructions}
  let priced: String
  var details: ServiceDetails? = nil
  
  enum CodingKeys: String, CodingKey {
    case id = "SERVICE_ID"
    case arabicName = "SERV_NAME_AR"
    case englishName = "SERV_NAME_EN"
    case prepareArabicInstructions = "PREPARE_NAME_AR"
    case prepareEnglishInstructions = "PREPARE_NAME_EN"
    case priced = "SERVICE_PRICED"
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
