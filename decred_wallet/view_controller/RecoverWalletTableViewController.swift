//
//  RecoverWalletTableViewController.swift
//  Decred Wallet
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

class RecoverWalletTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var tableView : UITableView!
    @IBOutlet var vDropDownPlaceholder: UIView!
    
    var seedWords: [String?] = []
    var suggestionWords: [String] = []
    var textFields: [UITextField?] = []
    var seedtmp : [String] = []
    var currentTextField : UITextField?
    var nextTextField : UITextField?
    var suggestions: [String] = []
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: indexPath) as? RecoveryWalletSeedWordsCell
        cell?.setup(wordNum: indexPath.row, word: seedWords.count <= indexPath.row ? "" : seedWords[indexPath.row] ?? "", seed: seedtmp, placeholder: vDropDownPlaceholder)
        cell?.tfSeedWord.isEnabled = (indexPath.row == 0 || textFields.count < indexPath.row)
        let cellRect = cell?.frame
        cell?.tfSeedWord.vertPosition = (cellRect?.origin.y)! + (cellRect?.size.height)!
        if indexPath.row > textFields.count {
            textFields[indexPath.row] = cell?.tfSeedWord
        } else {
            textFields.append(cell?.tfSeedWord)
        }
        
        cell?.onPickUpSeed = {(index, pickedSeedWord) in
            cell?.tfSeedWord.text = pickedSeedWord
            self.seedWords.append(pickedSeedWord)
            cell?.tfSeedWord.clean()
            self.vDropDownPlaceholder.isHidden = true
        }
        return cell!
    }

    
    private func checkupSeed(){
        let seed = seedWords.reduce("", { x, y in  x + " " + y!})
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            self.performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
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

extension RecoverWalletTableViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //let f = vDropDownPlaceholder.frame
        
    }
}
