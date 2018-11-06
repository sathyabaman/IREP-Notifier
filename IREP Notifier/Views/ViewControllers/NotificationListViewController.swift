//
//  NotificationListViewController.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NotificationListViewController: UIViewController {
  private lazy var notificationListViewModel: NotificationListViewModel = {
    return NotificationListViewModel(notificationListTable: &self.notificationTableView)
  }()
  
  @IBOutlet weak var infoBoard: UIView!
  @IBOutlet weak var notificationTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func menuAction(_ sender: UIBarButtonItem) {
    
  }
  
}
