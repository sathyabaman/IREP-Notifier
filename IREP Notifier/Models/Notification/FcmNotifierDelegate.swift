//
//  FcmNotifierDelegate.swift
//  IREP Notifier
//
//  Created by Aaron Lee on 19/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation

protocol FcmNotifierDelegate: class {
  func receivedFcmToken()
}
