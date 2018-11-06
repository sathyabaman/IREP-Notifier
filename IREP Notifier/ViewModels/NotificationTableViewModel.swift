//
//  NotificationTableViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 6/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyJSON

class NotificationTableViewModel {
  private let disposeBag = DisposeBag()
  
  let notications: BehaviorRelay<[Notification]>
  
  init(notificationTable: inout UITableView) {
    self.notications = BehaviorRelay<[Notification]>(value: [])
    let disposable = self.notications
      .asObservable()
      .bind(to: notificationTable.rx.items(
        cellIdentifier: NotificationTableViewCell.identifier,
        cellType: NotificationTableViewCell.self
      )) {(row, notification, cell) in
        cell.titleLabel.text = notification.title
        cell.descriptionLabel.text = notification.text
    }
    disposable.disposed(by: self.disposeBag)
  }
  
  func fetchNotications() {
    let disposable = NotificationManager.shared.getNotificationsByDeviceID()?.subscribe {
      switch $0 {
      case .error(let error):
        fatalError("Failed to get notifications by device ID: \(error.localizedDescription)")
      case .next(let data):
        do {
          let json = try JSON(data: data)
          print("N: \(json.description)")
        } catch {
          print("Err: \(error.localizedDescription)")
        }
      default:
        break
      }
    }
    disposable?.disposed(by: self.disposeBag)
  }
  
  private func processNotications(_ data: Data) {
    do {
      let json = try JSON(data: data)
      let data = json["Data"].arrayValue
      self.notications.accept(data.map({ (info) -> Notification in
        return Notification(info: info)
      }))
    } catch {
      print("JSON parse error: \(error)")
    }
  }
}
