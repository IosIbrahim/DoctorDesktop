//
//  ComponentCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/12/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol ComponentCellPresenter {
  var title: String { get }
  var subtitle: String { get }
  var count: String { get }
  var startColor: UIColor { get }
  var endColor: UIColor { get }
  var image: UIImage { get }
}

class ComponentCellPresenterImpl: ComponentCellPresenter {
  var component: Component
  var startColor: UIColor
  var endColor: UIColor
  var image: UIImage

  var title: String { return component.shortName ?? component.name }
  var count: String { return component.patientsCount }

  /// Short context line under the title (e.g. "Active cases on your wards").
  /// Derived from the component's known type — falls back to a generic
  /// "Patients today" for any future category we haven't labelled.
  var subtitle: String {
    switch ComponentType(rawValue: component.processInfoCode) {
    case .inpatient:    return "Active cases on your wards"
    case .outpatient:   return "Today's clinic patients"
    case .emergency:    return "Currently in ER"
    case .operations:   return "Scheduled procedures"
    case .consultation: return "Consultation requests"
    case .ICU:          return "ICU patients"
    case .nicu:         return "NICU patients"
    case .none:         return "Patients today"
    }
  }

  init(withComponent component: Component, colorAndImage: ColorAndImageTuple) {
    self.component = component
    self.startColor = colorAndImage.startColor
    self.endColor = colorAndImage.endColor
    self.image = colorAndImage.image
  }
}
