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
    var startTimerWhenViewAppears = true
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
        
        logo.loadGif(name: "splashLogo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // start timer to load main screen after specified interval
        if self.startTimerWhenViewAppears {
            timer = Timer.scheduledTimer(withTimeInterval: self.animationDurationSeconds, repeats: false, block: {_ in
                self.loadMainScreen()
            })
            self.startTimerWhenViewAppears = false
        }
        
        if WalletLoader.isWalletCreated {
            self.label.text = "Opening wallet..."
        }
    }
    
    @IBAction func animatedLogoTap(_ sender: Any) {
        timer?.invalidate()
        self.startTimerWhenViewAppears = true
        
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
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            let walletPassphrase = (password as NSString).data(using: String.Encoding.utf8.rawValue)!
            do {
                try SingleInstance.shared.wallet?.open(walletPassphrase)
                Utils.runInMainThread {
                    NavigationMenuViewController.setupMenuAndLaunchApp()
                }
            } catch let error {
                Utils.runInMainThread {
                    this.showOkAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    static func instantiate() -> Self {
        return Storyboards.Main.instantiateViewController(for: self)
    }
}
