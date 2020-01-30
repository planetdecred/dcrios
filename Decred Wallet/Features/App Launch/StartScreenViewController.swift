//
//  StartScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2020 The Decred developers
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

        let settingsVC = SettingsController.instantiate(from: .Settings).wrapInNavigationcontroller()
        settingsVC.modalPresentationStyle = .fullScreen
        self.present(settingsVC, animated: true, completion: nil)
    }

    func loadMainScreen() {
        if !WalletLoader.shared.isInitialized {
            // there was an error initializing multiwallet
            return
        }
        
        if WalletLoader.shared.oneOrMoreWalletsExist {
            self.checkStartupSecurityAndStartApp()
        } else if DcrlibwalletWalletExistsAt("\(WalletLoader.appDataDir)/\(BuildConfig.NetType)") {
            self.checkLegacyStartupSecurityAndLinkExistingWallet()
        } else {
            self.displayWalletSetupScreen()
        }
    }
    
    func checkStartupSecurityAndStartApp() {
        if !StartupPinOrPassword.pinOrPasswordIsSet() {
            self.openWalletsAndStartApp(startupPinOrPassword: "", completion: nil)
            return
        }
        
        self.promptForStartupPinOrPassword(legacy: false) { pinOrPassword, _, completion in
            self.openWalletsAndStartApp(startupPinOrPassword: pinOrPassword, completion: completion)
        }
    }
    
    func checkLegacyStartupSecurityAndLinkExistingWallet() {
        if !StartupPinOrPassword.legacyPinOrPasswordIsSet() {
            try? WalletLoader.shared.linkExistingWalletAndStartApp(startupPinOrPassword: "")
            return
        }
        
        self.promptForStartupPinOrPassword(legacy: true) { pinOrPassword, _, completion in
            do {
                try WalletLoader.shared.linkExistingWalletAndStartApp(startupPinOrPassword: pinOrPassword)
                completion?.securityCodeProcessed()
            } catch let error {
                print("link existing wallet error: \(error.localizedDescription)")
                if error.isInvalidPassphraseError {
                    completion?.securityCodeError(errorMessage: StartupPinOrPassword.invalidSecurityCodeMessage())
                } else {
                    completion?.securityCodeError(errorMessage: error.localizedDescription)
                }
            }
        }
    }

    func promptForStartupPinOrPassword(legacy: Bool, callback: @escaping SecurityCodeRequestCallback) {
        let securityType = legacy ? StartupPinOrPassword.legacySecurityType() : StartupPinOrPassword.currentSecurityType()
        let securityTypeText = securityType == .pin ? LocalizedStrings.pin : LocalizedStrings.password.lowercased()
        let prompt = String(format: LocalizedStrings.unlockWithStartupCode, securityTypeText)
        
        Security.startup(legacy: legacy)
            .with(prompt: prompt)
            .with(submitBtnText: LocalizedStrings.unlock)
            .should(showCancelButton: false)
            .requestCurrentCode(sender: self, callback: callback)
    }

    func openWalletsAndStartApp(startupPinOrPassword: String, completion: SecurityCodeRequestCompletionDelegate?) {
        self.label.text = LocalizedStrings.openingWallet

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.openWallets(startupPinOrPassword.utf8Bits)
                DispatchQueue.main.async {
                    completion?.securityCodeProcessed()
                    NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        completion?.securityCodeError(errorMessage: StartupPinOrPassword.invalidSecurityCodeMessage())
                    } else {
                        completion?.securityCodeError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func displayWalletSetupScreen() {
        let walletSetupController = WalletSetupViewController.instantiate(from: .WalletSetup).wrapInNavigationcontroller()
        walletSetupController.isNavigationBarHidden = true
        AppDelegate.shared.setAndDisplayRootViewController(walletSetupController)
    }
}
