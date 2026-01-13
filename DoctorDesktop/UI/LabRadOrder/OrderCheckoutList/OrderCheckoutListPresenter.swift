//
//  OrderCheckoutListPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/19/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
typealias LabRadService = GeneralObejct
typealias LabRadServices = [LabRadService]
typealias LabRadServicesBlock = (LabRadServices) -> Void
typealias MessageBlock = ((Message) -> Void)

protocol OrderCheckoutListPresenter {
  var templateType: TemplateType { get }
  var servicesDetails: ServicesDetails { get set }
  var labRadServices: LabRadServices { get }
  func getServices(finished: @escaping EmptyBlock)
  func validateServiceRow(withNewServiceId serviceId: String, finished: @escaping EmptyBlock)
  func saveOrder (finished: @escaping MessageBlock)
}

class OrderCheckoutListPresenterImpl: OrderCheckoutListPresenter {
  private var modelLayer: ModelLayer

  var templateType: TemplateType
  var labOrderServiceListPresenter: OrderServiceListPresenter!
  var servicesDetails: ServicesDetails
  var user: User
  let patient: Patient
  let requestDoctor: String
  var labRadServices = LabRadServices()
  init(modelLayer: ModelLayer, servicesDetails: ServicesDetails, templateType: TemplateType, user: User, labOrderServiceListPresenter: OrderServiceListPresenter?, patient: Patient, requestDoctor: String) {
    self.modelLayer = modelLayer
    self.servicesDetails = servicesDetails
    self.templateType = templateType
    self.user = user
    self.labOrderServiceListPresenter = labOrderServiceListPresenter
    self.patient = patient
    self.requestDoctor = requestDoctor
  }
  
  func getServices(finished: @escaping EmptyBlock) {
    switch templateType {
    case .labOrder: getLabServices(finished: finished)
    case .radOrder: getRadServices(finished: finished)
    }
  }
  
  func getLabServices(finished: @escaping EmptyBlock) {
    let params = [
      "USER_ID": user.userName ?? "",
      "BRANCH_ID": user.branch ?? ""
    ]
    modelLayer.getLabServices(with: params) { labServices in
      self.labRadServices = labServices
      finished()
    }
  }
  
  func getRadServices(finished: @escaping EmptyBlock) {
    let params = [
      "RadType": "1",
      "ParentServ": "0",
      "GetSessionInfo": getEncodedURLParam(jsonObject: ["UserID":user.userName,"BranchID":user.branch,"ComputerName":"iOS","LanguageID":2])
    ]
    modelLayer.getLabServices(with: params) { radServices in
      self.labRadServices = radServices
      finished()
    }
  }
  
  func validateServiceRow(withNewServiceId serviceId: String, finished: @escaping EmptyBlock) {
    var servicesIds = self.servicesDetails.map() { serviceDetails in serviceDetails.id }
    servicesIds.append(serviceId)
    self.labOrderServiceListPresenter.validateServiceRow(withServicesIds: servicesIds) {
      self.servicesDetails = self.labOrderServiceListPresenter.servicesDetails ?? []
      finished()
    }
  }
  
  func saveOrder(finished: @escaping MessageBlock) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH.mm.ss"
    let now = dateFormatter.string(from: Date())
    var labRequest = [[String:Any]]()
    for service in servicesDetails {
      labRequest.append(["PATIENTID":patient.id,
                         "VISIT_ID":patient.visitId,
                         "PLACE_ID1":patient.placeId,
                         "REQ_DOCTOR":requestDoctor,
                         "SERVICE_ID":service.id,
                         "REQ_DATE_STR_FORMATED": now,
                         "CASH_CHARGE":service.cashPayment == true ? 1:0,
                         "REMARKS":service.notes,
                         "EMERGENCY":"\(service.emergencyLevel)",
                         "UNITSAMOUNT":service.amount,
                         
                         "ADM_METHOD_SRV":0,
                         "DOCTOR_SCREEN":1,
                         "FREQ": 0])
    }
    let params = [
      "processId": "120",
      "session": getEncodedBodyParam(jsonObject: ["UserID":user.userName,"BranchID":user.branch,"ComputerName":"iOS","LanguageID":2]),
      "labRequest": getEncodedBodyParam(jsonObject: labRequest),
    ]
    modelLayer.saveOrder(with: params, orderType: templateType) { message in
      finished(message)
    }
  }
}

func getEncodedBodyParam(jsonObject: Any) -> String {
  let jsonObjectData = try! JSONSerialization.data(withJSONObject: jsonObject)
  let jsonObjectString = String(data: jsonObjectData, encoding: .utf8)
  return jsonObjectString!
}
