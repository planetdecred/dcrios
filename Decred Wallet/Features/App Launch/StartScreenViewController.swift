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
    @IBOutlet weak var imageViewContainer: UIView!
    
    let initialAnimationToggleValue : CGFloat = 50
    let splashViewSlideUpValue : CGFloat = 80
    let walletSetupViewSlideUpValue : CGFloat = 100
    
    var isAnimated = false
    var timer: Timer?
    var startTimerWhenViewAppears = true
    var animationDurationSeconds: Double = 7

    // Create animation
    let animation = CAKeyframeAnimation(keyPath: "contents")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        if BuildConfig.IsTestNet {
            testnetLabel.isHidden = false
        }

        let initError = WalletLoader.shared.initMultiWallet()
        if initError != nil {
            print("init multiwallet error: \(initError!.localizedDescription)")
        }
        
        if WalletLoader.shared.oneOrMoreWalletsExist {
            self.loadingLabel.text = LocalizedStrings.openingWallet
            self.animationDurationSeconds = 6
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.startTimerWhenViewAppears {
            self.startAnim()
            self.timer = Timer.scheduledTimer(withTimeInterval: animationDurationSeconds, repeats: false) {_ in
                self.loadMainScreen()
            }
            self.startTimerWhenViewAppears = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !startTimerWhenViewAppears{
            self.setStartupAnimationPosition()
        }
    }
    
    func startAnim(done: (() -> Void)? = nil) {
        let splashLogo = UIImage.gif(name: "splashLogo")
        
        // CAKeyframeAnimation.values are expected to be CGImageRef,
        // so we take the values from the UIImage images
        var values = [CGImage]()
        for image in splashLogo!.images! {
            values.append(image.cgImage!)
        }
        
        self.animation.calculationMode = CAAnimationCalculationMode.discrete
        self.animation.duration = splashLogo!.duration
        self.animation.values = values
        // Set the repeat count
        self.animation.repeatCount = 3
        // Other stuff
        self.animation.isRemovedOnCompletion = false
        self.animation.fillMode = CAMediaTimingFillMode.forwards
        // Set the delegate
        self.animation.delegate = self
        self.logo.contentMode = .scaleAspectFit
        self.logo.layer.add(animation, forKey: "animation")
    }
    
     func animationDidStop(_ anim: CAAnimation, finished animated: Bool) {
        self.isAnimated = animated
    }
    
    @objc func appMovedToForeground() {
        if !self.isAnimated {
            DispatchQueue.main.async {
                self.revertAnimationPosition()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func animatedLogoTap(_ sender: Any) {
        if self.isAnimated {
            return
        }
        
        self.timer?.invalidate()
        self.startTimerWhenViewAppears = true
        self.logo.layer.removeAllAnimations()
        
        let settingsVC = SettingsController.instantiate(from: .Settings).wrapInNavigationcontroller()
        settingsVC.modalPresentationStyle = .fullScreen
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func setStartupAnimationPosition() {
        self.imageViewContainer.center.y += initialAnimationToggleValue
        self.testnetLabel.center.y += initialAnimationToggleValue
        self.loadingLabel.center.y += initialAnimationToggleValue
    }
    
    func revertAnimationPosition() {
        self.imageViewContainer.center.y -= self.initialAnimationToggleValue
        self.testnetLabel.center.y -= self.initialAnimationToggleValue
        self.loadingLabel.center.y -= self.initialAnimationToggleValue
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
        // update splash screen location
        UIView.animate(withDuration: 0,
                   delay: 0,
                   options: UIView.AnimationOptions.curveLinear,
                   animations: { () -> Void in
        }, completion: { (finished) -> Void in
            self.revertAnimationPosition()
        })
        
        // animate and display wallet setup options
        UIView.animate(withDuration: 0.4,
                                     delay: 0,
                                     options: UIView.AnimationOptions.curveLinear,
                                     animations: { () -> Void in
                                        self.loadingLabel.isHidden = true
                                        self.createWalletBtn.center.y -= self.walletSetupViewSlideUpValue
                                        self.logo.image = UIImage(named: "ic_decred_logo")
                                        self.loadingLabel.center.y -= self.splashViewSlideUpValue
                                        self.imageViewContainer.center.y -= self.splashViewSlideUpValue
                                        self.welcomeText.center.y -= self.walletSetupViewSlideUpValue
                                        self.restoreWalletBtn.center.y -= self.walletSetupViewSlideUpValue
                                        self.testnetLabel.center.y -= self.splashViewSlideUpValue
                                        self.createWalletBtn.isHidden = false
                                        self.restoreWalletBtn.isHidden = false
                                        self.welcomeText.isHidden = false
                                        self.welcomeText.text = LocalizedStrings.introMessage
        })
    }
}
