//
//  NotificationListViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 6/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyJSON

class NotificationListViewModel {
  private let disposeBag = DisposeBag()
  
  let notications: BehaviorRelay<[Notification]>
  
  init(notificationListTable: inout UITableView) {
    self.notications = BehaviorRelay<[Notification]>(value: [])
    let disposable = self.notications
      .asObservable()
      .bind(to: notificationListTable.rx.items(
        cellIdentifier: AccountTableViewCell.identifier,
        cellType: AccountTableViewCell.self
      )) {(row, notification, cell) in
        cell.categoryLabel.text = notification.title
        cell.nameLabel.text = notification.text
    }
    disposable.disposed(by: self.disposeBag)
  }
}
