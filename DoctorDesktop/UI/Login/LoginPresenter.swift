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
            
            self?.components = components.filter({ component in
              if let mobileFlag = component.mobileFlag {
                  return mobileFlag == 1
              } else {
                return false
              }
            })
            var not:Component?
            for item in components {
                if not == nil {
                    not = item
                    not?.updateName("Notifications")
                    not?.patientsCount = ""
                    not?.id = 0
                    not?.processInfoCode = 0
                }
                if item.name == "Search" {
                    if let new = not {
                        self?.components .append(new)
                    }
                    self?.components.append(item)
                }
            }
        }else {
            self?.error = "Unknwon Error has occured please try again!"
        }
    
      finished()
    }
  }
}
