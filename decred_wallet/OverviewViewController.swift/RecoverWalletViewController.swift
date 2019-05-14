//  RecoverWalletViewController.swift
//  Decred Wallet
//
//  Created by rails on 18/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit
import Mobilewallet

class RecoverWalletViewController: UIViewController {
    @IBOutlet var txSeedCheckCombined: UITextView!
    @IBOutlet var tfSeedCheckWord: DropDownSearchField!
    @IBOutlet var txtInputView: UIView!
    @IBOutlet var btnConfirm: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var btnClear: UIButton!
    @IBOutlet var txtFieldContainer: UIView!
    
    var arrSeed = Array<String>()
    var seedWords: String! = ""
    let seedtmp = "reform aftermath printer warranty gremlin paragraph beehive stethoscope regain disruptive regain Bradbury chisel October trouble forever Algol applicant island infancy physique paragraph woodlark hydraulic snapshot backwater ratchet surrender revenge customer retouch intention minnow"
    var recognizer:UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAccessory()
        self.btnConfirm.isEnabled = true
        txSeedCheckCombined!.text  = ""
        recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        self.btnConfirm.addGestureRecognizer(recognizer!)
        addSearchWords()
        tfSeedCheckWord.searchResult?.onSelect = { [weak self] _, item in
            guard let this = self else { return }
            this.txSeedCheckCombined.text.append("\(item) ")
            this.tfSeedCheckWord.clean()
            let count = this.txSeedCheckCombined!.text!.components(separatedBy: " ").count
            this.btnConfirm.isEnabled = count >= 25
            this.arrSeed.append(item)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfSeedCheckWord.becomeFirstResponder()
        count = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var count = 0
    @objc func longPressHappened(){
        view.endEditing(true)
        print("button pressed long tap")
        count = count + 1
        if count == 1{
            self.btnConfirm.isEnabled = false
            txSeedCheckCombined.text = seedtmp
            let flag = SingleInstance.shared.wallet?.verifySeed(txSeedCheckCombined.text)
            if flag! {
                performSegue(withIdentifier: "createPassword", sender: nil)
                return
            } else {
                showError(error: "Seed was not verifed!")
            }
        }
        
    }
    
    func addSearchWords() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "wordlist", ofType: "txt")
        var list = [String]()
        do {
            let text2 = try String(contentsOf: URL(fileURLWithPath: path!))
            list = text2.components(separatedBy: "\n")
            
            print(list)
        } catch { /* error handling here */ }
        tfSeedCheckWord.itemsToSearch = list
        tfSeedCheckWord.dropDownListPlaceholder = view
        tfSeedCheckWord.searchResult?.onSelect = { _, item in
            self.verifyWord(word: item)
            self.tfSeedCheckWord.clean()
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnConfirmSeed(_ sender: Any) {
        view.endEditing(true)
        print("button pressed tap")
        let flag = SingleInstance.shared.wallet?.verifySeed(txSeedCheckCombined.text) 
        if flag! {
            print("true")
            performSegue(withIdentifier: "createPassword", sender: nil)
        } else {
            print("false")
            showError(error: "Seed was not verifed!")
        }
    }
    
    @IBAction func testConfirm(_ sender: Any) {
       
    }
    func verifyWord(word: String) {
        if word.length > 0 {
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
    
    @IBAction func deleteLastSeed(sender: UIButton) {
        if arrSeed.count > 0 {
            arrSeed.removeLast()
            seedWords = arrSeed.joined(separator: " ")
            txSeedCheckCombined.text = seedWords
        }
        btnClear.isHidden = (arrSeed.count == 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPassword"{
            var seedcheck = segue.destination as? SeedCheckupProtocol
            seedcheck?.seedToVerify = txSeedCheckCombined.text
            
        }
        
    }
    // MARK: - Utility Methods

    func showError(error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: { self.navigationController?.popToRootViewController(animated: true) })
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: {})
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
        btnConfirm.isEnabled = true
        btnConfirm.alpha = 1.0
    }
}
