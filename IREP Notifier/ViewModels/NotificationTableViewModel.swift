//
//  NotificationTableViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 6/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import SwiftyJSON

class NotificationTableViewModel: NSObject {
  private let disposeBag = DisposeBag()
  private let notications: BehaviorRelay<[Notification]>
  
  init(notificationTable: inout UITableView) {
    self.notications = BehaviorRelay<[Notification]>(value: [])
    // table data load logics
    self.notications
      .asObservable()
      // do observable binding here
      .bind(to: notificationTable.rx.items(
        cellIdentifier: NotificationTableViewCell.identifier,
        cellType: NotificationTableViewCell.self
      )) {(row, notification, cell) in
        cell.titleLabel.text = notification.title
        cell.descriptionLabel.text = notification.text
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
      }
      .disposed(by: self.disposeBag)
    super.init()
    let dataSource = RxTableViewSectionedReloadDataSource<NotificationGroup>(
      configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: NotificationTableViewCell.identifier,
          for: indexPath
        )
        return cell
    })
    // tableview cell select event logics
    notificationTable
      .rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        print("\(indexPath.row)")
//      let cell = notificationTable.cellForRow(at: indexPath) as? NotificationTableViewCell
//      cell?.titleLabel.text = "\(clicked) \(cell?.titleLabel.text)"
      })
      .disposed(by: disposeBag)
  }
  
  func fetchNotications() {
    let disposable = NotificationManager.shared.getNotificationsByDeviceId()?.subscribe {
      switch $0 {
      case .error(let error):
        fatalError("Failed to get notifications by device ID: \(error.localizedDescription)")
      case .next(let data):
        self.processNotications(data)
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
      print("Group count: \(data.count)")
      let messages = data[0]["FCMNotificationMsgList"].arrayValue
      self.notications.accept(messages.map({ (info) -> Notification in
        return Notification(info: info)
      }))
    } catch {
      fatalError("JSON parse error: \(error)")
    }
  }
}

extension NotificationTableViewModel: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return nil
  }
}
