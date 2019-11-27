//
//  BackupVerifyViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import JGProgressHUD

class BackupVerifyViewController: UIViewController {
    var seedWordsGroupedByThree: [[String]] = []
    var selectedWords: [String] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnConfirm: LoaderButton!
    var errorView:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBackButton()
    }
    
    
    func prepareSeedForVerification(seedToVerify: String) {
        let allSeedWords = loadSeedWordsList()
        let validSeedWords = seedToVerify.split{$0 == " "}.map(String.init)
        
        for seedIndex in 0...32 {
            let seedWordsGrouped = self.breakdownByThree(allSeedWords, validSeedWordToInclude: validSeedWords[seedIndex])
            self.seedWordsGroupedByThree.append(seedWordsGrouped)
            self.selectedWords.append("")
        }
    }
    
    private func breakdownByThree(_ allSeedWords: [String], validSeedWordToInclude: String) -> [String] {
        var suggestionsWithFake: [String] = ["", "", ""]
        let trueSeedIndex = Int.random(in: 0...2)
        suggestionsWithFake[trueSeedIndex] = validSeedWordToInclude
        
        let fakeWordsArray = allSeedWords.filter({
            return ($0.lowercased() != validSeedWordToInclude.lowercased())
        })
        
        var fakeWordsSet = Array(Set(fakeWordsArray))
        let fake1 = Int.random(in: 0...(fakeWordsSet.count) - 1)
        var fakes = [fakeWordsSet.remove(at: fake1)]
        let fake2 = Int.random(in: 0...(fakeWordsSet.count) - 1)
        fakes.append(fakeWordsSet.remove(at: fake2))
        var fakeIndex = 0
        for i in 0...2 {
            if i != trueSeedIndex {
                suggestionsWithFake[i] = fakes[fakeIndex]
                fakeIndex += 1
            }
        }
        
        return  suggestionsWithFake
    }
    
    @IBAction func backbtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        self.dismissError()
        self.tableView?.isUserInteractionEnabled = false
        self.btnConfirm?.startLoading()
        let seed = selectedWords.joined(separator: " ")
        let seedIsValid = DcrlibwalletVerifySeed(seed)
        
        self.tableView?.isUserInteractionEnabled = true
        self.btnConfirm?.stopLoading()
        
        if seedIsValid {
            self.performSegue(withIdentifier: "toBackupSuccess", sender: nil)
        } else {
            self.showError(error: NSLocalizedString("FailedToVerify", comment: ""))
        }
    }
    
    @objc private func dismissError(){
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(dismissError),
                                               object: nil)
        if errorView != nil{
            self.errorView.removeFromSuperview()
            self.errorView = nil
        }
    }
    
    private func showError(error:String){
        
        if errorView == nil{
            errorView = UIView()
            self.view.addSubview(errorView)
            
            errorView.translatesAutoresizingMaskIntoConstraints = false
            errorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 8).isActive = true
            errorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -8).isActive = true
            errorView.topAnchor.constraint(equalTo: self.tableView.topAnchor,constant: 8).isActive = true

            errorView.backgroundColor = UIColor.appColors.decredOrange
            errorView.layer.cornerRadius = 7;
            errorView.layer.shadowColor = UIColor.appColors.shadowColor.cgColor
            errorView.layer.shadowRadius = 4
            errorView.layer.shadowOpacity = 0.24
            errorView.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            let errorLabel = UILabel()
            errorView.addSubview(errorLabel)
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor,constant: 10).isActive = true
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor,constant: -10).isActive = true
            errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor,constant: 5).isActive = true
            errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor,constant: -5).isActive = true
            errorLabel.numberOfLines = 0
            errorLabel.lineBreakMode = .byWordWrapping
            errorLabel.textAlignment = .center
            errorLabel.textColor = .white
            errorLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
            errorLabel.text = error
            
            let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissError))
            swipeUpGesture.direction = .up
            errorView.addGestureRecognizer(swipeUpGesture)
            
            self.perform(#selector(self.dismissError), with: nil, afterDelay: 5)
        }
    }
    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
    
}

extension BackupVerifyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripleSeedCell", for: indexPath) as? BackupVerifyTableViewCell
        
        let userSelection = self.selectedWords[indexPath.row]
        cell?.setup(num: indexPath.row, seedWords: seedWordsGroupedByThree[indexPath.row], selectedWord: userSelection)
        
        cell?.onPick = {(index, seedWord) in
            self.dismissError()
            self.selectedWords[indexPath.row] = seedWord
            
            var allChecked = true;
            for seedIndex in 0...32 {
                allChecked = allChecked
                                && self.selectedWords.indices.contains(seedIndex)
                                && self.selectedWords[seedIndex] != ""
            }
            
            if(allChecked)
            {
                self.btnConfirm.isEnabled = true
            }
        }
        
        return cell!
    }
}
