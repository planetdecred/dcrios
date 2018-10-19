//
//  RecoverWalletTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

class RecoverWalletTableViewController: UITableViewController {
    var svSuggestions: UIToolbar?
    
    var arrSeed = Array<String>()
    var seedWords: [String?] = []
    var suggestionLabel1 : UILabel?
    var suggestionLabel2 : UILabel?
    var suggestionLabel3 : UILabel?
    var suggestionWords: [String] = []
    var suggestions: [String]{
        set{
            if newValue.count > 0 {
                suggestionLabel1?.text = newValue[0]
            }
            if newValue.count > 1{
                suggestionLabel1?.text = newValue[1]
            }
            if newValue.count > 2{
                suggestionLabel1?.text = newValue[2]
            }
        }
        get{
            return suggestionWords
        }
    }
    
    var seedtmp : [String] = []
    var currentTextField : UITextField?
    var nextTextField : UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetSuggestions()
        seedtmp = loadSeedWordsList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: indexPath) as? RecoveryWalletSeedWordsCell
        cell?.setup(wordNum: indexPath.row, word: seedWords.count <= indexPath.row ? "" : seedWords[indexPath.row] ?? "", seed: seedtmp)
        
        cell?.onNext = {
            cell?.tfSeedWord.resignFirstResponder()
            var nextIndexPath = indexPath
            nextIndexPath.row += 1
            let nextCell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: nextIndexPath) as? RecoveryWalletSeedWordsCell
            nextCell?.tfSeedWord.becomeFirstResponder()
            if let next = nextCell{
                self.currentTextField = next.tfSeedWord
            }
        }
        cell?.onEditingText = {(textField:UITextField) in
            self.currentTextField = textField
            self.svSuggestions?.autoresizingMask = .flexibleHeight
            self.currentTextField?.inputAccessoryView = self.svSuggestions
        }
        cell?.onFoundSeedWord = {(seedSuggestions:[String]) in
            self.suggestions = seedSuggestions
        }
        return cell!
    }
   
    private func resetSuggestions(){
        let labelWidth = self.view.frame.size.width / 3
        svSuggestions = UIToolbar()
        suggestionLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        suggestionLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        suggestionLabel3 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        
        let suggestion1 = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.pickSuggestion1))
        let suggestion2 = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.pickSuggestion2))
        let suggestion3 = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.pickSuggestion3))
        
        suggestion1.customView?.addSubview(suggestionLabel1!)
        suggestion2.customView?.addSubview(suggestionLabel2!)
        suggestion3.customView?.addSubview(suggestionLabel3!)
        
        svSuggestions!.items = [suggestion1, suggestion2, suggestion3]
    }
    
    @objc func pickSuggestion1(){
        currentTextField?.text = suggestions[0]
    }
    
    @objc func pickSuggestion2(){
        currentTextField?.text = suggestions[1]
    }
    
    @objc func pickSuggestion3(){
        currentTextField?.text = suggestions[2]
    }

    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
}
