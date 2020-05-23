//
//  WalletsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletsViewController: UIViewController {
    @IBOutlet weak var walletsTableView: UITableView!
    
    var wallets = [Wallet]()
    var watchOnly = [Wallet]()
    weak var customTabBar: CustomTabMenuView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.walletsTableView.hideEmptyAndExtraRows()
        self.walletsTableView.registerCellNib(WatchOnlyWalletInfoTableViewCell.self)
        self.walletsTableView.registerCellNib(WalletInfoTableViewCell.self)
        self.walletsTableView.dataSource = self
        self.walletsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        refreshView()
    }

    @objc func refreshView() {
        self.loadWallets()
        self.refreshAccountDetails()
    }

    func loadWallets() {
        let accountsFilterFn: (DcrlibwalletAccount) -> Bool = { ($0.totalBalance >= 0 && $0.name != "imported") || ($0.totalBalance > 0 && $0.name == "imported")}
        let watchOnly = WalletLoader.shared.wallets.filter { $0.isWatchingOnlyWallet()}
        let fullCoinWallet = WalletLoader.shared.wallets.filter { !$0.isWatchingOnlyWallet()}
        
        self.watchOnly = watchOnly.map({ Wallet.init($0, accountsFilterFn: accountsFilterFn) })
        self.wallets = fullCoinWallet.map({ Wallet.init($0, accountsFilterFn: accountsFilterFn) })
    }
    
    @IBAction func addNewWalletTapped(_ sender: UIView) {
        let alertController = UIAlertController(title: nil,
                                                message: LocalizedStrings.createOrImportWallet,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: LocalizedStrings.createNewWallet, style: .default, handler: { _ in
            if StartupPinOrPassword.pinOrPasswordIsSet() {
                self.verifyStartupSecurityCode(prompt: LocalizedStrings.confirmToCreateNewWallet,
                                               onVerifiedSuccess: self.createNewWallet)
            } else {
                self.createNewWallet()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: LocalizedStrings.restoreExistingWallet, style: .default, handler: { _ in
            if StartupPinOrPassword.pinOrPasswordIsSet() {
                self.verifyStartupSecurityCode(prompt: LocalizedStrings.confirmToImportWallet,
                                               onVerifiedSuccess: self.goToRestoreWallet)
            } else {
                self.goToRestoreWallet()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Import a watch-only wallet", style: .default, handler: { _ in
                       self.createWatchOnlyWallet()
               }))
        
        alertController.addAction(UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil))
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func verifyStartupSecurityCode(prompt: String, onVerifiedSuccess: @escaping () -> ()) {
        Security.startup()
            .with(prompt: prompt)
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestCurrentCode(sender: self) { pinOrPassword, _, completion in
                
                do {
                    try WalletLoader.shared.multiWallet.verifyStartupPassphrase(pinOrPassword.utf8Bits)
                    completion?.dismissDialog()
                    onVerifiedSuccess()
                } catch let error {
                    if error.isInvalidPassphraseError {
                        completion?.displayError(errorMessage: StartupPinOrPassword.invalidSecurityCodeMessage())
                    } else {
                        completion?.displayError(errorMessage: error.localizedDescription)
                    }
                }
        }
    }
    
    func createNewWallet() {
        SimpleTextInputDialog.show(sender: self,
        title: LocalizedStrings.walletName,
        placeholder: LocalizedStrings.walletName,
        submitButtonText: LocalizedStrings.confirm) { walletName, dialogDelegate in
            var errorValue: ObjCBool = false
            do {
                try WalletLoader.shared.multiWallet.walletNameExists(walletName, ret0_: &errorValue)
                if !errorValue.boolValue {
                    dialogDelegate?.dismissDialog()
                    Security.spending(initialSecurityType: .password).requestNewCode(sender: self, isChangeAttempt: false) { pinOrPassword, type, completion in
                        WalletLoader.shared.createWallet(spendingPinOrPassword: pinOrPassword, securityType: type, walletName: walletName.lowercased()) { error in
                            if error == nil {
                                DispatchQueue.main.async {
                                    completion?.dismissDialog()
                                    self.loadWallets()
                                    self.refreshAccountDetails()
                                    self.customTabBar?.hasUnBackedUpWallets(true)
                                    Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.walletCreated)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion?.displayError(errorMessage: error!.localizedDescription)
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        dialogDelegate?.displayError(errorMessage: LocalizedStrings.walletNameExists)
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    if error.localizedDescription == DcrlibwalletErrExist {
                        dialogDelegate?.displayError(errorMessage: LocalizedStrings.walletNameExists)
                    } else {
                        
                    }
                }
            }
        }
    }
    
    func goToRestoreWallet() {
        SimpleTextInputDialog.show(sender: self,
        title: LocalizedStrings.walletName,
        placeholder: LocalizedStrings.walletName,
        submitButtonText: LocalizedStrings.confirm) { walletName, dialogDelegate in
            var errorValue: ObjCBool = false
            do {
                try WalletLoader.shared.multiWallet.walletNameExists(walletName, ret0_: &errorValue)
                if !errorValue.boolValue {
                    dialogDelegate?.dismissDialog()
                    let restoreWalletVC = RestoreExistingWalletViewController.instantiate(from: .WalletSetup)
                    restoreWalletVC.walletName = walletName.lowercased()
                    restoreWalletVC.onWalletRestored = {
                        self.loadWallets()
                        Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.walletCreated)
                    }
                    self.navigationController?.pushViewController(restoreWalletVC, animated: true)
                } else {
                    dialogDelegate?.displayError(errorMessage: LocalizedStrings.walletNameExists)
                }
            } catch {
                DispatchQueue.main.async {
                    Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
                }
            }
        }
    }
    
    func createWatchOnlyWallet() {
        MultipleTextInputDialog.show(sender: self,
                                     title: LocalizedStrings.createWatchOnlyWallet,
        userNamePlaceholder: LocalizedStrings.walletName,
        userPassPlaceholder: LocalizedStrings.extendedPublicKey,
        submitButtonText: LocalizedStrings.import_) { walletName, walletPubKey, dialogDelegate in
            var errorValue: ObjCBool = false
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try WalletLoader.shared.multiWallet.walletNameExists(walletName, ret0_: &errorValue)
                    try WalletLoader.shared.multiWallet.validateExtPubKey(walletPubKey)
                    try WalletLoader.shared.multiWallet.createWatchOnlyWallet(walletName, extendedPublicKey: walletPubKey)
                    DispatchQueue.main.async {
                        dialogDelegate?.dismissDialog()
                        self.loadWallets()
                        self.refreshAccountDetails()
                        Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.walletCreated)
                    }
                } catch {
                    DispatchQueue.main.async {
                        if error.localizedDescription == DcrlibwalletErrExist {
                            dialogDelegate?.displayError(errorMessage: LocalizedStrings.walletNameExists, firstTextField: true)
                        } else if error.localizedDescription == DcrlibwalletErrInvalid {
                            dialogDelegate?.displayError(errorMessage: LocalizedStrings.keyIsInvalid, firstTextField: false)
                        } else {
                            Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
                            dialogDelegate?.dismissDialog()
                        }
                    }
                }
            }
        }
    }
    
    var numberOfAccountsToDisplay: Int {
        return self.watchOnly.count > 0 ? self.wallets.count + 1 : self.wallets.count
    }
}

