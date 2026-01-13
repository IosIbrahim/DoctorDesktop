//
//  OverviewCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/16/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

protocol OverviewSectionCellPresenter {
  var sectionImageName: String { get }
  var sectionTitle: String { get }
  var sectionColor: UIColor { get }
  var counter: Int { get }
}

class OverviewSectionCellPresenterImpl: OverviewSectionCellPresenter {
  let sectionImageName: String
  let sectionTitle: String
  let sectionColor: UIColor
  let counter: Int

  init(sectionImageName: String, sectionTitle: String, sectionColor: UIColor, counter: Int) {
    self.sectionImageName = sectionImageName
    self.sectionTitle = sectionTitle
    self.sectionColor = sectionColor
    self.counter = counter
  }
}
