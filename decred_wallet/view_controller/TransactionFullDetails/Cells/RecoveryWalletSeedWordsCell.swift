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
    @IBOutlet weak var tfSeedWord: UITextField!
     var seed:[String]?
    var wordNum:Int = 0
    var onNext:(()->Void)?
    func setup(wordNum:Int, word: String?, seed:[String]){
        tfSeedWord.delegate = self
        lbWordNum.text = "Word #\(wordNum + 1)"
        tfSeedWord.text = word ?? ""
        self.seed = seed
        self.wordNum = wordNum
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason){
        if reason == .committed && textField.text == seed?[wordNum] ?? "" {
            onNext?()
        }
    }
}
