//
//  Extensions.swift
//  IREP Notifier
//
//  Created by Chin Wee Kerk on 03/11/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation

extension Date {
  static func fromString(_ value: String, format: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.date(from: value)
  }
}
