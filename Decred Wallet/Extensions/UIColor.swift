//
//  UIColor.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

extension UIColor {
    
    struct Colors {
        static let orangeColor = UIColor.init(hex: "fd714a")
        static let navigationBarColor = UIColor.init(hex: "689F38")
        static let lightGrey = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        static let lightBlue =  UIColor(red: 206.0/255.0, green: 238.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        static let separaterGrey = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        static let greenishGrey = UIColor.init(hex: "F1F8E9")
        static let black = UIColor.init(hex: "000000")
        static let TextAmount = UIColor.init(hex: "#091440")
        static let displayAamount = UIColor.init(hex: "617386")
    }
    
    struct appColors {
        // decred colors are from https://decred.org/brand/
        static let decredBlue = UIColor.init(hex: "#2970FF")
        static let decredGreen = UIColor.init(hex: "#41BF53")
        static let decredOrange = UIColor.init(hex: "#ED6D47")
        
        static let darkYellowWarning = UIColor.init(hex: "#E7C659")
        static let green = UIColor.init(hex: "#2DD8A3")
        static let lightGray = UIColor.init(hex: "#DEE1E3")
        static let lighterGray = UIColor.init(hex: "#C4CBD2")
        static let offWhite = UIColor(hex:"#F3F5F6")
        static let lightOffWhite = UIColor(hex: "#F9FBFA")
        static let yellowWarning = UIColor.init(hex: "#FFC84E")
        static let thinGray = UIColor.init(hex: "#a4abb1")
        static let darkGray = UIColor.init(hex: "#4e5f70")
        static let transparentThinGray = UIColor.init(hex: "#a4abb1", alpha: 0.3)
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#") {
            hexWithoutSymbol = hex.substring(1)
        }
        
        let scanner = Scanner(string: hexWithoutSymbol)
        var hexInt:UInt32 = 0x0
        scanner.scanHexInt32(&hexInt)
        
        var r:UInt32!, g:UInt32!, b:UInt32!
        switch (hexWithoutSymbol.length) {
        case 3: // #RGB
            r = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
            g = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
            b = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
            break;
        case 6: // #RRGGBB
            r = (hexInt >> 16) & 0xff
            g = (hexInt >> 8) & 0xff
            b = hexInt & 0xff
            break;
        default:
            // TODO:ERROR
            break;
        }
        
        self.init(
            red: (CGFloat(r)/255),
            green: (CGFloat(g)/255),
            blue: (CGFloat(b)/255),
            alpha:alpha)
    }
}
