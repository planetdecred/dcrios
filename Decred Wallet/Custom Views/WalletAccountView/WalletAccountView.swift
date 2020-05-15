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
    
    var selectedWallet: DcrlibwalletWallet? {
        didSet {
            self.walletNameLabel.text = self.selectedWallet?.name ?? LocalizedStrings.noWalletSelected
        }
    }
    
    var selectedAccount: DcrlibwalletAccount? {
        didSet {
            self.accountNameLabel.text = self.selectedAccount?.name ?? LocalizedStrings.tapToSelectAccount
            let accountBalance = self.selectedAccount?.dcrTotalBalance ?? 0
            self.accountBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: accountBalance,
                                                                                     smallerTextSize: 15.0)
        }
    }
    
    var onAccountSelectionChanged: ((_ selectedWallet: DcrlibwalletWallet, _ selectedAccount: DcrlibwalletAccount) -> Void)?
    
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
    }
    
    @objc func showAccountSelectorDialog(_ sender: Any) {
        guard let topVC = AppDelegate.shared.topViewController() else { return }
        
        var accountSelectorDialogTitle = self.accountSelectorPrompt ?? LocalizedStrings.selectAccount
        if self.localizeAccountSelectorPrompt && self.accountSelectorPrompt != nil {
            accountSelectorDialogTitle = NSLocalizedString(self.accountSelectorPrompt!, comment: "")
        }
        
        AccountSelectorDialog.show(sender: topVC,
                                   title: accountSelectorDialogTitle,
                                   selectedWallet: self.selectedWallet,
                                   selectedAccount: self.selectedAccount,
                                   callback: self.updateSelectedAccount)
    }

    func updateSelectedAccount(_ selectedWalletId: Int, _ selectedAccount: DcrlibwalletAccount) {
        guard let selectedWallet = WalletLoader.shared.multiWallet.wallet(withID: selectedWalletId) else { return }

        self.selectedWallet = selectedWallet
        self.selectedAccount = selectedAccount
        
        self.onAccountSelectionChanged?(selectedWallet, selectedAccount)
    }
    
    func selectFirstWalletAccount() {
        guard let firstWallet = WalletLoader.shared.wallets.first,
            let firstWalletAccount = firstWallet.accounts.filter({ $0.totalBalance > 0 || $0.name != "imported" }).first
            else { return }
        
        self.selectedWallet = firstWallet
        self.selectedAccount = firstWalletAccount
        
        self.onAccountSelectionChanged?(firstWallet, firstWalletAccount)
    }
}
