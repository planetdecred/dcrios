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

        let initError = WalletLoader.shared.initMultiWallet()
        if initError != nil {
            print("init multiwallet error: \(initError!.localizedDescription)")
        }

        logo.loadGif(name: "splashLogo")
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

        if WalletLoader.shared.oneOrMoreWalletsExist {
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
        if !WalletLoader.shared.initialized {
            // there was an error initializing multiwallet
            return
        }
        
        if WalletLoader.shared.oneOrMoreWalletsExist {
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
        if !StartupPinOrPassword.pinOrPasswordIsSet() {
            try? WalletLoader.shared.linkExistingWalletAndStartApp(startupPinOrPassword: "")
            return
        }
        
        self.promptForStartupPinOrPassword() { startupPinOrPassword, completionDelegate in
            do {
                try WalletLoader.shared.linkExistingWalletAndStartApp(startupPinOrPassword: startupPinOrPassword)
                completionDelegate?.securityCodeProcessed(true, nil)
            } catch let error {
                print("link existing wallet error: \(error.localizedDescription)")
                completionDelegate?.securityCodeProcessed(false, error.localizedDescription)
            }
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

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.openWallets(startupPinOrPassword.utf8Bits)
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
