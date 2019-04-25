//
//  RecoverWalletTableViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class RecoverWalletTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var vDropDownPlaceholder: UIView! // todo remove
    @IBOutlet weak var confirm_btn: UIButton!
    
    var currentTextField : UITextField?
    var nextTextField : UITextField?
    var textFields: [UITextField?] = []
    
    var allSeedWords : [String] = []
    var userEnteredSeedWords: [String?] = []
    
    let testSeedWords = "reform aftermath printer warranty gremlin paragraph beehive stethoscope regain disruptive regain Bradbury chisel October trouble forever Algol applicant island infancy physique paragraph woodlark hydraulic snapshot backwater ratchet surrender revenge customer retouch intention minnow"
    
    var recognizer:UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        self.confirm_btn.addGestureRecognizer(recognizer!)
        allSeedWords = loadSeedWordsList()
        
        registerObserverForKeyboardNotification()
    }
    
    // MARK: - Table view data source
    
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        }
    }
    
    @objc func onKeyboardWillHide(_ notification: Notification){
        if let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wordNum = indexPath.row + 1
        let currentWord = userEnteredSeedWords.count <= indexPath.row ? "" : userEnteredSeedWords[indexPath.row] ?? ""
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: indexPath) as? RecoveryWalletSeedWordsCell
        cell?.setup(wordNum: wordNum, currentWord: currentWord, seedWords: allSeedWords)
        cell?.seedWordAutoComplete.isEnabled = (indexPath.row == 0 || textFields.count < indexPath.row)
        
        if indexPath.row > textFields.count {
            textFields[indexPath.row] = cell?.seedWordAutoComplete
        } else {
            textFields.append(cell?.seedWordAutoComplete)
        }
        
//        cell?.onSeedWordSelected = {(pickedSeedWord, index) in
//            let selectedWord = pickedSeedWord[index].title
//
//            cell?.seedAutoComplete.text = selectedWord
//            self.seedWords.append(selectedWord)
//
//            if indexPath.row < 32 {
//                let nextIndexPath = IndexPath(row: indexPath.row + 1, section: 0 )
//                let next = tableView.cellForRow(at: nextIndexPath) as? RecoveryWalletSeedWordsCell
//
//                next?.seedAutoComplete.isEnabled = true
//                next?.seedAutoComplete.becomeFirstResponder()
//                tableView.scrollToRow(at: nextIndexPath, at: .middle, animated: true)
//            } else {
//                cell?.seedAutoComplete.resignFirstResponder()
//            }
//        }
        
        return cell!
    }
    
    private func checkupSeed() {
        let seed = userEnteredSeedWords.reduce("", { x, y in  x + " " + y!})
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            self.performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
        } else {
            show(error:"Seed is not valid")
        }
    }
    
    private func loadSeedWordsList() -> [String] {
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
    
    @IBAction func onConfirm() {
        checkupSeed()
    }
    
    @IBAction func onClear(_ sender: Any) {
        userEnteredSeedWords = []
        tableView.reloadData()
    }
    
    var count = 0
    @objc func longPressHappened(){
        view.endEditing(true)
        count = count + 1
        if (count == 1){
            let flag = SingleInstance.shared.wallet?.verifySeed(testSeedWords)
            if flag! {
                performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
                return
            }
            
            show(error: "Seed was not verifed!")
        }
        
    }
    
    private func show(error:String){
        let alert = UIAlertController(title: "Recovery error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try again", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {
                self.onClear(self)
            })
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmSeedSegue" {
            var vc = segue.destination as? SeedCheckupProtocol
            vc?.seedToVerify = userEnteredSeedWords.reduce("", { x, y in  x + " " + y!})
            if (count == 1) {
                vc?.seedToVerify = testSeedWords
            }
        }
    }
}

extension RecoverWalletTableViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        vDropDownPlaceholder.isHidden = true
    }
}
