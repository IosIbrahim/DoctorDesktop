//
//  Utility.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 1/30/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation
import UIKit

func getNumberOfDaysUntilTodayStartingFromDate(_ date: Date?) -> Int? {
  guard let date = date else { return nil }
  let components = Calendar.current.dateComponents([.day], from: date, to: Date())
  return components.day ?? 0
}

func enumCount<T: Hashable>(_: T.Type) -> Int {
  var i = 1
  while (withUnsafePointer(to: &i, {
    return $0.withMemoryRebound(to: T.self, capacity: 1, { return $0.pointee })
  }).hashValue != 0) {
    i += 1
  }
  return i
}

extension Collection {
  /// Returns the element at the specified index iff it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

extension Array where Element: Decodable {
  public static func decode(_ data: Data, keyPath: String, jsonDecoder: JSONDecoder = JSONDecoder()) throws -> [Element] {
    var decodedElements: [Element] = []
    guard let lastKeyPathComponent = keyPath.split(separator: ".").last,
      let json = String(data: data, encoding: .utf8),
      json.contains(lastKeyPathComponent) else { return decodedElements }
    if let dataObject = try? Element(data: data, keyPath: keyPath) {
      decodedElements = [dataObject]
    }
    else {
        let dataArray = try? [Element](data: data, keyPath: keyPath)
        let dataObject = try? Element(data: data, keyPath: keyPath)
      var finallArray = [Element]()
        if dataArray != nil
        {
            finallArray.append(contentsOf: dataArray!)
        }
        if dataObject != nil
        {
            finallArray.append(dataObject!)
        }
        
      decodedElements = finallArray
    }
    return decodedElements
  }
}

extension UISegmentedControl {
  func replaceSegments(segments: Array<String>) {
    self.removeAllSegments()
    for segment in segments {
      self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
    }
  }
}
