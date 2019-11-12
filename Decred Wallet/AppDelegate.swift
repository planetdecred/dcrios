//
//  AppDelegate.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import CoreData
import Dcrlibwallet
import SlideMenuControllerSwift
import UserNotifications

// compile-time preprocessor, following code will only be added if compiling for testnet
#if IsTestnet
import Fabric
import Crashlytics
#endif

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
    
    static var walletLoader: WalletLoader = WalletLoader()
    
    var lastActiveTimestamp: Double?
    var shouldTrackLastActiveTime: Bool = false
    
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
            print("Unable to start network change notifier.")
        }
    }
    
    @objc func networkChanged(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        print("network changed to \(reachability.connection)")
        self.lifeCycleDelegates.values.forEach({ $0.networkChanged(reachability.connection) })
    }
    
    func updateLastActiveTime() {
        // This method may be triggered immediately the app returns to foreground when `self.shouldTrackLastActiveTime == true`.
        // Wait 2 seconds so that the `applicationWillEnterForeground` method is able set `self.shouldTrackLastActiveTime = false` before proceeding.
        sleep(2)
        
        if self.shouldTrackLastActiveTime {
            self.lastActiveTimestamp = Date().timeIntervalSince1970
            // update last active time after 10 seconds
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10, execute: self.updateLastActiveTime)
        }
    }
    
    func setAndDisplayRootViewController(_ vc: UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    func showOkAlert(message: String, title: String? = nil, onPressOk: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default) { _ in
            alert.dismiss(animated: true, completion: onPressOk)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension AppDelegate: UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // compile-time preprocessor, following code will only be added if compiling for testnet
        #if IsTestnet
        Fabric.with([Crashlytics.self])
        print("crashlytics set up on testnet")
        #endif
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge , .sound]) { (granted, error) in
            print("user authorized notifications: \(granted)")
        }
        
        self.listenForNetworkChanges()
        
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
        lifeCycleDelegates.forEach {$0.value.applicationWillEnterBackground()}
        self.shouldTrackLastActiveTime = true
        self.updateLastActiveTime()
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
                self.lifeCycleDelegates.values.forEach({ $0.applicationEnteredForegroundFromSuspendedState(lastActiveTime) })
            }
        }
    }
    
    func applicationWillTerminate(_: UIApplication) {
        lifeCycleDelegates.forEach {$0.value.applicationWillTerminate()}
        self.reachability.stopNotifier()
        AppDelegate.walletLoader.wallet?.shutdown()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // handle notification display when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping
        (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}
