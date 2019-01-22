//
//  SeedCheckActiveCellView.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 12/7/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class SeedCheckActiveCellView: UIView {
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var btnSeed1: ContouredButton!
    @IBOutlet weak var btnSeed2: ContouredButton!
    @IBOutlet weak var btnSeed3: ContouredButton!
    var onSeedPick:((Int, String)->Void)?
    
    func setup(seedWords:[String], onSeedPick:@escaping ((Int, String)->Void)){
        self.onSeedPick = onSeedPick
    }

}
