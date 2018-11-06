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
  let companyName: String
  let category: String
  let loginID: String // account user name which is used for login in general
  let name: String // account given name for display
  
  init(id: Int, company: String, category: String, loginID: String, name: String) {
    self.id = id
    self.companyName = company
    self.category = category
    self.loginID = loginID
    self.name = name
  }
  
  init(info: JSON) {
    let id = info["ID"].intValue
    let company = info["CompanyName"].stringValue
    let category = info["Name"].stringValue
    let loginID = info["LoginID"].stringValue
    let name = info["UserName"].stringValue
    self.init(id: id, company: company, category: category, loginID: loginID, name: name)
  }
}
