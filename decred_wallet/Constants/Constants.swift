//
//  Constants.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

struct GlobalConstants {
    
    //MARK: - Colors
    struct Colors {
        static let orangeColor = UIColor(hex: "fd714a")
        static let navigationBarColor = UIColor(hex: "689F38")
        static let lightGrey = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        static let menuCell = UIColor(hex:"#F9FAFA")
        static let menuTitle = UIColor(red: 132.0/255.0, green: 139.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        static let lightBlue =  UIColor(red: 206.0/255.0, green: 238.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        static let separaterGrey = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        static let greenishGrey = UIColor(hex: "F1F8E9")
        static let black = UIColor(hex: "000000")
        static let TextAmount = UIColor(hex: "#091440")
        static let displayAamount = UIColor(hex: "617386")
    }
    
    //MARK: - Storyboard
    struct ConstantStoryboardMain {
        static let IDENTIFIER_STORYBOARD_MAIN = "Main"
        static func getControllerInstance(identifier:String, storyBoard:String) -> UIViewController {
            return UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        }
    }
    
    //MARK: - Cell Identifiers
    struct VCIdentifier {
        
    }
    
    //MARK: - Cell Identifiers
    struct CellIdentifier {
        
    }
    
    struct Strings {
        static let VOTE = "VOTE"
        static let REVOCATION = "REVOCATION"
        static let TICKET_PURCHASE = "TICKET_PURCHASE"
        static let COINBASE = "COINBASE"
        static let REGULAR = "REGULAR"
        static let TESTNET_HD_PATH = "m / 44' / 1' /"
        static let LEGACY_TESTNET_HD_PATH = "m / 44' / 11' /"
        static let MAINNET_HD_PATH = "m / 44' / 42' /"
        static let LEGACY_MAINNET_HD_PATH = "m / 44' / 20' /"
        static let DELETE_WALLET = "delete_wallet"
        static let USE_TESTNET = "pref_use_testnet"
    }
}
