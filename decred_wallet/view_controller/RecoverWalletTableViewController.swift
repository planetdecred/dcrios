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
    
    var seedWords: [String?] = []
    var suggestionLabel1 : UILabel?
    var suggestionLabel2 : UILabel?
    var suggestionLabel3 : UILabel?
    var suggestionWords: [String] = []
    var textFields: [UITextField?] = []
    var seedtmp : [String] = []
    var currentTextField : UITextField?
    var nextTextField : UITextField?
    
    var suggestions: [String]{
        set{
            if newValue.count > 0 {
                suggestionLabel1?.text = newValue[0]
            }else{
                suggestionLabel1?.text = ""
            }
            if newValue.count > 1{
                suggestionLabel2?.text = newValue[1]
            }else{
                suggestionLabel2?.text = ""
            }
            if newValue.count > 2{
                suggestionLabel3?.text = newValue[2]
            }else{
                suggestionLabel3?.text = ""
            }
            suggestionWords = newValue
        }
        get{
            return suggestionWords
        }
    }
    
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
        cell?.tfSeedWord.isEnabled = (indexPath.row == 0 || textFields.count < indexPath.row )
        if indexPath.row > textFields.count{
            textFields[indexPath.row] = cell?.tfSeedWord
        }else{
            textFields.append(cell?.tfSeedWord)
        }
        
        cell?.onNext = {(wordNum: Int) in
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
        
        let suggestion1 = UIBarButtonItem(title: "label1", style: .plain, target: self, action: #selector(self.pickSuggestion1))
        let suggestion2 = UIBarButtonItem(title: "label2", style: .plain, target: self, action: #selector(self.pickSuggestion2))
        let suggestion3 = UIBarButtonItem(title: "label3", style: .plain, target: self, action: #selector(self.pickSuggestion3))
        suggestion1.customView = suggestionLabel1
        suggestion2.customView = suggestionLabel2
        suggestion3.customView = suggestionLabel3
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(pickSuggestion1))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(pickSuggestion2))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(pickSuggestion3))
        suggestionLabel1?.addGestureRecognizer(tap1)
        suggestionLabel2?.addGestureRecognizer(tap2)
        suggestionLabel3?.addGestureRecognizer(tap3)
        suggestionLabel1?.isUserInteractionEnabled = true
        suggestionLabel2?.isUserInteractionEnabled = true
        suggestionLabel3?.isUserInteractionEnabled = true
        
        svSuggestions!.items = [suggestion1, suggestion2, suggestion3]
    }
    
    @objc func pickSuggestion1(){
        if suggestions.count > 0 {
            currentTextField?.text = suggestions[0]
            suggestions = ["","",""]
            nextTextField?.becomeFirstResponder()
        }
    }
    
    @objc func pickSuggestion2(){
        if suggestions.count > 1 {
            currentTextField?.text = suggestions[1]
            suggestions = ["","",""]
            nextTextField?.becomeFirstResponder()
        }
    }
    
    @objc func pickSuggestion3(){
        if suggestions.count > 2 {
            currentTextField?.text = suggestions[2]
            suggestions = ["","",""]
            nextTextField?.becomeFirstResponder()
        }
    }
    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
}
