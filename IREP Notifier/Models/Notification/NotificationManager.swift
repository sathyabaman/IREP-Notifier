//
//  NotificationManager.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 4/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Alamofire
import RxSwift

struct NotificationManager {
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
  
  private init() {}
}
