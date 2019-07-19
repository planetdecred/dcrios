//
//  ConfirmNewWalletSeedViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import JGProgressHUD

class ConfirmNewWalletSeedViewController: UIViewController {
    static func instantiate() -> Self {
        return Storyboards.WalletSetup.instantiateViewController(for: self)
    }
    
    var seedWordsGroupedByThree: [[String]] = []
    var selectedWords: [String] = []
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet var vActiveCellView: SeedCheckActiveCellView!
    
    var isSeedBackedUp: ((String?)->())?
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func prepareSeedForVerification(seedToVerify: String) {
        let allSeedWords = loadSeedWordsList()
        let validSeedWords = seedToVerify.split{$0 == " "}.map(String.init)
        
        for seedIndex in 0...32 {
            let seedWordsGrouped = self.breakdownByThree(allSeedWords, validSeedWordToInclude: validSeedWords[seedIndex])
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
        for i in 0...2 {
            if i != trueSeedIndex {
                suggestionsWithFake[i] = fakes[fakeIndex]
                fakeIndex += 1
            }
        }
        
        return  suggestionsWithFake
    }
    
    @IBAction func backbtn(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        let seed = selectedWords.joined(separator: " ")
        let seedIsValid = DcrlibwalletVerifySeed(seed)
        if seedIsValid {
            Settings.setValue(true, for: Settings.Keys.SeedBackedUp)
            Settings.clearValue(for: Settings.Keys.Seed)
            isSeedBackedUp?(seed)
            self.backbtn(sender)
        } else {
            self.showError(error: LocalizedStrings.seedDoesNotMatch)
        }
    }
    
    private func showError(error:String){
        let alert = UIAlertController(title: LocalizedStrings.error, message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion:nil)
    }
    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
}

extension ConfirmNewWalletSeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripleSeedCell", for: indexPath) as? SeedConfirmTableViewCell
        
        let userSelection = self.selectedWords[indexPath.row]
        cell?.setup(num: indexPath.row, seedWords: seedWordsGroupedByThree[indexPath.row], selectedWord: userSelection)
        
        cell?.onPick = {(index, seedWord) in
            self.selectedWords[indexPath.row] = seedWord
            
            self.btnConfirm.isEnabled = self.selectedWords.reduce(true, { (res, input) -> Bool in
                return res && input != ""
            })
            
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
        }
        
        return cell!
    }
}
