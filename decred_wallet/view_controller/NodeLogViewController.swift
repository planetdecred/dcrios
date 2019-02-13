//
//  NodeLogViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 18/05/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class NodeLogViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Node Log"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadLog(){
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
