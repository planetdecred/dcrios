//
//  certificateViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 18/05/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class certificateViewController: UIViewController {

    @IBOutlet weak var certificate: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.title = "Certificate"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func save() -> Void {
       // save here
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc func cancel() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadCert(){
        
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
