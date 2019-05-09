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
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // setup crash reporting for testnet build only
        if GlobalConstants.App.IsTestnet {
            Fabric.with([Crashlytics.self])
        }
        
        self.showAnimatedStartScreen()
        
        // request permission to display notifications in background while app is launched
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge , .sound]){ (granted, error) in
                print("user authorized notifications: \(granted)")
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard {
            return false
        }
        return true
    }
    
    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if (SingleInstance.shared.wallet != nil){
            UserDefaults.standard.set(false, forKey: "walletScanning")
            UserDefaults.standard.set(false, forKey: "synced")
            UserDefaults.standard.set(0, forKey: "peercount")
            UserDefaults.standard.synchronize()
            SingleInstance.shared.wallet?.shutdown()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping
        (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}

extension AppDelegate {
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func showAnimatedStartScreen() {
        let startScreenController = Storyboards.Main.instantiateViewController(vc: StartScreenViewController.self)
        
        let navigationVC = UINavigationController(rootViewController: startScreenController)
        UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
        navigationVC.navigationBar.isHidden = true
        
        self.window?.rootViewController = navigationVC
        self.window?.makeKeyAndVisible()
    }
    
    func setAndDisplayRootViewController(_ vc: UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
}
