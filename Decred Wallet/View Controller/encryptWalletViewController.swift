//
//  encryptWalletViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 05/04/2018.
//  Copyright © 2018 Macsleven. All rights reserved.
//

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
        
        UINavigationBar.appearance().tintColor = UIColor(hex: "689F38")
        
        leftViewController.mainViewController = nvc
        
        let slideMenuController = ExSlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
        //     slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        appDelegate.window?.rootViewController = slideMenuController
        appDelegate.window?.makeKeyAndVisible()
        
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "walletCreated")
        UserDefaults.standard.synchronize()
    }
}
