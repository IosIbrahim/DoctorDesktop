//
//  OrderCollectionPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/6/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

typealias TemplateBlock = ((Template?) -> Void)

protocol OrderCollectionPresenter {
  var user: User { get }
  var templateType: TemplateType { get }
  var template: Template? { set get }
  var patient: Patient { get }
  func getTemplate(withTemplateId tempId: String?, finished: @escaping EmptyBlock)
}

extension OrderCollectionPresenter {
  func getTemplate(withTemplateId tempId: String? = nil, finished: @escaping EmptyBlock) {
    getTemplate(withTemplateId: tempId, finished: finished)
  }
}

class OrderCollectionPresenterImpl: OrderCollectionPresenter {
  private var modelLayer: ModelLayer!
  var user: User
  var patient: Patient
  var templateType: TemplateType
  var template: Template?
  
  init(modelLayer: ModelLayer, patient: Patient, templateType: TemplateType, user: User) {
    self.modelLayer = modelLayer
    self.patient = patient
    self.templateType = templateType
    self.user = user
  }
  
  func getTemplate(withTemplateId tempId: String?, finished: @escaping EmptyBlock) {
    var params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "TEMPLATE_TYPE": "\(templateType.rawValue)"
    ]
    if let templateId = tempId {
      params["TEMPLATE_ID"] = "\(templateId)"
    }
    modelLayer.getTemplate(with: params) { template in
      self.template = template
      finished()
    }
  }

}
