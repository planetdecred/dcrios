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
    
    @IBOutlet weak var tfSeedCheckWord: DropDownSearchField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tfSeedCheckWord.itemsToSearch = seedToVerify?.components(separatedBy: " ")
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
