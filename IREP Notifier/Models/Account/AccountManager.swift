//
//  AccountManagementModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Alamofire
import RxSwift

struct AccountManager {
  static func getAccountListBDeviceID() -> Observable<Data>? {
    let path = "\(BASE_URL)/api/Account/GetAccountListByDeviceID"
    guard let url = URL(string: path) else { return nil }
    return Observable.create { (observable) -> Disposable in
      Alamofire.request(
        url,
        method: .post,
        parameters: ["imei": "356904080702361"],
        encoding: JSONEncoding(),
        headers: nil
      ).responseJSON(
        queue: DispatchQueue.global(),
        options: JSONSerialization.ReadingOptions.mutableContainers
      ) { (response) in
        switch (response.data, response.error) {
          case (_, .some(let error)):
            observable.onError(error)
          case (.some(let data), _):
            observable.onNext(data)
            observable.onCompleted()
          default:
            break
        }
      }
      return Disposables.create {
        // do anything needed when clean up.
      }
    }
  }
  
  static func registerAccount(account: Account, password: String) -> Observable<Data>? {
    let path = "\(BASE_URL)/api/Account/RegisterAccount"
    guard let url = URL(string: path) else { return nil }
    return Observable.create { (observable) -> Disposable in
      Alamofire.request(
        url,
        method: .post,
        parameters: [
          "AccountType": account.id.description,
          "CompanyID": account.name, // WRONG ...
          "FcmID": NotificationManager.shared.fcmToken,
          "Imei": "356904080702361",
          "LoginID": account.loginID,
          "Password": password
        ],
        encoding: JSONEncoding(),
        headers: nil
      ).responseJSON(
        queue: DispatchQueue.global(),
        options: JSONSerialization.ReadingOptions.mutableContainers
      ) { (response) in
        switch (response.data, response.error) {
          case (_, .some(let error)):
            observable.onError(error)
          case (.some(let data), _):
            observable.onNext(data)
            observable.onCompleted()
          default:
            break
        }
      }
      return Disposables.create {
        // do anything needed when clean up.
      }
    }
  }
  
  private init() {}
}
