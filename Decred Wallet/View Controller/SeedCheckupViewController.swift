//
//  SeedCheckupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

protocol SeedCheckupProtocol {
    var seedToVerify: String?{get set}
}

class SeedCheckupViewController: UIViewController, SeedCheckupProtocol {
    var seedToVerify: String?
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var txSeedCheckCombined: UITextView!
    @IBOutlet weak var tfSeedCheckWord: DropDownSearchField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tfSeedCheckWord.itemsToSearch = seedToVerify?.components(separatedBy: " ")
        tfSeedCheckWord.dropDownListPlaceholder = view
        tfSeedCheckWord.searchResult?.onSelect = {(index, item) in
            self.txSeedCheckCombined.text.append("\(item) ")
            self.tfSeedCheckWord.clean()
            self.btnConfirm.isEnabled = (self.txSeedCheckCombined.text == "\(self.seedToVerify ?? "") ")
        }
    }

    @IBAction func onDelete(_ sender: Any) {
        self.txSeedCheckCombined.text = ""
    }
    
    @IBAction func onClear(_ sender: Any) {
        self.tfSeedCheckWord.clean()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = seedToVerify
    }
    

}
