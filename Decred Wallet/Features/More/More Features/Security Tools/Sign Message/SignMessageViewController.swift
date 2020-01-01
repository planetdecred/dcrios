//
//  SignMessageViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 30/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit
import Dcrlibwallet
import JGProgressHUD

class SignMessageViewController: UIViewController {
    @IBOutlet weak var addressText: FloatingLabelTextInput!
    @IBOutlet weak var signatureText: FloatingLabelTextInput!
    @IBOutlet weak var messageText: FloatingLabelTextInput!
    @IBOutlet weak var signBtn: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var signatureContainer: UIView!
    @IBOutlet weak var viewContHeightContraint: NSLayoutConstraint!
    
    var dcrlibwallet :DcrlibwalletLibWallet!
    
    var progressHud : JGProgressHUD?
       
    // Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode.
    private lazy var qrImageScanner = QRImageScanner()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        dcrlibwallet = AppDelegate.walletLoader.wallet
           
        viewContHeightContraint.constant = 280
           
        self.TextFieldAddRightButton(textField: self.addressText, imgName: "ic_paste", action: #selector(onAddressPaste), location: 68, index: 0)
        self.TextFieldAddRightButton(textField: self.addressText, imgName: "ic_scan", action: #selector(onScan), location: CGFloat(self.addressText!.subviews.index(0, offsetBy: 22)), index: 1)
        self.TextFieldAddRightButton(textField: self.messageText, imgName: "ic_paste", action: #selector(onMessagePaste), location: 22, index: 0)
           
        self.addressText.addTarget(self, action: #selector(self.TextFieldChanged), for: .editingChanged)
        self.messageText.addTarget(self, action: #selector(self.TextFieldChanged), for: .editingChanged)
        
        self.addressText.placeholder = LocalizedStrings.address
        self.signatureText.placeholder = LocalizedStrings.signature
        self.messageText.placeholder = LocalizedStrings.message
        
        self.hideKeyboardOnTapAround()
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
        //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
                 
        self.addNavigationBackButton()
              
        //setup leftBar button
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.signMessage, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
                     
        self.navigationItem.leftBarButtonItems =  [ (self.navigationItem.leftBarButtonItem)!, barButtonTitle]
        
        //setup rightBar button
        let infoBtn = UIButton(type: .custom)
        infoBtn.setImage(UIImage(named: "info"), for: .normal)
        infoBtn.addTarget(self, action: #selector(pageInfo), for: .touchUpInside)
        infoBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let infoBtnBtnItem:UIBarButtonItem = UIBarButtonItem(customView: infoBtn)
        
        self.navigationItem.rightBarButtonItem = infoBtnBtnItem
    }
       
    @objc func onScan() {
           self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
       }
    
    @objc func onAddressPaste() {
        self.addressText.editingBegan()
        self.addressText.text = UIPasteboard.general.string
        self.toggleSignButtonState()
        self.addressText.editingEnded()
    }
    
    @objc func onMessagePaste() {
        self.messageText.editingBegan()
        self.messageText.text = UIPasteboard.general.string
        self.toggleSignButtonState()
        self.messageText.editingEnded()
    }
    
    @objc func pageInfo(){
        let alertController = UIAlertController(title: LocalizedStrings.signMessage, message: LocalizedStrings.signMsgPageInfo, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt, style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func TextFieldAddRightButton(textField: UITextField, imgName: String, action: Selector , location: CGFloat, index: Int) {
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named: imgName), for: .normal)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(-16), bottom: 0, right: 0)
        rightButton.frame = CGRect(x: CGFloat(textField.frame.size.width - location), y: CGFloat(16), width: CGFloat(20), height: CGFloat(20))
           
        rightButton.addTarget(self, action: action, for: .touchUpInside)
        textField.insertSubview(rightButton, at: index)
        textField.setNeedsDisplay()
    }
    
    
    @objc func TextFieldChanged() {
        self.toggleSignButtonState()
    }
    
    func toggleSignButtonState() {
        let textCheck =  self.addressText.text!.isEmpty || self.messageText.text!.isEmpty
        self.signBtn.isEnabled = textCheck ?  false : true
        self.signBtn.backgroundColor = textCheck ?  UIColor.appColors.darkerGray : UIColor.appColors.lightBlue
    }
    
    @IBAction func signMessage(_ sender: UIButton) {
        self.askPassword()
    }
    
    @IBAction func Copy(_ sender: Any) {
        self.copyData()
    }
    
    @IBAction func clearFields(_ sender: Any) {
        self.addressText.text = nil
        self.messageText.text = nil
        self.signatureText.text = nil
        self.signBtn.backgroundColor = UIColor.appColors.darkerGray
        self.signBtn.isEnabled = false
        self.addressText.isEnabled = true
        self.messageText.isEnabled = true
        self.viewContHeightContraint.constant = 280
        self.signatureContainer.isHidden = true
    }
       
    func checkAddressFromQrCode(textScannedFromQRCode: String?) {
        guard var capturedText = textScannedFromQRCode else {
            self.addressText.text = ""
            return
        }
           
        if capturedText.starts(with: "decred:") {
            capturedText = capturedText.replacingOccurrences(of: "decred:", with: "")
        }
        self.addressText.editingEnded()
        self.addressText.text = capturedText
        self.addressText.editingEnded()
    }
    
    func SignMsg(pass:String) {
        
        self.progressHud = Utils.showProgressHud(withText: LocalizedStrings.signingMessage)
           
        let address = self.addressText.text
        let message = self.messageText.text
        let finalPassphrase = pass as NSString
        let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
           
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
               
            do {
                let signature = try self!.dcrlibwallet.signMessage(finalPassphraseData, address: address, message: message)
                DispatchQueue.main.async {
                       self!.progressHud?.dismiss()
                    this.viewContHeightContraint.constant = 382
                    this.signatureContainer.isHidden = false
                    this.signatureText.editingBegan()
                    this.signatureText.text = signature.base64EncodedString()
                    this.signatureText.editingEnded()
                    this.addressText.isEnabled = false
                    this.messageText.isEnabled = false
                    this.signBtn.backgroundColor = UIColor.appColors.darkerGray
                    this.signBtn.isEnabled = false
                   }
               } catch {
                   DispatchQueue.main.async {
                       self!.progressHud?.dismiss()
                       let alertController = UIAlertController(title: "", message: LocalizedStrings.passwordInvalid, preferredStyle: UIAlertController.Style.alert)
                       alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
                       this.present(alertController, animated: true, completion: nil)
                   }
               }
           }
       }
    
    private func askPassword() {
        
        if SpendingPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            let alert = UIAlertController(title: LocalizedStrings.security, message: LocalizedStrings.promptSpendingPassword, preferredStyle: .alert)
            alert.addTextField { textField in
            textField.placeholder = LocalizedStrings.password.lowercased()
            textField.isSecureTextEntry = true
            }
            
            let okAction = UIAlertAction(title: LocalizedStrings.proceed, style: .default) { _ in
                let tfPasswd = alert.textFields![0] as UITextField
                if (tfPasswd.text?.count)! > 0 {
                    self.SignMsg(pass: tfPasswd.text!)
                    alert.dismiss(animated: false, completion: nil)
                } else {
                    alert.dismiss(animated: false, completion: nil)
                    self.showAlert(message: LocalizedStrings.passwordEmpty, titles: LocalizedStrings.invalidInput)
                }
            }
            
            let CancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .default) { _ in
                alert.dismiss(animated: false, completion: nil)
            }
            alert.addAction(CancelAction)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }else {
            let requestPinVC = RequestPinViewController.instantiate()
            requestPinVC.securityFor = LocalizedStrings.spending
            requestPinVC.showCancelButton = true
            requestPinVC.onUserEnteredPin = { pin in
                self.SignMsg(pass: pin)
            }
            self.present(requestPinVC, animated: true, completion: nil)
        }
    }
    
    private func showAlert(message: String? , titles: String?) {
        let alert = UIAlertController(title: titles, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func copyData(){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            let info = "\(LocalizedStrings.address): \(self.addressText.text ?? "") \n\(LocalizedStrings.message): \(self.messageText.text ?? "") \n\(LocalizedStrings.signature): \(self.signatureText.text ?? "")"
            UIPasteboard.general.string = info
               
            //Alert
            let alertController = UIAlertController(title: "", message: LocalizedStrings.copiedSuccessfully, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
