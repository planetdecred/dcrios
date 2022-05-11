//
//  RestoreExistingWalletViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class RestoreExistingWalletViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var wordSelectionDropDownContainer: UIView!
    @IBOutlet weak var tableViewFooterHeightCosnt: NSLayoutConstraint!
    @IBOutlet weak var tableViewFooter: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var validSeedWords: [String] = []
    var userEnteredSeedWords = [String](repeating: "", count: 33)
    
    var onWalletRestored: (() -> ())?
    
    var walletName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load seed words
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        validSeedWords = seedWords?.split{$0 == "\n"}.map(String.init) ?? []
        
        // set border for dropdown list
        self.wordSelectionDropDownContainer.layer.borderWidth = 1
        self.wordSelectionDropDownContainer.layer.borderColor = UIColor.appColors.lightGray.cgColor
        self.wordSelectionDropDownContainer.setRoundCorners(corners: [.bottomRight, .bottomLeft, .topLeft, .topRight], radius: 4.0)
        self.wordSelectionDropDownContainer?.layer.shadowColor = UIColor.appColors.text1.cgColor
        self.wordSelectionDropDownContainer?.layer.shadowRadius = 4
        self.wordSelectionDropDownContainer?.layer.shadowOpacity = 0.24
        self.wordSelectionDropDownContainer?.layer.shadowOffset = CGSize(width: -1, height: 1)
        
        // add drop shadow for better transition while scrolling the tableView
        self.tableViewFooter.dropShadow(color: UIColor.appColors.lighterGrayGray,
                                        opacity: 0.2,
                                        offset: CGSize.zero,
                                        radius: 1,
                                        spread: 0)
        
        // long press to proceed with test seed, only on testnet
        #if IsTestnet
        self.btnConfirm.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(self.onConfirmButtonLongPress))
        )
        #endif
        
        self.hideKeyboardWhenTappedAround()
        self.listenForKeyboardVisibilityChanges(delegate: self)
    }
    
    // following code will only be included if compiling for testnet
    #if IsTestnet
    @objc func onConfirmButtonLongPress() {
        let testSeed = "reform aftermath printer warranty gremlin paragraph beehive stethoscope regain disruptive regain Bradbury chisel October trouble forever Algol applicant island infancy physique paragraph woodlark hydraulic snapshot backwater ratchet surrender revenge customer retouch intention minnow"
        self.requestSpendingSecurityCodeAndRestoreWallet(with: testSeed)
    }
    #endif
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        var tapPoint = tap.location(in: self.view)
        tapPoint = self.wordSelectionDropDownContainer.convert(tapPoint, from: self.view)
        if self.wordSelectionDropDownContainer.bounds.contains(tapPoint) {
            // ignore taps inside the autoselection dropdown
            return
        }
        
        self.view.endEditing(true)
        self.wordSelectionDropDownContainer.isHidden = true
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onConfirm() {
        if self.userEnteredSeedWords.contains("") {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.notAllSeedsAreEntered)
            return
        }
        
        let seed = self.userEnteredSeedWords.reduce("", {(word1, word2) in "\(word1) \(word2)"})
        let seedValid = DcrlibwalletVerifySeed(seed)
        
        if !seedValid {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.incorrectSeedEntered)
            return
        }
        
        // Compare seed with existing wallet seed
        var walletID = 1
        let op = "wallet.restoreWallet error:"
        do {
            try WalletLoader.shared.multiWallet.wallet(withSeed: seed, ret0_: &walletID)
            if walletID != -1 {
                Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.wallet_with_seed_exist)
                return
            }
        } catch let error {
            DispatchQueue.main.async {
                print(op, error.localizedDescription)
                DcrlibwalletLogT(op, error.localizedDescription)
                Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
            }
        }

        self.tableView.isUserInteractionEnabled = false
        self.btnConfirm.setTitle(LocalizedStrings.success, for: .normal)
        self.btnConfirm.setTitleColor(UIColor.appColors.green, for: .normal)
        self.btnConfirm.setImage(.init(imageLiteralResourceName: "success_checked"), for: .normal)
        self.btnConfirm.backgroundColor = .white
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.requestSpendingSecurityCodeAndRestoreWallet(with: seed)
        }
    }
    
    func requestSpendingSecurityCodeAndRestoreWallet(with seed: String) {
        Security.spending(initialSecurityType: .password)
            .requestNewCode(sender: self, isChangeAttempt: false) { pinOrPassword, type, completion in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let wallet = try WalletLoader.shared.multiWallet.restore(self.walletName, seedMnemonic: seed, privatePassphrase: pinOrPassword, privatePassphraseType: type.type)
                        
                        Utils.renameDefaultAccountToLocalLanguage(wallet: wallet)
                        
                        DispatchQueue.main.async {
                            completion?.dismissDialog()
                            
                            if self.onWalletRestored == nil {
                                self.performSegue(withIdentifier: "recoverySuccess", sender: self)
                            } else {
                                self.onWalletRestored!()
                                self.dismissView()
                            }
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completion?.displayError(errorMessage: error.localizedDescription)
                        }
                    }
                }
        }
    }
}

