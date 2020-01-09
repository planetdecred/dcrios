//
//  StartScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

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
        
        logo.loadGif(name: "splashLogo")
        
        AppDelegate.walletLoader = WalletLoader()
        let initWalletError = AppDelegate.walletLoader.initWallets()
        if initWalletError != nil {
            print("init wallet error: \(initWalletError!.localizedDescription)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // start timer to load main screen after specified interval
        if self.startTimerWhenViewAppears {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.animationDurationSeconds, repeats: false) {_ in
                self.loadMainScreen()
            }
            self.startTimerWhenViewAppears = false
        }
        
        if AppDelegate.walletLoader.oneOrMoreWalletsExist {
            self.label.text = LocalizedStrings.openingWallet
        }
    }

    @IBAction func animatedLogoTap(_ sender: Any) {
        self.timer?.invalidate()
        self.startTimerWhenViewAppears = true

        let settingsVC = SettingsController.instantiate().wrapInNavigationcontroller()
        settingsVC.modalPresentationStyle = .fullScreen
        self.present(settingsVC, animated: true, completion: nil)
    }

    func loadMainScreen() {
        if AppDelegate.walletLoader.oneOrMoreWalletsExist {
            self.checkStartupSecurityAndStartApp()
        } else if DcrlibwalletWalletExistsAt(WalletLoader.appDataDir, BuildConfig.NetType) {
            self.checkStartupSecurityAndLinkExistingWallet()
        } else {
            self.displayWalletSetupScreen()
        }
    }
    
    func checkStartupSecurityAndStartApp() {
        if StartupPinOrPassword.pinOrPasswordIsSet() {
            self.promptForStartupPinOrPassword(completion: self.openWalletsAndStartApp)
        } else {
            self.openWalletsAndStartApp(startupPinOrPassword: "", completionDelegate: nil)
        }
    }
    
    func checkStartupSecurityAndLinkExistingWallet() {
        if StartupPinOrPassword.pinOrPasswordIsSet() {
            self.promptForStartupPinOrPassword() { startupPinOrPassword, completionDelegate in
                let error = AppDelegate.walletLoader.linkExistingWalletAndStartApp(startupPinOrPassword: startupPinOrPassword)
                if error == nil {
                    completionDelegate?.securityCodeProcessed(true, nil)
                } else {
                    completionDelegate?.securityCodeProcessed(false, error!.localizedDescription)
                }
            }
        } else {
            _ = AppDelegate.walletLoader.linkExistingWalletAndStartApp(startupPinOrPassword: "")
        }
    }
    
    func promptForStartupPinOrPassword(completion: @escaping ((String, SecurityRequestCompletionDelegate?) -> Void)) {
        if StartupPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            let requestPasswordVC = RequestPasswordViewController.instantiate()
            requestPasswordVC.securityFor = LocalizedStrings.startup
            requestPasswordVC.prompt = LocalizedStrings.enterStartupPassword
            requestPasswordVC.modalPresentationStyle = .pageSheet
            requestPasswordVC.submitBtnText = LocalizedStrings.unlock
            requestPasswordVC.onUserEnteredSecurityCode = completion
            requestPasswordVC.showCancelButton = false
            self.present(requestPasswordVC, animated: true, completion: {
              requestPasswordVC.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
            })
        } else {
            let requestPinVC = RequestPinViewController.instantiate()
            requestPinVC.securityFor = LocalizedStrings.startup
            requestPinVC.modalPresentationStyle = .pageSheet
            requestPinVC.onUserEnteredSecurityCode = completion
            requestPinVC.prompt = LocalizedStrings.unlockWithStartupPIN
            requestPinVC.submitBtnText = LocalizedStrings.unlock
            requestPinVC.showCancelButton = false
            self.present(requestPinVC, animated: true, completion: {
              requestPinVC.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
            })
        }
    }
    
    func openWalletsAndStartApp(startupPinOrPassword: String, completionDelegate: SecurityRequestCompletionDelegate?) {
        self.label.text = LocalizedStrings.openingWallet
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            
            do {
                try AppDelegate.walletLoader.multiWallet.openWallets(startupPinOrPassword.utf8Bits)
                DispatchQueue.main.async {
                    completionDelegate?.securityCodeProcessed(true, nil)
                    NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
                }
            } catch let error {
                DispatchQueue.main.async {
                    var errorMessage = error.localizedDescription
                    if error.localizedDescription == DcrlibwalletErrInvalidPassphrase {
                        let securityType = StartupPinOrPassword.currentSecurityType()!.lowercased()
                        errorMessage = String(format: LocalizedStrings.incorrectSecurityInfo, securityType)
                    }
                    completionDelegate?.securityCodeProcessed(false, errorMessage)
                    
                    self.showOkAlert(message: errorMessage, title: LocalizedStrings.error)
                }
            }
        }
    }
    
    func displayWalletSetupScreen() {
        let walletSetupController = WalletSetupViewController.instantiate().wrapInNavigationcontroller()
        walletSetupController.isNavigationBarHidden = true
        AppDelegate.shared.setAndDisplayRootViewController(walletSetupController)
    }
    
    static func instantiate() -> Self {
        return Storyboards.Main.instantiateViewController(for: self)
    }
}
