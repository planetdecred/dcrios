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
        
        if Settings.readBoolValue(for: DcrlibwalletUseFingerprintConfigKey) {
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
        self.label.text = LocalizedStrings.openingWallet

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
        let walletSetupController = WalletSetupViewController.instantiate(from: .WalletSetup).wrapInNavigationcontroller()
        walletSetupController.isNavigationBarHidden = true
        AppDelegate.shared.setAndDisplayRootViewController(walletSetupController)
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
<<<<<<< HEAD
                    self.openWalletsAndStartApp(startupPinOrPassword: "1234", dialogDelegate: nil)
=======
                    if let passOrPin = KeychainWrapper.standard.string(forKey: "StartupPinOrPassword") {
                        self.openWalletsAndStartApp(startupPinOrPassword: passOrPin, dialogDelegate: nil)
                    }
>>>>>>> f60f5735578a7775546f9ad3252e0d63b1dad3f8
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
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
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
            default:
                message = "Did not find error code on LAError object"
            }
        }
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        var message = ""
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
        default:
            message = self.evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        return message
    }
}
