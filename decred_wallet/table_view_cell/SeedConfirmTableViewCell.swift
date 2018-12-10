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
    
    @IBOutlet weak var vTopLine: UIView!
    @IBOutlet weak var vButtomLine: UIView!
    
    var seedWordNumber:Int = 0
    var onPick:((Int, String)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(num:Int, seedWords:[String], selected: Int){
        btnSeed1.setTitle(seedWords[0], for: .normal)
        btnSeed2.setTitle(seedWords[1], for: .normal)
        btnSeed3.setTitle(seedWords[2], for: .normal)
        
        let buttons = [btnSeed1, btnSeed2, btnSeed3]
        let _ = buttons.map({$0?.isSelected = false})
        if selected >= 0 {
            buttons[selected]?.isSelected = true
        }
        seedWordNumber = num
        lbWordTitle.text = "Word #\(num + 1)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let size1 = btnSeed1.frame.size
        let origin1 = btnSeed1.frame.origin
        UIView.animate(withDuration: 0.3) {
            self.btnSeed1.frame = CGRect(x: selected ? origin1.x - 10 : origin1.x,
                                         y: selected ? 20 : origin1.y,
                                         width: selected ? size1.width + 10 : size1.width,
                                         height: selected ? 40 : 25)
            let size2 = self.btnSeed2.frame.size
            let origin2 = self.btnSeed2.frame.origin
            self.btnSeed2.frame = CGRect(x: origin2.x,
                                         y: selected ? 20 :  origin2.y,
                                         width: selected ? size2.width + 10 : size2.width,
                                         height: selected ? 40 : 25)
            let size3 = self.btnSeed3.frame.size
            let origin3 = self.btnSeed3.frame.origin
            self.btnSeed3.frame = CGRect(x: selected ?  origin3.x + 10  : origin3.x,
                                         y:  selected ? 20 :  origin3.y,
                                         width: selected ? size3.width + 10 : size3.width,
                                         height: selected ? 40 : 25)
            self.vTopLine.isHidden = !selected
            self.vButtomLine.isHidden = !selected
            self.btnSeed1.isEnabled = selected
            self.btnSeed2.isEnabled = selected
            self.btnSeed3.isEnabled = selected
        }
        
    }

}
