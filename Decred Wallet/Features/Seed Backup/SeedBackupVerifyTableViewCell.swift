//
//  SeedBackupVerifyTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SeedBackupVerifyTableViewCell: UITableViewCell {
    @IBOutlet weak var serialNumberLbl: Label!
    @IBOutlet weak var selectedWordLbl: UILabel!
    @IBOutlet weak var btnSeed1: Button!
    @IBOutlet weak var btnSeed2: Button!
    @IBOutlet weak var btnSeed3: Button!

    var seedWordIndex: Int = 0
    var onSeedWordSelected: (( _ selectedWordIndex: Int, _ selectedWord: String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(index: Int, seedWords: [String], selectedWord: String) {
        btnSeed1.setTitle(seedWords[0], for: .normal)
        btnSeed2.setTitle(seedWords[1], for: .normal)
        btnSeed3.setTitle(seedWords[2], for: .normal)

        let buttons = [btnSeed1, btnSeed2, btnSeed3]
        _ = buttons.map({ button in
            button?.isSelected = button?.title(for: .normal) == selectedWord
        })

        seedWordIndex = index
        serialNumberLbl.text = String(index + 1)
        self.setSelectedWordText(selectedWord: selectedWord)
    }

    private func setSelectedWordText(selectedWord: String) {
        self.selectedWordLbl?.text = selectedWord.isEmpty ? "—" : selectedWord
        self.selectedWordLbl?.textColor = selectedWord.isEmpty ? UIColor.appColors.text3 : UIColor.appColors.text2
    }

    private func deselectAllButtons() {
        btnSeed1.isSelected = false
        btnSeed2.isSelected = false
        btnSeed3.isSelected = false
    }

    @IBAction func onSelectSeedWord(_ sender: Button) {
        self.deselectAllButtons()
        sender.isSelected = true
        if let selectedWord = sender.title(for: .normal) {
            self.setSelectedWordText(selectedWord: selectedWord)
            onSeedWordSelected?(sender.tag - 1, selectedWord)
        }
    }
}
