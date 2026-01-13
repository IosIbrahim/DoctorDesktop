//
//  PatientHistoryFiltrationCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 2/17/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

enum PatientHistoryFiltrationType {
  case currentVisit (String)
  case allVisits (String)
  case currentSpeciality (String)
  case currentDoctor (String)

  var activeIconImage: UIImage {
    switch self {
    case .currentVisit: return #imageLiteral(resourceName: "visit_icon")
    case .allVisits: return #imageLiteral(resourceName: "allvisit")
    case .currentSpeciality: return #imageLiteral(resourceName: "lab")
    case .currentDoctor: return #imageLiteral(resourceName: "dr_icon")
    }
  }

  var inactiveIconImage: UIImage {
    switch self {
    case .currentVisit: return #imageLiteral(resourceName: "visit_icon_no_activ")
    case .allVisits: return #imageLiteral(resourceName: "allvisit_not_active")
    case .currentSpeciality: return #imageLiteral(resourceName: "lab_not_active")
    case .currentDoctor: return #imageLiteral(resourceName: "dr_icon_not_active")
    }
  }

  var activeContentImage: UIImage {
    switch self {
    case .currentVisit, .allVisits: return #imageLiteral(resourceName: "visit_content")
    case .currentSpeciality: return #imageLiteral(resourceName: "lab_content_actvie")
    case .currentDoctor: return #imageLiteral(resourceName: "dr_content_active")
    }
  }
}

extension PatientHistoryFiltrationType: RawRepresentable {
  typealias RawValue = Int

  var rawValue: Int {
    switch self {
    case .currentVisit: return 0
    case .allVisits: return 1
    case .currentSpeciality: return 2
    case .currentDoctor: return 3
    }
  }

  public init?(rawValue: RawValue) {
    switch rawValue {
    case 0: self = .currentVisit("")
    case 1: self = .allVisits("")
    case 2: self = .currentSpeciality("")
    case 3: self = .currentDoctor("")
    default:
      return nil
    }
  }
}

protocol PatientHistoryFiltrationCellPresenter {
  var patientHistoryFiltrationType: PatientHistoryFiltrationType { get }
}

class PatientHistoryFiltrationCellPresenterImpl: PatientHistoryFiltrationCellPresenter {
  let patientHistoryFiltrationType: PatientHistoryFiltrationType
  init(patientHistoryFiltrationType: PatientHistoryFiltrationType) {
    self.patientHistoryFiltrationType = patientHistoryFiltrationType
  }
}
