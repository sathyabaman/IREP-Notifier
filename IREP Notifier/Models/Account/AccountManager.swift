//
//  AccountManagementModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 29/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Alamofire
import RxSwift
import SwiftyJSON

struct AccountManager {
  static func registerAccountBy(
    type: Int,
    companyId: String,
    username: String,
    password: String
  ) -> Observable<Data>? {
    let path = "\(BASE_URL)/api/Account/RegisterAccount"
    guard
      let url = URL(string: path),
      let delegate = UIApplication.shared.delegate as? AppDelegate,
      let fcmToken = delegate.fcmToken
      else {
        return nil
    }
    return Observable.create { (observable) -> Disposable in
      Alamofire.request(
        url,
        method: .post,
        parameters: [
          "AccountType": type,
          "CompanyID": companyId,
          "FcmID": fcmToken,
          "Imei": DEVICE_IMEI,
          "LoginID": username,
          "Password": password
        ],
        encoding: JSONEncoding(),
        headers: nil
      )
      .responseJSON(
        queue: DispatchQueue.global(),
        options: JSONSerialization.ReadingOptions.mutableContainers
      ) { (response) in
        switch (response.data, response.error) {
          case (_, .some(let error)):
            observable.onError(error)
          case (.some(let data), _):
            // data return 1 when succeed
            // data return 0 when failed
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

  static func deleteAccountBy(accountId: Int) -> Observable<Data>? {
    let path = "\(BASE_URL)/api/Account/DeleteAccountByID"
    guard let url = URL(string: path) else { return nil }
    return Observable.create { (observable) -> Disposable in
      Alamofire.request(
        url,
        method: .post,
        parameters: ["ID": accountId],
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
  
  static func getAccountListByDeviceId() -> Observable<[Account]>? {
    let path = "\(BASE_URL)/api/Account/GetAccountListByDeviceID"
    guard let url = URL(string: path) else { return nil }
    return Observable<Data>.create { (observable) -> Disposable in
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
  }
}
