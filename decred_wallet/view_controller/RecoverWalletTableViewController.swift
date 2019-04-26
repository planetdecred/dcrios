//
//  RecoverWalletTableViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class RecoverWalletTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet weak var tableViewFooter: UIStackView!
    @IBOutlet weak var tableViewFooterTopSpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblEnterAllSeeds: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var validSeedWords : [String] = []
    var userEnteredSeedWords = [String](repeating: "", count: 33)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load seed words
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        validSeedWords = seedWords?.split{$0 == "\n"}.map(String.init) ?? []
        
        registerObserverForKeyboardNotification()
        self.hideKeyboardWhenTappedAround()
    }
    
    deinit {
        unregisterObserverForKeyboardNotification()
    }
    
    func registerObserverForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterObserverForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    
    @objc func onKeyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // Minusing keyboard height from window height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        }
    }
    
    @objc func onKeyboardWillHide(_ notification: Notification) {
        if let window = self.view.window?.frame {
            // Resize main view to window height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height)
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
        
        seedWordCell.lbSeedWordNum.text = "Word #\(indexPath.row + 1)"
        seedWordCell.seedWordAutoComplete.text = self.userEnteredSeedWords[indexPath.row]
        seedWordCell.seedWordAutoComplete.resignFirstResponder()
        
        seedWordCell.setupAutoComplete(for: indexPath.row,
                                       filter: self.validSeedWords,
                                       onSeedEntered: self.seedWordEntered)
        
        return seedWordCell
    }
    
    func seedWordEntered(for wordIndex: Int, seedWord: String, moveToNextField: Bool) {
        self.userEnteredSeedWords[wordIndex] = seedWord
        
        if wordIndex < 32 && moveToNextField {
            self.focusSeedWordInput(at: wordIndex + 1)
        } else {
            self.view.endEditing(true)
        }
        
        if self.userEnteredSeedWords.contains("") {
            self.deactivateConfirmButton()
        } else {
            self.activateConfirmButton()
        }
    }
    
    func focusSeedWordInput(at tableRowIndex: Int) {
        let tableIndexPath = IndexPath(row: tableRowIndex, section: 0)
        
        let nextSeedWordCell = self.tableView.cellForRow(at: tableIndexPath) as? RecoveryWalletSeedWordCell
        nextSeedWordCell?.seedWordAutoComplete.becomeFirstResponder()
        
        self.tableView.scrollToRow(at: tableIndexPath, at: .middle, animated: true)
    }
    
    func activateConfirmButton() {
        self.btnConfirm.alpha = 1
        self.lblEnterAllSeeds.isHidden = true
        
        // increase top spacing since warning label is now hidden so as to position button in center
        self.tableViewFooterTopSpacingConstraint.constant = 25
        UIView.animate(withDuration: 0.5) {
            self.tableViewFooter.layoutIfNeeded()
        }
    }
    
    func deactivateConfirmButton() {
        self.btnConfirm.alpha = 0.5
        self.lblEnterAllSeeds.isHidden = false
        
        // reduce top spacing so that warning label and confirm button are centered in display
        self.tableViewFooterTopSpacingConstraint.constant = 10
        UIView.animate(withDuration: 0.5) {
            self.tableViewFooter.layoutIfNeeded()
        }
    }
    
    @IBAction func onConfirm() {
        let seed = self.userEnteredSeedWords.reduce("", {(word1, word2) in "\(word1!) \(word2)"})
        let seedValid = SingleInstance.shared.wallet?.verifySeed(seed)
        if seedValid! {
            self.performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
        } else {
            self.showError("Seed is not valid")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmSeedSegue" {
            var vc = segue.destination as? SeedCheckupProtocol
            vc?.seedToVerify = self.userEnteredSeedWords.reduce("", {(word1, word2) in "\(word1!) \(word2)"})
        }
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(title: "Wallet recovery error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try again", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            self.clearSeedInputs()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func clearSeedInputs() {
        self.userEnteredSeedWords = []
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
