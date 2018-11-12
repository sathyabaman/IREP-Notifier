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
    let viewModel = NotificationTableViewModel(viewController: self)
    viewModel.bindDataSourceToNotifications(
      tableView: &self.notificationTableView
    )
    viewModel.bindCellOnSelectionHandlerToNotifications(
      tableView: &self.notificationTableView
    )
    viewModel.bindRefresherToNotifications(
      tableView: &self.notificationTableView
    )
    return viewModel
  }()
  
  @IBOutlet weak var notificationSearcher: UISearchBar!
  @IBOutlet weak var notificationSegmentControl: UISegmentedControl!
  @IBOutlet weak var notificationTableView: UITableView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.notificationTableView.backgroundColor =
      UIColor.gray.withAlphaComponent(0.3)
    self.notificationTableViewModel.bindNotificationTableViewTo(searcher: &self.notificationSearcher)
  }
  
}
