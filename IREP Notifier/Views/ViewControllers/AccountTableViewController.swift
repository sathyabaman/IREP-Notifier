//
//  AccountTableViewController.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccountTableViewController: UIViewController {
  private var accountTableViewModel: AccountTableViewModel!
  
  @IBOutlet weak var accountTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.accountTableViewModel = AccountTableViewModel(viewController: self)
  }

}
