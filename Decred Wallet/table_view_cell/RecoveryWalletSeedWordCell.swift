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
    @IBOutlet weak var cellComponentTopMargin: NSLayoutConstraint!
    @IBOutlet weak var cellComponentBottomMargin: NSLayoutConstraint!
    
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
        self.onSeedEntered!(self.fieldIndex!, selectedWord, true)
        self.lbSeedWordNum.layer.borderColor = UIColor.appColors.darkBlue.cgColor
        self.cellBorder.layer.borderColor = UIColor.appColors.gray.cgColor
        self.seedWordAutoComplete.textColor = UIColor.appColors.darkBlue
    }
    
    func textEditingEndedWithoutPickingSeedWord() {
        self.setTextAppearance()
        self.onSeedEntered!(self.fieldIndex!, self.seedWordAutoComplete.text ?? "", false)
    }
    
    func textEditingFocussed() {
        self.cellBorder.layer.borderColor =  UIColor.appColors.lightBlue.cgColor
        self.lbSeedWordNum.layer.borderColor =  UIColor.appColors.lightBlue.cgColor
        self.lbSeedWordNum.textColor = UIColor.appColors.lightBlue
    }
    
    func setTextAppearance() {
        let currentText = self.seedWordAutoComplete.text ?? ""
        // validate and define text appearance
        let isValidWordOrEmptyString = self.validSeedWords.contains(currentText) || currentText.isEmpty
        let lbSeedWordNumBorderColor = isValidWordOrEmptyString ? UIColor.appColors.darkBlue.cgColor: UIColor.appColors.orange.cgColor
        let lbSeedWordNumColor = isValidWordOrEmptyString ? UIColor.appColors.darkBlue: UIColor.appColors.orange
        let seedWordAutoCompleteClearButtonMode = isValidWordOrEmptyString ? UITextField.ViewMode.whileEditing : UITextField.ViewMode.always
        let cellBorderBorderColor = isValidWordOrEmptyString ? UIColor.appColors.gray.cgColor: UIColor.appColors.orange.cgColor
        let seedWordAutoCompleteTextColor = isValidWordOrEmptyString ? UIColor.appColors.darkBlue: UIColor.appColors.orange
        
        self.lbSeedWordNum.textColor = lbSeedWordNumColor
        self.lbSeedWordNum.layer.borderColor = lbSeedWordNumBorderColor
        self.seedWordAutoComplete.textColor = seedWordAutoCompleteTextColor
        self.seedWordAutoComplete.clearButtonMode = seedWordAutoCompleteClearButtonMode
        self.cellBorder.layer.borderColor = cellBorderBorderColor
    }
}
