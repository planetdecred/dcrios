//
//  certificateViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 18/05/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class certificateViewController: UIViewController {
    @IBOutlet var certificate: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        self.navigationItem.title = "Certificate"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        // Do any additional setup after loading the view.

        self.loadCert()
        self.certificate.addDoneButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func save() {
        // save here
        guard self.certificate.text.length > 0 else { return }

        saveCertificate(secretKey: self.certificate.text)
        self.navigationController?.popViewController(animated: true)
    }

    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }

    func loadCert() {
        guard let cerContent = try? loadCertificate() else { return }
        self.certificate.text = cerContent
    }
}
