//
//  BackupVerifyViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import JGProgressHUD

class BackupVerifyViewController: UIViewController {
    var seedWordsGroupedByThree: [[String]] = []
    var selectedWords: [String] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnConfirm: Button!
    private var banner: Banner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBackButton()
        self.banner = Banner(parent: self)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        self.banner?.dismiss()
        self.tableView?.isUserInteractionEnabled = false
        self.btnConfirm?.startLoading()
        let seed = selectedWords.joined(separator: " ")
        let seedIsValid = DcrlibwalletVerifySeed(seed)
        
        self.tableView?.isUserInteractionEnabled = true
        self.btnConfirm?.stopLoading()
        
        if seedIsValid && seed.elementsEqual(Settings.Keys.Seed) {
            Settings.setValue(true, for: Settings.Keys.SeedBackedUp)
            Settings.clearValue(for: Settings.Keys.Seed)
            self.performSegue(withIdentifier: "toBackupSuccess", sender: nil)
        } else {
            self.banner?.show(type:.error, text: NSLocalizedString("failedToVerify", comment: ""))
        }
    }
    
    private func loadSeedWordsList() -> [String] {
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
}

extension BackupVerifyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripleSeedCell", for: indexPath) as? BackupVerifyTableViewCell
        
        let userSelection = self.selectedWords[indexPath.row]
        cell?.setup(num: indexPath.row, seedWords: seedWordsGroupedByThree[indexPath.row], selectedWord: userSelection)
        
        cell?.onPick = {(index, seedWord) in
            self.banner?.dismiss()
            self.selectedWords[indexPath.row] = seedWord
            
            var allChecked = true;
            for seedIndex in 0...32 {
                allChecked = allChecked
                                && self.selectedWords.indices.contains(seedIndex)
                                && self.selectedWords[seedIndex] != ""
            }
            
            if allChecked {
                self.btnConfirm.isEnabled = true
            }
        }
        
        return cell!
    }
}
