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
  private let refreshControl = UIRefreshControl()
  private let source: NotificationTableViewController
  private let visibleNoticationGroups: BehaviorRelay<[NotificationGroup]>
  
  init(viewController: NotificationTableViewController) {
    self.noticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    self.visibleNoticationGroups = BehaviorRelay<[NotificationGroup]>(value: [])
    self.source = viewController
    super.init()
    self.prepareNotificationTableViewDataSource()
    self.delegateNotificationTableViewCellOnClickEvent()
    self.bindSearcherToNotificationTable()
  }
  
  private func prepareNotificationTableViewDataSource() {
    let dataSource = RxTableViewSectionedReloadDataSource<NotificationGroup>(
      configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: NotificationTableViewCell.identifier,
          for: indexPath
        ) as! NotificationTableViewCell
        cell.titleLabel.text = item.title
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
    self.visibleNoticationGroups
      .asObservable()
      .bind(
        to: self.source.notificationTableView.rx.items(dataSource: dataSource)
      )
      .disposed(by: self.disposeBag)
    
    self.refreshControl.addTarget(
      self,
      action: #selector(fetchNotications),
      for: .valueChanged
    )
    if #available(iOS 10.0, *) {
      self.source.notificationTableView.refreshControl = self.refreshControl
    } else {
      self.source.notificationTableView.addSubview(self.refreshControl)
    }
  }
  
  private func delegateNotificationTableViewCellOnClickEvent() {
    self.source.notificationTableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let sect = self?.visibleNoticationGroups.value[indexPath.section]
        else { return }
        let item = sect.items[indexPath.row]
        let alert = UIAlertController(
          title: item.title,
          message: item.text,
          preferredStyle: .alert
        )
        alert.addAction(
          UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        )
        self?.source.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
  
  private func bindSearcherToNotificationTable() {
    let searchBar = self.source.searchBar.rx
    searchBar
      .text
      .orEmpty
      .filter({ !$0.isEmpty })
      .distinctUntilChanged()
      .subscribe(
        onNext: { (text) in
          self.visibleNoticationGroups.accept(
            self.noticationGroups.value.compactMap(
              { (group) -> NotificationGroup? in
                let items = group.items.compactMap({ (item) -> Notification? in
                  let fit = item.text.contains(text) || item.title.contains(text)
                  return fit ? item : nil
                })
                let fit  = items.count > 0 || group.title.contains(text)
                let newGroup = NotificationGroup(
                  accountTypeId: group.accountTypeId,
                  title: group.title,
                  items: items
                )
                return fit ? newGroup : nil
              }
            )
          )
        },
        onError: { (error) in
          fatalError("Failed to filter: \(error.localizedDescription)")
        },
        onCompleted: {},
        onDisposed: {}
      )
      .disposed(by: self.disposeBag)
    
    searchBar
      .cancelButtonClicked
      .asObservable()
      .bind {
        self.source.searchBar.text = ""
      }
      .disposed(by: self.disposeBag)
    searchBar
      .searchButtonClicked
      .asObservable()
      .bind {
        self.source.searchBar.resignFirstResponder()
      }
      .disposed(by: self.disposeBag)
  }
  
  @objc func fetchNotications() {
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
      self.visibleNoticationGroups.accept(self.noticationGroups.value)
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
