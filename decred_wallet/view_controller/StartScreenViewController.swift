//
//  StartScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class StartScreenViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var testnetLabel: UILabel!
    
    var timer: Timer?
    let animationDurationSeconds: Double = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GlobalConstants.App.IsTestnet {
            testnetLabel.isHidden = false
        }
        
        let initWalletError = WalletLoader.initialize()
        if initWalletError != nil {
            print("init wallet error: \(initWalletError!.localizedDescription)")
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logo.loadGif(name: "splashLogo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // start timer to load main screen after specified interval
        timer = Timer.scheduledTimer(withTimeInterval: self.animationDurationSeconds, repeats: false, block: {_ in
            self.loadMainScreen()
        })
        
        if WalletLoader.isWalletCreated {
            self.label.text = "Opening wallet..."
        }
    }
    
    @IBAction func animatedLogoTap(_ sender: Any) {
        // stop timer, will be restarted after settings page is closed and this page re-appears
        timer?.invalidate()
        
        let settingsVC = Storyboards.Main.instantiateViewController(vc: SettingsController.self)
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func loadMainScreen() {
        if !WalletLoader.isWalletCreated {
            self.displayWalletSetupScreen()
        }
        else if StartupPinOrPassword.pinOrPasswordIsSet() {
            self.openSecuredWallet()
        } else {
            self.openUnSecuredWallet()
        }
    }
    
    func displayWalletSetupScreen() {
        DispatchQueue.main.async{
            let walletSetupController = Storyboards.WalletSetup.instantiateViewController(vc: WalletSetupViewController.self)
            let navigationController = UINavigationController(rootViewController: walletSetupController)
            navigationController.isNavigationBarHidden = true
            AppDelegate.shared.setAndDisplayRootViewController(navigationController)
        }
    }
    
    func openSecuredWallet() {
        if StartupPinOrPassword.currentSecurityType() == "PASSWORD" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let requestPasswordVC = storyboard.instantiateViewController(withIdentifier: "RequestPasswordViewController") as! RequestPasswordViewController
            requestPasswordVC.prompt = "Enter Startup Password"
            requestPasswordVC.openWalletOnEnterPassword = true
            AppDelegate.shared.setAndDisplayRootViewController(requestPasswordVC)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let requestPinVC = storyboard.instantiateViewController(withIdentifier: "RequestPinViewController") as! RequestPinViewController
            requestPinVC.securityFor = "Startup"
            requestPinVC.openWalletOnEnterPin = true
            AppDelegate.shared.setAndDisplayRootViewController(requestPinVC)
        }
    }
    
    func openUnSecuredWallet() {
        let key = "public"
        let finalkey = key as NSString
        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
        do {
            ((try SingleInstance.shared.wallet?.open(finalkeyData)))
        } catch let error {
            print(error)
        }
        
        self.createMenuView()
    }
    
    func createMenuView() {
        DispatchQueue.main.async{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "OverviewViewController") as! OverviewViewController
            
            let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
            mainViewController.delegate = leftViewController
            
            let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
            
            UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
            
            leftViewController.mainViewController = nvc
            
            let window = AppDelegate.shared.window
            let slideMenuController = ExSlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
            slideMenuController.changeLeftViewWidth((window?.frame.size.width)! - (window?.frame.size.width)! / 6)
            
            slideMenuController.delegate = mainViewController
            window?.backgroundColor = GlobalConstants.Colors.lightGrey
            window?.rootViewController = slideMenuController
            window?.makeKeyAndVisible()
        }
    }
}
