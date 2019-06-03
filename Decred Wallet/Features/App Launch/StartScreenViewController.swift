//
//  StartScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
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
        
        if BuildConfig.IsTestNet {
            testnetLabel.isHidden = false
        }
        
        AppDelegate.walletLoader = WalletLoader()
        let initWalletError = AppDelegate.walletLoader.initWallet()
        if initWalletError != nil {
            print("init wallet error: \(initWalletError!.localizedDescription)")
        }
        
        logo.loadGif(name: "splashLogo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // start timer to load main screen after specified interval
        if self.startTimerWhenViewAppears {
            timer = Timer.scheduledTimer(withTimeInterval: self.animationDurationSeconds, repeats: false) {_ in
                self.loadMainScreen()
            }
            self.startTimerWhenViewAppears = false
        }
        
        if AppDelegate.walletLoader.isWalletCreated {
            self.label.text = "Opening wallet..."
        }
    }
    
    func loadMainScreen() {
        if !AppDelegate.walletLoader.isWalletCreated {
            self.displayWalletSetupScreen()
        }
        else if StartupPinOrPassword.pinOrPasswordIsSet() {
            self.promptForStartupPinOrPassword()
        } else {
            self.unlockWalletAndStartApp(pinOrPassword: "public") // unlock wallet using default public passphrase
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
    
    func unlockWalletAndStartApp(pinOrPassword: String) {
        self.label.text = "Opening wallet..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try AppDelegate.walletLoader.wallet?.open(pinOrPassword.utf8Bits)
                DispatchQueue.main.async {
                    NavigationMenuViewController.setupMenuAndLaunchApp(isNewWallet: false)
                }
            } catch let error {
                DispatchQueue.main.async {
                    var errorMessage = error.localizedDescription
                    if error.localizedDescription == DcrlibwalletErrInvalidPassphrase {
                        let securityType = StartupPinOrPassword.currentSecurityType()!.lowercased()
                        errorMessage = "You entered an incorrect \(securityType). Try again?"
                    }
                    this.showOkAlert(message: errorMessage, title: "Error", okText: "Retry", onPressOk: this.promptForStartupPinOrPassword)
                }
            }
        }
    }
    
    static func instantiate() -> Self {
        return Storyboards.Main.instantiateViewController(for: self)
    }
}
