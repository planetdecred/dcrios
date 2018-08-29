//
//  SeedCheckupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

protocol SeedCheckupProtocol {
    var seedToVerify: String? { get set }
}

class SeedCheckupViewController: UIViewController, SeedCheckupProtocol {
    var seedToVerify: String?
    
    @IBOutlet var txtInputView: UIView!
    @IBOutlet var btnConfirm: UIButton!
    @IBOutlet var txSeedCheckCombined: UITextView!
    @IBOutlet var tfSeedCheckWord: DropDownSearchField!
    @IBOutlet var btnDelete: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // addAccessory()
        let arr = seedToVerify?.components(separatedBy: " ")
        tfSeedCheckWord.itemsToSearch = arr
        tfSeedCheckWord.dropDownListPlaceholder = view
        self.btnConfirm.isEnabled = true
        tfSeedCheckWord.searchResult?.onSelect = { _, item in
            self.txSeedCheckCombined.text.append("\(item) ")
            self.tfSeedCheckWord.clean()
            
            // self.btnConfirm.isEnabled = (self.txSeedCheckCombined.text == "\(self.seedToVerify ?? "") ")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tfSeedCheckWord.becomeFirstResponder()
    }
    
    @IBAction func onDelete(_ sender: Any) {
        self.txSeedCheckCombined.text = ""
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClear(_ sender: Any) {
        self.tfSeedCheckWord.clean()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = seedToVerify
        UserDefaults.standard.set(seedToVerify, forKey: "passphrase")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    // Input views
    func addAccessory() {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        customView.addSubview(txtInputView)
        customView.backgroundColor = UIColor.red
        tfSeedCheckWord.inputAccessoryView = customView
        
        txtInputView.translatesAutoresizingMaskIntoConstraints = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        btnConfirm.translatesAutoresizingMaskIntoConstraints = false
        btnDelete.translatesAutoresizingMaskIntoConstraints = false
        
        // Input view constraints
        NSLayoutConstraint.activate([
            txtInputView.leadingAnchor.constraint(equalTo:
                customView.leadingAnchor, constant: 0),
            txtInputView.topAnchor.constraint(equalTo:
                customView.topAnchor, constant: 0),
            txtInputView.trailingAnchor.constraint(equalTo:
                customView.trailingAnchor, constant: 0),
            txtInputView.bottomAnchor.constraint(equalTo:
                customView.bottomAnchor, constant: 0)
        ])
        
        // Button clear constraints
        NSLayoutConstraint.activate([
            btnDelete.leadingAnchor.constraint(equalTo:
                txtInputView.leadingAnchor, constant: 10),
            btnDelete.heightAnchor.constraint(equalToConstant: 35),
            btnDelete.widthAnchor.constraint(equalToConstant: 118),
            btnDelete.topAnchor.constraint(equalTo:
                txtInputView.topAnchor, constant: 10)
        ])
        
        // Button confirm constraints
        NSLayoutConstraint.activate([
            btnConfirm.rightAnchor.constraint(equalTo:
                txtInputView.rightAnchor, constant: -10),
            btnConfirm.heightAnchor.constraint(equalToConstant: 35),
            btnConfirm.widthAnchor.constraint(equalToConstant: 118),
            btnConfirm.topAnchor.constraint(equalTo:
                txtInputView.topAnchor, constant: 10)
        ])
    }
    
    func enableButton() {
        self.btnConfirm.isEnabled = true
        self.btnConfirm.alpha = 1.0
    }
}
