//
//  ValidateAddressesViewController.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class ValidateAddressesViewController: UIViewController, UITextViewDelegate, FloatingPlaceholderTextViewDelegate {
    @IBOutlet weak var addressText: FloatingPlaceholderTextView!
    @IBOutlet weak var validateBtn: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var isValidMsgContainer: UIView!
    @IBOutlet weak var viewContHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var validityInfo: UILabel!
    @IBOutlet weak var addrOwnerInfo: UILabel!
    @IBOutlet weak var isValidImg: UIImageView!
    
    var dcrlibwallet: DcrlibwalletWallet!
    
    // Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode.
    private lazy var qrImageScanner = QRImageScanner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dcrlibwallet = WalletLoader.shared.firstWallet!
        
        viewContHeightContraint.constant = 144
        
        let pasteButton = UIButton(type: .custom)
        pasteButton.setImage(UIImage(named: "ic_paste"), for: .normal)
        pasteButton.addTarget(self, action: #selector(onPaste), for: .touchUpInside)
        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "ic_scan"), for: .normal)
        scanButton.addTarget(self, action: #selector(onScan), for: .touchUpInside)
        
        self.addressText.add(button: pasteButton)
        self.addressText.add(button: scanButton)
        self.addressText.textViewDelegate = self
        self.addressText.setNeedsDisplay()
        self.addressText.placeholder = LocalizedStrings.address
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
        self.addNavigationBackButton()
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.validateAddresses, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.darkBlue
               
        self.navigationItem.leftBarButtonItems =  [ (self.navigationItem.leftBarButtonItem)!, barButtonTitle]
       }
    
    func textView(_ textField: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // figure out what the new string will be after the pending edit
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        self.toggleValidateButtonState(addressHasText: updatedString!)
        
        if updatedString!.isEmpty {
            self.viewContHeightContraint.constant = 144
            self.isValidMsgContainer.isHidden = true
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.toggleValidateButtonState(addressHasText: textView.text)
    }
    
    @objc func onScan() {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
    }
    
    @objc func onPaste() {
        self.addressText.textViewDidBeginEditing(self.addressText)
        self.addressText.text = UIPasteboard.general.string
        self.toggleValidateButtonState(addressHasText: self.addressText.text!)
    }
    
    func toggleValidateButtonState(addressHasText: String) {
        self.validateBtn.isEnabled = addressHasText.isEmpty ?  false : true
        self.validateBtn.backgroundColor = addressHasText.isEmpty ?  UIColor.appColors.darkGray : UIColor.appColors.lightBlue
    }
    
    @IBAction func validatAddress(_ sender: Any) {
        self.viewContHeightContraint.constant = 234
        self.isValidMsgContainer.isHidden = false
        self.validateAdd(address: self.addressText.text!)
       
    }
    
    func validateAdd(address: String) {
        let isOwnAndValid = dcrlibwallet.isAddressValid(address) && dcrlibwallet.haveAddress(address)
               let isValid = dcrlibwallet.isAddressValid(address)
               
               if isOwnAndValid {
                   self.validityInfo.textColor = UIColor.appColors.green
                   self.validityInfo.text = LocalizedStrings.validAddress
                   self.addrOwnerInfo.isHidden = false
                   self.addrOwnerInfo.textColor = UIColor.appColors.green
                   self.addrOwnerInfo.text = LocalizedStrings.validOwnAddr
                   self.isValidImg.image = UIImage.init(named: "ic_checkmark_round")
               } else {
                   if isValid {
                       self.validityInfo.textColor = UIColor.appColors.green
                       self.validityInfo.text = LocalizedStrings.validAddress
                       self.addrOwnerInfo.isHidden = false
                       self.addrOwnerInfo.textColor = UIColor.appColors.lightBluishGray
                       self.addrOwnerInfo.text = LocalizedStrings.validNotOwnAddr
                       self.isValidImg.image = UIImage.init(named: "ic_checkmark_round")
                   } else {
                       self.validityInfo.textColor = UIColor.appColors.orange
                       self.validityInfo.text = LocalizedStrings.invalidAddr
                       self.addrOwnerInfo.isHidden = true
                       self.addrOwnerInfo.text = nil
                       self.isValidImg.image = UIImage.init(named: "ic_crossmark")
                   }
               }
    }
    
    @IBAction func clearAddress(_ sender: Any) {
        self.addressText.text = nil
        self.validateBtn.backgroundColor = UIColor.appColors.darkGray
        self.validateBtn.isEnabled = false
        self.viewContHeightContraint.constant = 144
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
        self.addressText.textViewDidBeginEditing(self.addressText)
        self.addressText.text = capturedText
        self.toggleValidateButtonState(addressHasText: self.addressText.text)
    }
}
