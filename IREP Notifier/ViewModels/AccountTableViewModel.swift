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
    self.fetchAccounts()
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
  
  private func fetchAccounts() {
    AccountManager.getAccountListByDeviceId()?
      .bind(to: self.accountInfo)
      .disposed(by: self.disposeBag)
  }
  
  private func removeAccountBy(accountId: Int) {
    AccountManager.deleteAccountBy(accountId: accountId)?
      .subscribe({
        switch $0 {
          case .error(let error):
            self.viewController.alert(
              title: "Failed to delete account",
              message: error.localizedDescription,
              completion: nil
            )
          case .next(let result):
            if result.statusMessage != nil {
              self.viewController.alert(
                title: "Failed to delete account",
                message: result.statusMessage,
                completion: nil
              )
            } else {
              self.fetchAccounts()
            }
          case .completed:
            break
        }
      })
      .disposed(by: self.disposeBag)
  }
}
