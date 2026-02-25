//
//  OutpatientCellPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/18/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

protocol OutpatientCellPresenter {
    var genderAgeImage: UIImage? { get }
    var patientName: String { get }
    var queue :String { get }
    var doctorName: String { get }
    var time: String { get }
    var clinicTitle: String { get }
    var age: String { get }
    var status:String { get }
    var statusColor:String { get }
    var gender:String { get }
    var patMobile:String { get }
    var shift:String { get }
    var servStatus:String { set get }

}

class OutpatientCellPresenterImpl: OutpatientCellPresenter {
    var outpatientPatient: OutpatientPatient
    var servStatus:String
    
    var genderAgeImage: UIImage? {
      guard let genderAgeType = GenderAgeType(rawValue: outpatientPatient.genderAge) else {
        return nil
      }
      return getGenderAgeImage(genderAgeType: genderAgeType)
    }
    
      var patientName: String { return outpatientPatient.name }
      var queue: String { return outpatientPatient.queSysSer ?? "" }
      var doctorName: String { return outpatientPatient.empNameEn ?? "" }
      var time: String { return outpatientPatient.serviceTime ?? ""  }
      var clinicTitle: String { return outpatientPatient.clinicNameEN ?? "" }
      var age: String { return outpatientPatient.age }
      var status: String { return outpatientPatient.serVStatusNameEn ?? "" }
      var statusColor: String { return outpatientPatient.serColor ?? "" }
      var gender: String { return outpatientPatient.genderAgeNameEn ?? "" }
      var patMobile:String { return outpatientPatient.patMobile ?? "" }
      var shift:String { return outpatientPatient.shiftID ?? "" }

    init(with outpatientPatient: OutpatientPatient) {
      self.outpatientPatient = outpatientPatient
        self.servStatus = outpatientPatient.serVStatus ?? ""
    }

}
