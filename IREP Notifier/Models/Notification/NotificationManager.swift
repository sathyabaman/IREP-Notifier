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

class NotificationManager: NSObject {
  static let shared = NotificationManager()
  
  private(set) var fcmToken: String
  private(set) var messages: [MessagingRemoteMessage]
  
  private override init() {
    self.fcmToken = ""
    self.messages = [MessagingRemoteMessage]()
    super.init()
    Messaging.messaging().delegate = self
  }
  
  func getNotificationsByDeviceID() -> Observable<Data>? {
    let path = "\(BASE_URL)/api/Notification/GetNotificationByDeviceID"
    guard let url = URL(string: path) else { return nil }
    return Observable.create { (observable) -> Disposable in
      Alamofire.request(
        url,
        method: .post,
        parameters: [
          "FcmID": self.fcmToken,
          "Imei": "356904080702361"
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
  
  func updateReadNotificationStatusByID(id: String) -> Observable<Data>? {
    let path = "\(BASE_URL)/api/Notification/UpdateReadNotificationStatusByID"
    guard let url = URL(string: path) else { return nil }
    return Observable.create { (observable) -> Disposable in
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
  }
  
}

extension NotificationManager: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    self.fcmToken = fcmToken
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("Getting message: \(remoteMessage.messageID)")
    self.messages.append(remoteMessage)
  }
}
