//
//  Label.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 15/06/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

@IBDesignable
class Label: UILabel , XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.getLocalizedString
            self.setNeedsLayout()
        }
    }
}
