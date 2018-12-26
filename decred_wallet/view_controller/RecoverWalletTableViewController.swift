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
        let notificationInfo = notification.userInfo
        let keyboardFrame = (notificationInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let f = tableView.frame
        tableView.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.size.width, height: f.size.height - keyboardFrame.size.height + (tableView.tableHeaderView?.frame.size.height)! )
        
    }
    
    @objc func onKeyboardWillHide(_ notification: Notification){
        let f = view.frame
        tableView.frame = CGRect(x: 0, y: 0, width: f.size.width, height: f.size.height)
    }
    
    
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
        //let cellRect = cell?.frame
        //cell?.tfSeedWord.vertPosition = (cellRect?.origin.y)! + (cellRect?.size.height)!
        if indexPath.row > textFields.count {
            textFields[indexPath.row] = cell?.tfSeedWord
        } else {
            textFields.append(cell?.tfSeedWord)
        }
        
        cell?.onPickUpSeed = {(index, pickedSeedWord) in
            cell?.tfSeedWord.text = pickedSeedWord
            self.seedWords.append(pickedSeedWord)
            cell?.hideDropDown()
            
            if indexPath.row < 32 {
                let nextIndexPath = IndexPath(row: indexPath.row + 1, section: 0 )
                let next = tableView.cellForRow(at: nextIndexPath) as? RecoveryWalletSeedWordsCell
                next?.tfSeedWord.updateSearchResults()
                next?.tfSeedWord.isEnabled = true
                next?.tfSeedWord.becomeFirstResponder()
                tableView.scrollToRow(at: nextIndexPath, at: .middle, animated: true)
                next?.updatePlaceholder(vertPosition: Int(self.dropdownPosition(for: nextIndexPath)))
            }else{
                cell?.tfSeedWord.resignFirstResponder()
            }
        }
        return cell!
    }

    private func dropdownPosition(for indexPath:IndexPath) -> CGFloat{
        let scrollOffset = self.tableView.contentOffset
        let nextCellPos = self.tableView.rectForRow(at: indexPath)
        let dropDownHeight = vDropDownPlaceholder.frame.size.height
        let res = nextCellPos.origin.y - scrollOffset.y
        if indexPath.row < 4{
            return nextCellPos.origin.y + nextCellPos.size.height + 10
        }else if indexPath.row > 29 {
            print("flipped res:\(res)")
            return res - dropDownHeight + nextCellPos.size.height
        }else{
            print("res:\(res)")
            return res
        }
    }
    
    private func checkupSeed(){
        let seed = seedWords.reduce("", { x, y in  x + " " + y!})
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            self.performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
        } else {
            show(error:"Seed is not valid")
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
        if segue.identifier == "confirmSeedSegue"{
            var vc = segue.destination as? SeedCheckupProtocol
            vc?.seedToVerify = seedWords.reduce("", { x, y in  x + " " + y!})

        }
    }
}

extension RecoverWalletTableViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        vDropDownPlaceholder.isHidden = true
    }
}
