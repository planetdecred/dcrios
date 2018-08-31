//
//  SeedCheckupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

protocol SeedCheckupProtocol {
    var seedToVerify: String?{get set}
}

class SeedCheckupViewController: UIViewController, SeedCheckupProtocol {
    var seedToVerify: String?
    
    @IBOutlet weak var txtInputView: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var txSeedCheckCombined: UITextView!
    @IBOutlet weak var tfSeedCheckWord: DropDownSearchField!
    @IBOutlet weak var btnDelete: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addAccessory()
        let arr = seedToVerify?.components(separatedBy: " ")
        tfSeedCheckWord.itemsToSearch = arr
        tfSeedCheckWord.dropDownListPlaceholder = view
        self.btnConfirm.isEnabled = false
        tfSeedCheckWord.searchResult?.onSelect = {(index, item) in
            self.txSeedCheckCombined.text.append("\(item) ")
            self.tfSeedCheckWord.clean()
            
            self.btnConfirm.isEnabled = (self.txSeedCheckCombined.text == "\(self.seedToVerify ?? "") ")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfSeedCheckWord.becomeFirstResponder()
    }

    @IBAction func onDelete(_ sender: Any) {
        self.txSeedCheckCombined.text = ""
    }
    
    @IBAction func onClear(_ sender: Any) {
        self.tfSeedCheckWord.clean()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
                customView.bottomAnchor, constant: 0),
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
        btnConfirm.isEnabled = true
        btnConfirm.alpha = 1.0
    }
    

}
