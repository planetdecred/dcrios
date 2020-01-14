//
//  SeedBackupReminderViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SeedBackupReminderViewController: UIViewController {
    @IBOutlet var seedBackupNoticeLabels: [UILabel]?
    var checkedCheckBoxesDict: [Int: Bool] = [:]
    @IBOutlet weak var viewSeedBtn: Button!
    var delegate: SeedBackupModalHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        styleSeedBackupNoticeLabels()
    }

    private func styleSeedBackupNoticeLabels() {
        let attributedStringStyles = [ AttributedStringStyle(tag: "bold",
                                                             font: UIFont(name: "SourceSansPro-bold", size: 16),
                                                             color: UIColor.appColors.darkBluishGray),
                                      AttributedStringStyle(tag: "orange",
                                                            font: UIFont(name: "SourceSansPro-bold", size: 16),
                                                            color: UIColor.appColors.orange),
                                      AttributedStringStyle(tag: "green",
                                                            font: UIFont(name: "SourceSansPro-bold", size: 16),
                                                            color: UIColor.appColors.green) ]

        if let seedBackupNoticeLabels = self.seedBackupNoticeLabels {
            for label in seedBackupNoticeLabels {
                label.attributedText = Utils.styleAttributedString(label.text!, styles: attributedStringStyles)
            }
        }
    }

    @IBAction func onCheck(_ sender: Any) {
        if let checkbox = sender as? Button {
            if let checked = self.checkedCheckBoxesDict[checkbox.tag], checked {
                checkbox.setImage(nil, for: .normal)
                checkbox.borderWidth = 2
                self.checkedCheckBoxesDict[checkbox.tag] = false
            } else {
                checkbox.setImage(UIImage(named: "ic_checkmark"), for: .normal)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         let seedWordsDisplayViewController = segue.destination as! SeedWordsDisplayViewController
         seedWordsDisplayViewController.delegate = self.delegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    @IBAction func backAction(_ sender: UIButton) {
        navigateToBackScreen()
    }
}
