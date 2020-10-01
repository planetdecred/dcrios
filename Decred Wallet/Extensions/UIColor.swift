//
//  UIColor.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

extension UIColor {
    struct appColors {
        static let thinGray = UIColor.init(hex: "#a4abb1")
        static let darkerGray = UIColor.init(hex: "#4e5f70")
        static let transparentThinGray = UIColor.init(hex: "#a4abb1", alpha: 0.3)
        static let shadowColor = UIColor(hex: "#3D0914")
        static let lighterGrayGray = UIColor(hex: "#140000")
        
        // following are colors from new mockup color guide
        // ultimately other color constants should end up being obsolete once
        // the implementation of the new mockup is completed
        static let blue = UIColor.init(hex: "#1B41B3")
        static let lightBlue = UIColor.init(hex: "#2970FF")
        static let darkBlue = UIColor.init(hex: "#091440")
        static let skyBlue = UIColor.init(hex: "#70CBFF")
        static let lightSkyBlue = UIColor.init(hex: "#E9F8FE")
        
        static let green = UIColor.init(hex: "#41BE53")
        static let lightGreen = UIColor.init(hex: "#C4ECCA")
        static let turquoise = UIColor.init(hex: "#2DD8A3")
        static let darkTurquoise = UIColor.init(hex: "#14A078")
        
        static let orange = UIColor.init(hex: "#ED6D47")
        static let lightOrange = UIColor.init(hex: "#FEB8A5")
        
        static let yellow = UIColor.init(hex: "#FFC84E")
        static let lightYellow = UIColor.init(hex: "#FFE4A7")
        
        static let bluishGray = UIColor.init(hex: "#596D81")
        static let darkBluishGray = UIColor.init(hex: "#3D5873")
        static let lightBluishGray = UIColor.init(hex: "#8997A5")
        
        static let gray = UIColor.init(hex: "#E6EAED")
        static let paleGray = UIColor.init(hex: "#C4CBD2")
        static let lightGray = UIColor.init(hex: "#EDEFF1")
        static let deepGray = UIColor.init(hex:"#030303")
        
        static let offWhite = UIColor(hex:"#F3F5F6")
        static let lightOffWhite = UIColor(hex: "#F9FAFA")
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
