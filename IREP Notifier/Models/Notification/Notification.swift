//
//  Notification.swift
//  IREP Notifier
//
//  Created by Chin Wee Kerk on 03/11/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import SwiftyJSON

struct Notification {
  let createdDate: Date
  let id: String
  let isRead: Bool
  let text: String
  let title: String
  
  init(id: String, title: String, text: String, createdAt: Date, isRead: Bool) {
    self.createdDate = createdAt
    self.id = id
    self.isRead = isRead
    self.text = text
    self.title = title
  }
  
  init(info: JSON) {
    let date = Date.fromString(
      info["CreatedDate"].stringValue,
      format: "dd MMM yyyy"
    )!
    let id = info["ID"].stringValue
    let isRead = info["IsRead"].boolValue
    let title = info["FcmMessage"].stringValue
    let text = info["FullMessage"].stringValue
    self.init(id: id, title: title, text: text, createdAt: date, isRead: isRead)
  }
  
  func isCategorized(by keyword: String) -> Bool {
    return self.text.contains(keyword) || self.title.contains(keyword)
  }
}
