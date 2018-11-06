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
    self.accountViewModel.fetchAccountInfo()
  }

}
