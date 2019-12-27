//
//  ValidateAddressesViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 25/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit
import Dcrlibwallet

class ValidateAddressesViewController: UIViewController, UITextFieldDelegate  {
    @IBOutlet weak var addressText: FloatingLabelTextInput!
    @IBOutlet weak var validateBtn: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var isValidMsgContainer: UIView!
    @IBOutlet weak var viewContHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var validityInfo: UILabel!
    @IBOutlet weak var addrOwnerInfo: UILabel!
    @IBOutlet weak var isValidImg: UIImageView!
    
    var dcrlibwallet :DcrlibwalletLibWallet!
    
    // Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode.
    private lazy var qrImageScanner = QRImageScanner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dcrlibwallet = AppDelegate.walletLoader.wallet
        
        viewContHeightContraint.constant = 144
        
        self.TextFieldAddRightButton(textField: self.addressText, imgName: "ic_paste", action: #selector(onPaste), location: 68, index: 0)
        self.addressText.layoutIfNeeded()
        
        self.TextFieldAddRightButton(textField: self.addressText, imgName: "ic_scan", action: #selector(onScan), location: CGFloat(self.addressText!.subviews.index(0, offsetBy: 22)), index: 1)
        self.addressText.setNeedsDisplay()
        
        self.addressText.delegate = self
        self.addressText.placeholder = LocalizedStrings.address
    }
    
    func TextFieldAddRightButton(textField: UITextField, imgName: String, action: Selector , location: CGFloat, index: Int) {
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named: imgName), for: .normal)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(-16), bottom: 0, right: 0)
        rightButton.frame = CGRect(x: CGFloat(textField.frame.size.width - location), y: CGFloat(16), width: CGFloat(20), height: CGFloat(20))
        
        rightButton.addTarget(self, action: action, for: .touchUpInside)
        textField.insertSubview(rightButton, at: index)
       // textField.addSubview(rightButton)
        textField.setNeedsDisplay()
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
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.validateAddresses, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
               
        self.navigationItem.leftBarButtonItems =  [ (self.navigationItem.leftBarButtonItem)!, barButtonTitle]
        
       }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // figure out what the new string will be after the pending edit
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        self.toggleValidateButtonState(addressHasText: updatedString!)
        
        if updatedString!.isEmpty {
            self.viewContHeightContraint.constant = 144
            self.isValidMsgContainer.isHidden = true
        }
        
        return true
    }
    
    @objc func onScan() {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
    }
    
    @objc func onPaste() {
        self.addressText.editingBegan()
        self.addressText.text = UIPasteboard.general.string
        self.toggleValidateButtonState(addressHasText: self.addressText.text!)
        self.addressText.editingEnded()
    }
    
    func toggleValidateButtonState(addressHasText: String) {
        self.validateBtn.isEnabled = addressHasText.isEmpty ?  false : true
        self.validateBtn.backgroundColor = addressHasText.isEmpty ?  UIColor.appColors.darkerGray : UIColor.appColors.lightBlue
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
                   self.validityInfo.textColor = UIColor.appColors.decredLightGreen
                   self.validityInfo.text = LocalizedStrings.validAddress
                   self.addrOwnerInfo.isHidden = false
                   self.addrOwnerInfo.textColor = UIColor.appColors.green
                   self.addrOwnerInfo.text = LocalizedStrings.validOwnAddr
                   self.isValidImg.image = UIImage.init(named: "ic_checkmark")
               } else {
                   if isValid {
                       self.validityInfo.textColor = UIColor.appColors.decredLightGreen
                       self.validityInfo.text = LocalizedStrings.validAddress
                       self.addrOwnerInfo.isHidden = false
                       self.addrOwnerInfo.textColor = UIColor.appColors.lightBluishGray
                       self.addrOwnerInfo.text = LocalizedStrings.validNotOwnAddr
                       self.isValidImg.image = UIImage.init(named: "ic_checkmark")
                   } else {
                       self.validityInfo.textColor = UIColor.appColors.decredOrange
                       self.validityInfo.text = LocalizedStrings.invalidAddr
                       self.addrOwnerInfo.isHidden = true
                       self.addrOwnerInfo.text = nil
                       self.isValidImg.image = UIImage.init(named: "ic_crossmark")
                   }
               }
    }
    
    @IBAction func clearAddress(_ sender: Any) {
        self.addressText.text = nil
        self.validateBtn.backgroundColor = UIColor.appColors.darkerGray
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
        self.addressText.text = capturedText
        self.validateAdd(address: capturedText)
    }
}
