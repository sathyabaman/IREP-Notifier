//
//  NotificationTableViewController.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationTableViewController: UIViewController {
  private var notificationTableViewModel: NotificationTableViewModel!
  
  let sideMenuSegueKey = "openSideMenu"
  
  @IBOutlet weak var navigationMenuButton: UIBarButtonItem!
  @IBOutlet weak var navigationSearchButton: UIBarButtonItem!
  @IBOutlet weak var notificationSearcher: UISearchBar!
  @IBOutlet weak var notificationSegmentControl: UISegmentedControl!
  @IBOutlet weak var notificationTableView: UITableView!
  @IBOutlet weak var notificationTableViewTop: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.notificationTableView.backgroundColor =
      UIColor.gray.withAlphaComponent(0.3)
    self.notificationTableViewModel = NotificationTableViewModel(
      viewController: self
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.notificationTableViewModel.fetchNotications()
  }
  
  func hideSearcher() {
    self.navigationSearchButton.isEnabled = true
    self.notificationSearcher.isHidden = true
    self.notificationTableViewTop.constant = 0
  }
  
  func showSearcher() {
    self.navigationSearchButton.isEnabled = false
    self.notificationSearcher.text = nil
    self.notificationSearcher.isHidden = false
    self.notificationTableViewTop.constant = 56
  }
}
