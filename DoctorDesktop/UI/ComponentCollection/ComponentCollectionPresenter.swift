//
//  ComponentCollectionPresenter.swift
//  Doctor DeskTop
//
//  Created by Mohammed Sami on 12/9/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

typealias EmptyBlock = (() -> Void)
var userNamePermission:String = ""
var UserBranchPermission:String = ""

protocol ComponentCollectionPresenter {
    var user: User { get }
    var components: Components { get }
    func getPatientsCount(finished: @escaping EmptyBlock)
    func getDoctorPermission(finished: @escaping EmptyBlock)
}

class ComponentCollectionPresenterImpl: ComponentCollectionPresenter {
    private var modelLayer: ModelLayer
    var user: User
    var components: Components
    var permissions: DoctorPermissions = []

  init(modelLayer: ModelLayer, components: Components, user: User) {
      self.modelLayer = modelLayer
      self.components = components
      self.user = user
      self.permissions = []
    print("com")
  }
}

extension ComponentCollectionPresenterImpl {
  
  func getPatientsCount(finished: @escaping EmptyBlock) {
    
    var processInfoCode: String = ""
    components.forEach ({ component in
      processInfoCode += "\(component.processInfoCode),"
    })
    processInfoCode.removeLast()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
      userNamePermission = user.userName ?? ""
      UserBranchPermission = user.branch ?? ""
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
      "GROUP_ID":user.group ?? "",
      "SER_ARRAY": processInfoCode,
      "COMPUTER_NAME": "iOS",
      "USER_OPEN_FLAG": "D",
      "SELECTED_DATE_STR_FORMATED": formatter.string(from: Date())
    ]
    
    modelLayer.getPatientsCount(with: params) { patientCounts in
      for component in self.components {
        
        print(component.processInfoCode)
        if let componentType = ComponentType(rawValue: component.processInfoCode) {
          switch(componentType) {
          case .inpatient:
            component.patientsCount = patientCounts.inpatientFloor
          case .ICU:
            component.patientsCount = patientCounts.inpatientCare
          case .outpatient:
            print("asfafadsfa")
            component.patientsCount = patientCounts.outpatient
            print(processInfoCode)
            print(component.patientsCount)
          case .emergency:
            component.patientsCount = patientCounts.emergency
          case .operations:
            component.patientsCount = patientCounts.operation
          case .clinicalAlert:
            component.patientsCount = patientCounts.clinicalAlert
          case .consultation:
            component.patientsCount = patientCounts.cosultationFromDoctor
          case .nicu:
              component.patientsCount = patientCounts.inpatientNICU
//          case .nurseTL:
//              component.patientsCount = patientCounts.inpatientNICU
          }
            component.type = componentType
        }
      }
      finished()
    }
    
  }

    func getDoctorPermission(finished: @escaping EmptyBlock) {
      let params = [
        "BRANCH_ID": user.branch ?? "",
        "USER_ID": user.userName ?? "",
        "PROCESS_ID":"289980",
        "OBJECT_ID": "6528",
        "PROCESS_INFO_CODE": "",
        "CAT_ID": "",
        "DEFAULTGROUP": "DR"
      ]
      modelLayer.getDoctorPermissions(with: params) { models in
          self.permissions = models
          finished()
      }
      
    }
}



