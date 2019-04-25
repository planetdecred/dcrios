//
//  RecoveryWalletSeedWordsCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import SearchTextField

class RecoveryWalletSeedWordsCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var lbSeedWordNum: UILabel!
    @IBOutlet weak var seedWordAutoComplete: SearchTextField!
    
    var seedWords: [String] = []
    
    func setup(wordNum: Int, currentWord: String?, seedWords: [String]) {
        self.seedWords = seedWords
        
        self.lbSeedWordNum.text = "Word #\(wordNum)"
        
        self.seedWordAutoComplete.text = currentWord ?? ""
        self.seedWordAutoComplete.autocorrectionType = .no
        self.seedWordAutoComplete.minCharactersNumberToStartFiltering = 3
        
        self.seedWordAutoComplete.delegate = self
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.seedWordAutoComplete.filterStrings(seedWords)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.seedWordAutoComplete.filterStrings([])
        return true
    }
    
    var onSeedWordSelected: ((_ filteredResults: [SearchTextFieldItem], _ itemPosition: Int) -> Void)? {
        set{
            self.seedWordAutoComplete.itemSelectionHandler = newValue
        }
        get{
            return self.seedWordAutoComplete.itemSelectionHandler
        }
    }
}