extension WalletsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfAccountsToDisplay
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight = WalletInfoTableViewCell.walletInfoSectionHeight
        if indexPath.row < self.wallets.count {
            let wallet = self.wallets[indexPath.row]
            if !wallet.isSeedBackedUp {
                cellHeight += WalletInfoTableViewCell.walletNotBackedUpLabelHeight
                    + WalletInfoTableViewCell.seedBackupPromptHeight
            }
            
            if wallet.displayAccounts {
                cellHeight += (WalletInfoTableViewCell.accountCellHeight * CGFloat(wallet.accounts.count))
                    + WalletInfoTableViewCell.addNewAccountButtonHeight
            }
        } else {
            cellHeight += (WalletInfoTableViewCell.accountCellHeight * CGFloat(watchOnly.count))
        }
        return cellHeight
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = (indexPath.row < self.wallets.count) ? "WalletInfoTableViewCell" : "WatchOnlyWalletInfoTableViewCell"
        
        if  indexPath.row < self.wallets.count {
            let walletViewCell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! WalletInfoTableViewCell
            walletViewCell.wallet = self.wallets[indexPath.row]
            walletViewCell.delegate = self
            return walletViewCell
        } else {
            let watchOnlyWalletViewCell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! WatchOnlyWalletInfoTableViewCell
            watchOnlyWalletViewCell.watchOnlywallet = self.watchOnly
            watchOnlyWalletViewCell.delegate = self
            return watchOnlyWalletViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.wallets.count {
            self.wallets[indexPath.row].toggleAccountsDisplay()
            tableView.reloadData()
        }
    }
}

