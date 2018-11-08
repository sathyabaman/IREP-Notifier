//
//  AccountViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 31/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyJSON

struct AccountViewModel {
  private let disposeBag = DisposeBag()
  
  let accountInfo: BehaviorRelay<[Account]>
  
  init(accountTable: inout UITableView) {
    self.accountInfo = BehaviorRelay<[Account]>(value: [])
    self.accountInfo
      .asObservable()
      .bind(to: accountTable.rx.items(
        cellIdentifier: AccountTableViewCell.identifier,
        cellType: AccountTableViewCell.self
      )) {(row, account, cell) in
        cell.categoryLabel.text = account.companyName
        cell.nameLabel.text = account.name
      }
      .disposed(by: self.disposeBag)
  }
  
  func fetchAccounts() {
    AccountManager.getAccountListByDeviceId()?
      // reactiveX logics goes here
      .subscribe {
        switch $0 {
        case .error(let error):
          fatalError("Failed to get account list by device ID: \(error.localizedDescription)")
        case .next(let data):
          self.processAccountInfo(data)
        case .completed:
          break
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  func registerAccountBy(accountType: Int, companyId: String, username: String, password: String) {
    AccountManager.registerAccountBy(
      type: accountType,
      companyId: companyId,
      username: username,
      password: password
    )?
      // reactiveX logics goes here
      .subscribe {
        switch $0 {
        case .error(let error):
          fatalError("Failed to get account list by device ID: \(error.localizedDescription)")
        case .next(let data):
          self.processServerResponseForAccount(data)
        case .completed:
          break
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  func removeAccountBy(accountId: Int) {
    AccountManager.deleteAccountBy(accountId: accountId)?
      // reactiveX logics goes here
      .subscribe {
        switch $0 {
        case .error(let error):
          fatalError("Failed to get account list by device ID: \(error.localizedDescription)")
        case .next(let data):
          self.processServerResponseForAccount(data)
        case .completed:
          break
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  private func processAccountInfo(_ data: Data) {
    do {
      let json = try JSON(data: data)
      let data = json["Data"].arrayValue
      self.accountInfo.accept(data.map({ (info) -> Account in
        return Account(info: info)
      }))
    } catch {
      fatalError("JSON parse error: \(error)")
    }
  }
  
  private func processServerResponseForAccount(_ data: Data) {
    do {
      let json = try JSON(data: data)
      let status = json["status"].intValue
      switch status {
      case 1: // success
        break
      case 0: // failure
        if let errorMessage = json["ErrMsg"].string {
          print("Should Alert error: \(errorMessage)")
        }
      default: // unexpected encounter
        fatalError("Unexpected encounter of result returns from register account server request")
      }
    } catch {
      fatalError("JSON parse error: \(error)")
    }
  }
}
