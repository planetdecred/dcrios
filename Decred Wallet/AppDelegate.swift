//
//  AppDelegate.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import CoreData
import Dcrlibwallet
import UserNotifications

protocol AppLifeCycleDelegate {
    func applicationEnteredForegroundFromSuspendedState(_ lastActiveTime: Date)
    func applicationWillEnterBackground()
    func applicationWillTerminate()
    func networkChanged(_ connection: Reachability.Connection)
}

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
    var lifeCycleDelegates = [String : AppLifeCycleDelegate]()
    
    var reachability: Reachability!
    
    var lastActiveTimestamp: Double?
    var shouldTrackLastActiveTime: Bool = false
    static var appUpTime: Double?
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class var compileDate: Date {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date {
            return infoDate
        }
        
        return Date()
    }
    
    func registerLifeCylceDelegate(_ delegate: AppLifeCycleDelegate, for identifier: String) {
        self.lifeCycleDelegates[identifier] = delegate
    }
    
    func deRegisterLifeCylceDelegate(for identifier: String) {
        self.lifeCycleDelegates.removeValue(forKey: identifier)
    }
    
    func listenForNetworkChanges() {
        if self.reachability != nil {
            self.reachability.stopNotifier()
        }
        
        self.reachability = Reachability()!
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkChanged(_:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            DcrlibwalletLogT("network error:", "Unable to start network change notifier.")
            print("Unable to start network change notifier.")
        }
    }
    
    @objc func networkChanged(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        print("network changed to \(reachability.connection)")
        SyncManager.shared.networkChanged(reachability.connection)
    }
    
    func updateLastActiveTime() {
        // This method may be triggered immediately the app returns to foreground when `self.shouldTrackLastActiveTime == true`.
        // Wait 2 seconds so that the `applicationWillEnterForeground` method is able set `self.shouldTrackLastActiveTime = false` before proceeding.
        sleep(2)
        
        if self.shouldTrackLastActiveTime {
            self.lastActiveTimestamp = Date().timeIntervalSince1970
            // update last active time after 28 seconds
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 28, execute: self.updateLastActiveTime)
        }
    }
    
    func setAndDisplayRootViewController(_ vc: UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    func topViewController() -> UIViewController? {
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while let vc = topVC?.presentedViewController {
            topVC = vc
        }
        return topVC
    }
    
    func showOkAlert(message: String, title: String? = nil, onPressOk: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default) { _ in
            alert.dismiss(animated: true, completion: onPressOk)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
}

extension AppDelegate: UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if CommandLine.arguments.contains("--UITests") {
            UIView.setAnimationsEnabled(false)
        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(
        UIApplication.backgroundFetchIntervalMinimum)
        
        AppDelegate.appUpTime = Date().timeIntervalSince1970
        
        NotificationsManager.shared.requestAuthorization()
        self.listenForNetworkChanges()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard {
            // disallow use of custom keyboards
            return false
        }
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if WalletLoader.shared.isInitialized {
            SyncManager.shared.applicationWillEnterBackground()
            self.shouldTrackLastActiveTime = true
            self.updateLastActiveTime()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.shouldTrackLastActiveTime = false
        
        // `self.lastActiveTimestamp` is the last time this app executed code.
        // If the app was suspended by the OS, `self.lastActiveTimestamp` time would not be recent.
        if self.lastActiveTimestamp != nil {
            let lastActiveTime = Date.init(timeIntervalSince1970: self.lastActiveTimestamp!)
            self.lastActiveTimestamp = nil
            
            // Notify life cycle delegates if app was last active (i.e. suspended) 10 or more seconds ago.
            if Date().timeIntervalSince(lastActiveTime) > 10 {
                if WalletLoader.shared.isInitialized {
                    SyncManager.shared.applicationEnteredForegroundFromSuspendedState(lastActiveTime)
                }
            }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if WalletLoader.shared.isInitialized {
            if SyncManager.shared.isSyncing || SyncManager.shared.isSynced {
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        } else {
            completionHandler(.noData)
        }
    }
    
    func applicationWillTerminate(_: UIApplication) {
        self.reachability.stopNotifier()
        if WalletLoader.shared.isInitialized {
            SyncManager.shared.applicationWillTerminate()
            WalletLoader.shared.multiWallet.shutdown()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func handlerNotification(response: UNNotificationResponse) {
        guard let data = response.notification.request.content.userInfo as? [String: String] else { return }
        if let navigation = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, navigation.viewControllers.count > 0 {
            let storyboard = UIStoryboard(name: "Politeia", bundle: nil)
            if let politeiaVC = storyboard.instantiateViewController(withIdentifier: "PoliteiaDetailController") as? PoliteiaDetailController {
                politeiaVC.isNotificationOpen = true
                politeiaVC.proposalId = data["proposalId"]
                navigation.pushViewController(politeiaVC, animated: true)
            }
        } else {
            print("Not found Root Viewcontroller")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.handlerNotification(response: response)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
