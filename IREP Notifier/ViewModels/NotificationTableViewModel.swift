//
//  NotificationTableViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 6/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import SideMenu

class NotificationTableViewModel: NSObject {
  private let disposeBag = DisposeBag()
  private let model = NotificationManager()
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
      .map { (groups) -> [NotificationGroup] in
        return groups.compactMap({ (group) -> NotificationGroup? in
          let items = group.filterNotificationsBy(readStatus: false)
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
      tableView: self.viewController.notificationTableView,
      segmentControl: self.viewController.notificationSegmentControl
    )
    self.bindNotificationTableViewTo(
      searcher: self.viewController.notificationSearcher,
      segmentControl: self.viewController.notificationSegmentControl
    )
    self.bindNotificationTableViewTo(
      segmentControl: self.viewController.notificationSegmentControl
    )
    self.bindOnSelectionHandlerToNotifications(
      tableView: self.viewController.notificationTableView
    )
    self.bindRefresherToNotifications(
      tableView: self.viewController.notificationTableView
    )
    self.bindSearcherTrigger(button: self.viewController.navigationSearchButton)
    self.bindSideMenuTrigger(button: self.viewController.navigationMenuButton)
    // initial setup
    self.viewController.hideSearcher()
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.fcmNotifierDelegate = self
    }
  }
  
  /**
   Method to bind notification table view data source to visible notification
   observable and configure the cell display based on logics.
  */
  private func bindDataSourceToNotifications(
    tableView: UITableView,
    segmentControl: UISegmentedControl
  ) {
    let dataSource = RxTableViewSectionedReloadDataSource<NotificationGroup>(
      configureCell: { dataviewController, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: NotificationTableViewCell.identifier,
          for: indexPath
        ) as! NotificationTableViewCell
        cell.titleLabel.text = item.title
        switch segmentControl.selectedSegmentIndex {
          case 0:
            cell.titleLabel.textColor =
              item.isRead ? UIColor.red : UIColor.darkGray
          case 1:
            cell.titleLabel.textColor = UIColor.darkGray
          default:
            break
        }
        return cell
      }
    )
    dataSource.rowAnimation = .fade
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
   Method to bind visible notification observables to search bar event.
   Keyword search using search bar which filter the data emitted by visible
   notification observables by checking whether the keyword exists in the title
   of notification group or in content of notifications.
   Both `Cancel` and `Done` event cause search bar to resign its responder but
   `Cancel` event set search bar text to nil which trigger empty keyword
   search in turn.
   */
  private func bindNotificationTableViewTo(
    searcher: UISearchBar,
    segmentControl: UISegmentedControl
  ) {
    searcher.rx.text
      .orEmpty
      .distinctUntilChanged()
      .subscribe(
        onNext: { (text) in
          let data: [NotificationGroup]
            switch segmentControl.selectedSegmentIndex {
            case 0: data = self.allNoticationGroups.value
            case 1: data = self.readNoticationGroups.value
            default: data = []
          }
          if text.isEmpty {
            self.visibleNoticationGroups.accept(data)
          } else {
            self.visibleNoticationGroups.accept(data.compactMap(
              { (group) -> NotificationGroup? in
                let items = group.filterNotifications(by: text)
                if group.isCategorized(by: text) {
                  return NotificationGroup(original: group, items: items)
                } else {
                  return nil
                }
              }
            ))
          }
        },
        onError: { (error) in fatalError(error.localizedDescription) },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
    let searchCancelEvent = searcher.rx.cancelButtonClicked
    searchCancelEvent.asDriver()
      .drive(
        onNext: { _ in
          searcher.text = nil
          searcher.resignFirstResponder()
          self.viewController.hideSearcher()
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
          self.viewController.hideSearcher()
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  /**
   Method to bind notification table view data source observable to segment
   control index observable. The last value emitted by search bar will trigger
   event of selecting notification observable as the table view data source.
   */
  private func bindNotificationTableViewTo(segmentControl: UISegmentedControl) {
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
   Method to create driver for tablke view cell on select event.
   */
  private func bindOnSelectionHandlerToNotifications(tableView: UITableView) {
    let events = tableView.rx.itemSelected
    events.asDriver()
      .drive(
        onNext: { (indexPath) in
          let sec = self.visibleNoticationGroups.value[indexPath.section]
          let item = sec.items[indexPath.row]
          let id = item.id
          let title = item.title
          let message = item.text
          self.viewController.alert(title: title, message: message) { _ in
            self.model.updateReadNotificationStatusById(id: id)?
              .subscribe(
                onNext: { (status) in
                  if status {
                    self.fetchNotications()
                  }
                },
                onError: { (error) in fatalError(error.localizedDescription) },
                onCompleted: nil,
                onDisposed: nil
              )
              .disposed(by: self.disposeBag)
          }
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  /**
   Method to add UIRefreshControl to notification table view.
   The UIRefreshControl handler drive the notification observables to load
   notifications to table view.
  */
  private func bindRefresherToNotifications(tableView: UITableView) {
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
   Method to bind trigger button event to notification table view search bar.
  */
  private func bindSearcherTrigger(button: UIBarButtonItem) {
    let tap = button.rx.tap
    tap.subscribe(
      onNext: { self.viewController.showSearcher() },
      onError: nil,
      onCompleted: nil,
      onDisposed: nil
    )
    .disposed(by: self.disposeBag)
  }
  
  private func bindSideMenuTrigger(button: UIBarButtonItem) {
    let tap = button.rx.tap
    tap.subscribe(
      onNext: {
        let source = self.viewController
        source.performSegue(withIdentifier:source.sideMenuSegueKey, sender: nil)
      },
      onError: nil,
      onCompleted: nil,
      onDisposed: nil
      )
      .disposed(by: self.disposeBag)
    
    SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(
      toView: self.viewController.view
    )
  }
  
  /**
   Method to bind the event of getting all notifications from server and emitted
   as data from all notification observable
  */
  @objc private func fetchNotications() {
    DispatchQueue.main.async {
      self.refreshControl.beginRefreshing()
      self.model.getNotificationsByDeviceId()?
        .map({ (groups) -> [NotificationGroup] in
          DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
          }
          return groups
        })
        .bind(to: self.allNoticationGroups)
        .disposed(by: self.disposeBag)
    }
  }
}

extension NotificationTableViewModel: FcmNotifierDelegate {
  func receivedFcmToken() {
    self.fetchNotications()
  }
}
