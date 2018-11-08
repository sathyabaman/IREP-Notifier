//
//  AccountManagerViewController.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccountManagerViewController: UIViewController {
  private lazy var accountViewModel: AccountViewModel = {
    return AccountViewModel(accountTable: &self.accountTableView)
  }()
  
  @IBOutlet weak var accountTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    self.accountViewModel.registerAccountBy(
//      accountType: 1,
//      companyId: "SEN0001",
//      username: "Test",
//      password: "1234"
//    )
//    self.accountViewModel.removeAccountBy(accountId: 43)
    self.accountViewModel.fetchAccounts()
  }

}
