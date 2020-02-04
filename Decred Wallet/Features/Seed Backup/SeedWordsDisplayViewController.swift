//
//  SeedWordsDisplayViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SeedWordsDisplayViewController: UIViewController {
    @IBOutlet weak var seedWordsTableView: UITableView!
    @IBOutlet weak var topCorneredView: UIView!
    @IBOutlet weak var bottomCorneredView: UIView!
    
    var walletID: Int!
    var seedBackupCompleted: (() -> Void)?
    
    var seed: String = ""
    var seedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.seed = WalletLoader.shared.multiWallet.wallet(withID: self.walletID)?.seed ?? ""
        self.seedWords = self.seed.components(separatedBy: " ")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            self?.seedWordsTableView?.reloadData()
        }
        
        // set cornered views
        topCorneredView.clipsToBounds = true
        topCorneredView.layer.cornerRadius = 14
        topCorneredView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        bottomCorneredView.clipsToBounds = true
        bottomCorneredView.layer.cornerRadius = 14
        bottomCorneredView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let verifySeedVC = segue.destination as! SeedBackupVerifyViewController
        verifySeedVC.prepareSeedForVerification(seedToVerify: self.seed,
                                                walletID: self.walletID,
                                                seedBackupCompleted: seedBackupCompleted)
    }

    @IBAction func backAction(_ sender: UIButton) {
        navigateToBackScreen()
    }
}

// extension to display seed words on the seedWordsTableView
extension SeedWordsDisplayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(ceil(Double(self.seedWords.count) / 2))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "seedWordsDisplayTableViewCell") as! SeedWordsDisplayTableViewCell

       if self.seedWords.indices.contains(indexPath.row) {
           cell.serialNumberLbl1?.text = String(indexPath.row + 1)
           cell.seedWordLbl1?.text = self.seedWords[indexPath.row]
       }

       let secoundColumnIndex = indexPath.row + Int(ceil(Double(seedWords.count) / 2))

       if self.seedWords.indices.contains(secoundColumnIndex) {
           cell.serialNumberLbl2?.text = String(secoundColumnIndex + 1)
           cell.seedWordLbl2?.text = self.seedWords[secoundColumnIndex]
           cell.serialNumberLbl2?.isHidden = false
           cell.seedWordLbl2?.isHidden = false
       } else {
           cell.serialNumberLbl2?.isHidden = true
           cell.seedWordLbl2?.isHidden = true
       }

       return cell
    }
}
