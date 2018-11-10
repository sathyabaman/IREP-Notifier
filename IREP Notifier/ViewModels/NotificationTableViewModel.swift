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
  
  private let noticationGroups: BehaviorRelay<[NotificationGroup]>
  
  init(notificationTable: inout UITableView) {
    self.noticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    super.init()
    self.prepareDataSourceFor(notificationTable: &notificationTable)
    self.configureOnClickEventHandling(notificationTable: &notificationTable)
  }
  
  func prepareDataSourceFor(notificationTable: inout UITableView) {
    let dataSource = RxTableViewSectionedReloadDataSource<NotificationGroup>(
      configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: NotificationTableViewCell.identifier,
          for: indexPath
        ) as! NotificationTableViewCell
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.text
        return cell
    })
    dataSource.titleForHeaderInSection = {(dataSource, section) in
      return dataSource.sectionModels[section].title
    }
    dataSource.canEditRowAtIndexPath = {(dataSource, section) in
      return false
    }
    dataSource.canMoveRowAtIndexPath = {(dataSource, section) in
      return false
    }
    self.noticationGroups
      .asObservable()
      .bind(to: notificationTable.rx.items(dataSource: dataSource))
      .disposed(by: self.disposeBag)
  }
  
  func configureOnClickEventHandling(notificationTable: inout UITableView) {
    notificationTable
      .rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        print("\(self?.noticationGroups.value[indexPath.section].items[indexPath.row].title)")
      })
      .disposed(by: disposeBag)
  }
  
  func fetchNotications() {
    NotificationManager
      .shared
      .getNotificationsByDeviceId()?
      .subscribe {
        switch $0 {
        case .error(let error):
          fatalError(
            "Failed to get notifications: \(error.localizedDescription)"
          )
        case .next(let data):
          self.processNotications(data)
        default:
          break
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  private func processNotications(_ data: Data) {
    do {
      let json = try JSON(data: data)
      let data = json["Data"].arrayValue
      self.noticationGroups.accept(data.map { (json) -> NotificationGroup in
        return NotificationGroup(
          accountTypeId: json["AccountTypeID"].intValue,
          title: json["Name"].stringValue,
          items: json["FCMNotificationMsgList"]
            .arrayValue
            .map({ (itemInfo) -> Notification in
              return Notification(info: itemInfo)
            })
        )
      })
    } catch {
      fatalError("JSON parse error: \(error)")
    }
  }
}

//extension NotificationTableViewModel: UITableViewDelegate {
//  func tableView(
//    _ tableView: UITableView,
//    viewForHeaderInSection section: Int
//    ) -> UIView? {
//    let headerView = UIView(frame: CGRect(
//      x: 0,
//      y: 0,
//      width: UIScreen.main.bounds.size.width,
//      height: 20
//    ))
//    headerView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
//    headerView.layer.cornerRadius = 10.0
//    let title = UILabel(frame: headerView.bounds)
//    title.center = headerView.center
//    title.font = UIFont.systemFont(ofSize: 20, weight: .medium)
//    title.textAlignment = .center
//    title.textColor = UIColor.gray
//    title.text = self.noticationGroups.value[section].title
//    headerView.addSubview(title)
//    return headerView
//  }
//}
