//
//  SecurityViewController.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 11/6/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class SecurityViewController: UIViewController, SeedCheckupProtocol {
    var seedToVerify: String?
    var pager: UITabBarController?
    
    @IBOutlet weak var btnPin: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    
    @IBAction func onPasswordTab(_ sender: Any) {
        pager?.selectedIndex = 0
        btnPassword.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        btnPin.backgroundColor = #colorLiteral(red: 0.9449833035, green: 0.9450840354, blue: 0.9490672946, alpha: 1)
    }
    
    @IBAction func onPinTab(_ sender: Any) {
        pager?.selectedIndex = 1
        btnPin.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        btnPassword.backgroundColor = #colorLiteral(red: 0.9449833035, green: 0.9450840354, blue: 0.9490672946, alpha: 1)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPager" {
            pager = segue.destination as? UITabBarController
            pager?.tabBar.isHidden = true
            var seedChecked1 = pager?.viewControllers?.first as? SeedCheckupProtocol
            var seedChecked2 = pager?.viewControllers?.last as? SeedCheckupProtocol
            seedChecked1?.seedToVerify = seedToVerify
            seedChecked2?.seedToVerify = seedToVerify
        }
    }
}
