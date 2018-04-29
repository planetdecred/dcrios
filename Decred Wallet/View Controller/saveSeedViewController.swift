//
//  saveSeedViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 08/04/2018.
//  Copyright © 2018 Macsleven. All rights reserved.
//

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
    



