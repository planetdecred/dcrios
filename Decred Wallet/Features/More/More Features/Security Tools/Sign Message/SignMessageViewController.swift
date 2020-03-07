//
//  SignMessageViewController.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import JGProgressHUD

class SignMessageViewController: UIViewController, FloatingPlaceholderTextViewDelegate {
    @IBOutlet weak var addressText: FloatingPlaceholderTextView!
    @IBOutlet weak var signatureText: FloatingPlaceholderTextView!
    @IBOutlet weak var messageText: FloatingPlaceholderTextView!
    @IBOutlet weak var signBtn: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var signatureContainer: UIView!
    @IBOutlet weak var viewContHeightContraint: NSLayoutConstraint!
    
    var dcrlibwallet: DcrlibwalletWallet!
    
    var progressHud : JGProgressHUD?
       
    // Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode.
    private lazy var qrImageScanner = QRImageScanner()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dcrlibwallet = WalletLoader.shared.firstWallet!
           
        viewContHeightContraint.constant = 280
        
        let addressPasteButton = UIButton(type: .custom)
        addressPasteButton.setImage(UIImage(named: "ic_paste"), for: .normal)
        addressPasteButton.addTarget(self, action: #selector(onAddressPaste), for: .touchUpInside)
        let addressScanButton = UIButton(type: .custom)
        addressScanButton.setImage(UIImage(named: "ic_scan"), for: .normal)
        addressScanButton.addTarget(self, action: #selector(onScan), for: .touchUpInside)
          
        self.addressText.add(button: addressPasteButton)
        self.addressText.add(button: addressScanButton)
          
        let messagePasteButton = UIButton(type: .custom)
        messagePasteButton.setImage(UIImage(named: "ic_paste"), for: .normal)
        messagePasteButton.addTarget(self, action: #selector(onMessagePaste), for: .touchUpInside)
          
        self.messageText.add(button: messagePasteButton)
          
        self.addressText.textViewDelegate = self
        self.messageText.textViewDelegate = self
        
        self.addressText.placeholder = LocalizedStrings.address
        self.signatureText.placeholder = LocalizedStrings.signature
        self.messageText.placeholder = LocalizedStrings.message
        
        self.hideKeyboardOnTapAround()
       }
    
    func textViewDidChange(_ textView: UITextView) {
         self.toggleSignButtonState()
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
        //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //setup leftBar button
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.signMessage, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
        
        self.navigationItem.leftBarButtonItems =  [barButtonTitle]
        
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
        self.addressText.textViewDidBeginEditing(self.addressText)
        self.addressText.text = UIPasteboard.general.string
        self.toggleSignButtonState()
    }
    
    @objc func onMessagePaste() {
        self.messageText.textViewDidBeginEditing(self.messageText)
        self.messageText.text = UIPasteboard.general.string
        self.toggleSignButtonState()
    }
    
    @objc func pageInfo(){
        let alertController = UIAlertController(title: LocalizedStrings.signMessage, message: LocalizedStrings.signMsgPageInfo, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt, style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func TextFieldChanged() {
        self.toggleSignButtonState()
    }
    
    func toggleSignButtonState() {
        let textCheck =  self.addressText.text!.isEmpty || self.messageText.text!.isEmpty
        self.signBtn.isEnabled = textCheck ?  false : true
        self.signBtn.backgroundColor = textCheck ?  UIColor.appColors.darkGray : UIColor.appColors.lightBlue
    }
    
    @IBAction func signMessage(_ sender: UIButton) {
        self.signMessage()
    }
    
    @IBAction func Copy(_ sender: Any) {
        self.copyData()
    }
    
    @IBAction func clearFields(_ sender: Any) {
        self.addressText.text = nil
        self.messageText.text = nil
        self.signatureText.text = nil
        self.signBtn.backgroundColor = UIColor.appColors.darkGray
        self.signBtn.isEnabled = false
        self.addressText.isUserInteractionEnabled = true
        self.messageText.isUserInteractionEnabled = true
        self.viewContHeightContraint.constant = 280
        self.signatureContainer.isHidden = true
        self.addressText.textViewDidEndEditing(self.addressText)
        self.messageText.textViewDidEndEditing(self.messageText)
        self.signatureText.textViewDidEndEditing(self.signatureText)
    }
       
    func checkAddressFromQrCode(textScannedFromQRCode: String?) {
        guard var capturedText = textScannedFromQRCode else {
            self.addressText.text = ""
            return
        }
           
        if capturedText.starts(with: "decred:") {
            capturedText = capturedText.replacingOccurrences(of: "decred:", with: "")
        }
        self.addressText.textViewDidBeginEditing(self.addressText)
        self.addressText.text = capturedText
       
    }
    
    
    func signMessage() {
        let privatePassType = SpendingPinOrPassword.securityType(for: dcrlibwallet.id_)
               Security.spending(initialSecurityType: privatePassType)
                .with(prompt: LocalizedStrings.signMessage)
                   .with(submitBtnText: LocalizedStrings.confirm)
                   .requestCurrentCode(sender: self) { privatePass, _, dialogDelegate in
                       
                       self.ProcessSignMsg(privatePass: privatePass) { error in
                           if error == nil {
                               dialogDelegate?.dismissDialog()
                               self.dismissView()
                            self.viewContHeightContraint.constant = 382
                                               self.signatureContainer.isHidden = false
                            self.signatureText.textViewDidBeginEditing(self.signatureText)
                                               self.addressText.isUserInteractionEnabled = false
                                               self.messageText.isUserInteractionEnabled = false
                                               self.signBtn.backgroundColor = UIColor.appColors.darkGray
                                               self.signBtn.isEnabled = false
                           } else if error!.isInvalidPassphraseError {
                            let errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.dcrlibwallet.id_)
                            dialogDelegate?.displayError(errorMessage: errorMessage)
                           } else {
                            print("sign error:", error!.localizedDescription)
                            dialogDelegate?.dismissDialog()
                            Utils.showBanner(in: self.view.subviews.first!, type: .error, text: "Failed to sign message. Please try again.")
                        }
                }
        }
    }
    
    func ProcessSignMsg(privatePass: String, next: @escaping (_ error: Error?) -> Void) {
        let address = self.addressText.text
        let message = self.messageText.text
        let finalPassphrase = privatePass as NSString
        let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let signature = try self.dcrlibwallet.signMessage(finalPassphraseData, address: address, message: message)
                DispatchQueue.main.async {
                    self.signatureText.text = signature.base64EncodedString()
                    next(nil)
                }
                
            } catch let error {
                DispatchQueue.main.async {
                    next(error)
                }
            }
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
