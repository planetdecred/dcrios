//
//  HelpViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 01/10/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit
import SafariServices

class HelpViewController: UIViewController,SFSafariViewControllerDelegate {

    @IBOutlet weak var linkBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Help"
    }

    @IBAction func openHelpLink(_ sender: Any) {
        self.openLink(urlString: linkBtn.currentTitle!)
    }
    func openLink(urlString: String) {
        
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            viewController.delegate = self as SFSafariViewControllerDelegate
            
            self.present(viewController, animated: true)
        }
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
