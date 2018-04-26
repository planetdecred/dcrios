//
//  SeedCheckupViewController.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 25.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import UIKit

protocol SeedCheckupProtocol {
    var seedToVerify: String?{get set}
}

class SeedCheckupViewController: UIViewController, SeedCheckupProtocol {
    var seedToVerify: String?
    
    @IBOutlet weak var txSeedCheckCombined: UITextView!
    @IBOutlet weak var tfSeedCheckWord: DropDownSearchField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tfSeedCheckWord.itemsToSearch = seedToVerify?.components(separatedBy: " ")
        tfSeedCheckWord.dropDownListPlaceholder = view
        tfSeedCheckWord.searchResult?.onSelect = {(index, item) in
            self.txSeedCheckCombined.text.append("\(item) ")
            self.tfSeedCheckWord.clean()
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
