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
  static func insertAccountBy(info: LoginInfo) -> Observable<ServerResult>? {
    let path = "\(BASE_URL)/api/Account/RegisterAccount"
    guard
      let url = URL(string: path),
      let delegate = UIApplication.shared.delegate as? AppDelegate,
      let fcmToken = delegate.fcmToken
    else {
        return nil
    }
    return Observable<Data>.create { (observable) -> Disposable in
      Alamofire.request(
        url,
        method: .post,
        parameters: [
          "AccountType": info.category,
          "CompanyID": info.company,
          "FcmID": fcmToken,
          "Imei": DEVICE_IMEI,
          "LoginID": info.username,
          "Password": info.password
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
    .flatMapLatest({ (data) -> Observable<ServerResult> in
      do {
        let json = try JSON(data: data)
        let status = json["status"].intValue
        let message = json["ErrMsg"].string
        let result = ServerResult(statusCode: status, statusMessage: message)
        return Observable.of(result)
      } catch {
        throw error
      }
    })
  }

  static func deleteAccountBy(accountId: Int) -> Observable<ServerResult>? {
    let path = "\(BASE_URL)/api/Account/DeleteAccountByID"
    guard let url = URL(string: path) else { return nil }
    return Observable<Data>.create { (observable) -> Disposable in
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
    .flatMapLatest({ (data) -> Observable<ServerResult> in
      do {
        let json = try JSON(data: data)
        let status = json["status"].intValue
        let message = json["ErrMsg"].string
        let result = ServerResult(statusCode: status, statusMessage: message)
        return Observable.of(result)
      } catch {
        throw error
      }
    })
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
  
  private init() {}
}
