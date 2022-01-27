//
//  SeedBackupVerifyViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import JGProgressHUD

class SeedBackupVerifyViewController: UIViewController {
    @IBOutlet weak var groupedSeedWordsTableView: UITableView!
    @IBOutlet weak var btnConfirm: Button!
    
    var walletID: Int!
    var seedBackupCompleted: (() -> Void)?
    
    var seedWordsGroupedByThree: [[String]] = []
    var selectedWords: [String] = []

    func prepareSeedForVerification(seedToVerify: String, walletID: Int, seedBackupCompleted: (() -> Void)?) {
        self.walletID = walletID
        self.seedBackupCompleted = seedBackupCompleted
        
        let allSeedWords = loadSeedWordsList()
        let validSeedWords = seedToVerify.split{$0 == " "}.map(String.init)
        
        for seedIndex in 0...validSeedWords.count - 1 {
            let seedWordsGrouped = self.breakdownByThree( allSeedWords, validSeedWordToInclude: validSeedWords[seedIndex] )
            self.seedWordsGroupedByThree.append(seedWordsGrouped)
            self.selectedWords.append("")
        }
    }

    private func breakdownByThree(_ allSeedWords: [String], validSeedWordToInclude: String) -> [String] {
        var suggestionsWithFake: [String] = ["", "", ""]
        let trueSeedIndex = Int.random(in: 0...2)
        suggestionsWithFake[trueSeedIndex] = validSeedWordToInclude

        let fakeWordsArray = allSeedWords.filter({
            return ($0.lowercased() != validSeedWordToInclude.lowercased())
        })

        var fakeWordsSet = Array(Set(fakeWordsArray))
        let fake1 = Int.random(in: 0...(fakeWordsSet.count) - 1)
        var fakes = [fakeWordsSet.remove(at: fake1)]
        let fake2 = Int.random(in: 0...(fakeWordsSet.count) - 1)
        fakes.append(fakeWordsSet.remove(at: fake2))
        var fakeIndex = 0
        for index in 0...2 {
            if index != trueSeedIndex {
                suggestionsWithFake[index] = fakes[fakeIndex]
                fakeIndex += 1
            }
        }
        return  suggestionsWithFake
    }

    @IBAction func backbtn(_ sender: Any) {
        self.goBackHome()
    }

    @IBAction func onConfirm(_ sender: Any) {
        if self.btnConfirm!.isLoading { return } // prevent multiple click/tap attempts.
        if LocalAuthentication.isWalletSetupBiometric(walletId: self.walletID) {
            LocalAuthentication.localAuthenticaionWithWallet(walletId: self.walletID) { result, err in
                if let passOrPin = result {
                    self.groupedSeedWordsTableView?.isUserInteractionEnabled = false
                    let userEnteredSeed = self.selectedWords.joined(separator: " ")
                    var errorValue: ObjCBool = false
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try WalletLoader.shared.multiWallet.verifySeed(forWallet: self.walletID, seedMnemonic: userEnteredSeed, privpass: passOrPin.utf8Bits, ret0_: &errorValue)
                            if errorValue.boolValue == true {
                                DispatchQueue.main.async {
                                    self.seedBackupCompleted?()
                                    self.performSegue(withIdentifier: "toSeedBackupSuccess", sender: nil)
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.groupedSeedWordsTableView?.isUserInteractionEnabled = true
                                DcrlibwalletLogT("verify seed:", error.localizedDescription)
                                Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
                            }
                        }
                    }
                } else {
                    self.verifyByPinOrPass()
                }
            }
        } else {
            self.verifyByPinOrPass()
        }
    }
    
    private func verifyByPinOrPass() {
        let privatePassType = SpendingPinOrPassword.securityType(for: self.walletID)
        Security.spending(initialSecurityType: privatePassType)
            .with(prompt: LocalizedStrings.confirmToVerifySeed)
            .with(submitBtnText: LocalizedStrings.confirm)
            .should(showCancelButton: true)
            .requestCurrentCode(sender: self) { privatePass, _, dialogDelegate in
                self.groupedSeedWordsTableView?.isUserInteractionEnabled = false
                let userEnteredSeed = self.selectedWords.joined(separator: " ")
                var errorValue: ObjCBool = false
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try WalletLoader.shared.multiWallet.verifySeed(forWallet: self.walletID, seedMnemonic: userEnteredSeed, privpass: privatePass.utf8Bits, ret0_: &errorValue)
                        if errorValue.boolValue == true {
                            DispatchQueue.main.async {
                                self.seedBackupCompleted?()
                                dialogDelegate?.dismissDialog()
                                self.performSegue(withIdentifier: "toSeedBackupSuccess", sender: nil)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            if error.isInvalidPassphraseError {
                                let errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.walletID)
                                dialogDelegate?.displayPassphraseError(errorMessage: errorMessage)
                                self.groupedSeedWordsTableView?.isUserInteractionEnabled = true
                            } else if error.localizedDescription == DcrlibwalletErrInvalid {
                                self.groupedSeedWordsTableView?.isUserInteractionEnabled = true
                                dialogDelegate?.dismissDialog()
                                Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.failedToVerify)
                            } else {
                                self.groupedSeedWordsTableView?.isUserInteractionEnabled = true
                                dialogDelegate?.dismissDialog()
                                DcrlibwalletLogT("verify seed:", error.localizedDescription)
                                Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
                            }
                        }
                    }
                }
            }
    }

    private func loadSeedWordsList() -> [String] {
        // todo: load seeds from dcrlibwallet using DcrlibwalletPGPWordList(), when it will be avaliable
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{ $0 == "\n"}.map(String.init) ?? []
    }
}

extension SeedBackupVerifyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripleSeedCell", for: indexPath) as? SeedBackupVerifyTableViewCell

        let userSelection = self.selectedWords[indexPath.row]
        cell?.setup(index: indexPath.row, seedWords: seedWordsGroupedByThree[indexPath.row], selectedWord: userSelection)

        cell?.onSeedWordSelected = {(selectedWordIndex, selectedWord) in
            self.selectedWords[indexPath.row] = selectedWord

            var allChecked = true
            for seedIndex in 0...32 {
                allChecked = allChecked
                                && self.selectedWords.indices.contains(seedIndex)
                                && self.selectedWords[seedIndex] != ""
            }

            if indexPath.row < 32 {
                let nextRowIndex = IndexPath(row: indexPath.row + 1, section: 0)
                if tableView.isCellCompletelyVisible(at: nextRowIndex) {
                    tableView.selectRow(at: nextRowIndex, animated: true, scrollPosition: .none)
                } else {
                    tableView.selectRow(at: nextRowIndex, animated: true, scrollPosition: .bottom)
                }
            } else {
                // Last row, scroll to middle so that the "Confirm" button below the table will appear.
                let lastRowIndex = IndexPath(row: 32, section: 0)
                tableView.selectRow(at: lastRowIndex, animated: true, scrollPosition: .middle)
            }

            if allChecked {
                self.btnConfirm.isEnabled = true
            }
        }

        return cell!
    }
}
