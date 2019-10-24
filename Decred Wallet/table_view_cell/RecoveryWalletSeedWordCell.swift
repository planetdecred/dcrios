//
//  RecoveryWalletSeedWordsCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class RecoveryWalletSeedWordCell: UITableViewCell {
    @IBOutlet weak var lbSeedWordNum: UILabel!
    @IBOutlet weak var seedWordAutoComplete: DropDownSearchField!
    @IBOutlet weak var cellBorder: UIView!
    
    private var validSeedWords: [String] = []
    private var fieldIndex: Int?
    
    private var onSeedEntered: ((Int, String, Bool) -> Void)?
    
    func setupAutoComplete(for fieldIndex: Int, filter wordsToFilter: [String], dropDownListPlaceholder: UIView, onSeedEntered: @escaping (Int, String, Bool) -> Void) {
        
        self.fieldIndex = fieldIndex
        self.validSeedWords = wordsToFilter
        self.onSeedEntered = onSeedEntered
        self.setTextAppearance()
        
        // set autocomplete properties
        self.seedWordAutoComplete.autocorrectionType = .no
        self.seedWordAutoComplete.setupDropdownTable(with: wordsToFilter, and: dropDownListPlaceholder)

        // set up autocomplete callbacks
        self.seedWordAutoComplete.onWordSelected = self.seedWordSelected
        self.seedWordAutoComplete.onTextChanged = self.textEditingEndedWithoutPickingSeedWord
        self.seedWordAutoComplete.onTextFocused = self.textEditingFocussed
    }
    
    func seedWordSelected(_ selectedWord: String) {
        self.seedWordAutoComplete.text = selectedWord
       // self.setTextAppearance()
        self.onSeedEntered!(self.fieldIndex!, selectedWord, true)
        self.lbSeedWordNum.layer.borderColor = UIColor(hex: "#3d5873").cgColor
        self.cellBorder.layer.borderColor = UIColor(hex: "#e6eaed").cgColor
        self.seedWordAutoComplete.textColor = UIColor(hex: "#3d5873")
    }
    
    func textEditingEndedWithoutPickingSeedWord() {
        self.setTextAppearance()
        self.onSeedEntered!(self.fieldIndex!, self.seedWordAutoComplete.text ?? "", false)
    }
    
    func textEditingFocussed() {
        self.cellBorder.layer.borderColor =  UIColor(hex: "#2970ff").cgColor
        self.lbSeedWordNum.layer.borderColor =  UIColor(hex: "#2970ff").cgColor
       // self.lbSeedWordNum.textColor = UIColor(hex: "#2970ff")
    }
    
    
    func setTextAppearance() {
        let currentText = self.seedWordAutoComplete.text ?? ""
        if self.validSeedWords.contains(currentText) {
            // valid seed word, use normal text color and only show clear button if user focuses field
            self.seedWordAutoComplete.clearButtonMode = .whileEditing
        } else if currentText != "" {
            // invalid seed word, use error text color and show clear button persistently
            self.seedWordAutoComplete.textColor = UIColor.appColors.decredOrange
            self.seedWordAutoComplete.clearButtonMode = .always
            lbSeedWordNum.layer.borderColor = UIColor.appColors.decredOrange.cgColor
                   cellBorder.layer.borderColor = UIColor.appColors.decredOrange.cgColor
        }
        else{
             self.seedWordAutoComplete.textColor = UIColor(hex: "#3d5873")
            lbSeedWordNum.layer.borderColor = UIColor(hex: "#3d5873").cgColor
            cellBorder.layer.borderColor = UIColor(hex: "#e6eaed").cgColor
        }
    }
}
