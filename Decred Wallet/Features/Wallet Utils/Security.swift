//
//  Security.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

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
        var requestConfirmation = false
        var showCancelButton = true
        var submitBtnText: String?
        
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
    private var currentSecurityType: SecurityType?
    
    static func startup() -> Security {
        return Security(for: .Startup)
    }
    
    static func spending() -> Security {
        return Security(for: .Spending)
    }
    
    init(for securityFor: For) {
        self.for = securityFor
        self.request = Request(for: securityFor)
        super.init()
        
        if self.for == .Startup {
            self.setDefaultStartupSecurityRequestParameters()
        } else {
            self.setDefaultSpendingSecurityRequestParameters()
        }
    }
    
    private func setDefaultStartupSecurityRequestParameters() {
        self.currentSecurityType = StartupPinOrPassword.currentSecurityType()
        
        if self.currentSecurityType == .password {
            self.request.prompt = LocalizedStrings.promptStartupPassword
        } else {
            self.request.prompt = LocalizedStrings.promptStartupPIN
        }
    }
    
    private func setDefaultSpendingSecurityRequestParameters() {
        self.currentSecurityType = SpendingPinOrPassword.currentSecurityType()

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
    func should(requestConfirmation: Bool) -> Security {
        self.request.requestConfirmation = requestConfirmation
        return self
    }
    
    @discardableResult
    func should(showCancelButton: Bool) -> Security {
        self.request.showCancelButton = showCancelButton
        return self
    }
    
    @discardableResult
    func with(submitBtnText: String) -> Security {
        self.request.submitBtnText = submitBtnText
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
    
    func requestNewCode(sender vc: UIViewController, callback: @escaping SecurityCodeRequestCallback) {
        // init secutity vc to use in getting new spending password or pin from user
        let securityVC = SecurityViewController.instantiate(from: .Security)
        securityVC.securityFor = self.request.for
        securityVC.initialSecurityType = self.currentSecurityType
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
