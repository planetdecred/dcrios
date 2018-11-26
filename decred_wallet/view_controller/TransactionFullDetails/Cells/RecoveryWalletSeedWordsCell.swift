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
    var onNext:((Int)->Void)?
    var onEditingText:((Int, UITextField)->Void)?
    var onFoundSeedWord:(([String], UITextField)->Void)?
    
    func setup(wordNum:Int, word: String?, seed:[String]){
        tfSeedWord.delegate = self
        lbWordNum.text = "Word #\(wordNum + 1)"
        tfSeedWord.text = word ?? ""
        self.seed = seed
        self.wordNum = wordNum
        tfSeedWord.autocorrectionType = .no
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onEditingText?(wordNum, textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let suggestions = seed?.filter({
            return ($0.lowercased().hasPrefix((textField.text! + string).lowercased()) && (textField.text?.count)! >= 1)
        })
        onFoundSeedWord?(suggestions!, textField)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isMatchesAnyWordInList(entereText: textField.text) {
            onNext?(wordNum)
        }
        return true
    }
    
    private func isMatchesAnyWordInList(entereText:String?) -> Bool{
        return seed?.filter({
            return ($0.lowercased().hasPrefix(entereText!.lowercased()) && (entereText?.count)! >= 1)
        }).count ?? 0 > 0
    }
}
