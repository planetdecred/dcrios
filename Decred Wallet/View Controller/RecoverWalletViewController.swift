//
//  RecoverWalletViewController.swift
//  Decred Wallet
//
//  Created by rails on 18/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit
import Wallet

class RecoverWalletViewController: UIViewController {
    
    @IBOutlet weak var txSeedCheckCombined: UITextView!
    @IBOutlet weak var tfSeedCheckWord: DropDownSearchField!
    @IBOutlet weak var txtInputView: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var txtFieldContainer: UIView!

    var arrSeed = Array<String>()
    var seedWords : String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addAccessory()
        self.addSearchWords()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfSeedCheckWord.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addSearchWords() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "wordlist", ofType: "txt")
        var list = [String]()
        do {
    
            let text2 = try String(contentsOf:URL(fileURLWithPath: path!))
            list = text2.components(separatedBy: "\n")
           
            print(list)
        }
        catch {/* error handling here */}
        tfSeedCheckWord.itemsToSearch = list
        tfSeedCheckWord.dropDownListPlaceholder = view
          tfSeedCheckWord.searchResult?.onSelect = {(index, item) in
            self.verifyWord(word: item)
            self.tfSeedCheckWord.clean()
        }
    }
    // MARK: - Action Methods
    @IBAction func btnConfirmSeed(_ sender: Any) {
        self.view.endEditing(true)
        
        let flag =  AppContext.instance.decrdConnection?.verifySeed(seed: txSeedCheckCombined.text)
        if(flag)! {
            self.performSegue(withIdentifier: "encryptWallet", sender: self)
        } else {
            self.showError(error: "Seed was not verifed!")
        }
        
    }
    
    func verifyWord(word : String) {
        if( word.length > 0 ) {
            arrSeed.append(word)
            seedWords = arrSeed.joined(separator: " ")
            txSeedCheckCombined.text = seedWords
            tfSeedCheckWord.text = ""
            btnClear.isHidden = false
        }
    }
    
    @IBAction func clearSeed(_ sender: Any) {
        txSeedCheckCombined.text = ""
        seedWords = ""
        arrSeed.removeAll()
        btnClear.isHidden = true
    }
    
    @IBAction func deleteLastSeed(sender: UIButton)
    {
        
        if(arrSeed.count > 0) {
            arrSeed.removeLast()
            seedWords = arrSeed.joined(separator: " ")
            print(seedWords)
            txSeedCheckCombined.text = seedWords
        }
        btnClear.isHidden = (arrSeed.count == 0)

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






