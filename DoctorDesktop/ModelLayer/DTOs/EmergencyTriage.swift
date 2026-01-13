//
//  EmergencyTriage.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/18/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

enum Vital: String {
  case temp = "TEMP"
  case pulse = "PULSE"
  case bloodPressure = "BP"
  case respiratoryRate = "RESPIRATORY_RATE"
  case o2Sat = "O2SAT"
  case bloodSugar = "BLOOD_GLUCOSE"
  case weight = "WEIGHT"
  case height = "HEIGHT"
  case sIndex = "SHOCK_INDEX"
  
  var color: UIColor {
    switch self {
    case .temp: return #colorLiteral(red: 0.3176470588, green: 0.2509803922, blue: 0.831372549, alpha: 1)
    case .pulse: return #colorLiteral(red: 0.05490196078, green: 0.6549019608, blue: 0.3411764706, alpha: 1)
    case .bloodPressure: return #colorLiteral(red: 0.8, green: 0.1411764706, blue: 0.08235294118, alpha: 1)
    case .respiratoryRate: return #colorLiteral(red: 0.7882352941, green: 0.0862745098, blue: 0.4274509804, alpha: 1)
    case .o2Sat: return #colorLiteral(red: 0.8745098039, green: 0.5294117647, blue: 0.0862745098, alpha: 1)
    case .bloodSugar: return #colorLiteral(red: 0.3529411765, green: 0.4235294118, blue: 0.4901960784, alpha: 1)
    case .weight: return #colorLiteral(red: 0, green: 0.6509803922, blue: 0.6431372549, alpha: 1)
    case .height: return #colorLiteral(red: 0.3529411765, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
    case .sIndex: return #colorLiteral(red: 0.5803921569, green: 0, blue: 0.8941176471, alpha: 1)
    }
  }
  
  var title: String {
    switch self {
    case .temp: return "Temp"
    case .pulse: return "Pulse"
    case .bloodPressure: return "B. Pressure"
    case .respiratoryRate: return "Resp. Rate"
    case .o2Sat: return "O2 Sat"
    case .bloodSugar: return "B. Sugar"
    case .weight: return "Weight"
    case .height: return "Height"
    case .sIndex: return "S.Index"
    }
  }
  
  var icon: UIImage {
    switch self {
    case .temp: return #imageLiteral(resourceName: "temperature")
    case .pulse: return #imageLiteral(resourceName: "pulse")
    case .bloodPressure: return #imageLiteral(resourceName: "blood_pressure")
    case .respiratoryRate: return #imageLiteral(resourceName: "respiratory_rate")
    case .o2Sat: return #imageLiteral(resourceName: "o2")
    case .bloodSugar: return #imageLiteral(resourceName: "blood")
    case .weight: return #imageLiteral(resourceName: "weight")
    case .height: return #imageLiteral(resourceName: "height")
    case .sIndex: return #imageLiteral(resourceName: "weight")
    }
  }
}

struct UCAFData: Decodable {
  var temp: String?
  var pulse: String?
  var bloodPressureLow: String?
  var bloodPressureHigh: String?
  var respiratoryRate: String?
  var o2Sat: String?
  var bloodSugar: String?
  var weight: String?
  var height: String?
  var sIndex: String?
  var scoreType: String?
  var ser: String
  
  enum CodingKeys: String, CodingKey {
    case ser = "SER"
    case temp = "TEMP"
    case pulse = "PULSE"
    case bloodPressureLow = "PB_2"
    case bloodPressureHigh = "BP"
    case respiratoryRate = "RESPIRATORY_RATE"
    case o2Sat = "O2SAT"
    case bloodSugar = "BLOOD_GLUCOSE"
    case weight = "WEIGHT"
    case height = "HEIGHT"
    case sIndex = "SHOCK_INDEX"
    case scoreType = "SCORE_TYPE"
  }
}

struct Symptom: Decodable, Equatable {
  static func ==(lhs: Symptom, rhs: Symptom) -> Bool {
    return lhs.id == rhs.id
  }
  
