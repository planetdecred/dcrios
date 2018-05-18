//
//  ServerSetTableViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 18/05/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class ServerSetTableViewController: UITableViewController {

    @IBOutlet weak var server_ip: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.title = "Server Address"
        // Do any additional setup after loading the view.
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? "0.0.0.0"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.server_ip.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func save() -> Void {
        // save here
        if !(server_ip.text?.isEmpty)!{
            UserDefaults.standard.set(server_ip.text, forKey: "pref_server_ip")
            UserDefaults.standard.synchronize()
            
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.showMessage(title: "Invali input", userMessage: "please input a valid IP", buttonTitle: "ok")
        }
        
        
    }
    @objc func cancel() -> Void {
    self.navigationController?.popViewController(animated: true)
    }
    func showMessage(title: String,userMessage : String, buttonTitle button:String) {
        let uiAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let uiAction = UIAlertAction(title: button, style: UIAlertActionStyle.default, handler: nil)
        
        uiAlert.addAction(uiAction)
        
        self.present(uiAlert, animated: true, completion: nil)
    }

}
