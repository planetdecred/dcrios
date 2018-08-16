//
//  DataTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

struct DataTableViewCellData {
    
    init(imageUrl: String, text: String) {
        self.imageUrl = imageUrl
        self.text = text
        
    }
    var imageUrl: String
    var text: String
}

class DataTableViewCell : BaseTableViewCell {
    
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    
    override func awakeFromNib() {
        self.dataText?.font = UIFont.systemFont(ofSize: 16)
    }
    
    override class func height() -> CGFloat {
        return 80
    }
    
    override func setData(_ data: Any?) {
        if let data = data as? DataTableViewCellData {
            //self.dataImage.setRandomDownloadImage(80, height: 80)
            self.dataText.text = data.text
            
            if(data.text.hasPrefix("-")){
                self.dataImage?.image = UIImage(named: "debit")
            }
            else{
                self.dataImage?.image = UIImage(named: "credit")
            }
        }
    }
}
