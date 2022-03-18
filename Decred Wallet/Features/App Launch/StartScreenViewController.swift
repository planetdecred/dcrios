//
//  StartScreenViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import LocalAuthentication
import JGProgressHUD
import SwiftKeychainWrapper

class StartScreenViewController: UIViewController, CAAnimationDelegate {
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var createWalletBtn: Button!
    @IBOutlet weak var restoreWalletBtn: Button!
    @IBOutlet weak var importWatchWalletBtn: Button!
    @IBOutlet weak var testnetLabel: UILabel!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var version: UILabel!
    
    let initialAnimationToggleValue : CGFloat = 5
    let splashViewSlideUpValue : CGFloat = 80
    let walletSetupViewSlideUpValue : CGFloat = 100
    
    var isAnimated = false
    var timer: Timer?
    var startTimerWhenViewAppears = true
    var animationDurationSeconds: Double = 4.7
    
    var progressHud = JGProgressHUD(style: .light)
    
    let ONE_GB_VALUE: UInt64 = 1073741824
    var numberOfRam: Int {
        return Int(ProcessInfo.processInfo.physicalMemory/(ONE_GB_VALUE))
    }
    let appDataDir = NSHomeDirectory() + "/Documents/dcrlibwallet"
    
    var upgradedDB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        if BuildConfig.IsTestNet {
            testnetLabel.isHidden = false
        }
        
