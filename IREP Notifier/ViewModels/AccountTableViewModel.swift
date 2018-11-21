//
//  AccountTableViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 31/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import SwiftyJSON

struct AccountTableViewModel {
  private let disposeBag = DisposeBag()
  // data observables
  let accountInfo: BehaviorRelay<[Account]>
  // UI elements
  private let viewController:AccountTableViewController
  
  init(viewController: AccountTableViewController) {
    self.accountInfo = BehaviorRelay<[Account]>(value: [])
    self.viewController = viewController
    self.bindAccountTable(self.viewController.accountTableView)
  }
  
  private func bindAccountTable(_ accountTable: UITableView) {
    self.accountInfo.asObservable()
      .bind(to: accountTable.rx.items(
        cellIdentifier: AccountTableViewCell.identifier,
        cellType: AccountTableViewCell.self
      )) {(row, account, cell) in
        cell.categoryLabel.text = "Product name: \(account.category)"
        cell.loginIdLabel.text = "Login ID: \(account.loginId)"
        cell.nameLabel.text = "User name: \(account.name)"
      }
      .disposed(by: self.disposeBag)
    let select = accountTable.rx.itemSelected
    select.asDriver()
      .drive(
        onNext: { (indexPath) in
          self.removeAccountBy(accountId: self.accountInfo.value[indexPath.row].id)
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  func fetchAccounts() {
    AccountManager.getAccountListByDeviceId()?
      .catchError({ (error) -> Observable<Data> in
        fatalError(error.localizedDescription)
      })
      .flatMapLatest({ (data) -> Observable<[Account]> in
        do {
          let json = try JSON(data: data)
          let data = json["Data"].arrayValue
          let accounts = data.map({ (info) -> Account in
            return Account(info: info)
          })
          return Observable.of(accounts)
        } catch {
          throw error
        }
      })
      .bind(to: self.accountInfo)
      .disposed(by: self.disposeBag)
  }
  
  private func removeAccountBy(accountId: Int) {
    AccountManager.deleteAccountBy(accountId: accountId)?
      .catchError({ (error) -> Observable<Data> in
        fatalError(error.localizedDescription)
      })
      .flatMapLatest({ (data) -> Observable<[Account]> in
        do {
          let json = try JSON(data: data)
          let status = json["status"].intValue
          switch status {
          case 1: // success
            var accounts = self.accountInfo.value
            accounts = accounts.filter({ (account) -> Bool in
              return account.id != accountId
            })
            return Observable.of(accounts)
          case 0: // failure
            if let errorMessage = json["ErrMsg"].string {
              self.viewController.alert(title: errorMessage, message: nil, completion: nil)
            }
            return self.accountInfo.asObservable()
          default: // unexpected encounter
            return self.accountInfo.asObservable()
          }
        } catch {
          return self.accountInfo.asObservable()
        }
      })
      .bind(to: self.accountInfo)
      .disposed(by: self.disposeBag)
  }
}
