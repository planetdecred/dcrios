//
//  PinWeakness.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit
import PasswordStrength
import CryptoSwift

class PinWeakness {
    let passstrength = MEPasswordStrength()
    func strength(forPin:String) -> Float{
        
        let combinedPass = forPin.md5()
        let res = passstrength.strength(forPassword: combinedPass)
        return res as! Float
    }
    
    func strengthColor(forPin:String) -> UIColor{
        let pinStrength = strength(forPin: forPin)
        let fs = CGFloat(pinStrength)
        print(pinStrength)
        return UIColor(hue: fs, saturation: 0.8, brightness: 1.0, alpha: 1.0)
    }

}

