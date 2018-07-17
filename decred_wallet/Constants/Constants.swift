//
//  Constants.swift
//  Decred Wallet
//
//  Created by rails on 25/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import Foundation
import UIKit
struct GlobalConstants {
    
    //MARK: - Colors
    struct Colors {
       static let orangeColor = UIColor(hex: "fd714a")
       static let navigationBarColor = UIColor(hex: "689F38")
       static let lightGrey = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        static let menuCell = UIColor(red: 241.0/255.0, green: 243.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        static let menuTitle = UIColor(red: 132.0/255.0, green: 139.0/255.0, blue: 144.0/255.0, alpha: 1.0)
       static let lightBlue =  UIColor(red: 206.0/255.0, green: 238.0/255.0, blue: 250.0/255.0, alpha: 1.0)
       static let separaterGrey = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
       static let greenishGrey = UIColor(hex: "F1F8E9")
        static let black = UIColor(hex: "000000")
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
    
}
