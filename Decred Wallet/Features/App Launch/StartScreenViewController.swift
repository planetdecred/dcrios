//
//  StartScreenViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class StartScreenViewController: UIViewController, CAAnimationDelegate {
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var createWalletBtn: Button!
    @IBOutlet weak var restoreWalletBtn: Button!
    @IBOutlet weak var testnetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if BuildConfig.IsTestNet {
            testnetLabel.isHidden = false
        }

        let initError = WalletLoader.shared.initMultiWallet()
        if initError != nil {
            print("init multiwallet error: \(initError!.localizedDescription)")
        }
        
        if WalletLoader.shared.oneOrMoreWalletsExist {
            self.loadingLabel.text = LocalizedStrings.openingWallet
        }
        
        self.startAnim()
        
    }
    
    func startAnim(done: (() -> Void)? = nil) {
        let splashLogo = UIImage.gif(name: "splashLogo")
        
        // CAKeyframeAnimation.values are expected to be CGImageRef,
        // so we take the values from the UIImage images
        var values = [CGImage]()
        for image in splashLogo!.images! {
            values.append(image.cgImage!)
        }

        // Create animation and set SwiftGif values and duration
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = CAAnimationCalculationMode.discrete
        animation.duration = splashLogo!.duration
        animation.values = values
        // Set the repeat count
        animation.repeatCount = 3
        // Other stuff
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        // Set the delegate
        animation.delegate = self
        self.logo.layer.add(animation, forKey: "animation")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
     func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.loadMainScreen()
        }
    }

    @IBAction func animatedLogoTap(_ sender: Any) {
        let settingsVC = SettingsController.instantiate(from: .Settings).wrapInNavigationcontroller()
        settingsVC.modalPresentationStyle = .fullScreen
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    @IBAction func createNewwallet(_ sender: Any) {
        Security.spending(initialSecurityType: .password)
            .requestNewCode(sender: self, isChangeAttempt: false) { pinOrPassword, type, completion in
                
                WalletLoader.shared.createWallet(spendingPinOrPassword: pinOrPassword, securityType: type) {
                    createWalletError in
                    
                    if createWalletError != nil {
                        completion?.displayError(errorMessage: createWalletError!.localizedDescription)
                    } else {
                        completion?.dismissDialog()
                        NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: true)
                    }
                }
        }
    }
    @IBAction func restoreExistingWallet(_ sender: Any) {
        print("restore")
        let restoreWalletVC = RestoreExistingWalletViewController.instantiate(from: .WalletSetup)
        self.navigationController?.pushViewController(restoreWalletVC, animated: true)
    }
    
    func loadMainScreen() {
        if !WalletLoader.shared.isInitialized {
            print("can't init")
            // there was an error initializing multiwallet
            return
        }
        
        if WalletLoader.shared.oneOrMoreWalletsExist {
            self.checkStartupSecurityAndStartApp()
        } else if SingleToMultiWalletMigration.migrationNeeded {
            SingleToMultiWalletMigration.migrateExistingWallet()
        } else {
            self.displayWalletSetupScreen()
        }
    }
    
    func checkStartupSecurityAndStartApp() {
        if !StartupPinOrPassword.pinOrPasswordIsSet() {
            self.openWalletsAndStartApp(startupPinOrPassword: "", dialogDelegate: nil)
            return
        }
        
        self.promptForStartupPinOrPassword() { pinOrPassword, _, dialogDelegate in
            self.openWalletsAndStartApp(startupPinOrPassword: pinOrPassword, dialogDelegate: dialogDelegate)
        }
    }

    func promptForStartupPinOrPassword(callback: @escaping SecurityCodeRequestCallback) {
        let prompt = String(format: LocalizedStrings.unlockWithStartupCode,
                            StartupPinOrPassword.currentSecurityType().localizedString)
        
        Security.startup()
            .with(prompt: prompt)
            .with(submitBtnText: LocalizedStrings.unlock)
            .should(showCancelButton: false)
            .requestCurrentCode(sender: self, callback: callback)
    }

    func openWalletsAndStartApp(startupPinOrPassword: String, dialogDelegate: InputDialogDelegate?) {
        self.loadingLabel.text = LocalizedStrings.openingWallet

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.openWallets(startupPinOrPassword.utf8Bits)
                DispatchQueue.main.async {
                    dialogDelegate?.dismissDialog()
                    NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        dialogDelegate?.displayError(errorMessage: StartupPinOrPassword.invalidSecurityCodeMessage())
                    } else {
                        dialogDelegate?.displayError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func displayWalletSetupScreen() {
        
        UIView.animate(withDuration: 0.4,
                                     delay: 0,
                                     options: UIView.AnimationOptions.curveLinear,
                                     animations: { () -> Void in
                                        self.loadingLabel.isHidden = true
                                      self.createWalletBtn.center.y -= 100
                                        self.logo.image = UIImage(named: "ic_decred_logo")
                                        self.logo.center.y -= 20
                                        self.welcomeText.center.y -= 100
                                        self.restoreWalletBtn.center.y -= 100
                                        self.testnetLabel.center.y -= 20
                                        self.createWalletBtn.isHidden = false
                                        self.restoreWalletBtn.isHidden = false
                                        self.welcomeText.isHidden = false
                                        self.welcomeText.text = LocalizedStrings.introMessage
                          }, completion: { (finished) -> Void in
                          })
        
    }
}
