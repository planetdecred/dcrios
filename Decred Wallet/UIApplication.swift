//
//  UIApplication.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import UserNotifications
import SlideMenuControllerSwift

extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        
        if let slide = viewController as? SlideMenuController {
            return topViewController(slide.mainViewController)
        }
        return viewController
    }
    
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
