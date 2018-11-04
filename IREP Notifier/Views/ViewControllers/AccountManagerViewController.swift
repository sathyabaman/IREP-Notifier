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
    NotificationManager.shared.getNotificationsByDeviceID()?.subscribe({ (event) in
      switch event {
      case .next(let data):
        do {
          let json = try JSON(data: data)
          print("N: \(json.description)")
        } catch {
          print("Err: \(error.localizedDescription)")
        }
      case .error(let error):
        print("E: \(error.localizedDescription)")
      default:
        break
      }
    })
  }

}
