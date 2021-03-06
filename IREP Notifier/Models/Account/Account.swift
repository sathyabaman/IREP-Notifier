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
  let company: String
  let category: String
  let loginId: String // account user name which is used for login in general
  let name: String // account given name for display
  
  init(
    id: Int,
    company: String,
    category: String,
    loginId: String,
    name: String
  ) {
    self.id = id
    self.company = company
    self.category = category
    self.loginId = loginId
    self.name = name
  }
  
  init(info: JSON) {
    let id = info["ID"].intValue
    let company = info["CompanyName"].stringValue
    let category = info["Name"].stringValue
    let loginId = info["LoginID"].stringValue
    let name = info["UserName"].stringValue
    self.init(
      id: id,
      company: company,
      category: category,
      loginId: loginId,
      name: name
    )
  }
}
