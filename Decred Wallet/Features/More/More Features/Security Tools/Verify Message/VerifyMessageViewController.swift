//
//  VerifyMessageViewController.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class VerifyMessageViewController: UIViewController {
    @IBOutlet weak var addressText: FloatingLabelTextInput!
    @IBOutlet weak var signatureText: FloatingLabelTextInput!
    @IBOutlet weak var messageText: FloatingLabelTextInput!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var isValidMsgContainer: UIView!
    @IBOutlet weak var viewContHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var isValidImg: UIImageView!
    @IBOutlet weak var isValidSignature: UILabel!
    
     var dcrlibwallet :DcrlibwalletLibWallet!
       
    // Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode.
    private lazy var qrImageScanner = QRImageScanner()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        dcrlibwallet = AppDelegate.walletLoader.wallet
           
        viewContHeightContraint.constant = 280
           
        self.TextFieldAddRightButton(textField: self.addressText, imgName: "ic_paste", action: #selector(onAddressPaste), location: 68, index: 0)
        self.TextFieldAddRightButton(textField: self.addressText, imgName: "ic_scan", action: #selector(onScan), location: CGFloat(self.addressText!.subviews.index(0, offsetBy: 22)), index: 1)
        self.TextFieldAddRightButton(textField: self.signatureText, imgName: "ic_paste", action: #selector(onSignaturePaste), location: 22, index: 0)
        self.TextFieldAddRightButton(textField: self.messageText, imgName: "ic_paste", action: #selector(onMessagePaste), location: 22, index: 0)
           
        self.addressText.addTarget(self, action: #selector(self.TextFieldChanged), for: .editingChanged)
        self.signatureText.addTarget(self, action: #selector(self.TextFieldChanged), for: .editingChanged)
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
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.verifyMessage, style: .plain, target: self, action: nil)
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
        self.toggleValidateButtonState()
        self.addressText.editingEnded()
    }
    
    @objc func onMessagePaste() {
        self.messageText.editingBegan()
        self.messageText.text = UIPasteboard.general.string
        self.toggleValidateButtonState()
        self.messageText.editingEnded()
    }
    
    @objc func onSignaturePaste() {
        self.signatureText.editingBegan()
        self.signatureText.text = UIPasteboard.general.string
        self.toggleValidateButtonState()
        self.signatureText.editingEnded()
    }
    
    @objc func pageInfo(){
        let alertController = UIAlertController(title: LocalizedStrings.verifyMessage, message: LocalizedStrings.verifyMessagepageInfo, preferredStyle: UIAlertController.Style.alert)
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
    
    @IBAction func verifyMsg(_ sender: Any) {
        self.viewContHeightContraint.constant = 360
        self.isValidMsgContainer.isHidden = false
        self.verifyMessage(signatures: self.signatureText.text!, messages: self.messageText.text!, address: self.addressText.text!)
       }
    
    func verifyMessage(signatures: String,messages :String, address:String) {
        let addressd = address.trimmingCharacters(in: .whitespaces)
        let message = messages
        let signatured = signatures
        let retV = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
           
        if (dcrlibwallet.isAddressValid(addressd)) {
            do{
                try dcrlibwallet.verifyMessage(addressd, message: message, signatureBase64: signatured, ret0_: retV)
                if (retV[0]).boolValue {
                    self.isValidSignature.text = LocalizedStrings.verifiedSignature
                    return
                } else {
                    self.isValidSignature.text = LocalizedStrings.invalidSignature
                    self.isValidSignature.textColor = UIColor.red
                    self.isValidImg.image = UIImage.init(named: "ic_checkmark")
                    return
                }
            } catch {
                self.isValidSignature.textColor = UIColor.red
                self.isValidSignature.text = LocalizedStrings.invalidSignature
                self.isValidImg.image = UIImage.init(named: "ic_crossmark")
               }
        } else {
            self.isValidSignature.text = LocalizedStrings.invalidSignature
            self.isValidSignature.textColor = UIColor.red
            self.isValidImg.image = UIImage.init(named: "ic_crossmark")
           }
           return
       }
    
    @objc func TextFieldChanged() {
        self.toggleValidateButtonState()
    }
    
    func toggleValidateButtonState() {
        let textCheck =  self.addressText.text!.isEmpty || self.messageText.text!.isEmpty || self.signatureText.text!.isEmpty
        self.verifyBtn.isEnabled = textCheck ?  false : true
        self.verifyBtn.backgroundColor = textCheck ?  UIColor.appColors.darkerGray : UIColor.appColors.lightBlue
    }
    
    @IBAction func clearFields(_ sender: Any) {
        self.addressText.text = nil
        self.messageText.text = nil
        self.signatureText.text = nil
        self.verifyBtn.backgroundColor = UIColor.appColors.darkerGray
        self.verifyBtn.isEnabled = false
        self.viewContHeightContraint.constant = 280
        self.isValidMsgContainer.isHidden = true
    }
       
    func checkAddressFromQrCode(textScannedFromQRCode: String?) {
        guard var capturedText = textScannedFromQRCode else {
            self.addressText.text = ""
            return
        }
           
        if capturedText.starts(with: "decred:") {
            capturedText = capturedText.replacingOccurrences(of: "decred:", with: "")
        }
        self.addressText.text = capturedText
    }
}
