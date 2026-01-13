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

  var title: String { return component.shortName ?? component.name}
  var count: String { return component.patientsCount}

  init(withComponent component: Component, colorAndImage: ColorAndImageTuple) {
    self.component = component
    self.startColor = colorAndImage.startColor
    self.endColor = colorAndImage.endColor
    self.image = colorAndImage.image
  }

}
