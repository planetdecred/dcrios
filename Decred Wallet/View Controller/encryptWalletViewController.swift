//
//  encryptWalletViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit
class encryptWalletViewController : UIViewController {

//MARK: Life Cycle
override func viewDidLoad() {
    super.viewDidLoad()
    UserDefaults.standard.set(true, forKey: "walletCreated")
    UserDefaults.standard.synchronize()
    }
    @IBAction func openwallet(_ sender: Any) {
        createMenuView()
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
        
        let slideMenuController = ExSlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
        //     slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.backgroundColor = GlobalConstants.Colors.lightGrey
        appDelegate.window?.rootViewController = slideMenuController
        appDelegate.window?.makeKeyAndVisible()
        
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "walletCreated")
        UserDefaults.standard.synchronize()
    }
}
