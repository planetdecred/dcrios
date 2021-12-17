//
//  SeedBackupReminderViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SeedBackupReminderViewController: UIViewController {
    @IBOutlet var seedBackupNoticeLabels: [UILabel]?
    var checkedCheckBoxesDict: [Int: Bool] = [:]
    @IBOutlet weak var viewSeedBtn: Button!
    
    var walletID: Int!
    var seedBackupCompleted: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleSeedBackupNoticeLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    private func styleSeedBackupNoticeLabels() {
        let attributedStringStyles = [ AttributedStringStyle(tag: "bold",
                                                             fontFamily: "SourceSansPro-bold",
                                                             fontSize: 16,
                                                             color: UIColor.appColors.text2),
                                      AttributedStringStyle(tag: "orange",
                                                            fontFamily: "SourceSansPro-bold",
                                                            fontSize: 16,
                                                            color: UIColor.appColors.orange),
                                      AttributedStringStyle(tag: "green",
                                                            fontFamily: "SourceSansPro-bold",
                                                            fontSize: 16,
                                                            color: UIColor.appColors.green) ]

        if let seedBackupNoticeLabels = self.seedBackupNoticeLabels {
            for label in seedBackupNoticeLabels {
                label.attributedText = Utils.styleAttributedString(label.text!, styles: attributedStringStyles)
            }
        }
    }

    @IBAction func backupNoticeCheckboxChecked(_ sender: Any) {
        if let checkbox = sender as? Button {
            if let checked = self.checkedCheckBoxesDict[checkbox.tag], checked {
                checkbox.setImage(nil, for: .normal)
                checkbox.borderWidth = 2
                self.checkedCheckBoxesDict[checkbox.tag] = false
            } else {
                checkbox.setImage(UIImage(named: "ic_checkmark_round"), for: .normal)
                checkbox.borderWidth = 0
                self.checkedCheckBoxesDict[checkbox.tag] = true
            }

            var allChecked = true
            for index in 1...5 {
                allChecked = allChecked && self.checkedCheckBoxesDict[index] == true
            }
            self.viewSeedBtn?.isEnabled = allChecked
        }
    }
    
    @IBAction func viewSeedPhraseButtonTapped(_ sender: Any) {
        let seedWordsDisplayVC = SeedWordsDisplayViewController.instantiate(from: .SeedBackup)
        seedWordsDisplayVC.walletID = self.walletID
        seedWordsDisplayVC.seedBackupCompleted = self.seedBackupCompleted
        self.navigationController?.pushViewController(seedWordsDisplayVC, animated: true)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.goBackHome()
    }
}
