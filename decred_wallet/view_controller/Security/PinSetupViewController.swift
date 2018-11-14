//
//  PinSetupViewController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.


import UIKit
import MBProgressHUD
import Mobilewallet

class PinSetupViewController: UIViewController, SeedCheckupProtocol {

    @IBOutlet weak var pinMarks: PinMarksView!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    @IBOutlet weak var btnCommit: UIButton!
    
    
    var progressHud : MBProgressHUD?
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
        progressHud = MBProgressHUD(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        view.addSubview(progressHud!)
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
        self.progressHud?.show(animated: true)
        self.progressHud?.label.text = "creating wallet..."
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
                    this.progressHud?.hide(animated: true)
                    UserDefaults.standard.set(pass, forKey: "password")
                    print("wallet created")
                    createMainWindow()
                    this.dismiss(animated: true, completion: nil)
                }
                print("done")
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.hide(animated: true)
                    this.showError(error: error)
                    print("wallet error")
                    print(error)
                }
            }
        }
    }
    
    func showError(error:Error){
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: {self.progressHud?.hide(animated: false)})
    }
}
