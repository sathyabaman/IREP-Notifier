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
    return NotificationTableViewModel(notificationTable: &self.notificationTableView)
  }()
  
  @IBOutlet weak var infoBoard: UIView!
  @IBOutlet weak var notificationTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.notificationTableViewModel.fetchNotications()
  }
  
  @IBAction func menuAction(_ sender: UIBarButtonItem) {
    
  }
  
}