        if let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            self.version?.text = "v\(versionNumber)"
        }

        let initError = WalletLoader.shared.initMultiWallet()
        if initError != nil {
            DispatchQueue.main.async {
                Utils.showBanner(in: self.view, type: .error, text: "init multiwallet error: \(initError!.localizedDescription)")
            }
        }
        
        let attribute = view.semanticContentAttribute
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: attribute)
        if layoutDirection == .rightToLeft {
            createWalletBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 32)
            restoreWalletBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 32)
            importWatchWalletBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 32)
            
            createWalletBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
            restoreWalletBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
            importWatchWalletBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
            
            createWalletBtn.contentHorizontalAlignment = .right
            importWatchWalletBtn.contentHorizontalAlignment = .right
            restoreWalletBtn.contentHorizontalAlignment = .right
        }
       
        
        if #available(iOS 13.0, *) {
            self.setTheme()
        }
        
        if SingleToMultiWalletMigration.migrationNeeded {
            self.loadingLabel.text = LocalizedStrings.migratingWallet
            self.animationDurationSeconds = 5
            
        } else if WalletLoader.shared.oneOrMoreWalletsExist {
            self.loadingLabel.text = LocalizedStrings.openingWallet
            self.animationDurationSeconds = 5
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.startTimerWhenViewAppears {
            self.slideInFromButtom()
            self.logo.image = UIImage(named: "ic_decred_logo")
            self.timer = Timer.scheduledTimer(withTimeInterval: animationDurationSeconds, repeats: false) {_ in
                DispatchQueue.main.async {
                    self.logo.layer.removeAllAnimations()
                    self.loadMainScreen()
                }
            }
            self.startTimerWhenViewAppears = false
        }
    }
    
    @available(iOS 13.0, *)
    func setTheme() {
        guard let window = AppDelegate.shared.window else {
            return
        }
        switch Settings.colorThemeOption {
        case .deviceDefault:
            window.overrideUserInterfaceStyle = .unspecified
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !startTimerWhenViewAppears && self.isAnimated == false {
            self.setStartupAnimationPosition()
        }
    }
    
    func slideInFromButtom(duration: TimeInterval = 1.5, completionDelegate: AnyObject? = nil) {
        self.logo.layer.removeAllAnimations()
        // Create a CATransition animation
        let slideInFromBottomTransition = CATransition()
    
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromBottomTransition.delegate = (delegate as! CAAnimationDelegate)
        }

        // Customize the animation's properties
        slideInFromBottomTransition.type = CATransitionType.moveIn
        slideInFromBottomTransition.subtype = CATransitionSubtype.fromTop
        slideInFromBottomTransition.duration = duration
        slideInFromBottomTransition.repeatCount = 3
        slideInFromBottomTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromBottomTransition.fillMode = CAMediaTimingFillMode.removed

        // Add the animation to the View's layer
        self.logo.layer.add(slideInFromBottomTransition, forKey: "slideInFromBottomTransition")
    }
    
     func animationDidStop(_ anim: CAAnimation, finished animated: Bool) {
        self.isAnimated = animated
    }
    
    @objc func appMovedToForeground() {
        if !self.isAnimated {
            DispatchQueue.main.async {
                self.revertAnimationPosition()
                self.isAnimated = true
            }
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func animatedLogoTap(_ sender: Any) {
        if self.isAnimated {
            return
        }
        
        self.timer?.invalidate()
        self.startTimerWhenViewAppears = true
        self.logo.image = nil
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
            
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let wallet = try WalletLoader.shared.multiWallet.createNewWallet(LocalizedStrings.myWallet, privatePassphrase: pinOrPassword, privatePassphraseType: type.type)
                        
                        Utils.renameDefaultAccountToLocalLanguage(wallet: wallet)
                        
                        DispatchQueue.main.async {
                           completion?.dismissDialog()
                           NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: true)
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completion?.displayError(errorMessage: error.localizedDescription)
                        }
                    }
                }
        }
    }
    
    @IBAction func restoreExistingWallet(_ sender: Any) {
        let restoreWalletVC = RestoreExistingWalletViewController.instantiate(from: .WalletSetup)
        restoreWalletVC.walletName = LocalizedStrings.myWallet
        self.navigationController?.pushViewController(restoreWalletVC, animated: true)
    }
    
    @IBAction func importWatchWallet(_ sender: Any) {
        SimpleTextInputDialog.show(sender: self, title: LocalizedStrings.watchWalletTitle, placeholder: LocalizedStrings.extendedPublicKey, cancelButtonText: LocalizedStrings.cancel, submitButtonText: LocalizedStrings.import_, showInfoButton: true, infoText: LocalizedStrings.extendPublicKeyInfo) { publicKey, dialogDelegate in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let wallet = try WalletLoader.shared.multiWallet.createWatchOnlyWallet(LocalizedStrings.myWallet, extendedPublicKey: publicKey)
                    Utils.renameDefaultAccountToLocalLanguage(wallet: wallet)
                    
                    DispatchQueue.main.async {
                        dialogDelegate?.dismissDialog()
                        self.progressHud.dismiss()
                        Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.watchWalletImported)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        dialogDelegate?.displayError(errorMessage: LocalizedStrings.keyIsInvalid)
                    }
                }
            }
        }
    }
    
    
    func loadMainScreen() {
        if !WalletLoader.shared.isInitialized {
            print("there was an error initializing multiwallet")
            return
        }
        
        if WalletLoader.shared.oneOrMoreWalletsExist {
            self.checkDBfile()
        } else if SingleToMultiWalletMigration.migrationNeeded {
            SingleToMultiWalletMigration.migrateExistingWallet()
        } else {
            self.displayWalletSetupScreen()
            self.imageViewContainer.isUserInteractionEnabled = false
            self.checkStorageSpace()
        }
    }
    
    func checkStartupSecurityAndStartApp() {
        if !StartupPinOrPassword.pinOrPasswordIsSet() {
            self.openWalletsAndStartApp(startupPinOrPassword: "", dialogDelegate: nil)
            return
        }
        
        if Settings.readBoolValue(for: DcrlibwalletUseBiometricConfigKey) {
            self.authenticationWithTouchID()
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
                        dialogDelegate?.displayPassphraseError(errorMessage: StartupPinOrPassword.invalidSecurityCodeMessage())
                    } else {
                        dialogDelegate?.displayError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func clearAppDir() {
        do {
            WalletLoader.shared.multiWallet.shutdown()
            let filemgr = FileManager.default
            try filemgr.removeItem(atPath: appDataDir)
            let initError = WalletLoader.shared.initMultiWallet()
            if initError != nil {
                DispatchQueue.main.async {
                    Utils.showBanner(in: self.view, type: .error, text: "init multiwallet error: \(initError!.localizedDescription)")
                }
            }
            self.displayWalletSetupScreen()
            self.imageViewContainer.isUserInteractionEnabled = false
        } catch let error {
            DispatchQueue.main.async {
                Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
            }
        }
    }
    
    func checkDBfile() {
        let walletDB = WalletLoader.shared.wallets.first?.dbDriver
        if numberOfRam < 3 && walletDB != GlobalConstants.Strings.BADGER {
            self.showRemoveWalletWarning { _ in
                self.clearAppDir()
            }
            return
        } else {
            self.checkStartupSecurityAndStartApp()
        }
    }
    
    func showRemoveWalletWarning(callback: @escaping (Bool) -> Void) {
        let message = LocalizedStrings.dataFileErrorMsg
        SimpleAlertDialog.show(sender: self,
                                  message: message,
                                  okButtonText: LocalizedStrings.yes,
                                  callback: callback)
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
                                        self.version.isHidden = true
                                        self.createWalletBtn.center.y -= self.walletSetupViewSlideUpValue
                                        self.loadingLabel.center.y -= self.splashViewSlideUpValue
                                        self.imageViewContainer.center.y -= self.splashViewSlideUpValue
                                        self.welcomeText.center.y -= self.walletSetupViewSlideUpValue
                                        self.restoreWalletBtn.center.y -= self.walletSetupViewSlideUpValue
                                        self.importWatchWalletBtn.center.y -= self.walletSetupViewSlideUpValue
                                        self.testnetLabel.center.y -= self.splashViewSlideUpValue
                                        self.createWalletBtn.isHidden = false
                                        self.restoreWalletBtn.isHidden = false
                                        self.importWatchWalletBtn.isHidden = false
                                        self.welcomeText.isHidden = false
                                        self.welcomeText.text = LocalizedStrings.introMessage
        })
    }
    
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = LocalizedStrings.promptStartupPassOrPIN
        var authError: NSError?
        var reasonString = ""
        if localAuthenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if #available(iOS 11.0, *) {
                switch localAuthenticationContext.biometryType {
                case .faceID:
                    reasonString = LocalizedStrings.promptFaceIDUsageUsage
                    break
                case .touchID:
                    reasonString = LocalizedStrings.promptTouchIDUsageUsage
                    break
                case .none:
                    reasonString = ""
                    break
                @unknown default:
                    reasonString = ""
                    break
                }
            } else {
                reasonString = ""
            }
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                DispatchQueue.main.async {
                if success {
                    if let passOrPin = KeychainWrapper.standard.string(forKey: "StartupPinOrPassword") {
                        self.openWalletsAndStartApp(startupPinOrPassword: passOrPin, dialogDelegate: nil)
                    }
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    print(ErrorMessageForLA.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    self.promptForStartupPinOrPassword() { pinOrPassword, _, dialogDelegate in
                        self.openWalletsAndStartApp(startupPinOrPassword: pinOrPassword, dialogDelegate: dialogDelegate)
                    }
                    }
                }
            }
        } else {
            guard let error = authError else {
                return
            }
            
            self.promptForStartupPinOrPassword() { pinOrPassword, _, dialogDelegate in
                self.openWalletsAndStartApp(startupPinOrPassword: pinOrPassword, dialogDelegate: dialogDelegate)
            }
            print(ErrorMessageForLA.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
}

extension UIButton {
    func setInsets(
        forContentPadding contentPadding: UIEdgeInsets,
        imageTitlePadding: CGFloat
    ) {
        self.contentEdgeInsets = UIEdgeInsets(
                    top: contentPadding.top,
                    left: contentPadding.left,
                    bottom: contentPadding.bottom,
                    right: contentPadding.right + imageTitlePadding
                )
                self.titleEdgeInsets = UIEdgeInsets(
                    top: 0,
                    left: imageTitlePadding,
                    bottom: 0,
                    right: -imageTitlePadding
                )
    }
}
