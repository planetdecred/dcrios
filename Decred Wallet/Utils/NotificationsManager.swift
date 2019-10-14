//
//  NotificationsManager.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UserNotifications

enum NotificationCategory: String, CaseIterable {
    case syncInProgressNotification
}

class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    static let shared = NotificationsManager()
    let authorizationOptions: UNAuthorizationOptions = [.alert]
    let presentationOptions: UNNotificationPresentationOptions = [.alert]

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: authorizationOptions) { didAllow, error in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(presentationOptions)
    }

    func fireSyncInProgressNotification(with message: String) {
        let content = UNMutableNotificationContent()
//        let categoryIdentifire = "Delete Notification Type"

        content.title = "Sync in Progress...."
        content.body = message
        content.categoryIdentifier = NotificationCategory.syncInProgressNotification.rawValue
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = NotificationCategory.syncInProgressNotification.rawValue
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

    func removeSyncInprogressNotification() {
         notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationCategory.syncInProgressNotification.rawValue])
    }
}
