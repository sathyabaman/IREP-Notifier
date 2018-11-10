//
//  NotificationGroup.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 9/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxDataSources
import SwiftyJSON

struct NotificationGroup {
  private(set) var accountTypeId: Int
  private(set) var title: String
  var notifications: [Notification]
}

extension NotificationGroup: SectionModelType {
  typealias Item = Notification
  
  var items: [Notification] {
    return self.notifications
  }
  
  init(original: NotificationGroup, items: [Notification]) {
    self = original
    self.notifications = items
  }
}
