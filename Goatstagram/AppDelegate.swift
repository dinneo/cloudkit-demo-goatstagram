//
//  AppDelegate.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CloudKit

let SubscriptionNotification = "SubscriptionNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        registerForPushNotifications(application)
        return true
    }

    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let castedUserInfo = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: castedUserInfo)
        if notification.notificationType == .Query {
            NSNotificationCenter.defaultCenter().postNotificationName(SubscriptionNotification, object: nil, userInfo: ["subscriptionID": notification.subscriptionID!])
        }
    }
}
