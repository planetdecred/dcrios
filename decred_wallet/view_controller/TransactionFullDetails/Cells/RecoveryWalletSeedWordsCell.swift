//
//  RecoveryWalletSeedWordsCell.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

class RecoveryWalletSeedWordsCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var lbWordNum: UILabel!
    @IBOutlet weak var tfSeedWord: DropDownSearchField!
    
    var seed:[String]?
    var wordNum:Int = 0
    var onPickUpSeed:((Int, String)->Void)?{
        set{
            tfSeedWord.onSelect = newValue
        }
        get{
            return tfSeedWord.onSelect
        }
    }
    
    func setup(wordNum:Int, word: String?, seed:[String], placeholder: UIView){
        tfSeedWord.dropDownListPlaceholder = placeholder
        lbWordNum.text = "Word #\(wordNum + 1)"
        tfSeedWord.text = word ?? ""
        self.seed = seed
        self.wordNum = wordNum
        tfSeedWord.autocorrectionType = .no
        tfSeedWord.itemsToSearch = seed
        tfSeedWord.vertPosition = self.frame.origin.y
        tfSeedWord.setupDropdownTable()
    }
    
    func updatePlaceholder(vertPosition: Int){
        tfSeedWord.updatePlaceholder(position:vertPosition)
    }
}
