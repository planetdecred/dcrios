//
//  RecoverWalletTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

class RecoverWalletTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView : UITableView!
    
    var svSuggestions: UIToolbar?
    var seedWords: [String?] = []
    var suggestionLabel1 : UILabel?
    var suggestionLabel2 : UILabel?
    var suggestionLabel3 : UILabel?
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
        cell?.setup(wordNum: indexPath.row, word: seedWords.count <= indexPath.row ? "" : seedWords[indexPath.row] ?? "", seed: seedtmp)
        cell?.tfSeedWord.isEnabled = (indexPath.row == 0 || textFields.count < indexPath.row )
        if indexPath.row > textFields.count{
            textFields[indexPath.row] = cell?.tfSeedWord
        }else{
            textFields.append(cell?.tfSeedWord)
        }
        
        cell?.onNext = {(wordNum: Int) in
            if (wordNum + 1) == self.textFields.count{
                self.checkupSeed()
                return
            }
            let textField = self.textFields[wordNum + 1]
            textField?.isEnabled = true
            textField?.becomeFirstResponder()
            if self.seedWords.count < wordNum {
                self.seedWords[wordNum] = self.textFields[wordNum]?.text
            }else{
                self.seedWords.append(self.textFields[wordNum]?.text)
            }

            self.currentTextField = textField
        }
        
        cell?.onEditingText = {(wordNum:Int, textField:UITextField) in
            self.currentTextField = self.textFields[wordNum]
        }
        
        cell?.onFoundSeedWord = {(seedSuggestions:[String], textField: UITextField) in
            self.suggestions = seedSuggestions
            if (seedSuggestions.count) > 0{
                self.performSegue(withIdentifier: "showRecoverSeedSuggestionsSegue", sender: (textField, cell))
            }
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
    
    @IBAction func onClear(_ sender: Any) {
        seedWords = []
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecoverSeedSuggestionsSegue" {
            let popup = segue.destination as? RecoverWalletSeedSuggestionsViewController
            let textfield = (sender as? (UITextField, RecoveryWalletSeedWordsCell))?.0
            let cell = (sender as? (UITextField, RecoveryWalletSeedWordsCell))?.1
            let cellIndex = self.tableView.indexPath(for: cell!)
            popup?.onSuggestionPick = {(pickedSuggestion) in
                textfield?.text = pickedSuggestion
                popup?.dismiss(animated: false, completion: nil)
            }
            popup?.suggestions = self.suggestions
            let cellFrame = self.tableView.rectForRow(at: cellIndex!)
            popup?.popupVerticalPosition = Int(cellFrame.origin.y + cellFrame.size.height)
        }
    }
}
