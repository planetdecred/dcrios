//
//  certificateViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class CertificateViewController: UIViewController {
    
    @IBOutlet weak var certificate: UITextView!
    @IBOutlet weak var certificateDesc: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.title = "certificate".localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        self.certificateDesc.text = "\("certificate".localized):"
        
        loadCert()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func save() -> Void {
        // save here
        guard certificate.text.length > 0 else { return }
        
        Utils.saveCertificate(secretKey: self.certificate.text)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cancel() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadCert(){
        guard let cerContent = try? Utils.loadCertificate() else { return }
        self.certificate.text = cerContent
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
