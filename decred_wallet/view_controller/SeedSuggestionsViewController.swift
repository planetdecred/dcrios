//
//  SeedSuggestionsViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit

//Obsolete
class SeedSuggestionsViewController: UIViewController, UITabBarDelegate {
    
    var suggestions = ["","",""]
    @IBOutlet var suggestion1: UITabBarItem!
    @IBOutlet var suggestion2: UITabBarItem!
    @IBOutlet var suggestion3: UITabBarItem!
    var onSuggestionPicked: ((String)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        suggestion1.setTitleTextAttributes([.font : UIFont(name: "Source Sans Pro", size: 16.0)!, .foregroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)], for: .normal)
        suggestion2.setTitleTextAttributes([.font : UIFont(name: "Source Sans Pro", size: 16.0)!, .foregroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)], for: .normal)
        suggestion3.setTitleTextAttributes([.font : UIFont(name: "Source Sans Pro", size: 16.0)!, .foregroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)], for: .normal)
        suggestion1.title = suggestions[0]
        suggestion2.title = suggestions[1]
        suggestion3.title = suggestions[2]
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        onSuggestionPicked?(item.title!)
        dismiss(animated: true, completion: nil)
    }

}
