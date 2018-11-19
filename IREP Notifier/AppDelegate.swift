//
//  AppDelegate.swift
//  IREP Notifier
//
//  Created by Chin Wee Kerk on 27/10/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import IQKeyboardManagerSwift
import SideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  private(set) var fcmToken: String? = nil
  private(set) var messages = [MessagingRemoteMessage]()
  var window: UIWindow?
  weak var fcmNotifierDelegate: FcmNotifierDelegate?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [
      UIApplication.LaunchOptionsKey: Any
    ]?
  ) -> Bool {
    FirebaseApp.configure()
    application.registerForRemoteNotifications()
    self.configUserNotificationSettingsFor(application)
    IQKeyboardManager.shared.enable = true
    Messaging.messaging().delegate = self
    SideMenuManager.default.menuFadeStatusBar = false
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
  private func configUserNotificationSettingsFor(_ application: UIApplication) {
    if #available(iOS 10, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in}
      )
    } else {
      let settings: UIUserNotificationSettings = UIUserNotificationSettings(
        types: [.alert, .badge, .sound],
        categories: nil
      )
      application.registerUserNotificationSettings(settings)
    }
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String
  ) {
    print("Getting FCM token: \(fcmToken)")
    self.fcmToken = fcmToken
    self.fcmNotifierDelegate?.receivedFcmToken()
  }
  
  func messaging(
    _ messaging: Messaging,
    didReceive remoteMessage: MessagingRemoteMessage
  ) {
    print("Getting message: \(remoteMessage.messageID)")
    self.messages.append(remoteMessage)
  }
}
