//
//  RecoverWalletSeedSuggestionsViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit

class RecoverWalletSeedSuggestionsViewController: UIViewController {
    var popupVerticalPosition : Int = 0
    var suggestions : [String] = []
    
    @IBOutlet weak var popupTabBar: UITabBar!
    @IBOutlet weak var suggestion1: UITabBarItem!
    @IBOutlet weak var suggestion2: UITabBarItem!
    @IBOutlet weak var suggestion3: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suggestion1.setTitleTextAttributes([
            .font: UIFont(name: "Source Sans Pro", size: 16)!,
            .foregroundColor: #colorLiteral(red: 0.4196078431, green: 0.737254902, blue: 1, alpha: 1)], for: .normal)
        suggestion2.setTitleTextAttributes([
            .font: UIFont(name: "Source Sans Pro", size: 16)!,
            .foregroundColor: #colorLiteral(red: 0.4196078431, green: 0.737254902, blue: 1, alpha: 1)], for: .normal)
        suggestion3.setTitleTextAttributes([
            .font: UIFont(name: "Source Sans Pro", size: 16)!,
            .foregroundColor: #colorLiteral(red: 0.4196078431, green: 0.737254902, blue: 1, alpha: 1)], for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
