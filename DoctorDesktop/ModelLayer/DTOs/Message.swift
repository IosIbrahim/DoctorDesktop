//
//  Message.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/25/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

struct Message: Decodable {
  let code: Int
  var message: String?
}
