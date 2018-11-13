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
  private(set) var items: [Notification]
}

extension NotificationGroup: SectionModelType {
  typealias Item = Notification
  
  init(original: NotificationGroup, items: [Notification]) {
    self = original
    self.items = items
  }
  
  func filterNotifications(by keyword: String) -> [Notification] {
    return self.items.filter { return $0.isCategorized(by: keyword) }
  }
  
  func filterNotificationsBy(readStatus: Bool) -> [Notification] {
    return self.items.filter { return $0.isRead }
  }
  
  func isCategorized(by keyword: String) -> Bool {
    let candidates = self.filterNotifications(by: keyword)
    return self.title.contains(keyword) || candidates.count > 0
  }
}