extension WalletsViewController: WalletInfoTableViewCellDelegate {
    
    func walletSeedBackedUp() {
        self.refreshView()
    }
    
    func showWalletMenu(walletName: String, walletID: Int, _ sender: UIView) {
        let prompt = String(format: "%@ (%@)", LocalizedStrings.wallet, walletName)
        let walletMenu = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        walletMenu.addAction(UIAlertAction(title: LocalizedStrings.signMessage, style: .default, handler: { _ in
            self.gotToSignMessage(walletID: walletID)
        }))
        
        walletMenu.addAction(UIAlertAction(title: LocalizedStrings.rename, style: .default, handler: { _ in
            self.renameWallet(walletID: walletID)
        }))
        
        walletMenu.addAction(UIAlertAction(title: LocalizedStrings.settings, style: .default, handler: { _ in
            self.goToWalletSettingsPage(walletID: walletID)
        }))
        
        walletMenu.addAction(UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil))
        
        if let popoverPresentationController = walletMenu.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        
        self.present(walletMenu, animated: true, completion: nil)
    }
    
    func addNewAccount(_ wallet: Wallet) {
        SimpleTextInputDialog.show(sender: self,
                                   title: LocalizedStrings.createNewAccount,
                                   placeholder: LocalizedStrings.accountName,
                                   submitButtonText: LocalizedStrings.create) { accountName, dialogDelegate in
                                    dialogDelegate?.dismissDialog()
                                    
                                    let privatePassType = SpendingPinOrPassword.securityType(for: wallet.id)
                                    Security.spending(initialSecurityType: privatePassType).requestCurrentCode(sender: self) { pinOrPassword, type, completion in
                                        DispatchQueue.global(qos: .userInitiated).async {
                                            let intPointer = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
                                            defer {
                                                intPointer.deallocate()
                                            }
                                            do {
                                                try WalletLoader.shared.multiWallet.wallet(withID: wallet.id)?.nextAccount(accountName, privPass: pinOrPassword.utf8Bits, ret0_: intPointer)
                                                DispatchQueue.main.async {
                                                    dialogDelegate?.dismissDialog()
                                                    completion?.dismissDialog()
                                                    self.loadWallets()
                                                    self.refreshAccountDetails()
                                                    Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.accountCreated)
                                                }
                                            } catch {
                                                DispatchQueue.main.async {
                                                    completion?.displayError(errorMessage: error.localizedDescription)
                                                }
                                            }
                                        }
                                    }
        }
    }
    
    func promptForSpendingPinOrPassword(submitBtnText: String, prompt: String, callback: @escaping SecurityCodeRequestCallback) {
        let prompt = String(format: LocalizedStrings.enableWithStartupCode,
                            StartupPinOrPassword.currentSecurityType().localizedString)
        
        Security.spending(initialSecurityType: .password)
            .with(prompt: prompt)
            .with(submitBtnText: submitBtnText)
            .should(showCancelButton: true)
            .requestCurrentCode(sender: self, callback: callback)
    }
    
    func showAccountDetailsDialog(_ account: DcrlibwalletAccount) {
        AccountDetailsViewController.showDetails(for: account, onAccountDetailsUpdated: self.refreshAccountDetails, sender: self)
    }

    func refreshAccountDetails() {
        self.wallets.forEach({ $0.reloadAccounts() })
        self.walletsTableView.reloadData()
        let numberOfNotBackedupWallets = self.wallets.filter {!$0.isSeedBackedUp}.count
        if numberOfNotBackedupWallets < 1 {
            customTabBar?.hasUnBackedUpWallets(false)
        }
    }
}

