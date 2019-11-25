//
//  NotificationsManager.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import UserNotifications

enum NotificationCategory: String, CaseIterable {
    case syncInProgressNotification
}

class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    static let shared = NotificationsManager()
    let authorizationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    let presentationOptions: UNNotificationPresentationOptions = [.alert]

    override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: authorizationOptions) { didAllow, error in
                print("user authorized notifications: \(didAllow)")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(presentationOptions)
    }

    func fireSyncInProgressNotification(with message: String) {
        notificationCenter.getDeliveredNotifications { notifications in
            let backgroundSyncNotification = notifications.filter{$0.request.identifier == NotificationCategory.syncInProgressNotification.rawValue}

            guard !backgroundSyncNotification.isEmpty else {
                // No background sync notification has been fired
                self.postBackgroundSyncNotificationRequest(message: message)
                return
            }

            // We can update the content in the notification center when the screen is locked
            DispatchQueue.main.async {
                guard UIApplication.shared.isProtectedDataAvailable == false else {return}
                self.postBackgroundSyncNotificationRequest(message: message)
            }
        }
    }

    func removeSyncInProgressNotification() {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [NotificationCategory.syncInProgressNotification.rawValue])
    }
    
    fileprivate func postBackgroundSyncNotificationRequest(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Sync in Progress...."
        content.body = message
        content.categoryIdentifier = NotificationCategory.syncInProgressNotification.rawValue
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = NotificationCategory.syncInProgressNotification.rawValue
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        DispatchQueue.main.async {
            self.notificationCenter.add( request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
    }
}
