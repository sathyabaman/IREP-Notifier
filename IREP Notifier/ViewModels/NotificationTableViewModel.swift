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
  private let allNoticationGroups: BehaviorRelay<[NotificationGroup]>
  private let refreshControl = UIRefreshControl()
  private let viewController: NotificationTableViewController
  private let visibleNoticationGroups: BehaviorRelay<[NotificationGroup]>
  
  init(viewController: NotificationTableViewController) {
    self.allNoticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    self.visibleNoticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    self.viewController = viewController
    super.init()
    self.fetchNotications()
  }
  
  /**
   Method to create driver for tablke view cell on select event.
   */
  func bindCellOnSelectionHandlerToNotifications(tableView: inout UITableView) {
    let events = self.viewController.notificationTableView.rx.itemSelected
    events.asDriver().drive(
      onNext: { [weak self] indexPath in
        guard let sect = self?.visibleNoticationGroups.value[indexPath.section]
          else { return }
        let item = sect.items[indexPath.row]
        self?.viewController.alert(title: item.title, message: item.text)
      },
      onCompleted: nil,
      onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  /**
   Method to bind notification table view data source to a notification group
   observable (NotificationGroup) which emit data for visible notifications.
  */
  func bindDataSourceToNotifications(tableView: inout UITableView) {
    let dataSource = RxTableViewSectionedReloadDataSource<NotificationGroup>(
      configureCell: { dataviewController, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: NotificationTableViewCell.identifier,
          for: indexPath
        ) as! NotificationTableViewCell
        cell.titleLabel.text = item.title
        return cell
      }
    )
    dataSource.titleForHeaderInSection = {(dataviewController, section) in
      return dataviewController.sectionModels[section].title
    }
    dataSource.canEditRowAtIndexPath = {(dataviewController, section) in
      return false
    }
    dataSource.canMoveRowAtIndexPath = {(dataviewController, section) in
      return false
    }
    self.visibleNoticationGroups.asObservable()
      .bind(to: self.viewController.notificationTableView.rx.items(
        dataSource: dataSource
      ))
      .disposed(by: self.disposeBag)
  }
  
  /**
   Method to bind notification table view data source observable to serach bar
   text observable. The last value emitted by search bar will trigger event of
   notification table view data source observable sequences
   */
  func bindNotificationTableViewTo(searcher: inout UISearchBar) {
    searcher.rx.text
      .orEmpty
      .distinctUntilChanged()
      .flatMapLatest({(text) -> Observable<[NotificationGroup]> in
        let groups = self.allNoticationGroups.value
          .compactMap({ (group) -> NotificationGroup? in
            let items = group.filterNotifications(by: text)
            if group.isCategorized(by: text) {
              return NotificationGroup(original: group, items: items)
            } else {
              return nil
            }
          })
        return Observable.of(groups)
      })
      .bind(to: self.visibleNoticationGroups)
      .disposed(by: self.disposeBag)
    let searchCancelEvent = searcher.rx.cancelButtonClicked
    searchCancelEvent.asObservable()
      .subscribe(
        onNext: { _ in
          self.viewController.notificationSearcher.text = nil
          self.viewController.notificationSearcher.resignFirstResponder()
        },
        onError: { (error) in fatalError(error.localizedDescription) },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
    let searchEvent = searcher.rx.searchButtonClicked
    searchEvent.asObservable()
      .subscribe(
        onNext: { _ in
          self.viewController.notificationSearcher.text = nil
          self.viewController.notificationSearcher.resignFirstResponder()
      },
        onError: { (error) in fatalError(error.localizedDescription) },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  /**
   
   */
  func bindRefresherToNotifications(tableView: inout UITableView) {
    self.refreshControl.addTarget(
      self,
      action: #selector(fetchNotications),
      for: .valueChanged
    )
    if #available(iOS 10.0, *) {
      tableView.refreshControl = self.refreshControl
    } else {
      tableView.addSubview(self.refreshControl)
    }
  }
  
  @objc private func fetchNotications() {
    self.refreshControl.beginRefreshing()
    NotificationManager
      .shared
      .getNotificationsByDeviceId()?
      .subscribe {
        switch $0 {
        case .error(let error):
          DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
          }
          fatalError(
            "Failed to get notifications: \(error.localizedDescription)"
          )
        case .next(let data):
          self.processNotications(data)
        default:
          DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
          }
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  private func processNotications(_ data: Data) {
    do {
      let json = try JSON(data: data)
      let data = json["Data"].arrayValue
      self.allNoticationGroups.accept(data.map { (json) -> NotificationGroup in
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
      self.visibleNoticationGroups.accept(self.allNoticationGroups.value)
      DispatchQueue.main.async {
        self.refreshControl.endRefreshing()
      }
    } catch {
      DispatchQueue.main.async {
        self.refreshControl.endRefreshing()
      }
      fatalError("JSON parse error: \(error)")
    }
  }
}