extension WalletsViewController: WatchOnlyWalletInfoTableViewCellDelegate {
    
    func showWatchOnlyWalletDetailsDialog(_ wallet: Wallet) {
        AccountDetailsViewController.showWatchOnlyWalletDetails(for: wallet, onAccountDetailsUpdated: self.refreshAccountDetails, sender: self)
    }
    
    func showWatchOnlyWalletMenu(walletName: String, walletID: Int, _ sender: UIView) {
        let prompt = String(format: "%@ (%@)", LocalizedStrings.wallet, walletName)
        let walletMenu = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
               
        walletMenu.addAction(UIAlertAction(title: LocalizedStrings.rename, style: .default, handler: { _ in
                   self.renameWallet(walletID: walletID)
               }))
               
        walletMenu.addAction(UIAlertAction(title: LocalizedStrings.settings, style: .default, handler: { _ in
                   self.goToWalletSettingsPage(walletID: walletID)
               }))
               
        walletMenu.addAction(UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil))
               
        if let popoverPresentationController = walletMenu.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        
        self.present(walletMenu, animated: true, completion: nil)
    }
}

// extension to handle wallet menu options.
extension WalletsViewController {
    func renameWallet(walletID: Int) {
        SimpleTextInputDialog.show(sender: self, title: LocalizedStrings.renameWallet, placeholder: LocalizedStrings.walletName, submitButtonText: LocalizedStrings.rename) { newWalletName, dialogDelegate in
            var errorValue: ObjCBool = false
            do {
                try WalletLoader.shared.multiWallet.walletNameExists(newWalletName, ret0_: &errorValue)
                if !errorValue.boolValue {
                    try WalletLoader.shared.multiWallet.renameWallet(walletID, newName: newWalletName)
                    dialogDelegate?.dismissDialog()
                    self.loadWallets()
                    self.refreshAccountDetails()
                    Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.walletRenamed)
                } else {
                    dialogDelegate?.displayError(errorMessage: LocalizedStrings.walletNameExists)
                }
                
            } catch let error {
                dialogDelegate?.displayError(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func goToWalletSettingsPage(walletID: Int) {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: walletID) else {
            return
        }
        
        let walletSettingsVC = WalletSettingsViewController.instantiate(from: .Wallets)
        walletSettingsVC.wallet = wallet
        self.navigationController?.pushViewController(walletSettingsVC, animated: true)
    }
    
    func gotToSignMessage(walletID: Int) {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: walletID) else {
            return
        }
        let signMessageVC = SignMessageViewController.instantiate(from: .SignMessage)
        signMessageVC.wallet = wallet
        self.navigationController?.pushViewController(signMessageVC, animated: true)
    }
    
    func gotToVerifyMessage(walletID: Int) {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: walletID) else {
            return
        }
        let verifyMessageVC = VerifyMessageViewController.instantiate(from: .VerifyMessage)
        verifyMessageVC.wallet = wallet
        self.navigationController?.pushViewController(verifyMessageVC, animated: true)
    }
}
