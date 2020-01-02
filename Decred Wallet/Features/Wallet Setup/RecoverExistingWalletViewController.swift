//
//  RecoverExistingWalletViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class RecoverExistingWalletViewController: WalletSetupBaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView : UITableView!
    @IBOutlet weak var wordSelectionDropDownContainer: UIView!
    @IBOutlet weak var tableViewFooter: UIStackView!
    @IBOutlet weak var tableViewFooterTopSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var invalidSeedLabel: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var validSeedWords: [String] = []
    var userEnteredSeedWords = [String](repeating: "", count: 33)
    
    // following code will only be included if compiling for testnet
    #if IsTestnet
    private var testSeed = "reform aftermath printer warranty gremlin paragraph beehive stethoscope regain disruptive regain Bradbury chisel October trouble forever Algol applicant island infancy physique paragraph woodlark hydraulic snapshot backwater ratchet surrender revenge customer retouch intention minnow"
    private var useTestSeed: Bool = false
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load seed words
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        validSeedWords = seedWords?.split{$0 == "\n"}.map(String.init) ?? []
        
        registerObserverForKeyboardNotification()
        self.hideKeyboardWhenTappedAround()
        
        // set border for dropdown list
        self.wordSelectionDropDownContainer.layer.borderWidth = 1
        self.wordSelectionDropDownContainer.layer.borderColor = UIColor.appColors.lightGray.cgColor
        
        // long press to proceed with test seed, only on testnet
        #if IsTestnet
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressConfirm))
        btnConfirm.addGestureRecognizer(longGesture)
        #endif
    }
    
    deinit {
        unregisterObserverForKeyboardNotification()
    }
    
    func registerObserverForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterObserverForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object:nil)
    }
    
    @objc func onKeyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // Minusing keyboard height from window height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
            
            // add space at the bottom of table so that the seed word input fields do not touch the keyboard
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
    
    @objc func onKeyboardWillHide(_ notification: Notification) {
        if let window = self.view.window?.frame {
            // Resize main view to window height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height)
            
            // remove space at the bottom of table that was added when keyboard was displayed
             self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let seedWordCell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: indexPath) as! RecoveryWalletSeedWordCell
        
        seedWordCell.lbSeedWordNum.text = String(format: LocalizedStrings.wordNumber, indexPath.row + 1)
        seedWordCell.seedWordAutoComplete.text = self.userEnteredSeedWords[indexPath.row]
        seedWordCell.seedWordAutoComplete.resignFirstResponder()
        
        seedWordCell.setupAutoComplete(for: indexPath.row,
                                       filter: self.validSeedWords,
                                       dropDownListPlaceholder: self.wordSelectionDropDownContainer,
                                       onSeedEntered: self.seedWordEntered)
        
        return seedWordCell
    }
    
    func seedWordEntered(for wordIndex: Int, seedWord: String, moveToNextField: Bool) {
        self.userEnteredSeedWords[wordIndex] = seedWord
        
        if (self.invalidSeedLabel.isHidden == false) {
            self.invalidSeedLabel.isHidden = true
            // increase top spacing so that confirm button is centered in display
            self.tableViewFooterTopSpacingConstraint.constant = 30
            UIView.animate(withDuration: 0.5) {
                self.tableViewFooter.layoutIfNeeded()
            }
        }
        
        if wordIndex < 32 && moveToNextField {
            self.focusSeedWordInput(at: wordIndex + 1)
        } else {
            self.view.endEditing(true)
        }
        
        if self.validateSeed().valid {
            self.btnConfirm.backgroundColor = UIColor.appColors.green
        } else {
            self.btnConfirm.backgroundColor = UIColor.appColors.darkGray
        }
    }
    
    func focusSeedWordInput(at tableRowIndex: Int) {
        let tableIndexPath = IndexPath(row: tableRowIndex, section: 0)
        let nextSeedWordCell = self.tableView.cellForRow(at: tableIndexPath) as? RecoveryWalletSeedWordCell
        nextSeedWordCell?.seedWordAutoComplete.becomeFirstResponder()
    }

    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onConfirm() {
        if self.userEnteredSeedWords.contains("") {
            self.displaySeedError(LocalizedStrings.notAllSeedsAreEntered)
        } else {
            let validatedSeed = self.validateSeed()
            if validatedSeed.valid {
                self.secureWallet(validatedSeed.seed)
            } else {
                self.displaySeedError(LocalizedStrings.incorrectSeedEntered)
            }
        }
    }
    
    func displaySeedError(_ errorMessage: String) {
        // reduce top spacing so that warning label and confirm button are centered in display
        self.tableViewFooterTopSpacingConstraint.constant = 10
        UIView.animate(withDuration: 0.5) {
            self.tableViewFooter.layoutIfNeeded()
        }
        self.invalidSeedLabel.text = errorMessage
        self.invalidSeedLabel.isHidden = false
    }
    
    // following code will only be included if compiling for testnet
    #if IsTestnet
    @objc func longPressConfirm() {
        if self.useTestSeed {
            return
        }
        self.useTestSeed = true
        self.secureWallet(self.testSeed)
    }
    #endif
    
    func secureWallet(_ seed: String) {
        let securityVC = SecurityViewController.instantiate()
        securityVC.onUserEnteredPinOrPassword = { (pinOrPassword, securityType) in
            self.finalizeWalletSetup(seed, pinOrPassword, securityType)
        }
        self.navigationController?.pushViewController(securityVC, animated: true)
    }
    
    private func validateSeed() -> (seed: String, valid: Bool) {
        let seed = self.userEnteredSeedWords.reduce("", {(word1, word2) in "\(word1) \(word2)"})
        let seedValid = DcrlibwalletVerifySeed(seed)
        return (seed, seedValid)
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(title: LocalizedStrings.walletRecoveryError, message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.tryAgain, style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            self.clearSeedInputs()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func clearSeedInputs() {
        self.userEnteredSeedWords = [String](repeating: "", count: 33)
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension RecoverExistingWalletViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.wordSelectionDropDownContainer.isHidden = true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        var tapPoint = tap.location(in: self.view)
        tapPoint = self.wordSelectionDropDownContainer.convert(tapPoint, from: self.view)
        if self.wordSelectionDropDownContainer.bounds.contains(tapPoint) {
            // ignore taps inside the autoselection dropdown
            return
        }
        
        view.endEditing(true)
        self.wordSelectionDropDownContainer.isHidden = true
    }
}
