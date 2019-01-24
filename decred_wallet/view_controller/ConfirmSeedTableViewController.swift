//
//  ConfirmSeedTableViewController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit

//Obsolete
class ConfirmSeedTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView?
    
    var allWords: [String]?
    var svSuggestions: UIToolbar?
    var seedWords: [String?] = []
    var suggestionLabel1 : UILabel?
    var suggestionLabel2 : UILabel?
    var suggestionLabel3 : UILabel?
    var suggestionWords: [String] = []
    var textFields: [UITextField?] = []
    var seedToVerify : [String] = []

    var currentSeedIndex = 0
    
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
        tableView?.dataSource = self
        allWords = loadSeedWordsList()
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        checkupSeed()
    }
    
    @IBAction func onClear(_ sender: Any) {
        seedWords = []
        currentSeedIndex = 0
        tableView?.reloadData()
        tableView?.scrollToRow(at: IndexPath(row: currentSeedIndex, section: 0), at: .bottom, animated: true)
    }

    func onCommitSeedWord(text:String) {
        seedWords.append(text)
        textFields[currentSeedIndex]?.text = text
        currentSeedIndex += 1
        tableView?.reloadData()
        if currentSeedIndex < 33{
            //tableView?.scrollToRow(at: IndexPath(row: currentSeedIndex, section: 0), at: .bottom, animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmSeedCell", for: indexPath) as? ConfirmSeedViewCell
        cell?.setup(wordNum: indexPath.row, word: seedWords.count <= indexPath.row ? "" : seedWords[indexPath.row] ?? "", seed: self.seedToVerify)
        cell?.tfSeedWord.isEnabled = (indexPath.row == 0 || textFields.count < indexPath.row )
        if indexPath.row > textFields.count{
            textFields[indexPath.row] = cell?.tfSeedWord
        }else{
            textFields.append(cell?.tfSeedWord)
        }
        
        return cell!
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSeedIndex = indexPath.row
        performSegue(withIdentifier: "showSuggestionsPopover", sender: indexPath)
    }

    
    private func checkupSeed(){
        let seed = seedWords.reduce("", { x, y in  x + " " + y!})
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            self.performSegue(withIdentifier: "createPasswordSegue", sender: nil)
        }
    }
    

    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSuggestionsPopover" {
            let popup = segue.destination as? SeedSuggestionsViewController
            popup?.suggestions = prepareSuggestions(for: (sender as! IndexPath).row)
            popup?.onSuggestionPicked = {(text) in
                self.onCommitSeedWord(text: text)
            }
        }
    }
    
    private func prepareSuggestions(for row:Int) -> [String]{
        var suggestionsWithFake: [String] = ["","",""]
        let trueSeedIndex = Int.random(in: 0...2)
        let trueSeed = seedToVerify[currentSeedIndex]
        suggestionsWithFake[trueSeedIndex] = trueSeed
        let fakeWordsSet = allWords?.filter({
                    return ($0.lowercased().hasPrefix((String(trueSeed.first!)).lowercased()))
                })
        let fakes = [fakeWordsSet?[Int.random(in: 0...(fakeWordsSet?.count)!-1)], fakeWordsSet?[Int.random(in: 0...(fakeWordsSet?.count)!-1)]]
        var fakeIndex = 0
        for i in 0...2 {
            if i != trueSeedIndex {
                suggestionsWithFake[i] = fakes[fakeIndex]!
                fakeIndex += 1
            }
        }
        return  suggestionsWithFake
    }
}
