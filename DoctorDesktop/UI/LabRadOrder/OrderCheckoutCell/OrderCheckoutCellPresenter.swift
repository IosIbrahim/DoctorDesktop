//
//  OrderCheckoutCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol OrderCheckoutCellPresenter {
  var serviceName: String { get }
  var servicePrice: String { get }
}

class OrderCheckoutCellPresenterImpl: OrderCheckoutCellPresenter {
  let serviceDetails: ServiceDetails
  var serviceName: String { return serviceDetails.name }
  var servicePrice: String { return serviceDetails.price }

  init(withServiceDetails serviceDetails: ServiceDetails) {
    self.serviceDetails = serviceDetails
  }
}
