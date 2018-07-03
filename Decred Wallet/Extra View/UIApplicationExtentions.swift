//  UIApplicationExtentions.swift
//  Decred Wallet
//  Created by rails on 03/07/18.
//  Copyright © 2018 The Decred developers. All rights reserved.

import Foundation
import UIKit
import UserNotifications

public extension UIApplication {
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(
                options: [.badge, .alert, .sound]) { [weak self] granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        self?.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            let type: UIUserNotificationType = [
                UIUserNotificationType.badge,
                UIUserNotificationType.alert,
                UIUserNotificationType.sound,
            ]

            let setting = UIUserNotificationSettings(
                types: type,
                categories: nil
            )

            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
