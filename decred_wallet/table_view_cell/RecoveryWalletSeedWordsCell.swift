//
//  RecoveryWalletSeedWordsCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import AutoCompletion

class RecoveryWalletSeedWordsCell: UITableViewCell, AutoCompletionTextFieldDataSource, AutoCompletionTextFieldDelegate {
    
    @IBOutlet weak var lbSeedWordNum: UILabel!
    @IBOutlet weak var seedWordAutoComplete: AutoCompletionTextField!
    
    var seedWords: [String]?
    
    func setup(wordNum: Int, currentWord: String?, seedWords: [String]) {
        self.seedWords = seedWords
        
        self.lbSeedWordNum.text = "Word #\(wordNum)"
        
        self.seedWordAutoComplete.text = currentWord ?? ""
        self.seedWordAutoComplete.autocorrectionType = .no
        self.seedWordAutoComplete.suggestionsResultDataSource = self
        self.seedWordAutoComplete.suggestionsResultDelegate = self
    }
    
    /**
     Called by AutoCompletionTextField to get items to display in autoselection drop down.
     */
    func fetchSuggestions(forIncompleteString incompleteString: String!,
                          withCompletionBlock completion: FetchCompletionBlock!) {
        
        let matchingWords = self.seedWords?.filter({ return ($0.lowercased().hasPrefix(incompleteString.lowercased()) && incompleteString.count > 2) })
        completion(matchingWords, incompleteString)
    }
    
    func textField(_ textField: AutoCompletionTextField!, didSelectItem selectedItem: Any!) {
        
    }
    
    var onSeedWordSelected: AutoCompletionTextFieldDelegate {
        set{
            self.seedWordAutoComplete.suggestionsResultDelegate = newValue
        }
        get{
            return self.seedWordAutoComplete.suggestionsResultDelegate
        }
    }
}
