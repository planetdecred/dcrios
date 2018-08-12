//  AppDelegate.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import CoreData
import SlideMenuControllerSwift
import IQKeyboardManager
import Mobilewallet

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigation : UINavigationController?
    
    fileprivate func walletSetupView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let walletSetupController = storyboard.instantiateViewController(withIdentifier: "WalletSetupViewController") as! WalletSetupViewController
        let nv = UINavigationController(rootViewController: walletSetupController)
        nv.isNavigationBarHidden = true
        window?.rootViewController = nv
        window?.makeKeyAndVisible()
    }

    fileprivate func createMenuView() {
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "OverviewViewController") as! OverviewViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        let rightViewController = storyboard.instantiateViewController(withIdentifier: "RightViewController") as! RightViewController

        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)

        UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor

        leftViewController.mainViewController = nvc

        let slideMenuController = ExSlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
        slideMenuController.changeLeftViewWidth((window?.frame.size.width)! - (window?.frame.size.width)! / 6)

        slideMenuController.delegate = mainViewController
        window?.backgroundColor = GlobalConstants.Colors.lightGrey
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()
    }

    fileprivate func populateFirstScreen() {
        if isWalletCreated() {
            createMenuView()
        } else {
            walletSetupView()
        }
    }

    fileprivate func showAnimatedStartScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startScreenController = storyboard.instantiateViewController(withIdentifier:"WaiterScreenViewController") as! WaiterScreenViewController
        
        startScreenController.onFinish = {self.populateFirstScreen()}
        startScreenController.onTapAnimation = {self.gotoSetting()}
        self.navigation = UINavigationController(rootViewController: startScreenController)
        UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
        self.navigation?.navigationBar.isHidden = true
        self.window?.rootViewController = self.navigation
        self.window?.makeKeyAndVisible()
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        showAnimatedStartScreen()
        UserDefaults.standard.setValuesForKeys(["pref_user_name" : "dcrwallet",
                                                "pref_user_passwd":"dcrwallet",
                                                "pref_server_ip": "192.168.43.68"])
        AppContext.instance.decrdConnection = DcrdConnection()
        AppContext.instance.decrdConnection?.initiateWallet()
        
        IQKeyboardManager.shared().isEnabled = true
        
        return true
    }

    fileprivate func gotoSetting() {
        let vcSetting = GlobalConstants.ConstantStoryboardMain.getControllerInstance(identifier: "SettingsController2", storyBoard: GlobalConstants.ConstantStoryboardMain.IDENTIFIER_STORYBOARD_MAIN) as! SettingsController
        vcSetting.isFromLoader = true
        
        self.navigation?.pushViewController(vcSetting, animated: true)
    }
    
    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
