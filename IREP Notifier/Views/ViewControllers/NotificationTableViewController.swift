//
//  NotificationTableViewController.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NotificationTableViewController: UIViewController {
  private lazy var notificationTableViewModel: NotificationTableViewModel = {
    return NotificationTableViewModel(viewController: self)
  }()
  
  @IBOutlet weak var searchBarTriggerer: UIBarButtonItem!
  @IBOutlet weak var notificationTableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.searchBar.frame = CGRect(
      x: 0,
      y: 0,
      width: self.searchBar.bounds.width,
      height: 0
    )
    self.notificationTableView.backgroundColor =
      UIColor.gray.withAlphaComponent(0.3)
    self.notificationTableViewModel.fetchNotications()
  }
  
}
