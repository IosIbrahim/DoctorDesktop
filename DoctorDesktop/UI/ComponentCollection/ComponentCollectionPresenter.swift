//
//  ComponentCollectionPresenter.swift
//  Doctor DeskTop
//
//  Created by Mohammed Sami on 12/9/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation

typealias EmptyBlock = (() -> Void)

protocol ComponentCollectionPresenter {
  var user: User { get }
  var components: Components { get }
  func getPatientsCount(finished: @escaping EmptyBlock)
}

class ComponentCollectionPresenterImpl: ComponentCollectionPresenter {
  private var modelLayer: ModelLayer

  var user: User
  var components: Components

  init(modelLayer: ModelLayer, components: Components, user: User) {
    self.modelLayer = modelLayer
    self.components = components
    self.user = user
    
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
    
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "USER_ID": user.userName ?? "",
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
          }
          component.type = componentType
            
//            print(component.type)
        }
      }
      finished()
    }
    
  }
}



