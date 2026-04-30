//
//  LoginPresenter.swift
//  Doctor DeskTop
//
//  Created by Mohammed Sami on 12/9/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import Alamofire
import Toastlity
typealias Components = [Component]
typealias ComponentsBlock = ((Components) -> Void)
typealias UserAndComponentsBlock = ((User, Components) -> Void)

protocol LoginPresenter {
    var components: Components { get }
    var user: User! { get }
    var error: String { get }
    func login(with params: [String: String], finished: @escaping EmptyBlock)
}

class LoginPresenterImpl: LoginPresenter {
  fileprivate var modelLayer: ModelLayer
  var components = Components()
  var user: User!
  var error = ""
  init(modelLayer: ModelLayer) {
    self.modelLayer = modelLayer
  }
}

//FIXME: Refactor to Network Layer
extension LoginPresenterImpl {
  func login(with params: [String: String], finished: @escaping EmptyBlock) {
    modelLayer.login(with: params) { [weak self] user, components in
        if user.branch != nil {
            self?.user = user
            self?.components = components
            
            // Filter by whether the component maps to a known ComponentType
            // rather than the server's MOBILE_FLAG value. The test server
            // (MobileApitest) returns MOBILE_FLAG=0 for the same modules
            // that the live server returns MOBILE_FLAG=1 — relying on the
            // flag means tiles disappear when switching environments.
            self?.components = components.filter { component in
                ComponentType(rawValue: component.processInfoCode) != nil
            }
//            var not:Component?
//            var search:Component?
//
//            var searchFound:Bool = false
//            for item in components {
//                if not == nil {
//                    not = item
//                    not?.updateName("Notifications")
//                    not?.patientsCount = ""
//                    not?.id = 0
//                    not?.processInfoCode = 1
//                }else if !searchFound && search == nil {
//                    search = item
//                    search?.updateName("Search")
//                    search?.patientsCount = ""
//                    search?.id = 0
//                    search?.processInfoCode = 72
//                }
//                
//                if item.name == "Search" {
//                    searchFound = true
//                    if let new = not {
//                        self?.components.append(new)
//                    }
//                    self?.components.append(item)
//                }
//                
//            }
//            if !searchFound {
//                if let first = not {
//                    self?.components.append(first)
//                }
//                if let last = search {
//                    self?.components.append(last)
//                }
//            }
        }else {
            self?.error = "Unknwon Error has occured please try again!"
        }
    
      finished()
    }
  }
}
