//
//  OverviewSectionDetailsPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/21/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
typealias URLBlock = ((URL?) -> Void)

protocol OverviewSectionDetailsPresenter {
  var patientSummary: PatientSummary { get }
  var overviewSection: OverviewSection { get }
  var user: User { get }
  func getPacksURL(selectedRadRowIndex: Int, finished: @escaping URLBlock)
}

class OverviewSectionDetailsPresenterImpl: OverviewSectionDetailsPresenter {
  private var modelLayer: ModelLayer
  let overviewSection: OverviewSection
  let patientSummary: PatientSummary
  let user: User
  var urlToPreview: URL?

  init(modelLayer: ModelLayer, overviewSection: OverviewSection, patientSummary: PatientSummary, user: User) {
    self.modelLayer = modelLayer
    self.overviewSection = overviewSection
    self.patientSummary = patientSummary
    self.user = user
  }

  func getPacksURL(selectedRadRowIndex: Int, finished: @escaping URLBlock) {
    guard let accessionNumber = patientSummary.rads?[selectedRadRowIndex].accessNumber else {
      finished(nil)
      return
    }
    let params = [
      "BRANCH_ID": user.branch ?? "",
      "Accession_no": accessionNumber
    ]
    modelLayer.getPacksURL(with: params) { url in
      self.urlToPreview = url
      finished(url)
    }
  }
}
