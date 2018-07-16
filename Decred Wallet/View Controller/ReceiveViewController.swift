//  ReceiveViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class ReceiveViewController: UIViewController {
    @IBOutlet weak var accountDropdown: DropMenuButton!
    
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accountDropdown.backgroundColor = UIColor.clear
        
        if let acc = AppContext.instance.decrdConnection?.getAccounts()?.Acc {
            let accNames = acc.map({ (entity) -> String in
                return entity.Name
            })
            
            accountDropdown.initMenu(
                accNames,
                actions: ({ (ind, val) in
                    debugPrint(val)
                    if let selected = acc.filter({ $0.Name == val }).first {
                        debugPrint(selected)
                    }
                }))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
         self.navigationItem.title = "Receive"
        
        debugPrint(AppContext.instance.decrdConnection?.getAccounts())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
