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
import KWDrawerController

class NotificationTableViewController: DrawerController {
  private var notificationTableViewModel: NotificationTableViewModel!
  
  @IBOutlet weak var navigationRightButton: UIBarButtonItem!
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
    let swipeGesture = UISwipeGestureRecognizer(
      target: self.notificationTableViewModel,
      action: #selector(self.notificationTableViewModel.drawerHandler(gesture:))
    )
    self.view.addGestureRecognizer(swipeGesture)
  }
}
