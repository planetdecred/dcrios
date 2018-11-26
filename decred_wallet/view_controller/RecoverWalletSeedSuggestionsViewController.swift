//
//  RecoverWalletSeedSuggestionsViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit

class RecoverWalletSeedSuggestionsViewController: UIViewController, UITabBarDelegate {
    var popupVerticalPosition : Int = 0
    var suggestions : [String] = []
    
    @IBOutlet weak var popupTabBar: UITabBar!
    @IBOutlet weak var suggestion1: UITabBarItem!
    @IBOutlet weak var suggestion2: UITabBarItem!
    @IBOutlet weak var suggestion3: UITabBarItem!
    @IBOutlet weak var verticalSpacing: NSLayoutConstraint!
    var onSuggestionPick:((String)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupTabBar.delegate = self
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
        verticalSpacing.constant = CGFloat(popupVerticalPosition)
        
        if suggestions.count > 0{
            suggestion1.title = suggestions[0]
        }
        if suggestions.count > 1{
            suggestion2.title = suggestions[1]
        }
        if suggestions.count > 2{
            suggestion3.title = suggestions[2]
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        onSuggestionPick?(item.title!)
    }
}
