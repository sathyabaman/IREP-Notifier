//
//  Extensions.swift
//  IREP Notifier
//
//  Created by Chin Wee Kerk on 03/11/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit

extension Date {
  static func fromString(_ value: String, format: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.date(from: value)
  }
}

extension UIViewController {
  func alert(
    title: String,
    message: String?,
    completion: ((UIAlertAction) -> Void)?
  ) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alert.addAction(
      UIAlertAction(title: "Ok", style: .cancel, handler: completion)
    )
    self.present(alert, animated: true, completion: nil)
  }
  
  func enquiry(
    title: String,
    message: String?,
    accept: ((UIAlertAction) -> Void)?,
    reject: ((UIAlertAction) -> Void)?
  ) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alert.addAction(
      UIAlertAction(title: "Ok", style: .default, handler: accept)
    )
    alert.addAction(
      UIAlertAction(title: "Cancel", style: .cancel, handler: reject)
    )
    self.present(alert, animated: true, completion: nil)
  }
}
