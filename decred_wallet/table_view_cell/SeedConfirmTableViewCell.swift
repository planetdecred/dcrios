//
//  SeedConfirmTableViewCell.swift
//  Decred Wallet
//
//  Created by rails on 05/12/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//


import UIKit

class SeedConfirmTableViewCell: UITableViewCell {
    @IBOutlet weak var lbWordTitle: UILabel!
    @IBOutlet weak var btnSeed1: ContouredButton!
    @IBOutlet weak var btnSeed2: ContouredButton!
    @IBOutlet weak var btnSeed3: ContouredButton!
    
    var seedWordNumber:Int = 0
    
    var onPick:((String)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(num:Int, seedWords:[String]){
        btnSeed1.setTitle(seedWords[0], for: .normal)
        btnSeed2.setTitle(seedWords[1], for: .normal)
        btnSeed3.setTitle(seedWords[2], for: .normal)
        seedWordNumber = num
        lbWordTitle.text = "Word #\(num)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
