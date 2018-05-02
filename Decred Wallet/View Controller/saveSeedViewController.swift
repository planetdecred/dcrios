//
//  saveSeedViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit
class saveSeedViewController : UIViewController {
    
    @IBOutlet weak var warningCont: UILabel!
    
    @IBOutlet weak var warninicon: UIView!
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        warningCont.layer.borderColor = UIColor(hex: "fd714a").cgColor
        warninicon.layer.borderColor = UIColor(hex: "fd714a").cgColor
    }
    

    }
    



