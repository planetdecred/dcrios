//
//  RecoverWalletTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

class RecoverWalletTableViewController: UITableViewController {
    @IBOutlet var svSuggestions: UIStackView!
    
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
        let labels = resetSuggestions()
        suggestionLabel1 = labels.0
        suggestionLabel2 = labels.1
        suggestionLabel3 = labels.2
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
            self.currentTextField?.inputAccessoryView = self.svSuggestions
        }
        return cell!
    }
   
    private func resetSuggestions() -> (UILabel, UILabel, UILabel){
        let labelWidth = svSuggestions.frame.size.width / 3
        let suggestionLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        let suggestionLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        let suggestionLabel3 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        svSuggestions.addArrangedSubview(suggestionLabel1)
        svSuggestions.addArrangedSubview(suggestionLabel2)
        svSuggestions.addArrangedSubview(suggestionLabel3)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(pickSuggestion1))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(pickSuggestion2))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(pickSuggestion3))
        suggestionLabel1.addGestureRecognizer(tap1)
        suggestionLabel2.addGestureRecognizer(tap2)
        suggestionLabel3.addGestureRecognizer(tap3)
        suggestionLabel1.isUserInteractionEnabled = true
        suggestionLabel2.isUserInteractionEnabled = true
        suggestionLabel3.isUserInteractionEnabled = true
        
        return (suggestionLabel1, suggestionLabel2, suggestionLabel3)
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