extension RestoreExistingWalletViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let seedWordCell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: indexPath) as! RecoveryWalletSeedWordCell
        
        seedWordCell.lbSeedWordNum.text = String(format: LocalizedStrings.wordNumber, indexPath.row + 1)
        seedWordCell.lbSeedWordNum.layer.borderColor = UIColor.appColors.text2.cgColor
        seedWordCell.seedWordAutoComplete.text = self.userEnteredSeedWords[indexPath.row]
        seedWordCell.cellBorder.layer.borderColor = UIColor.appColors.border.cgColor
        seedWordCell.seedWordAutoComplete.resignFirstResponder()
        
        seedWordCell.setupAutoComplete(for: indexPath.row,
                                       filter: self.validSeedWords,
                                       dropDownListPlaceholder: self.wordSelectionDropDownContainer,
                                       onSeedEntered: self.seedWordEnteredOrSelected)
        if indexPath.row == 0 {
            seedWordCell.setRoundCorners(corners: [.topLeft, .topRight], radius: 14.0)
            seedWordCell.cellComponentTopMargin.constant = 16
        } else if indexPath.row == 32 {
            seedWordCell.setRoundCorners(corners: [.bottomRight, .bottomLeft], radius: 14.0)
            seedWordCell.cellComponentBottomMargin.constant = 16
        } else {
            seedWordCell.setRoundCorners(corners: [.bottomRight, .bottomLeft, .topLeft, .topRight], radius: 0.0)
            seedWordCell.cellComponentBottomMargin.constant = 8
            seedWordCell.cellComponentTopMargin.constant = 8
        }
        
        return seedWordCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0, 32:
            return 78
        default:
            return 70
        }
    }
    
    func seedWordEnteredOrSelected(for wordIndex: Int, seedWord: String, moveToNextField: Bool) {
        self.userEnteredSeedWords[wordIndex] = seedWord
        
        let allSeedWordsEntered = !self.userEnteredSeedWords.contains("")
        self.btnConfirm.backgroundColor = allSeedWordsEntered ? UIColor.appColors.primary : UIColor.appColors.text5
        
        if wordIndex < 32 && moveToNextField {
            let nextTableIndexPath = IndexPath(row: wordIndex + 1, section: 0)
            let nextSeedWordCell = self.tableView.cellForRow(at: nextTableIndexPath) as? RecoveryWalletSeedWordCell
            nextSeedWordCell?.seedWordAutoComplete.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
    }
}

extension RestoreExistingWalletViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.wordSelectionDropDownContainer.isHidden = true
    }
}

extension RestoreExistingWalletViewController: KeyboardVisibilityDelegate {
    @objc func onKeyboardWillShowOrHide(_ notification: Notification) {
        if notification.name == UIResponder.keyboardWillShowNotification {
            self.onKeyboardWillShow(notification)
        } else {
            self.onKeyboardWillHide()
        }
    }
    
    func onKeyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // Minusing keyboard height from window height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
            
            // hide the confirm button and allow the tableview occupy its height
            self.tableViewFooterHeightCosnt.constant = 0
            self.btnConfirm.isHidden = true
            // add space at the bottom of table so that the seed word input fields do not touch the keyboard
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        }
    }
    
    func onKeyboardWillHide() {
        if let window = self.view.window?.frame {
            // Resize main view to window height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height)
            
            // display the confirm button and retain its height
            self.tableViewFooterHeightCosnt.constant = 72
            self.btnConfirm.isHidden = false
            // remove space at the bottom of table that was added when keyboard was displayed
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        }
    }
}
