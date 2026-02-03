//
//  OrderServiceListPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/15/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

typealias ServicesDetails = [ServiceDetails]
typealias ServicesDetailsBlock = ((ServicesDetails) -> Void)

protocol OrderServiceListPresenter {
  var user: User { get }
  var templateType: TemplateType { get }
  var patient: Patient { get }
  var services: [Service] { get }
  var categoryName: String { get }
  var categoryImage: UIImage { get }
  var categoryColor: UIColor { get }
  var servicesDetails: ServicesDetails? { get }
  var generalParams: GeneralParams { get }

  func validateServiceRow(withServicesIds servicesIds: [String], finished: @escaping EmptyBlock)
}

class OrderServiceListPresenterImpl: OrderServiceListPresenter {
  private var modelLayer: ModelLayer

  var user: User
  var templateType: TemplateType
  var patient: Patient
  let serviceCategory: ServiceCategory
  let generalParams: GeneralParams
  var servicesDetails: ServicesDetails?
  
  var services: [Service] { return serviceCategory.services ?? [] }
  var categoryName: String { return serviceCategory.name }
  var categoryImage: UIImage {
    guard let typeText = serviceCategory.type, let type = ServiceCategoryType(rawValue: typeText) else { return #imageLiteral(resourceName: "body_fluid") }
    return type.image
  }
  var categoryColor: UIColor {
    guard let typeText = serviceCategory.type, let type = ServiceCategoryType(rawValue: typeText) else { return #colorLiteral(red: 0.9490196078, green: 0.6235294118, blue: 0.01960784314, alpha: 1) }
    return type.color
  }

  init(modelLayer: ModelLayer, patient: Patient, serviceCategory: ServiceCategory, templateType: TemplateType, generalParams: GeneralParams, user: User) {
    self.modelLayer = modelLayer
    self.patient = patient
    self.serviceCategory = serviceCategory
    self.templateType = templateType
    self.generalParams = generalParams
    self.user = user
  }
}


extension OrderServiceListPresenterImpl {
  func validateServiceRow(withServicesIds servicesIds: [String], finished: @escaping EmptyBlock) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH.mm.ss"
    let dateString = dateFormatter.string(from: Date())
    
    var servicesDicts = [[String: Any]]()
    for serviceId in servicesIds {
      servicesDicts.append(
        ["DCAF_MARKER_FLAG":0,
         "DOC_ID":generalParams.requestDoctor,
         "REQ_DATE_STR_FORMATED":dateString,
         "SERVICE_ID":serviceId])
    }
    let params = [
      "RcpServices": getEncodedBodyParam(jsonObject: servicesDicts),
      "PatientID": patient.id.trimmingCharacters(in: .whitespacesAndNewlines),
      "GetServValidateParms": getEncodedBodyParam(jsonObject: ["PatFinanAccount":patient.financialAccount.trimmingCharacters(in: .whitespacesAndNewlines),"ActualBalance":-1,"FinanActualBalance":-1]),
      "GetSessionInfo": getEncodedBodyParam(jsonObject: ["UserID":user.userName,"BranchID":user.branch,"ComputerName":"iOS","LanguageID":2])
    ]

    modelLayer.validateServiceRow(with: params) { servicesDetails in
      self.servicesDetails = servicesDetails
      finished()
    }
  }
}

func getEncodedURLParam(jsonObject: Any) -> String {
  let jsonObjectData = try! JSONSerialization.data(withJSONObject: jsonObject)
  let jsonObjectString = String(data: jsonObjectData, encoding: .utf8)
  let jsonObjectEncodedString = jsonObjectString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
  return jsonObjectEncodedString!
}
