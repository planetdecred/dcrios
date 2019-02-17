//  AccountsHeaderView.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class AccountsHeaderView: UIView {
    
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelTotalBalance: UILabel!
    @IBOutlet private var labelSpendableBalance: UILabel!
    @IBOutlet var expandOrCollapseDetailsButton: UIButton!
    @IBOutlet weak var arrowDirection: UIButton!
    @IBOutlet weak var accountImg: UIImageView!
    
    var headerIndex: Int = 0
    var arrobool = false
    
    
    var totalBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.labelTotalBalance.attributedText = getAttributedString(str: "\(newValue)", siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount)
            }
        }
    }
    
    @IBAction func expnandOrCollapseAction(_ sender: UIButton) {}
    
    var spendableBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async {
                self.labelSpendableBalance.attributedText = getAttributedString(str: "\(newValue)", siz: 11.0, TexthexColor: UIColor(hex: "#2DD8A3"))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func sethidden(status: Bool){
        if (status){
            setAlpha(valueFig: 0.5)
        }
        else{
            setAlpha(valueFig: 1)
        }
    }
    
    var title: String? {
        get {
            return labelTitle.text
        }
        set {
            DispatchQueue.main.async {
                self.labelTitle.text = newValue
            }
        }
    }
    func setAlpha(valueFig : CGFloat){
        self.labelSpendableBalance.alpha = valueFig
        self.labelTitle.alpha = valueFig
        labelTotalBalance.alpha = valueFig
        self.arrowDirection.alpha = valueFig
        self.labelSpendableBalance.alpha = valueFig
        self.accountImg.alpha = valueFig
    }
}
