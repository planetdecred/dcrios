//
//  RecoveryWalletSeedWordsCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import SearchTextField

class RecoveryWalletSeedWordCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var lbSeedWordNum: UILabel!
    @IBOutlet weak var seedWordAutoComplete: SearchTextField!
    
    private var validSeedWords: [String] = []
    private var fieldIndex: Int?
    
    private var onSeedEntered: ((Int, String, Bool) -> Void)?
    
    func setupAutoComplete(for fieldIndex: Int, filter wordsToFilter: [String], onSeedEntered: @escaping (Int, String, Bool) -> Void) {
        self.fieldIndex = fieldIndex
        self.validSeedWords = wordsToFilter
        self.onSeedEntered = onSeedEntered
        
        // set autocomplete properties
        self.seedWordAutoComplete.autocorrectionType = .no
        self.seedWordAutoComplete.minCharactersNumberToStartFiltering = 3
//        self.seedWordAutoComplete.theme.cellHeight = 50
        self.seedWordAutoComplete.theme.font = UIFont.systemFont(ofSize: 14)
        
        setTextAppearance(self.seedWordAutoComplete)
        
        // setup autocomplete text edit begin/end listeners
        self.seedWordAutoComplete.delegate = self
        
        // setup word selection callback to trigger onSeedEntered
        self.seedWordAutoComplete.itemSelectionHandler = { (filteredResults, itemPosition) in
            let selectedWord = filteredResults[itemPosition].title
            self.seedWordAutoComplete.text = selectedWord
            self.onSeedEntered!(self.fieldIndex!, selectedWord, true)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // enable dropdown on this field
        self.seedWordAutoComplete.filterStrings(validSeedWords)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // disable dropdown on this field after editing ends
        self.seedWordAutoComplete.filterStrings([])
        setTextAppearance(textField)
        self.onSeedEntered!(self.fieldIndex!, textField.text ?? "", false)
        return true
    }
    
    func setTextAppearance(_ textField: UITextField) {
        if textField.text != nil && self.validSeedWords.contains(textField.text!) {
            // valid seed word, use normal text color and only show clear button if user focuses field
            textField.textColor = UIColor.black
            textField.clearButtonMode = .whileEditing
        } else if textField.text != "" {
            // invalid or empty seed word, use error text color and show clear button persistently
            textField.textColor = UIColor.DecredColors.Warning
            textField.clearButtonMode = .always
        }
    }
}
