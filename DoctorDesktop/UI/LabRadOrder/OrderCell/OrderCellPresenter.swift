//
//  OrderCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/11/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

enum ServiceCategoryType: String {
  case bodyFluid = "1"
  case chemistry = "2"
  case coagulation = "3"
  case drugAbuse = "4"
  case hematology = "5"
  case hormones = "6"
  case microbiology = "7"
  case semens = "8"
  case vitamins = "9"
  
  var image: UIImage {
    switch self {
    case .bodyFluid: return #imageLiteral(resourceName: "body_fluid")
    case .chemistry: return #imageLiteral(resourceName: "chemistry")
    case .coagulation: return #imageLiteral(resourceName: "coagulation")
    case .drugAbuse: return #imageLiteral(resourceName: "drug_abuse")
    case .hematology: return #imageLiteral(resourceName: "hematology")
    case .hormones: return #imageLiteral(resourceName: "hormones")
    case .microbiology: return #imageLiteral(resourceName: "microbiology")
    case .semens: return #imageLiteral(resourceName: "semens")
    case .vitamins: return #imageLiteral(resourceName: "vitamins")
    }
  }
  
  var color: UIColor {
    switch self {
    case .bodyFluid: return #colorLiteral(red: 0.7921568627, green: 0.8431372549, blue: 0.8823529412, alpha: 1)
    case .chemistry: return #colorLiteral(red: 0.9490196078, green: 0.6235294118, blue: 0.01960784314, alpha: 1)
    case .coagulation: return #colorLiteral(red: 0.7490196078, green: 0.2117647059, blue: 0.2549019608, alpha: 1)
    case .drugAbuse: return #colorLiteral(red: 0.9764705882, green: 0.3921568627, blue: 0.368627451, alpha: 1)
    case .hematology: return #colorLiteral(red: 0.9098039216, green: 0.4901960784, blue: 0.4901960784, alpha: 1)
    case .hormones: return #colorLiteral(red: 0.5882352941, green: 0.7058823529, blue: 0.1607843137, alpha: 1)
    case .microbiology: return #colorLiteral(red: 0.9490196078, green: 0.3607843137, blue: 0.01960784314, alpha: 1)
    case .semens: return #colorLiteral(red: 0.05490196078, green: 0.2392156863, blue: 0.3490196078, alpha: 1)
    case .vitamins: return #colorLiteral(red: 0.6509803922, green: 0.2549019608, blue: 0.1568627451, alpha: 1)
    }
  }
}



protocol OrderCellPresenter {
  var title: String { get }
  var image: UIImage { get }
}

class OrderCellPresenterImpl: OrderCellPresenter {
  var serviceCategory: ServiceCategory
  
  init(withSericeCategory serviceCategory: ServiceCategory) {
    self.serviceCategory = serviceCategory
  }
  
  var title: String { return serviceCategory.name }
  var image: UIImage {
    guard let typeText = serviceCategory.type, let type = ServiceCategoryType(rawValue: typeText) else { return #imageLiteral(resourceName: "body_fluid") }
    return type.image
  }
}
