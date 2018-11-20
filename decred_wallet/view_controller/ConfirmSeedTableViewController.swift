//
//  ConfirmSeedTableViewController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit

class ConfirmSeedTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView?
    @IBOutlet weak var vSuggestionsPanel: UIView!
    @IBOutlet var tfSeed: UITextField?
    
    @IBOutlet weak var alcVisibleTableHeight: NSLayoutConstraint!
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
        registerObserverForKeyboardNotification()
        resetSuggestions()
        tableView?.dataSource = self
        hideSuggestions()
        tfSeed?.delegate = self
        allWords = loadSeedWordsList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfSeed?.becomeFirstResponder()
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
    
    @IBAction func onCommitSeedWord(_ sender: Any) {
        let word = tfSeed?.text
        seedWords.append(word)
        textFields[currentSeedIndex]?.text = word
        currentSeedIndex += 1
        tfSeed?.text = ""
        tableView?.reloadData()
        if currentSeedIndex < 33{
            tableView?.scrollToRow(at: IndexPath(row: currentSeedIndex, section: 0), at: .bottom, animated: true)
        }
    }
    
    deinit {
        unregisterObserverForKeyboardNotification()
    }
    
    func registerObserverForKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterObserverForKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    
    @objc func onKeyboardWillShow(_ notification: Notification){
        let notificationInfo = notification.userInfo
        let keyboardFrame = (notificationInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        tableView?.contentOffset = CGPoint(x:0, y:keyboardFrame.height / 2)
        adjustTableHeight(withKeyboard: keyboardFrame.size.height)
    }
    
    @objc func onKeyboardWillHide(_ notification: Notification){
        tableView?.contentOffset = CGPoint(x:0, y:0)
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
    
    private func resetSuggestions(){
        let labelWidth = self.view.frame.size.width / 3
        svSuggestions = UIToolbar(frame: CGRect(x:0.0, y:0.0, width:320.0, height:30.0))
        svSuggestions?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        suggestionLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        suggestionLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        suggestionLabel3 = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 30))
        suggestionLabel1?.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        suggestionLabel2?.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        suggestionLabel3?.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        suggestionLabel1?.font = UIFont(name: "Source Sans Pro", size: 16.0)
        suggestionLabel2?.font = UIFont(name: "Source Sans Pro", size: 16.0)
        suggestionLabel3?.font = UIFont(name: "Source Sans Pro", size: 16.0)
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
        suggestionLabel1?.adjustsFontSizeToFitWidth = true
        suggestionLabel2?.adjustsFontSizeToFitWidth = true
        suggestionLabel3?.adjustsFontSizeToFitWidth = true
        svSuggestions!.items = [suggestion1, suggestion2, suggestion3]
        vSuggestionsPanel.addSubview(svSuggestions!)
    }
    
    private func checkupSeed(){
        let seed = seedWords.reduce("", { x, y in  x + " " + y!})
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            self.performSegue(withIdentifier: "createPasswordSegue", sender: nil)
        }
    }
    
    @objc func pickSuggestion1(){
        if suggestions.count > 0 {
            tfSeed?.text = suggestions[0]
            suggestions = ["","",""]
            hideSuggestions()
        }
    }
    
    @objc func pickSuggestion2(){
        if suggestions.count > 1 {
            tfSeed?.text = suggestions[1]
            suggestions = ["","",""]
            hideSuggestions()
        }
    }
    
    @objc func pickSuggestion3(){
        if suggestions.count > 2 {
            tfSeed?.text = suggestions[2]
            suggestions = ["","",""]
            hideSuggestions()
        }
    }
    
    private func adjustTableHeight(withKeyboard height:CGFloat){
        let totalHeight = view.frame.size.height
        alcVisibleTableHeight.constant = totalHeight - 100.0 - height
        tableView?.scrollRectToVisible(CGRect(x: 0.0, y: 0.0, width: 100, height: 44), animated: false)
    }
    
    private func showSuggestions(){
        vSuggestionsPanel.isHidden = false
    }
    
    private func hideSuggestions(){
        vSuggestionsPanel.isHidden = true
    }
    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
    
}

extension ConfirmSeedTableViewController : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var suggestionsWithFake: [String] = ["","",""]
        let trueSeedIndex = Int.random(in: 0...2)
        suggestionsWithFake[trueSeedIndex] = seedToVerify[currentSeedIndex]

        let fakes = [allWords?[Int.random(in: 0...32)], allWords?[Int.random(in: 0...32)]]
        var fakeIndex = 0
        for i in 0...2 {
            if i != trueSeedIndex {
                suggestionsWithFake[i] = fakes[fakeIndex]!
                fakeIndex += 1
            }
        }
        
        self.suggestions = suggestionsWithFake
        if suggestions.count > 0 {
            showSuggestions()
        }else{
            hideSuggestions()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onCommitSeedWord(textField)
        suggestions = []
        hideSuggestions()
        return true
    }
}
