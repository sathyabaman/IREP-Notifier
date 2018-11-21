//
//  NotificationManager.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 4/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Alamofire
import Firebase
import RxSwift
import SwiftyJSON

struct NotificationManager {
  func getNotificationsByDeviceId() -> Observable<[NotificationGroup]>? {
    let path = "\(BASE_URL)/api/Notification/GetNotificationByDeviceID"
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
        parameters: ["FcmID": fcmToken, "Imei": "356904080702361"],
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
    .flatMapLatest({ (data) -> Observable<[NotificationGroup]> in
      do {
        let json = try JSON(data: data)
        let data = json["Data"].arrayValue
        return Observable.of(data.map { (json) -> NotificationGroup in
          return NotificationGroup(
            accountTypeId: json["AccountTypeID"].intValue,
            title: json["Name"].stringValue,
            items: json["FCMNotificationMsgList"].arrayValue.map(
              { (itemInfo) -> Notification in
                return Notification(info: itemInfo)
              }
            )
          )
        })
      } catch {
        throw error
      }
    })
  }
  
  func updateReadNotificationStatusById(id: String) -> Observable<Bool>? {
    let path = "\(BASE_URL)/api/Notification/UpdateReadNotificationStatusByID"
    guard let url = URL(string: path) else { return nil }
    return Observable<Data>.create { (observable) -> Disposable in
      Alamofire.request(
        url,
        method: .post,
        parameters: ["ID": id],
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
    .flatMapLatest({ (data) -> Observable<Bool> in
      do {
        let json = try JSON(data: data)
        let status = json["Data"]["Status"].intValue
        return Observable.of(status == 1)
      } catch {
        throw error
      }
    })
  }
}
