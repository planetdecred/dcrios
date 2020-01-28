//
//  WalletsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletsViewController: UIViewController, WalletInfoTableViewCellDelegate {
    @IBOutlet weak var walletsTableView: UITableView!
    
    var wallets = [Wallet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.walletsTableView.hideEmptyAndExtraRows()
        self.walletsTableView.registerCellNib(WalletInfoTableViewCell.self)
        self.walletsTableView.dataSource = self
        self.walletsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        self.loadWallets()
    }
    
    func loadWallets() {
        self.wallets = [Wallet]()
        
        let walletsIterator = WalletLoader.shared.multiWallet.walletsIterator()
        while let wallet = walletsIterator!.next() {
            self.wallets.append(Wallet.init(wallet))
        }
        
        // sort by id, as dcrlibwallet may return wallets in any order
        self.wallets.sort(by: { $0.id > $1.id })
        
        self.walletsTableView.reloadData()
    }
    
    // todo use localized strings
    @IBAction func addNewWalletTapped(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Create or import a wallet", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Create a new wallet", style: .default, handler: { _ in
            if StartupPinOrPassword.pinOrPasswordIsSet() {
                self.verifyStartupSecurityCode(prompt: "Confirm to create new wallet", onVerifiedSuccess: self.createNewWallet)
            } else {
                self.createNewWallet()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Import an existing wallet", style: .default, handler: { _ in
            if StartupPinOrPassword.pinOrPasswordIsSet() {
                self.verifyStartupSecurityCode(prompt: "Confirm to import wallet", onVerifiedSuccess: self.goToRestoreWallet)
            } else {
                self.goToRestoreWallet()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil))
        
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
        Security.spending().requestNewCode(sender: self) { pinOrPassword, type, completion in
            WalletLoader.shared.createWallet(spendingPinOrPassword: pinOrPassword, securityType: type) { error in
                if error == nil {
                    completion?.dismissDialog()
                    self.loadWallets()
                    Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.walletCreated)
                } else {
                    completion?.displayError(errorMessage: error!.localizedDescription)
                }
            }
        }
    }
    
    func goToRestoreWallet() {
        let restoreWalletVC = RestoreExistingWalletViewController.instantiate(from: .WalletSetup)
        restoreWalletVC.onWalletRestored = {
            self.loadWallets()
            Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.walletCreated)
        }
        self.navigationController?.pushViewController(restoreWalletVC, animated: true)
    }
    
    // todo use localized strings
    func showWalletMenu(_ wallet: Wallet) {
        let prompt = String(format: "%@ (%@)", LocalizedStrings.wallet, wallet.name)
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Remove from device", style: .destructive, handler: { _ in
            self.removeWalletFromDevice(walletID: wallet.id)
        }))
        
        alertController.addAction(UIAlertAction(title: "Change spending password/PIN", style: .default, handler: { _ in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Sign message", style: .default, handler: { _ in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Verify message", style: .default, handler: { _ in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Rename", style: .default, handler: { _ in
            self.renameWallet(walletID: wallet.id)
        }))
        
        alertController.addAction(UIAlertAction(title: "View property", style: .default, handler: { _ in
            
        }))
        
        alertController.addAction(UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func removeWalletFromDevice(walletID: Int) {
        
    }
    
    func renameWallet(walletID: Int) {
        SimpleTextInputDialog.show(sender: self, dialogTitle: "Rename wallet", placeholder: "Wallet name") {
            newWalletName, dialogDelegate in
            
            do {
                try WalletLoader.shared.multiWallet.renameWallet(walletID, newName: newWalletName)
                dialogDelegate?.dismissDialog()
                self.loadWallets()
            } catch let error {
                dialogDelegate?.displayError(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func addNewAccount(_ wallet: Wallet) {
        print("add new account to", wallet.name)
    }
    
    func showAccountDetailsDialog(_ account: DcrlibwalletAccount) {
        print("show account modal for", account.name)
    }
}

extension WalletsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let wallet = self.wallets[indexPath.row]
        if !wallet.displayAccounts {
            return WalletInfoTableViewCell.walletInfoSectionHeight
        }
        
        return WalletInfoTableViewCell.walletInfoSectionHeight
            + (WalletInfoTableViewCell.accountCellHeight * CGFloat(wallet.accounts.count))
            + WalletInfoTableViewCell.addNewAccountButtonHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let walletViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletInfoTableViewCell") as! WalletInfoTableViewCell
        walletViewCell.wallet = self.wallets[indexPath.row]
        walletViewCell.delegate = self
        return walletViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.wallets[indexPath.row].toggleAccountsDisplay()
        tableView.reloadData()
    }
}
