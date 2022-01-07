//
//  WalletAccountView.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

@IBDesignable class WalletAccountView: UIStackView {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    
    @IBInspectable var accountSelectorPrompt: String?
    @IBInspectable var localizeAccountSelectorPrompt: Bool = true
    
    var accountFilterFn: Wallet.AccountFilter?
    
    var selectedAccount: DcrlibwalletAccount? {
        didSet {
            self.accountNameLabel.text = self.selectedAccount?.name ?? LocalizedStrings.tapToSelectAccount
            let accountBalance = self.selectedAccount?.dcrTotalBalance ?? 0
            self.accountBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: accountBalance, smallerTextSize: 15.0)
        }
    }
    
    var onAccountSelectionChanged: ((_ selectedAccount: DcrlibwalletAccount) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }
    
    func initView() {
        let bundle = Bundle.init(for: WalletAccountView.self)
        guard let contentView = bundle.loadNibNamed("WalletAccountView", owner: self, options: nil)?.first as? UIView,
            let stackView = contentView.subviews.first as? UIStackView else { return }
        
        stackView.arrangedSubviews.forEach({ self.addArrangedSubview($0) })
        self.axis = stackView.axis
        self.alignment = stackView.alignment
        self.distribution = stackView.distribution
        self.spacing = stackView.spacing
        self.isLayoutMarginsRelativeArrangement = true
        self.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: contentView.frame.height)
        ])
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showAccountSelectorDialog)))
        
        let attribute = self.semanticContentAttribute
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: attribute)
        if layoutDirection == .rightToLeft {
            self.accountBalanceLabel.textAlignment = .left
        }
    }
    
    @objc func showAccountSelectorDialog(_ sender: Any) {
        guard let topVC = AppDelegate.shared.topViewController() else { return }
        
        var accountSelectorDialogTitle = self.accountSelectorPrompt ?? LocalizedStrings.selectAccount
        if self.localizeAccountSelectorPrompt && self.accountSelectorPrompt != nil {
            accountSelectorDialogTitle = NSLocalizedString(self.accountSelectorPrompt!, comment: "")
        }
        
        AccountSelectorDialog.show(sender: topVC,
                                   title: accountSelectorDialogTitle,
                                   selectedAccount: self.selectedAccount,
                                   accountFilterFn: self.accountFilterFn,
                                   callback: self.updateSelectedAccount)
    }

    func updateSelectedAccount(_ selectedAccount: DcrlibwalletAccount) {
        guard let selectedWallet = WalletLoader.shared.multiWallet.wallet(withID: selectedAccount.walletID) else { return }

        self.selectedAccount = selectedAccount
        self.walletNameLabel.text = selectedWallet.name
        
        self.onAccountSelectionChanged?(selectedAccount)
    }
    
    func selectFirstValidWalletAccount() {
        
        if self.selectedAccount != nil &&
            self.accountFilterFn != nil &&
            self.accountFilterFn!(self.selectedAccount!) {
            // already selected account is valid
            return
        }
        
        let fullCoinWallet = WalletLoader.shared.wallets
        for wallet in fullCoinWallet {
            let wal = Wallet.init(wallet, accountsFilterFn: self.accountFilterFn)
            
            // watch only wallets will have all accounts filtered out.
            if wal.accounts.count > 0 {
                self.selectedAccount = wal.accounts[0]
                self.walletNameLabel.text = wal.name
                self.onAccountSelectionChanged?(self.selectedAccount!)
                return
            }
        }
        
        
        
    }
}
