//
//  SeedBackupVerifyTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SeedBackupVerifyTableViewCell: UITableViewCell {
    @IBOutlet weak var lbWordTitle: UILabel!
    @IBOutlet weak var lbWordCountLabel: Label!
    @IBOutlet weak var btnSeed1: Button!
    @IBOutlet weak var btnSeed2: Button!
    @IBOutlet weak var btnSeed3: Button!

    var seedWordNumber: Int = 0
    var onPick: ((Int, String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(num: Int, seedWords: [String], selectedWord: String) {
        btnSeed1.setTitle(seedWords[0], for: .normal)
        btnSeed2.setTitle(seedWords[1], for: .normal)
        btnSeed3.setTitle(seedWords[2], for: .normal)

        let buttons = [btnSeed1, btnSeed2, btnSeed3]
        _ = buttons.map({ button in
            button?.isSelected = button?.title(for: .normal) == selectedWord
        })

        seedWordNumber = num
        lbWordCountLabel.text = String(num + 1)
        self.setWordTitle(selectedWord: selectedWord)
    }

    private func setWordTitle(selectedWord: String) {
        self.lbWordTitle?.text = selectedWord.isEmpty ? "—" : selectedWord
        self.lbWordTitle?.textColor = selectedWord.isEmpty ? UIColor.appColors.lightBluishGray : UIColor.appColors.darkBluishGray
    }

    private func disableAllButtons() {
        btnSeed1.isSelected = false
        btnSeed2.isSelected = false
        btnSeed3.isSelected = false
    }

    @IBAction func onSelectSeedWord(_ sender: Button) {
        self.disableAllButtons()
        sender.isSelected = true
        if let selectedWord = sender.title(for: .normal) {
            self.setWordTitle(selectedWord: selectedWord)
            onPick?(sender.tag - 1, selectedWord)
        }
    }
}
