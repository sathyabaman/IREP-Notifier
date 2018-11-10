//
//  NotificationTableViewController.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import FontAwesome_swift
import RxCocoa
import RxSwift

class NotificationTableViewController: UIViewController {
  private lazy var notificationTableViewModel: NotificationTableViewModel = {
    return NotificationTableViewModel(
      notificationTable: &self.notificationTableView,
      viewController: self
    )
  }()
  
  @IBOutlet weak var notificationTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.notificationTableView.backgroundColor =
      UIColor.gray.withAlphaComponent(0.3)
    self.notificationTableViewModel.fetchNotications()
  }
  
}
