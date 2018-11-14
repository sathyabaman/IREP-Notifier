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
  // data observables
  private let allNoticationGroups: BehaviorRelay<[NotificationGroup]>
  private let readNoticationGroups: BehaviorRelay<[NotificationGroup]>
  private let visibleNoticationGroups: BehaviorRelay<[NotificationGroup]>
  // UI elements
  private let refreshControl = UIRefreshControl()
  private let viewController: NotificationTableViewController
  
  init(viewController: NotificationTableViewController) {
    self.allNoticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    self.readNoticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    self.visibleNoticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    self.viewController = viewController
    super.init()
    // data observable bindings
    self.allNoticationGroups
      .bind(to: self.visibleNoticationGroups)
      .disposed(by: self.disposeBag)
    self.allNoticationGroups
      .map { (groups) -> [NotificationGroup] in
        return groups.compactMap({ (group) -> NotificationGroup? in
          let items = group.filterNotificationsBy(readStatus: true)
          if items.count > 0 {
            return NotificationGroup(original: group, items: items)
          } else {
            return nil
          }
        })
      }
      .bind(to: self.readNoticationGroups)
      .disposed(by: self.disposeBag)
    // bind UI elements with data observables
    self.bindDataSourceToNotifications(
      tableView: self.viewController.notificationTableView
    )
    self.bindCellOnSelectionHandlerToNotifications(
      tableView: self.viewController.notificationTableView
    )
    self.bindRefresherToNotifications(
      tableView: self.viewController.notificationTableView
    )
    self.bindNotificationTableViewTo(
      searcher: self.viewController.notificationSearcher
    )
    self.bindNotificationTableViewTo(
      segmentControl: self.viewController.notificationSegmentControl
    )
    // fetch notifications on the spot of this view model is being created.
    self.fetchNotications()
  }
  
  /**
   Method to create driver for tablke view cell on select event.
   */
  func bindCellOnSelectionHandlerToNotifications(tableView: UITableView) {
    let events = tableView.rx.itemSelected
    events.asDriver().drive(
      onNext: { [weak self] indexPath in
        guard let sect = self?.visibleNoticationGroups.value[indexPath.section]
        else { return }
        let item = sect.items[indexPath.row]
        self?.viewController.alert(title: item.title, message: item.text) {
          let cell = tableView.cellForRow(
            at: indexPath
          ) as? NotificationTableViewCell
          cell?.titleLabel.textColor = UIColor.red
        }
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
  func bindDataSourceToNotifications(tableView: UITableView) {
    let dataSource = RxTableViewSectionedReloadDataSource<NotificationGroup>(
      configureCell: { dataviewController, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: NotificationTableViewCell.identifier,
          for: indexPath
        ) as! NotificationTableViewCell
        cell.titleLabel.text = item.title
        cell.titleLabel.textColor = item.isRead ? UIColor.darkGray : UIColor.red
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
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: self.disposeBag)
  }
  
  /**
   Method to bind notification table view data source observable to search bar
   text observable. The last value emitted by search bar will trigger event of
   notification table view data source observable sequences
   */
  func bindNotificationTableViewTo(searcher: UISearchBar) {
    searcher.rx.text
      .orEmpty
      .distinctUntilChanged()
      .flatMapLatest({(text) -> Observable<[NotificationGroup]> in
        guard !text.isEmpty else {
          return self.allNoticationGroups.asObservable()
        }
        let data: [NotificationGroup]
        let segmentControl = self.viewController.notificationSegmentControl
        switch segmentControl?.selectedSegmentIndex {
          case .some(let index) where index == 0:
            data = self.allNoticationGroups.value
          case .some(let index) where index == 1:
            data = self.readNoticationGroups.value
          case .some(_):
            data = []
          case .none:
            fatalError("Unexpected segment index null")
        }
        let groups = data.compactMap({ (group) -> NotificationGroup? in
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
    searchCancelEvent.asDriver()
      .drive(
        onNext: { _ in
          searcher.text = nil
          searcher.resignFirstResponder()
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
    let searchEvent = searcher.rx.searchButtonClicked
    searchEvent.asDriver()
      .drive(
        onNext: { _ in
          searcher.resignFirstResponder()
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  /**
   Method to bind notification table view data source observable to segment
   control index observable. The last value emitted by search bar will trigger
   event of filter the notification by segment control.
   */
  func bindNotificationTableViewTo(segmentControl: UISegmentedControl) {
    segmentControl.rx.selectedSegmentIndex
      .distinctUntilChanged()
      .flatMapLatest { (index) -> Observable<[NotificationGroup]> in
        switch index {
        case 1: // second case is all read notifications
          return self.readNoticationGroups.asObservable()
        default: // default case is all notifications
          return self.allNoticationGroups.asObservable()
        }
      }
      .bind(to: self.visibleNoticationGroups)
      .disposed(by: self.disposeBag)
  }
  
  /**
   Method to add UIRefreshControl to notification table view
   the UIRefreshControl handler drive the notification group observable to load
   notifications to table view.
  */
  func bindRefresherToNotifications(tableView: UITableView) {
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
  
  /**
   Method to bind server request observable to notification pool observable.
  */
  @objc private func fetchNotications() {
    self.refreshControl.beginRefreshing()
    NotificationManager.shared.getNotificationsByDeviceId()?
      .flatMapLatest({ (data) -> Observable<[NotificationGroup]> in
        DispatchQueue.main.async {
          self.refreshControl.endRefreshing()
        }
        do {
          let json = try JSON(data: data)
          let data = json["Data"].arrayValue
          return Observable.of(data.map { (json) -> NotificationGroup in
            return NotificationGroup(
              accountTypeId: json["AccountTypeID"].intValue,
              title: json["Name"].stringValue,
              items: json["FCMNotificationMsgList"].arrayValue.map(
                { (itemInfo) -> Notification in
                  return Notification(info: itemInfo)
                }
              )
            )
          })
        } catch {
          throw error
        }
      })
      .bind(to: self.allNoticationGroups)
      .disposed(by: self.disposeBag)
  }
}
