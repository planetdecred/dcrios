//
//  StartScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import SlideMenuControllerSwift

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
        
        let settingsVC = SettingsController.instantiate().wrapInNavigationcontroller()
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func loadMainScreen() {
        if !WalletLoader.isWalletCreated {
            self.displayWalletSetupScreen()
        }
        else if StartupPinOrPassword.pinOrPasswordIsSet() {
            self.promptForStartupPinOrPassword()
        } else {
            self.unlockWalletAndStartApp(password: "public") // unlock wallet using default public passphrase
        }
    }
    
    func displayWalletSetupScreen() {
        let walletSetupController = WalletSetupViewController.instantiate().wrapInNavigationcontroller()
        walletSetupController.isNavigationBarHidden = true
        AppDelegate.shared.setAndDisplayRootViewController(walletSetupController)
    }
    
    func promptForStartupPinOrPassword() {
        if StartupPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            let requestPasswordVC = RequestPasswordViewController.instantiate()
            requestPasswordVC.prompt = "Enter Startup Password"
            requestPasswordVC.onUserEnteredPassword = self.unlockWalletAndStartApp
            self.present(requestPasswordVC, animated: true, completion: nil)
        }
        else {
            let requestPinVC = RequestPinViewController.instantiate()
            requestPinVC.securityFor = "Startup"
            requestPinVC.onUserEnteredPin = self.unlockWalletAndStartApp
            self.present(requestPinVC, animated: true, completion: nil)
        }
    }
    
    func unlockWalletAndStartApp(password: String) {
        self.label.text = "Opening wallet..."
        
        let walletPassphrase = (password as NSString).data(using: String.Encoding.utf8.rawValue)!
        do {
            try SingleInstance.shared.wallet?.open(walletPassphrase)
            self.createMenuView()
        } catch let error {
            self.showOkAlert(message: error.localizedDescription, title: "Error")
        }
    }
    
    func createMenuView() {
        let mainViewController = Storyboards.Main.instantiateViewController(for: OverviewViewController.self)
        
        let leftViewController = LeftViewController.instantiate()
        mainViewController.delegate = leftViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        
        UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
        
        leftViewController.mainViewController = nvc
        
        let window = AppDelegate.shared.window
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        slideMenuController.changeLeftViewWidth((window?.frame.size.width)! - (window?.frame.size.width)! / 6)
        
        slideMenuController.delegate = mainViewController
        window?.backgroundColor = GlobalConstants.Colors.lightGrey
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()
    }
    
    static func instantiate() -> Self {
        return Storyboards.Main.instantiateViewController(for: self)
    }
}
