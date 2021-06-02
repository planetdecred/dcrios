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
    case newProposal
    case voteProposalFinish
    case voteProposalStarted
}

extension NotificationCategory: CustomStringConvertible {
    var description: String {
        switch self {
        case .syncInProgressNotification:
            return "Sync in Progress...."
        case .newProposal:
            return "New Proposal"
        case .voteProposalStarted:
            return "Vote Started"
        case .voteProposalFinish:
            return "Vote Finished"
        }
    }
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
    
    func proposalNotification(category: NotificationCategory, message: String, proposalId: Int?) {
        let content = UNMutableNotificationContent()
        content.title = category.description
        content.body = message
        content.categoryIdentifier = category.rawValue
        if let idProposal = proposalId {
            content.userInfo = [GlobalConstants.Strings.PROPOSAL_ID: "\(idProposal)"]
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let identifier = category.rawValue
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        DispatchQueue.main.async {
            self.notificationCenter.add( request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
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
