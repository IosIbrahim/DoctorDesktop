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
    var permissions: DoctorPermissions { get }
    var error: String { get }
    func getPatientsCount(finished: @escaping EmptyBlock)
    func getDoctorPermission(finished: @escaping EmptyBlock)
}

class ComponentCollectionPresenterImpl: ComponentCollectionPresenter {
    private var modelLayer: ModelLayer
    var user: User
    var components: Components
    var error:String = ""
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
      "oauth_consumer_key":"khaber_1",
      "oauth_nonce":"815851173",
      "oauth_signature_method":"HMAC-SHA1",
      "oauth_timestamp":"1773061126",
      "oauth_version":"1.0",
      "USER_OPEN_FLAG": "D",
      "oauth_signature":"cuAJZj8Jn6Sy6A9aDuUOqaXZ0ZE",
      "SELECTED_DATE_STR_FORMATED": formatter.string(from: Date())
    ]
    
//      BRANCH_ID=1&COMPUTER_NAME=pc&GROUP_ID=DR&oauth_consumer_key=&oauth_nonce=815851173&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1773061126&oauth_version=1.0&SELECTED_DATE_STR_FORMATED=09%2F03%2F2026+14%3A58%3A46&USER_ID=KHABEER&USER_OPEN_FLAG=D&oauth_signature=cuAJZj8Jn6Sy6A9aDuUOqaXZ0ZE=
      
    modelLayer.getPatientsCount(with: params) { patientCounts in
        self.permissions = patientCounts.permissions ?? []
        if let err = patientCounts.error {
            self.error = err
        }else {
            for component in self.components {
              
              print(component.processInfoCode)
                if component.type == .notifications {
                    component.patientsCount = "2762"
                    component.updateName("Notifications")

                }else if let componentType = ComponentType(rawValue: component.processInfoCode) {
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
                case .search:
                    component.patientsCount = ""
                default: break
                }
                  component.type = componentType
              }
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



