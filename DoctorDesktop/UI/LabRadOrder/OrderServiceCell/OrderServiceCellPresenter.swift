//
//  OrderServiceCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/15/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol OrderServiceCellPresenter {
  var serviceName: String { get }
  var servicePrepareInstructions: String? { get }
}

class OrderServiceCellPresenterImpl: OrderServiceCellPresenter {
  let service: Service
  var serviceName: String { return service.name }
  var servicePrepareInstructions: String? { return service.prepareInstructions }

  init(withService service: Service) {
    self.service = service
  }
}
