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
    let disposable = self.accountInfo
      .asObservable()
      .bind(to: accountTable.rx.items(
        cellIdentifier: AccountTableViewCell.identifier,
        cellType: AccountTableViewCell.self
      )) {(row, account, cell) in
        cell.categoryLabel.text = account.category
        cell.nameLabel.text = account.name
    }
    disposable.disposed(by: self.disposeBag)
  }
  
  func fetchAccountInfo() {
    let disposable = AccountManager.getAccountListBDeviceID()?.subscribe {
      switch $0 {
      case .error(let error):
        fatalError("Failed to get account list by device ID: \(error.localizedDescription)")
      case .next(let data):
        self.processAccountInfo(data)
      case .completed:
        break
      }
    }
    disposable?.disposed(by: self.disposeBag)
  }
  
  private func processAccountInfo(_ data: Data) {
    do {
      let json = try JSON(data: data)
      let data = json["Data"].arrayValue
      self.accountInfo.accept(data.map({ (info) -> Account in
        return Account(info: info)
      }))
    } catch {
      print("JSON parse error: \(error)")
    }
  }
}
