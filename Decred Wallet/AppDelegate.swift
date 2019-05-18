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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static var walletLoader: WalletLoader = WalletLoader()
    
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
        
        return true
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard {
            // disallow use of custom keyboards
            return false
        }
        return true
    }
    
    func applicationWillTerminate(_: UIApplication) {
        AppDelegate.walletLoader.wallet?.shutdown(true)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // handle notification display when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping
        (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}

extension AppDelegate {
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
    
    func setAndDisplayRootViewController(_ vc: UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    func showOkAlert(message: String, title: String? = nil, onPressOk: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: onPressOk)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