  var id: String
  var arabicName: String
  var englishName: String?
  var bodyCaseType: String?
  var ser: String?
  var transDate: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case arabicName = "NAME_AR"
    case englishName = "NAME_EN"
    case bodyCaseType = "BODY_CASE_TYPE"
    case ser = "SER"
    case transDate = "TRANS_DATE"
  }
}

struct DiagnosisCategory: Decodable {
  var id: String
  var arabicName: String
  var englishName: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case arabicName = "NAME_AR"
    case englishName = "NAME_EN"
  }
}

protocol SymptomCategory {
  var id: String { get set }
  var arabicName: String { get set }
  var englishName: String? { get set }
}

struct RegularSymptomCategory: SymptomCategory, Decodable {
  var id: String
  var arabicName: String
  var englishName: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case arabicName = "NAME_AR"
    case englishName = "NAME_EN"
  }
}

struct HistorySymptomCategory: SymptomCategory, Decodable {
  var id: String
  var arabicName: String
  var englishName: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "COT_LV_2_ID"
    case arabicName = "COT_LV_2_NAME_AR"
    case englishName = "COT_LV_2_NAME_EN"
  }
}

struct Score: Decodable {
  var details: ScoreDetails
  
  struct ScoreDetails: Decodable {
    var id: String
    var arabicDescription: String?
    var englishDescription: String?
    var value: String?
    var firstLevelScore: FirstLevelScore?
    
    struct FirstLevelScore: Decodable {
      var pediatricsScoreCategories: [PediatricsScoreCategory]
      
      enum CodingKeys: String, CodingKey {
        case pediatricsScoreCategories = "LEVEL_1_ROW"
      }
    }
    
    enum CodingKeys: String, CodingKey {
      case id = "ITEM_ID"
      case arabicDescription = "ITEM_DESC_AR"
      case englishDescription = "ITEM_DESC"
      case value = "ITEM_VALUE"
      case firstLevelScore = "LEVEL_1"
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.id = try container.decode(String.self, forKey: .id)
      self.arabicDescription = try? container.decode(String.self, forKey: .arabicDescription)
      self.englishDescription = try? container.decode(String.self, forKey: .englishDescription)
      self.value = try? container.decode(String.self, forKey: .value)
      self.firstLevelScore = try? container.decode(FirstLevelScore.self, forKey: .firstLevelScore)
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case details = "SCORE_DETAILS_ROW"
  }
}

protocol PediatricsScoreElement {
  var id: String { get set }
  var englishDescription: String? { get set }
  var arabicDescription: String? { get set }
  var value: String? { get set }
  var disabled: String? { get set }
  var SER: String? { get set }
  var score: String? { get set }
  var viewType: String? { get set }
}

struct PediatricsScoreCategory: PediatricsScoreElement, Decodable {
  var id: String
  var englishDescription: String?
  var arabicDescription: String?
  var value: String?
  var disabled: String?
  var SER: String?
  var score: String?
  var viewType: String?
  var secondLevelScore: SecondLevelScore?
  
  enum CodingKeys: String, CodingKey {
    case id = "ITEM_ID"
    case englishDescription = "ITEM_DESC"
    case arabicDescription = "ITEM_DESC_AR"
    case value = "ITEM_VALUE"
    case disabled = "DISABLED_FLAG"
    case SER = "SER"
    case score = "ITEM_SCORE"
    case viewType = "VIEW_TYPE"
    case secondLevelScore = "LEVEL_2"
  }

  struct SecondLevelScore: Decodable {
    var secondLevelElements: [PediatricsScoreChoice]
    
    enum CodingKeys: String, CodingKey {
      case secondLevelElements = "LEVEL_2_ROW"
    }
  }
}

struct PediatricsScoreChoice: PediatricsScoreElement, Decodable {
  var id: String
  var englishDescription: String?
  var arabicDescription: String?
  var value: String?
  var disabled: String?
  var SER: String?
  var score: String?
  var viewType: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "ITEM_ID"
    case englishDescription = "ITEM_DESC"
    case arabicDescription = "ITEM_DESC_AR"
    case value = "ITEM_VALUE"
    case disabled = "DISABLED_FLAG"
    case SER = "SER"
    case score = "ITEM_SCORE"
    case viewType = "VIEW_TYPE"
  }
}
