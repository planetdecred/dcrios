//
//  PinSetupViewController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.


import UIKit
import JGProgressHUD
import Mobilewallet

class PinSetupViewController: UIViewController, SeedCheckupProtocol,StartUpPasswordProtocol,PINenteredProtocol {
    var pinInput: String?
    
    var pass_pinToVerify: String?
    
    var senders: String?
    
    @IBOutlet weak var headerText: UILabel!
    
    @IBOutlet weak var pinMarks: PinMarksView!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    @IBOutlet weak var btnCommit: UIButton!
    
    
    var progressHud : JGProgressHUD?
    let pinStrength = PinWeakness()
    let pinInputController = PinInputController(max: 5)
    var seedToVerify: String?
    
    var pin : String = ""{
        didSet {
            pinMarks.entered = pin.count
            pinMarks.update()
            prgsPinStrength.progressTintColor = pinStrength.strengthColor(forPin: pin)
            prgsPinStrength.progress = pinStrength.strength(forPin: pin)
            if pin.count == 5 {
                self.btnCommit.isEnabled = true
            }else{
                self.btnCommit.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        setHeader()
    }
    
    @IBAction func on1(_ sender: Any) {
        pin = pinInputController.input(digit: 1)
    }
    
    @IBAction func on2(_ sender: Any) {
        pin = pinInputController.input(digit: 2)
    }
    
    @IBAction func on3(_ sender: Any) {
        pin = pinInputController.input(digit: 3)
    }
    
    @IBAction func on4(_ sender: Any) {
        pin = pinInputController.input(digit: 4)
    }
    
    @IBAction func on5(_ sender: Any) {
        pin = pinInputController.input(digit: 5)
    }
    
    @IBAction func on6(_ sender: Any) {
        pin = pinInputController.input(digit: 6)
    }
    
    @IBAction func on7(_ sender: Any) {
        pin = pinInputController.input(digit: 7)
    }
    
    @IBAction func on8(_ sender: Any) {
        pin = pinInputController.input(digit: 8)
    }
    
    @IBAction func on9(_ sender: Any) {
        pin = pinInputController.input(digit: 9)
    }
    
    @IBAction func on0(_ sender: Any) {
        pin = pinInputController.input(digit: 0)
    }
    
    @IBAction func onBackspace(_ sender: Any) {
        pin = pinInputController.backspace()
    }

    @IBAction func onCommit(_ sender: Any) {
       // progressHud = showProgressHud(with: "creating wallet...")
        print(senders as Any)
        if senders == "launcher"{
                pass_PIn_Unlock()
        }
        else if senders == "settings"{
            if (UserDefaults.standard.bool(forKey: "secure_wallet")){
                RemovestartupPin_pas()
            }
            else{
                SetstartupPin_pas()
            }
        }
        else if senders == "settingsChangeSpending"{
            print("proccessing settingsChangeSpending")
            ChangeSpendingPIN()
            
        }
        else if senders == "settingsChangeSpendingPin"{
            let sendVC = storyboard!.instantiateViewController(withIdentifier: "SecurityViewController") as! SecurityViewController
            sendVC.senders = "settingsChangeSpending"
            sendVC.pass_pinToVerify = self.pin
            self.navigationController?.pushViewController(sendVC, animated: true)
            print("processing settings")
            
        }
            
        else if senders == "spendFund"{
            pinInput = pin
            UserDefaults.standard.set(pin, forKey: "TMPPIN") //deeply concern about
            UserDefaults.standard.synchronize()
            print("pin copy")
            print(pinInput as Any)
            self.navigationController?.popViewController(animated: true)
        }
        else{
            createWallet()
        }
        
    }
    
    func setHeader(){
        if senders == "launcher"{
                headerText.text = "Enter Startup PIN"

        }
        else if senders == "settings"{
            if (UserDefaults.standard.bool(forKey: "secure_wallet")){
                 headerText.text = "Enter Current PIN"
                
            }
            else{
                headerText.text = "Create Startup PIN"
                
            }
        }else if senders == "settingsChangeSpending"{
            headerText.text = "Change Spending PIN"
        }
        else if senders == "settingsChangeSpendingPin"{
            headerText.text = "Enter Spending PIN"
        }
        else if senders == "spendFund"{
            headerText.text = "Input Spending PIN"
        }
            
        else{
            headerText.text = "Create Spending PIN"
        }
    }
    func createWallet(){
        progressHud = showProgressHud(with: "creating wallet...")
        print("creating")
        let seed = self.seedToVerify!
        let pass = self.pin
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                if SingleInstance.shared.wallet == nil {
                    return
                }
                try SingleInstance.shared.wallet?.createWallet(pass, seedMnemonic: seed)
                DispatchQueue.main.async {
                    self!.progressHud!.dismiss()
                    print("wallet created")
                    UserDefaults.standard.set(pass, forKey: "password") //deeply concern about
                    UserDefaults.standard.set("PIN", forKey: "spendingSecureType") // this stuff
                    UserDefaults.standard.synchronize()
                    createMainWindow()
                    this.dismiss(animated: true, completion: nil)
                }
                print("done")
                return
            } catch let error {
                DispatchQueue.main.async {
                    self!.progressHud!.dismiss()
                    this.showError(error: error)
                    print("wallet error")
                    print(error)
                }
            }
        }
    }
    func SetstartupPin_pas(){
        progressHud = showProgressHud(with: "securing wallet...")
        let key = "public"
        let finalkey = key as NSString
        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
        let pass = self.pin
        
        let finalpass = pass as NSString
        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeyData, newPass: finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    
                    print("passSet")
                    UserDefaults.standard.set(true, forKey: "secure_wallet")
                    UserDefaults.standard.setValue("PIN", forKey: "securitytype")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    func dismissView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func pass_PIn_Unlock(){
        progressHud = showProgressHud(with: "Opening wallet")
        let pass = self.pin
        let finalpass = pass as NSString
        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.open(finalkeypassData)
                
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    self!.createMenu()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    func ChangeSpendingPIN(){
        progressHud = showProgressHud(with: "Changing spending PIN...")
        let key = pass_pinToVerify
        let finalkey = key! as NSString
        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
        let pass = self.pin
        
        let finalpass = pass as NSString
        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePrivatePassphrase(finalkeyData, newPass: finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    UserDefaults.standard.setValue("PIN", forKey: "spendingSecureType")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    
    func RemovestartupPin_pas(){
        progressHud = showProgressHud(with: "Removing Security")
        let key = "public"
        let finalkey = key as NSString
        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
        let pass = self.pin
        let finalpass = pass as NSString
        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeypassData, newPass: finalkeyData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    
                    print("passSet")
                    UserDefaults.standard.set(false, forKey: "secure_wallet")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                    
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    func createMenu(){
        createMainWindow()
    }
    
    func showError(error:Error){
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: {self.progressHud!.dismiss()})
    }
}
