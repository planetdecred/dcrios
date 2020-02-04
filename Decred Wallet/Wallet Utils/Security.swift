//
//  Security.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

enum SecurityType: String {
    case password = "PASSWORD"
    case pin = "PIN"
    
    var localizedString: String {
        switch self {
        case .pin:
            return LocalizedStrings.pin
        case .password:
            return LocalizedStrings.password.lowercased()
        }
    }

    var type: Int32 {
        switch self {
        case .password:
            return DcrlibwalletPassphraseTypePass
            
        case .pin:
            return DcrlibwalletPassphraseTypePin
        }
    }
}

class Security: NSObject {
    enum For {
        case Startup
        case Spending
        
        var localizedString: String {
            switch self {
            case .Startup:
                return LocalizedStrings.startup
            case .Spending:
                return LocalizedStrings.spending
            }
        }
    }
    
    class Request {
        var `for`: For
        var prompt: String?
        var subtext: String?
        var requestConfirmation = false
        var showCancelButton = true
        var submitBtnText: String?
        var isChangeAttempt: Bool = false
        
        init(for securityFor: For) {
            self.for = securityFor
        }
    }
    
    class RequestCallbacks {
        var onViewHeightChanged: ((_ height: CGFloat) -> Void)?
        var onLoadingStatusChanged: ((_ loading: Bool) -> Void)?
        var onSecurityCodeEntered: SecurityCodeRequestCallback?
        var onCurrentAndNewCodesEntered: CurrentAndNewSecurityCodeRequestCallback?
    }
    
    private var `for`: For
    private var request: Request
    private var callbacks = RequestCallbacks()
    private var currentSecurityType: SecurityType
    
    static func startup() -> Security {
        return Security(for: .Startup, initialSecurityType: StartupPinOrPassword.currentSecurityType())
    }
    
    static func spending(initialSecurityType: SecurityType) -> Security {
        return Security(for: .Spending, initialSecurityType: initialSecurityType)
    }
    
    init(for securityFor: For, initialSecurityType: SecurityType) {
        self.for = securityFor
        self.request = Request(for: securityFor)
        self.currentSecurityType = initialSecurityType
        super.init()
        
        if self.for == .Startup {
            self.setDefaultStartupSecurityPrompt()
        } else {
            self.setDefaultSpendingSecurityPrompt()
        }
    }
    
    private func setDefaultStartupSecurityPrompt() {
        if self.currentSecurityType == .password {
            self.request.prompt = LocalizedStrings.promptStartupPassword
        } else {
            self.request.prompt = LocalizedStrings.promptStartupPIN
        }
    }
    
    private func setDefaultSpendingSecurityPrompt() {
        if self.currentSecurityType == .password {
            self.request.prompt = LocalizedStrings.enterCurrentSpendingPassword
        } else {
            self.request.prompt = LocalizedStrings.enterCurrentSpendingPIN
        }
    }
    
    @discardableResult
    func with(prompt: String) -> Security {
        self.request.prompt = prompt
        return self
    }
    
    @discardableResult
    func with(subtext: String) -> Security {
        self.request.subtext = subtext
        return self
    }
    
    @discardableResult
    func with(submitBtnText: String) -> Security {
        self.request.submitBtnText = submitBtnText
        return self
    }
    
    @discardableResult
    func should(requestConfirmation: Bool) -> Security {
        self.request.requestConfirmation = requestConfirmation
        return self
    }

    func `is`(changeAttempt: Bool) -> Security {
        self.request.isChangeAttempt = changeAttempt
        return self
    }
    
    @discardableResult
    func should(showCancelButton: Bool) -> Security {
        self.request.showCancelButton = showCancelButton
        return self
    }
    
    @discardableResult
    func on(viewHeightChanged onViewHeightChanged: @escaping (_ height: CGFloat) -> Void) -> Security {
        self.callbacks.onViewHeightChanged = onViewHeightChanged
        return self
    }
    
    @discardableResult
    func on(loadingStatusChanged onLoadingStatusChanged: @escaping (_ loading: Bool) -> Void) -> Security {
        self.callbacks.onLoadingStatusChanged = onLoadingStatusChanged
        return self
    }
    
    func requestNewCode(sender vc: UIViewController, isChangeAttempt: Bool, callback: @escaping SecurityCodeRequestCallback) {
        // init secutity vc to use in getting new spending password or pin from user
        let securityVC = SecurityViewController.instantiate(from: .Security)
        securityVC.securityFor = self.request.for
        securityVC.initialSecurityType = self.currentSecurityType
        securityVC.isSecurityCodeChangeAttempt = isChangeAttempt
        securityVC.onSecurityCodeEntered = callback
        securityVC.modalPresentationStyle = .pageSheet
        vc.present(securityVC, animated: true, completion: nil)
    }
    
    func requestCurrentCode(sender: UIViewController,
                             callback onSecurityCodeEntered: @escaping SecurityCodeRequestCallback) {
        
        self.callbacks.onSecurityCodeEntered = onSecurityCodeEntered
        self.callbacks.onCurrentAndNewCodesEntered = nil
        self.presentSecurityRequestVC(sender: sender)
    }
    
    func requestCurrentAndNewCode(sender: UIViewController,
                                  callback onCurrentAndNewCodesEntered: @escaping CurrentAndNewSecurityCodeRequestCallback) {
        
        self.callbacks.onSecurityCodeEntered = nil
        self.callbacks.onCurrentAndNewCodesEntered = onCurrentAndNewCodesEntered
        self.presentSecurityRequestVC(sender: sender)
    }
    
    private func presentSecurityRequestVC(sender vc: UIViewController) {
        var securityRequestVC: SecurityCodeRequestBaseViewController
        if self.currentSecurityType == .password {
            securityRequestVC = RequestPasswordViewController.instantiate(from: .Security)
        } else {
            securityRequestVC = RequestPinViewController.instantiate(from: .Security)
        }
        
        securityRequestVC.request = self.request
        securityRequestVC.callbacks = self.callbacks
        
        securityRequestVC.modalPresentationStyle = .pageSheet
        vc.present(securityRequestVC, animated: true)
    }
}
