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
        setupCell(selected: false)
    }

    func setup(num:Int, seedWords:[String], selected: Int){
        setupCell(selected: false)
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
        setupCell(selected: selected)
    }
    
    private func setupCell(selected:Bool){
        let fHorizCenter = frame.size.width / 2
        
        if selected && btnSeed1.frame.origin.x == (fHorizCenter - 160) { return }
       
        let rTitle = CGRect(x: fHorizCenter - lbWordTitle.frame.size.width / 2,
                            y: 5,
                            width: lbWordTitle.frame.size.width,
                            height: 21)
        let rSelTitle = CGRect(x: fHorizCenter - lbWordTitle.frame.size.width / 2,
                               y: 1,
                               width: lbWordTitle.frame.size.width,
                               height: 21)
        
        let rBtn1 = CGRect(x: fHorizCenter - 140,
                           y: 29,
                           width: 87,
                           height: 25)
        let rBtn2 = CGRect(x: fHorizCenter - 44,
                           y: 29,
                           width: 87,
                           height: 25)
        let rBtn3 = CGRect(x: fHorizCenter + 54,
                           y: 29,
                           width: 87,
                           height: 25)
        
        
        let rSelBtn1 = CGRect(x: fHorizCenter - 160,
                              y: 38,
                              width: 97,
                              height: 45)
        let rSelBtn2 = CGRect(x: fHorizCenter - 44,
                              y: 38,
                              width: 97,
                              height: 45)
        let rSelBtn3 = CGRect(x: fHorizCenter + 74,
                              y: 38,
                              width: 87,
                              height: 45)
        
        
        UIView.animate(withDuration: 0.3) {
            self.lbWordTitle.font = selected ? UIFont(name: "SourceSansPro-Regular", size: 20) : UIFont(name: "SourceSansPro-Regular", size: 17)
            self.lbWordTitle.textColor = selected ?
                UIColor(hex: "#091440") :
                UIColor(hex: "#C4CBD2")
            
            self.btnSeed1.frame = selected ? rSelBtn1 : rBtn1
            self.btnSeed2.frame = selected ? rSelBtn2 : rBtn2
            self.btnSeed3.frame = selected ? rSelBtn3 : rBtn3
            
            self.btnSeed1.titleLabel?.font = selected ? UIFont(name: "SourceSansPro-Regular", size: 17) : UIFont(name: "SourceSansPro-Regular", size: 15)
            self.btnSeed2.titleLabel?.font = selected ? UIFont(name: "SourceSansPro-Regular", size: 17) : UIFont(name: "SourceSansPro-Regular", size: 15)
            self.btnSeed3.titleLabel?.font = selected ? UIFont(name: "SourceSansPro-Regular", size: 17) : UIFont(name: "SourceSansPro-Regular", size: 15)
            
            self.lbWordTitle.frame = selected ? rSelTitle : rTitle
            self.vTopLine.isHidden = !selected
            self.vButtomLine.isHidden = !selected
            self.btnSeed1.isEnabled = selected
            self.btnSeed2.isEnabled = selected
            self.btnSeed3.isEnabled = selected
        }
    }
    
    private func disableAllButtons(){
        btnSeed1.isSelected = false
        btnSeed2.isSelected = false
        btnSeed3.isSelected = false
    }
    
    @IBAction func onSelectSeedWord(_ sender: UIButton) {
        disableAllButtons()
        sender.isSelected = true
    }
    
    
}
