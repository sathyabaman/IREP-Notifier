//
//  Account.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 31/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import SwiftyJSON

struct Account {
  let id: Int
  let category: String
  let loginID: String // account user name which is used for login in general
  let name: String // account given name for display
  
  init(id: Int, category: String, loginID: String, name: String) {
    self.id = id
    self.category = category
    self.loginID = loginID
    self.name = name
  }
  
  init(info: JSON) {
    let id = info["ID"].intValue
    let category = info["Name"].stringValue
    let loginID = info["LoginID"].stringValue
    let name = info["UserName"].stringValue
    self.init(id: id, category: category, loginID: loginID, name: name)
  }
}
