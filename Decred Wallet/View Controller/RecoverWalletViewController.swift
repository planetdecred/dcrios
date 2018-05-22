//
//  RecoverWalletViewController.swift
//  Decred Wallet
//
//  Created by rails on 18/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit
import Mobilewallet

class RecoverWalletViewController: UIViewController {

    @IBOutlet weak var txSeedCheckCombined: UITextView!
    @IBOutlet weak var tfSeedCheckWord: UITextField!
    @IBOutlet weak var txtInputView: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var txtFieldContainer: UIView!
    var seedWords : String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addAccessory()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action Methods
    @IBAction func btnConfirmSeed(_ sender: Any) {
        if( tfSeedCheckWord.text!.length > 0 ) {
            let seed = NSMutableString(string: seedWords)
            seed.append(tfSeedCheckWord.text! + " ")
            seedWords = seed as String!
            txSeedCheckCombined.text = seedWords
            tfSeedCheckWord.text = ""
        }
        
    }
    @IBAction func btnClearSeed(_ sender: Any) {
        tfSeedCheckWord.text = ""
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        self.view.endEditing(true)

        let flag =  AppContext.instance.walletManager?.verifySeed(txSeedCheckCombined.text)
        if(flag)! {
            self.performSegue(withIdentifier: "encryptWallet", sender: self)
        } else {
            self.showError(error: "Seed was not verifed!")
        }
    }
    
    // MARK: - Utility Methods
    func showError(error: String){
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: {
            
        })
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "encryptWallet" {
            let vc = segue.destination as! CreatePasswordViewController
            vc.seedToVerify = txSeedCheckCombined.text
        } else {
            
        }
        
    }
    
    
    func addAccessory() {
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        customView.addSubview(txtInputView)
        customView.backgroundColor = UIColor.red
        txSeedCheckCombined.inputAccessoryView = customView
        
        txtInputView.translatesAutoresizingMaskIntoConstraints = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        txtFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        btnConfirm.translatesAutoresizingMaskIntoConstraints = false
        btnClear.translatesAutoresizingMaskIntoConstraints = false
        tfSeedCheckWord.translatesAutoresizingMaskIntoConstraints = false
       
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
        
        // Texfeild container constraints
        NSLayoutConstraint.activate([
            txtFieldContainer.leadingAnchor.constraint(equalTo:
                txtInputView.leadingAnchor, constant: 0),
            txtFieldContainer.heightAnchor.constraint(equalToConstant: 42),
            txtFieldContainer.trailingAnchor.constraint(equalTo:
                txtInputView.trailingAnchor, constant: 0),
            txtFieldContainer.bottomAnchor.constraint(equalTo:
                txtInputView.bottomAnchor, constant: 0)
            ])
        
        // Button clear constraints
        NSLayoutConstraint.activate([
            btnClear.leadingAnchor.constraint(equalTo:
                txtInputView.leadingAnchor, constant: 10),
            btnClear.heightAnchor.constraint(equalToConstant: 35),
            btnClear.widthAnchor.constraint(equalToConstant: 118),
            btnClear.topAnchor.constraint(equalTo:
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
        
        // Text field  constraints
        NSLayoutConstraint.activate([
            tfSeedCheckWord.leadingAnchor.constraint(equalTo:
                txtFieldContainer.leadingAnchor, constant: 10),
            tfSeedCheckWord.rightAnchor.constraint(equalTo:
                txtFieldContainer.rightAnchor, constant: -10),
            tfSeedCheckWord.heightAnchor.constraint(equalToConstant: 30),
            tfSeedCheckWord.topAnchor.constraint(equalTo:
                txtFieldContainer.topAnchor, constant: 10)
            ])
    }
    
    
    
    
    
}

// MARK: - TextView Delegate Methods

extension RecoverWalletViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tfSeedCheckWord.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return false
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
}
