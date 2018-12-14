//
//  RecoverWalletTableViewController.swift
//  Decred Wallet
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

class RecoverWalletTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView : UITableView!
    @IBOutlet var vDropDownPlaceholder: UIView!
    
    var seedWords: [String] = []
    var suggestionWords: [String] = []
    var textFields: [UITextField?] = []
    var seedtmp : [String] = []
    var currentTextField : UITextField?
    var nextTextField : UITextField?
    var suggestions: [String] = []
    
    var selectedSeedWords: [Int] = []
    var allWords: [String] = []
    var enteredWords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seedtmp = loadSeedWordsList()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripleSeedCell", for: indexPath) as? RecoveryWalletSeedWordsCell
        //cell?.setup(wordNum: indexPath.row, word: seedWords.count <= indexPath.row ? "" : seedWords[indexPath.row] ?? "", seed: seedtmp)
        cell?.setup(num: indexPath.row, seedWords: breakdownByThree(row: indexPath.row), selected: -1)
        
        cell?.onPick = {(index, seedWord) in
            
            self.selectedSeedWords[indexPath.row] = index
            self.enteredWords[indexPath.row] = seedWord
            if indexPath.row < 32{
                tableView.selectRow(at: IndexPath(row: indexPath.row + 1, section: 0), animated: true, scrollPosition: .middle)
            }
//            self.btnConfirm.isEnabled = self.enteredWords.reduce(true, { (res, input) -> Bool in
//                return res && input != ""
//            })
        }
//        cell?.onPickUp = {(index, pickedSeedWord) in
//            cell?.tfSeedWord.text = pickedSeedWord
//            self.seedWords.append(pickedSeedWord)
//            cell?.tfSeedWord.clean()
//            self.vDropDownPlaceholder.removeFromSuperview()
//        }
        return cell!
    }

    
    private func checkupSeed(){
        let seed = seedWords.reduce("", { x, y in  x + " " + y})
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            self.performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
        }
    }
    
    private func breakdownByThree(row:Int) -> [String]{
        let seed = seedtmp//?.split{$0 == " "}.map(String.init)
        
        var suggestionsWithFake: [String] = ["","",""]
        
        let trueSeedIndex = Int.random(in: 0...2)
        let trueSeed = seed[row]
        suggestionsWithFake[trueSeedIndex] = trueSeed ?? "dummy"
        let fakeWordsSet = allWords.filter({
            return ($0.lowercased().hasPrefix((String(trueSeed!.first!)).lowercased()))
        })
        
        let fakes = [fakeWordsSet[Int.random(in: 0...(fakeWordsSet.count) - 1)], fakeWordsSet[Int.random(in: 0...(fakeWordsSet.count)-1)]]
        var fakeIndex = 0
        for i in 0...2 {
            if i != trueSeedIndex {
                suggestionsWithFake[i] = fakes[fakeIndex]
                fakeIndex += 1
            }
        }
        return  suggestionsWithFake
    }
    
    private func pickSelected(row: Int) -> Int{
        if selectedSeedWords.count > row {
            return selectedSeedWords[row]
        } else {
            return -1
        }
    }
    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
    
    @IBAction func onConfirm() {
        checkupSeed()
    }
    
    @IBAction func onClear(_ sender: Any) {
        seedWords = []
        tableView.reloadData()
    }
}
