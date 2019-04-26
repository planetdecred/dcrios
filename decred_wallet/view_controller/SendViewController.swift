//
//  SendViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import QRCodeReader
import UIKit
import Dcrlibwallet
import SafariServices


class SendViewController: UIViewController, UITextFieldDelegate,UITextPasteDelegate, QRCodeReaderViewControllerDelegate, PinEnteredProtocol {

    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var sendInUsd: UILabel!
    @IBOutlet weak var sendInDcr: UILabel!
    @IBOutlet weak var dcrLabel: UILabel!
    @IBOutlet weak var estimatedFeeLabel: UILabel!
    @IBOutlet weak var balanceAfterLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet var BalanceAfter: UILabel!
    @IBOutlet var estimateFee: UILabel!
    @IBOutlet var estimateSize: UILabel!
    @IBOutlet var walletAddress: UITextField!
    @IBOutlet var tfAmount: UITextField!
    @IBOutlet var sendAllBtn: UIButton!
    @IBOutlet weak var pasteBtn: UIButton!
    @IBOutlet weak var sendNtwkErrtext: UILabel!
    @IBOutlet weak var amountErrorText: UILabel!
    @IBOutlet weak var addressErrorText: UILabel!
    @IBOutlet weak var exchangeRateDisplay: UILabel!
    @IBOutlet weak var convertionFeeOther: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var exchangeRateError: UIButton!
    @IBOutlet weak var currencyAmount2: AmountTextfield!
    @IBOutlet weak var qrcodeBtn: UIButton!
    @IBOutlet weak var conversionContHeight: NSLayoutConstraint!
    @IBOutlet weak var conversionRowCont: UIStackView!
    @IBOutlet weak var bottomCont: UIView!
    @IBOutlet weak var conversionFeeCont: UIStackView!
    @IBOutlet weak var buttomContHeight: NSLayoutConstraint!
    @IBOutlet weak var sendInfoHeight: NSLayoutConstraint!
    @IBOutlet weak var exchangeRateCont: UIStackView!
    weak var delegate: LeftMenuProtocol?
    @IBOutlet var accountDropdown: DropMenuButton!
    @IBOutlet weak var toAccountDropDown: DropMenuButton!
    @IBOutlet weak var toAccountContainer: UIStackView!
    @IBOutlet weak var toAddressContainer: UIStackView!
   
    var fromNotQRScreen = true
    var AccountFilter: [AccountsEntity]?
    var pinInput: String?
    private var barButton: UIBarButtonItem?
    var removedBtn = true
    var wallet :DcrlibwalletLibWallet!
    var selectedAccount: AccountsEntity?
    var sendToAccount: AccountsEntity?
    var password: String?
    var sendAllTX = false
    var exchangeRateGloabal :NSDecimalNumber = 0.0
    var tempFee = "0"
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setScreenFont()
        self.sendBtn.layer.cornerRadius = 5;
        self.accountDropdown.backgroundColor = UIColor.clear
        self.toAccountDropDown.backgroundColor = UIColor.clear
        self.tfAmount.delegate = self
        self.currencyAmount2.delegate = self
        self.pasteBtn.layer.cornerRadius = 4
        self.pasteBtn.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        wallet = SingleInstance.shared.wallet
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name:.UIApplicationWillEnterForeground, object: nil)
        self.walletAddress.delegate = self
        removedBtn = false
        let currency_value = UserDefaults.standard.integer(forKey: "currency")
        if(currency_value == 1){
            GetExchangeRate()
        }
        self.showDefaultAccount()
        self.removePasteBtn()
        self.checkpaste()
    }
    
    @objc func willResignActive(){
        if ( (self.walletAddress.text?.count)! < 1) {
             self.checkpaste()
        }
    }
    
    private func clearFields() {
        if(self.walletAddress.hasText){
            self.walletAddress.text = ""
            self.tfAmount.text = ""
            self.addQrbtn()
            self.checkpaste()
            self.addressErrorText.text = ""
            self.amountErrorText.text = ""
            self.tfAmount.text = ""
            self.currencyAmount2.text = ""
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
        } else {
            self.amountErrorText.text = ""
            self.tfAmount.text = ""
            self.currencyAmount2.text = ""
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
        }
    }
    
    func checkpaste(){
        let pasteboardString: String? = UIPasteboard.general.string
        if let theString = pasteboardString {
            if (self.wallet.isAddressValid(theString )) {
                print("address valid on appear")
                if !(removedBtn){
                    print("not showing but adding now")
                    removedBtn = true
                    self.removePasteBtn()
                }
                else{
                    print("showing and leaving it")
                }
                //self.addressError.text = ""
            }
            else{
                print("address invalid on appear")
                if (removedBtn){
                    print("showing but removing now")
                    removedBtn = false
                    self.removePasteBtn()
                }
                //self.addressError.text = ""
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Send"
        self.updateBalance()
        let menu = UIButton(type: .custom)
        menu.setImage(UIImage(named: "right-menu"), for: .normal)
        menu.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        menu.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        barButton = UIBarButtonItem(customView: menu)
        self.navigationItem.rightBarButtonItems = [barButton!]
        print("address valid on appear")
        if !(self.fromNotQRScreen){
            self.fromNotQRScreen = true
        }
        else{
            self.checkpaste()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.string(forKey: "TMPPIN") != nil{
            self.confirmSendWithoutPin(sendAll: false, pin: UserDefaults.standard.string(forKey: "TMPPIN")!, fee: self.tempFee)
            UserDefaults.standard.set(nil, forKey: "TMPPIN")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSendAll(_ sender: Any?) {
        self.sendAllTX = true
        sendAll()
        
    }
    func sendAll(){
        let spendableAmount = spendable(account: self.selectedAccount!)
        self.tfAmount.text = "\(spendableAmount)"
        if !(self.conversionRowCont.isHidden){
            self.currencyAmount2.text = "\((((self.exchangeRateGloabal as Decimal) * spendableAmount)as NSDecimalNumber).round(2))"
        }
        self.prepareTransaction(sendAll: self.sendAllTX, amount: self.tfAmount.text!)
        self.toggleSendBtn(validate: self.validateSentBtn(amount: self.tfAmount.text!))
    }
    
    @objc func showMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let sendTitle = self.toAddressContainer.isHidden ? "Send to address" : "Send to account"
        let sendToAccount = UIAlertAction(title: sendTitle, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.sendToSwitch()
        })
        
        let clearFields = UIAlertAction(title: "Clear fields", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.clearFields()
        })
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(sendToAccount)
        alertController.addAction(clearFields)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendToSwitch(){
        self.toAddressContainer.isHidden = !toAddressContainer.isHidden
        self.toAccountContainer.isHidden = !toAccountContainer.isHidden
        self.addressErrorText.isHidden = !self.addressErrorText.isHidden
        self.toggleSendBtn(validate: self.validateSentBtn(amount: self.tfAmount.text!))
    }
    
    func removePasteBtn(){
         DispatchQueue.main.async {
            if !(self.removedBtn){
            
            self.toAddressContainer.removeArrangedSubview(self.pasteBtn)
            self.pasteBtn.isHidden = true
                //self.removedBtn = true
                
            }
            else{
            self.toAddressContainer.insertArrangedSubview(self.pasteBtn, at: 1)
               // self.removedBtn = false
            self.pasteBtn.isHidden = false
            }
        }
        
    }
    
    func removeQrbtn(){
        DispatchQueue.main.async {
        self.toAddressContainer.removeArrangedSubview(self.qrcodeBtn)
        self.qrcodeBtn.isHidden = true
        }
    }
    func addQrbtn(){
        DispatchQueue.main.async {
        self.toAddressContainer.insertArrangedSubview(self.qrcodeBtn, at: 1)
        self.qrcodeBtn.isHidden = false
        }
    }
    
    @IBAction private func sendFund(_ sender: Any) {
        guard (UserDefaults.standard.bool(forKey: "synced")) else {
            sendNtwkErrtext.text = "Please wait for network synchronization."
          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendNtwkErrtext.text = " "
            }
            return
        }
        let peer = UserDefaults.standard.integer(forKey: "peercount")
        guard peer > 0 else {
            sendNtwkErrtext.text = "Not connected to the network."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendNtwkErrtext.text = " "
            }
            return
        }
        if self.validate(amount: self.tfAmount.text!) {
            self.fromNotQRScreen = false
            if(UserDefaults.standard.string(forKey: "spendingSecureType") == "PASSWORD"){
                self.confirmSend(sendAll: false)
            } else {
                let sendVC = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                sendVC.senders = "spendFund"
                self.navigationController?.pushViewController(sendVC, animated: true)
            }
        }
    }
    private func prepareTransaction(sendAll: Bool?, amount : String) {
        let amountToSend = Double((amount))!
        let amount = DcrlibwalletAmountAtom(amountToSend)
        var walletaddress = self.walletAddress.text!
        let acountN = (self.selectedAccount?.Number)!
        var fee = 0.0
        
        if !(validateDestinationAddress()) {
            walletaddress = (try!wallet?.currentAddress(acountN))!
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                
                let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
                let preparedTransaction: DcrlibwalletUnsignedTransaction?
                preparedTransaction = try self.wallet?.constructTransaction(walletaddress, amount: amount, srcAccount: acountN , requiredConfirmations: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
                
                DispatchQueue.main.async { [weak self] in
                    guard let this = self else { return }
                    fee = Double((preparedTransaction?.estimatedSignedSize)!) / 0.001 / 1e8
                    let spendableAmount = spendable(account: (self?.selectedAccount!)!)
                    this.estimateSize.text = "\(preparedTransaction?.estimatedSignedSize ?? 0) Bytes"
                    this.estimateFee.text = "\(fee) DCR"
                    let Amount =  (spendableAmount - (Decimal(amountToSend) )) as NSDecimalNumber
                    this.BalanceAfter.text = "\(Amount.round(8)) DCR"
                    if !(self!.conversionRowCont.isHidden){
                        self?.conversionFeeCont.isHidden = false
                        self!.sendInfoHeight.constant = 0.585 * self!.buttomContHeight.constant
                        self?.tempFee = "\((((Decimal(fee)) * ((self?.exchangeRateGloabal)! as Decimal)) as NSDecimalNumber).round(4))"
                        self?.convertionFeeOther.text = "(\(self!.tempFee) USD)"
                    }
                    if(sendAll)!{
                        this.tfAmount.text = "\(DcrlibwalletAmountCoin(amount - DcrlibwalletAmountAtom(fee)) )"
                    }
                }
            } catch let error {
               // self.showAlert(message: error.localizedDescription, titles: "Error")
            }
        }
    }
    
    private func signTransaction(sendAll: Bool?, password:String) {
        let peer = UserDefaults.standard.integer(forKey: "peercount")
        guard peer > 0 else {
            sendNtwkErrtext.text = "Not connected to the network."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendNtwkErrtext.text = " "
            }
            return
        }
          var walletAddress = ""
        if (self.toAddressContainer.isHidden){
            let receiveAddress = try?wallet?.currentAddress((self.sendToAccount?.Number)!)
            walletAddress = (receiveAddress!)!
        }
        else{
            DispatchQueue.main.async {
                 walletAddress = self.walletAddress.text!
            }
        }
        DispatchQueue.main.async {
            let amount = Double((self.tfAmount.text)!)! * 100000000
            let account = (self.selectedAccount?.Number)!
            DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
                do {
                    
                    let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
                    let result = try self.wallet?.sendTransaction(password.data(using: .utf8), destAddr: walletAddress, amount: Int64(amount) , srcAccount: account , requiredConfs: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
                    
                    DispatchQueue.main.async {
                        self.transactionSucceeded(hash: result?.hexEncodedString())
                        return
                    }
                    return
                    
                } catch let error {
                    self.showAlert(message: error.localizedDescription, titles: "Error")
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func confirmSend(sendAll: Bool) {
        
        let amountToSend = (tfAmount?.text)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewController") as! ConfirmToSendFundViewController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: confirmSendFundViewController.view, action: #selector(confirmSendFundViewController.vContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        confirmSendFundViewController.view.addGestureRecognizer(tap)
        DispatchQueue.main.async {
            if (self.toAddressContainer.isHidden){
                let receiveAddress = try?self.wallet?.currentAddress((self.sendToAccount?.Number)!)
                confirmSendFundViewController.address = (receiveAddress!)!
                confirmSendFundViewController.account = (self.selectedAccount?.Name)!
            }
            else{
                confirmSendFundViewController.accountLabel.isHidden = true
                confirmSendFundViewController.address = self.walletAddress.text!
            }
            if !(self.conversionRowCont.isHidden){
                confirmSendFundViewController.amount = "\(amountToSend) DCR ($\((self.currencyAmount2.text)!))"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) ($\((self.tempFee)))"
            }
            else{
                confirmSendFundViewController.amount = "\(amountToSend) DCR"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) (\((self.estimateSize.text)!))"
                
            }
            
        }
        
        confirmSendFundViewController.confirm = { (password) in
            self.signTransaction(sendAll: sendAll, password: password)
        }
        
        DispatchQueue.main.async {
            self.present(confirmSendFundViewController, animated: true, completion: nil)
        }
        return
    }
    
    private func confirmSendWithoutPin(sendAll: Bool, pin: String, fee : String) {
        
        let amountToSend = (tfAmount?.text)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewPINController") as! ConfirmToSendFundViewPINController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: confirmSendFundViewController.view, action: #selector(confirmSendFundViewController.vContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        confirmSendFundViewController.view.addGestureRecognizer(tap)
         DispatchQueue.main.async {
            if (self.toAddressContainer.isHidden){
                let receiveAddress = try?self.wallet?.currentAddress((self.sendToAccount?.Number)!)
                confirmSendFundViewController.address = (receiveAddress!)!
                confirmSendFundViewController.account = (self.selectedAccount?.Name)!
            }
            else{
                confirmSendFundViewController.accountName.isHidden = true
                    confirmSendFundViewController.address = self.walletAddress.text!
            }
            if !(self.conversionRowCont.isHidden){
                confirmSendFundViewController.amount = "\(amountToSend) DCR ($\((self.currencyAmount2.text)!))"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) ($\((self.tempFee)))"
            }
            else{
                confirmSendFundViewController.amount = "\(amountToSend) DCR"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) (\((self.estimateSize.text)!))"
            
                }
            
            }
        
        
        let tmp = pin
        confirmSendFundViewController.confirm = { () in
            self.signTransaction(sendAll: sendAll, password: tmp)
        }
        
        DispatchQueue.main.async {
            self.present(confirmSendFundViewController, animated: true, completion: nil)
        }
        
        return
    }
    
    @IBAction private func scanQRCodeAction(_ sender: UIButton) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        self.readerVC.delegate = self
        
        // Or by using the closure pattern
        self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                
                var address = result?.value
                if address == nil {
                    return
                }
                
                let lenght = min((address?.length)!,40)
                let errorText = address?.prefix(lenght)
                let message = "This is not a decred wallet address.\n".appending((errorText)!)
                
                if (address?.length)! > 0 {
                    if (address?.starts(with: "decred:"))! {
                        address = address?.replacingOccurrences(of: "decred:", with: "")
                    }
                    
                    if self!.wallet.isAddressValid(address!) {
                        self?.fromNotQRScreen = false
                        DispatchQueue.main.async {
                            this.walletAddress?.text = address
                        }
                        this.removeQrbtn()
                        if (this.removedBtn){
                            print("showing but removing now")
                            this.removedBtn = false
                            this.removePasteBtn()
                        }
                    } else{
                        self?.showAlert(message: message, titles: "Info")
                        print("invalid address length")
                    }
                } else{
                    self?.showAlert(message: message, titles: "Info")
                }
            }
        }
        
        // Presents the readerVC as modal form sheet
        self.readerVC.modalPresentationStyle = .formSheet
        DispatchQueue.main.async {
            self.present(self.readerVC, animated: true, completion: nil)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.dismiss(animated: true, completion: nil)
    }
    
    func openLink(urlString: String) {
        
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            viewController.delegate = self as? SFSafariViewControllerDelegate
            
            self.present(viewController, animated: true)
        }
    }
    
    private func transactionSucceeded(hash: String?) {
        
        let hashe = hash
        let storyboard = UIStoryboard(
            name: "SendCompletedViewController",
            bundle: nil
        )
        
        let sendCompletedVC = storyboard.instantiateViewController(withIdentifier: "SendCompletedViewController") as! SendCompletedViewController
        sendCompletedVC.modalTransitionStyle = .crossDissolve
        sendCompletedVC.modalPresentationStyle = .overCurrentContext
        sendCompletedVC.transactionHash = hashe
        
        sendCompletedVC.openDetails = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
            self.walletAddress.text = nil
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
            self.tfAmount.text = nil
            if !(self.toAddressContainer.isHidden){
                self.addQrbtn()
                self.checkpaste()
                
            }
            self.showDefaultAccount()
            }
            
            let isTestnet = Bool(infoForKey(GlobalConstants.Strings.IS_TESTNET)!)!
            if (isTestnet){
                self.openLink(urlString: "https://testnet.dcrdata.org/tx/" + hashe! )
            }else{
                self.openLink(urlString: "https://mainnet.dcrdata.org/tx/" + hashe! )
            }
        }
        sendCompletedVC.closeView = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
            self.walletAddress.text = nil
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
            self.tfAmount.text = nil
            if !(self.toAddressContainer.isHidden){
                self.addQrbtn()
                self.checkpaste()
            }
            self.showDefaultAccount()
            self.updateBalance()
            }
            
        }
        self.present(sendCompletedVC, animated: true, completion: nil)
        return
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.validateAmount(amount: self.tfAmount.text!) {
            self.showAlertInvalidAmount()
            return false
        }
        
       // self.prepareTransaction(sendAll: false)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (self.tfAmount.text != nil && self.tfAmount.text != "" && self.tfAmount.text != "0" && self.amountErrorText.text == "") {
            self.sendAllTX = false
           // self.prepareTransaction(sendAll: self.sendAllTX)
            return true
        }
        
        if (textField == self.tfAmount) {
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
        }
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
         if (textField == self.walletAddress) {
             DispatchQueue.main.async {
                self.addressErrorText.text = ""
                
            }
            self.addQrbtn()
            if (self.wallet.isAddressValid(UIPasteboard.general.string)) {
                removedBtn = true
                self.removePasteBtn()
                return true
            }
        }
        
        return true
    }
    var ACCEPTABLE_CHARACTERS = ""
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
       
        if (textField == self.walletAddress) {
           
            if (updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == "") {
                
                DispatchQueue.main.async {
                    self.addressErrorText.text = ""
                }
                self.addQrbtn()
                if (self.wallet.isAddressValid(UIPasteboard.general.string)) {
                   
                        removedBtn = true
                         self.removePasteBtn()
                        return true
            }
                return true
            }
            print("input is more than 1")
            if (removedBtn){
                removedBtn = false
                    self.removePasteBtn()
            }
            self.removeQrbtn()
            
            if (self.wallet.isAddressValid(updatedString)) {
                DispatchQueue.main.async {
                self.addressErrorText.text = ""
                    
                }
                return true
            } else {
                DispatchQueue.main.async {
                self.addressErrorText.text = "Destination address is not valid"
                    
                }
                return true
            }
        }
        if (textField == self.tfAmount) {
            self.sendAllTX = false
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            if (updatedString != nil && updatedString != "" ){
                
                if((updatedString?.contains("."))!){
                    let tmp2 = updatedString! as NSString
                    let TmpDot = tmp2.range(of: ".")
                    if((updatedString!.length - (TmpDot.location + 1)) > 8 || TmpDot.location > 8){
                        return false
                        
                    }
                    
                    if(updatedString?.first == "."){
                        DispatchQueue.main.async {
                            self.tfAmount.text = "0."
                        }
                        updatedString = "0."
                        ACCEPTABLE_CHARACTERS = "."
                    }
                    else{
                        ACCEPTABLE_CHARACTERS = "."
                    }
                }
                else{
                    if(updatedString!.length > 8){
                        return false
                        
                    }
                   
                    ACCEPTABLE_CHARACTERS = ""
                    
                }
                
                if !(CharacterSet(charactersIn: string).isSubset(of: cs)){
                    return false
                }
                self.amountErrorText.text = ""
                let tspendable = spendable(account: self.selectedAccount!) as Decimal
                let amountToSend = Decimal(Double((updatedString)!)!)
                
                if (amountToSend > tspendable) {
                    DispatchQueue.main.async {
                        if !(self.conversionRowCont.isHidden){
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                            self.currencyAmount2.text = "\((((self.exchangeRateGloabal as Decimal) * tmp2)as NSDecimalNumber).round(2))"
                        }
                        if(UserDefaults.standard.bool(forKey: "synced")){
                             self.amountErrorText.text = "Not enough funds"
                        }
                        else{
                             self.amountErrorText.text = "Not enough funds (or not connected)"
                        }
                        DispatchQueue.main.async {
                            self.estimateFee.text = "0.00 DCR"
                            self.estimateSize.text = "0 Bytes"
                            self.BalanceAfter.text = "0.00 DCR"
                            if !(self.conversionRowCont.isHidden){
                                self.conversionFeeCont.isHidden = true
                                self.sendInfoHeight.constant = 0.515 * self.buttomContHeight.constant
                                self.convertionFeeOther.text = ""
                            }
                        }
                    }
            }
                else{
                    DispatchQueue.main.async {
                        self.amountErrorText.text = ""
                        if !(self.conversionRowCont.isHidden){
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                            self.currencyAmount2.text = "\((((self.exchangeRateGloabal as Decimal) * tmp2)as NSDecimalNumber).round(2))"
                        }
                    }
                  
                }
                self.sendAllTX = false
                self.prepareTransaction(sendAll: self.sendAllTX, amount: updatedString!)
                self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
            }else{
                
                DispatchQueue.main.async {
                    self.currencyAmount2.text = nil
                    self.estimateFee.text = "0.00 DCR"
                    self.estimateSize.text = "0 Bytes"
                    self.BalanceAfter.text = "0.00 DCR"
                    self.amountErrorText.text = ""
                    if !(self.conversionRowCont.isHidden){
                        self.conversionFeeCont.isHidden = true
                        self.sendInfoHeight.constant = 0.515 * self.buttomContHeight.constant
                        self.convertionFeeOther.text = ""
                    }
                    self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
                }
            }
            
        }
       else if (textField == self.currencyAmount2) {
            self.sendAllTX = false
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            if (updatedString != nil && updatedString != "" ){
                
                if((updatedString?.contains("."))!){
                    let tmp2 = updatedString! as NSString
                    let TmpDot = tmp2.range(of: ".")
                    if((updatedString!.length - (TmpDot.location + 1)) > 2 || TmpDot.location > 10){
                        return false
                        
                    }
                    
                    if(updatedString?.first == "."){
                        DispatchQueue.main.async {
                            self.currencyAmount2.text = "0."
                            
                        }
                        updatedString = "0."
                        ACCEPTABLE_CHARACTERS = "."
                    }
                    else{
                        ACCEPTABLE_CHARACTERS = "."
                    }
                }
                else{
                    if(updatedString!.length > 10){
                        return false
                        
                    }
                   
                    ACCEPTABLE_CHARACTERS = ""
                    
                }
                
                if !(CharacterSet(charactersIn: string).isSubset(of: cs)){
                    return false
                }
                self.amountErrorText.text = ""
                let tspendable = spendable(account: self.selectedAccount!) as Decimal
                let amountToSend = Decimal(Double((updatedString)!)!)
                
                if (amountToSend > tspendable) {
                    DispatchQueue.main.async {
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                        print("\((tmp2 )) and \(self.exchangeRateGloabal as Decimal)")
                        print((tmp2 ) / (self.exchangeRateGloabal as Decimal))
                        print("currency")
                        self.tfAmount.text = "\(((tmp2 ) / (self.exchangeRateGloabal as Decimal) as NSDecimalNumber).round(8))"
                        if(UserDefaults.standard.bool(forKey: "synced")){
                            self.amountErrorText.text = "Not enough funds"
                        }
                        else{
                            self.amountErrorText.text = "Not enough funds (or not connected)"
                        }
                        DispatchQueue.main.async {
                            self.estimateFee.text = "0.00 DCR"
                            self.estimateSize.text = "0 Bytes"
                            self.BalanceAfter.text = "0.00 DCR"
                            if !(self.conversionRowCont.isHidden){
                                self.conversionFeeCont.isHidden = true
                                self.sendInfoHeight.constant = 0.515 * self.buttomContHeight.constant
                                self.convertionFeeOther.text = ""
                            }
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.amountErrorText.text = ""
                        if !(self.conversionRowCont.isHidden){
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                            self.tfAmount.text = "\(((tmp2 ) / (self.exchangeRateGloabal as Decimal) as NSDecimalNumber).round(8))"
                        }
                    }
                  
                }
                self.sendAllTX = false
                print("before validate")
                self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
                self.prepareTransaction(sendAll: self.sendAllTX, amount: updatedString!)
                
                return true
            }else{
                DispatchQueue.main.async {
                    self.tfAmount.text = nil
                    self.estimateFee.text = "0.00 DCR"
                    self.estimateSize.text = "0 Bytes"
                    self.BalanceAfter.text = "0.00 DCR"
                    if !(self.conversionRowCont.isHidden){
                        self.conversionFeeCont.isHidden = true
                        self.sendInfoHeight.constant = 0.515 * self.buttomContHeight.constant
                        self.convertionFeeOther.text = ""
                    }
                    self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
                }
                
            }
        }
        
        return true
            
        }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    private func toggleSendBtn(validate: Bool){
        if(validate){
            self.sendBtn.backgroundColor = UIColor(hex: "#007AFF")
            self.sendBtn.setTitleColor(UIColor.white, for: .normal)
            print("btn true")
        }
        else{
            self.sendBtn.backgroundColor = UIColor(hex: "#E6EAED")
            self.sendBtn.setTitleColor(UIColor(hex: "#000000", alpha: 0.61), for: .normal)
            print("btn false")
        }
    }
    
    private func showDefaultAccount() {
        var accounts = [String]()
        var account: GetAccountResponse?
        do {
            let strAccount = try wallet?.getAccounts(0)
            account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
            
        } catch let error {
            print(error)
        }
        
        accounts = (account?.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)")  != true && $0.Number != INT_MAX }).map { (acc) -> String in
            let tspendable = spendable(account: acc) as NSDecimalNumber
            print(acc.Number)
            
            return "\(acc.Name) [\( tspendable.round(8) )]"
            })!
        
        let defaultNumber = UserDefaults.standard.integer(forKey: "wallet_default")
        
        if let defaultAccount = account?.Acc.filter({ $0.Number == defaultNumber }).first {
            let tspendable = spendable(account: defaultAccount) as NSDecimalNumber
            
            accountDropdown.setTitle(
                "\(defaultAccount.Name) [\(tspendable.round(8) )]",
                for: UIControlState.normal
            )
            toAccountDropDown.setTitle(
                "\(defaultAccount.Name) [\(tspendable.round(8) )]",
                for: UIControlState.normal
            )
            selectedAccount = defaultAccount
            sendToAccount = defaultAccount
            print("before function default")
            
            
        }
        
    }
    
    private func updateBalance() {
        var accounts = [String]()
        var account: GetAccountResponse?
        do {
            let strAccount = try wallet?.getAccounts(0)
            account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
            
        } catch let error {
            print(error)
        }
        
        accounts = (account?.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)")  != true && $0.Number != INT_MAX }).map { (acc) -> String in
            let tspendable = spendable(account: acc) as NSDecimalNumber
            print(acc.Number)
            
            return "\(acc.Name) [\( tspendable.round(8) )]"
            })!
        AccountFilter = (account?.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)")  != true && $0.Number != INT_MAX }).map { (acc) -> AccountsEntity in
           
            
            return acc
            })!
        self.accountDropdown.initMenu(accounts) { [weak self] ind, val in
            guard let this = self else { return }
            
            this.accountDropdown.setTitle(
                val,
                for: UIControlState.normal
            )
            this.selectedAccount = self?.AccountFilter?[ind]
            print("before function update")
            if(self!.sendAllTX){
                self!.sendAll()
                
            }
        }
        self.toAccountDropDown.initMenu(accounts) { [weak self] ind, val in
            guard let this = self else { return }
            
            this.toAccountDropDown.setTitle(
                 val,
                for: UIControlState.normal
            )
            this.sendToAccount = self?.AccountFilter?[ind]
        }
    }
    
    @IBAction func pasteFunc(_ sender: Any) {
        DispatchQueue.main.async {
            self.walletAddress.text = UIPasteboard.general.string
        }
        self.removedBtn = false
        self.addressErrorText.text = ""
        self.removeQrbtn()
        self.removePasteBtn()
        self.walletAddress.becomeFirstResponder()
    }
    
    //MARK: - Validation
    
    private func validate(amount: String) -> Bool {
        if !self.validateWallet() {
            self.showAlertForInvalidWallet()
            return false
        }
        if !(self.toAddressContainer.isHidden){
            if !self.validateDestinationAddress() {
                self.addressErrorText.text = "Destination address is not valid"
                return false
            }
        }
        if !self.validateAmount(amount: amount) {
            self.amountErrorText.text = "Amount can not be zero"
            return false
        }
        if(self.amountErrorText.text != ""){
            return false
        }
        
        return true
    }
    private func validateSentBtn(amount : String)-> Bool{
        if !self.validateWallet() {
            self.showAlertForInvalidWallet()
            print("wallet error")
            return false
        }
        if !(self.toAddressContainer.isHidden){
            if !self.validateDestinationAddress() {
                print("address error")
                return false
            }
        }
        if !self.validateAmount(amount: amount) {
            print("amount error")
            return false
        }
        if(self.amountErrorText.text != ""){
            print("addressErrorText error")
            return false
        }
        
        return true
    }
    
    private func validateDestinationAddress() -> Bool {
        return (self.walletAddress.text?.count ?? 0) > 25
    }
    
    private func validateAmount(amount : String) -> Bool {
        if(amount == "" ){
            print("Amount nill or empty")
            return false
        }
        else{
            
            let amountToSend = Double((amount ))!
            let tspendable = spendable(account: self.selectedAccount!) as Decimal
            print(" result of amount is \(amountToSend > 0 || Decimal(amountToSend) < tspendable)")
            return amountToSend > 0 && Decimal(amountToSend) <= tspendable
        }
        
    }
    
    private func validateWallet() -> Bool {
        return self.selectedAccount != nil
    }
    
    private func showAlertForInvalidDestinationAddress() {
        self.showAlert(message: "Please paste a correct destination address.", titles: "Warning")
    }
    
    private func showAlertForInvalidWallet() {
        self.showAlert(message: "Please select your source wallet.", titles: "Warning")
    }
    
    private func showAlertInvalidAmount() {
        self.showAlert(message: "Please input amount of DCR to send.", titles: "Warning")
    }
    
    private func showAlert(message: String? , titles: String?) {
        let alert = UIAlertController(title: titles, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func validate(address: String) -> Bool {
        return (wallet?.isAddressValid(address)) ?? false
    }
    
    @IBAction func reloadExchange(_ sender: Any) {
        self.exchangeRateError.isEnabled = false
        self.GetExchangeRate()
    }
    
    func GetExchangeRate(){
        //create the url with NSURL
       let url = NSURL(string: "https://bittrex.com/api/v1.1/public/getticker?market=USDT-DCR")! //change the url
        print("start fetching")
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        let request = URLRequest(url: url as URL)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            print("in task now")
            guard error == nil else {
                DispatchQueue.main.async {
                    self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                    self.exchangeRateError.isEnabled = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                    self.exchangeRateError.isEnabled = true
                }
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    let resultValue = json["success"] as? Bool?
                    print(json["result"]! as Any)
                    print(json["success"]!)
                    if resultValue  == true{
                        // print(json["data"] as Any)
                        let reportLoad = json["result"] as? NSDictionary
                        if let exchangeRate = reportLoad!["Last"] as? Double?{
                            let exchange = Decimal(exchangeRate!) as NSDecimalNumber
                            DispatchQueue.main.async {
                                self.conversionContHeight.constant = UIScreen.main.bounds.height * 0.035
                                self.conversionRowCont.isHidden = false
                                self.sendInfoHeight.constant = 0.515 * self.buttomContHeight.constant
                                self.exchangeRateCont.isHidden = false
                                self.exchangeRateDisplay.text = exchange.round(2).stringValue + " USD/DCR (bittrex)"
                                self.exchangeRateGloabal = exchange.round(2)
                                self.exchangeRateError.isEnabled = false
                                self.exchangeRateError.setTitle("", for: .normal)
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                            self.exchangeRateError.isEnabled = true
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                            self.exchangeRateError.isEnabled = true
                        }
                        return
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                    self.exchangeRateError.isEnabled = true
                }
                
                print(error.localizedDescription)
                return
            }
        })
        
        task.resume()
    }
    
    func setScreenFont(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //iPhone 5 or 5S or 5C
                // self.setFontSize(addressTxt: 14, messageTxt: 14, securityTxtLabel: 16, signatureTxt: 14, addressErrorTxt: 11, copyBtnTxt: 13, signatureErrorTxt: 11, signMsgBtnTxt: 13, HeaderInfoTxt: 12, syncInfoLabelTxt: 12, messageErrorTxt: 11)
                self.setFontSize(TxtfeeLabel: 14, TxtusdLabel: 12, TxtfromLabel: 15, TxtsubHeaderLabel: 14, TxtHeaderLabel: 18, TxttoLabel: 15, TxtsendInUsd: 13, TxtsendInDcr: 13, TxtdcrLabel: 12, TxtestimatedFeeLabel: 14, TxtbalanceAfterLabel: 14, TxtexchangeRateLabel: 14, TxtBalanceAfter: 14, TxtestimateFee: 14, TxtestimateSize: 14, TxtwalletAddress: 13, TxttfAmount: 12, TxtsendAllBtn: 12, TxtpasteBtn: 9, TxtsendNtwkErrtext: 12, TxtamountErrorText: 9, TxtaddressErrorText: 9, TxtexchangeRateDisplay: 14, TxtconvertionFeeOther: 14, TxtsendBtn: 13, TxtexchangeRateError: 12, TxtcurrencyAmount2: 13, TxtaccountDropdown: 14, TxttoAccountDropDown: 14)
                break
            case 1334:
                // iPhone 6/6S/7/8
                // self.setFontSize(addressTxt: 16, messageTxt: 16, securityTxtLabel: 18, signatureTxt: 16, addressErrorTxt: 13, copyBtnTxt: 15, signatureErrorTxt: 13, signMsgBtnTxt: 15, HeaderInfoTxt: 14, syncInfoLabelTxt: 14, messageErrorTxt: 13)
                self.setFontSize(TxtfeeLabel: 16, TxtusdLabel: 14, TxtfromLabel: 18, TxtsubHeaderLabel: 17, TxtHeaderLabel: 20, TxttoLabel: 18, TxtsendInUsd: 16, TxtsendInDcr: 16, TxtdcrLabel: 14, TxtestimatedFeeLabel: 16, TxtbalanceAfterLabel: 16, TxtexchangeRateLabel: 16, TxtBalanceAfter: 16, TxtestimateFee: 16, TxtestimateSize: 16, TxtwalletAddress: 15, TxttfAmount: 15, TxtsendAllBtn: 14, TxtpasteBtn: 14, TxtsendNtwkErrtext: 14, TxtamountErrorText: 11, TxtaddressErrorText: 11, TxtexchangeRateDisplay: 16, TxtconvertionFeeOther: 16, TxtsendBtn: 15, TxtexchangeRateError: 14, TxtcurrencyAmount2: 15, TxtaccountDropdown: 16, TxttoAccountDropDown: 16)
                
                break
            case 2208:
                //iPhone 6+/6S+/7+/8+
                // self.setFontSize(addressTxt: 18, messageTxt: 18, securityTxtLabel: 20, signatureTxt: 18, addressErrorTxt: 15, copyBtnTxt: 17, signatureErrorTxt: 15, signMsgBtnTxt: 17, HeaderInfoTxt: 16, syncInfoLabelTxt: 16, messageErrorTxt: 15)
                self.setFontSize(TxtfeeLabel: 18, TxtusdLabel: 16, TxtfromLabel: 20, TxtsubHeaderLabel: 19, TxtHeaderLabel: 22, TxttoLabel: 20, TxtsendInUsd: 18, TxtsendInDcr: 18, TxtdcrLabel: 16, TxtestimatedFeeLabel: 18, TxtbalanceAfterLabel: 18, TxtexchangeRateLabel: 18, TxtBalanceAfter: 18, TxtestimateFee: 18, TxtestimateSize: 18, TxtwalletAddress: 17, TxttfAmount: 17, TxtsendAllBtn: 16, TxtpasteBtn: 16, TxtsendNtwkErrtext: 16, TxtamountErrorText: 13, TxtaddressErrorText: 13, TxtexchangeRateDisplay: 18, TxtconvertionFeeOther: 18, TxtsendBtn: 17, TxtexchangeRateError: 16, TxtcurrencyAmount2: 17, TxtaccountDropdown: 18, TxttoAccountDropDown: 18)
                break
            case 2436:
                // iPhone X
                //self.setFontSize(addressTxt: 16, messageTxt: 16, securityTxtLabel: 18, signatureTxt: 16, addressErrorTxt: 13, copyBtnTxt: 15, signatureErrorTxt: 13, signMsgBtnTxt: 15, HeaderInfoTxt: 14, syncInfoLabelTxt: 14, messageErrorTxt: 13)
                self.setFontSize(TxtfeeLabel: 16, TxtusdLabel: 14, TxtfromLabel: 18, TxtsubHeaderLabel: 17, TxtHeaderLabel: 20, TxttoLabel: 18, TxtsendInUsd: 16, TxtsendInDcr: 16, TxtdcrLabel: 14, TxtestimatedFeeLabel: 16, TxtbalanceAfterLabel: 16, TxtexchangeRateLabel: 16, TxtBalanceAfter: 16, TxtestimateFee: 16, TxtestimateSize: 16, TxtwalletAddress: 15, TxttfAmount: 15, TxtsendAllBtn: 14, TxtpasteBtn: 14, TxtsendNtwkErrtext: 14, TxtamountErrorText: 11, TxtaddressErrorText: 11, TxtexchangeRateDisplay: 16, TxtconvertionFeeOther: 16, TxtsendBtn: 15, TxtexchangeRateError: 14, TxtcurrencyAmount2: 15, TxtaccountDropdown: 16, TxttoAccountDropDown: 16)
                break
            default: break
                // print("unknown")
            }
        }
        else if UIDevice().userInterfaceIdiom == .pad{
            switch UIScreen.main.nativeBounds.height {
            case 2048:
                // iPad Pro (9.7-inch)/ iPad Air 2/ iPad Mini 4
                // self.setFontSize(addressTxt: 28, messageTxt: 28, securityTxtLabel: 40, signatureTxt: 28, addressErrorTxt: 16, copyBtnTxt: 27, signatureErrorTxt: 16, signMsgBtnTxt: 27, HeaderInfoTxt: 32, syncInfoLabelTxt: 20, messageErrorTxt: 16)
                self.setFontSize(TxtfeeLabel: 28, TxtusdLabel: 26, TxtfromLabel: 30, TxtsubHeaderLabel: 28, TxtHeaderLabel: 32, TxttoLabel: 30, TxtsendInUsd: 28, TxtsendInDcr: 28, TxtdcrLabel: 26, TxtestimatedFeeLabel: 28, TxtbalanceAfterLabel: 28, TxtexchangeRateLabel: 28, TxtBalanceAfter: 28, TxtestimateFee: 28, TxtestimateSize: 28, TxtwalletAddress: 27, TxttfAmount: 27, TxtsendAllBtn: 27, TxtpasteBtn: 26, TxtsendNtwkErrtext: 26, TxtamountErrorText: 23, TxtaddressErrorText: 23, TxtexchangeRateDisplay: 28, TxtconvertionFeeOther: 28, TxtsendBtn: 27, TxtexchangeRateError: 26, TxtcurrencyAmount2: 27, TxtaccountDropdown: 28, TxttoAccountDropDown: 28)
                print("ipad air")
                break
            case 2224:
                //iPad Pro 10.5-inch
                // self.setFontSize(addressTxt: 30, messageTxt: 30, securityTxtLabel: 42, signatureTxt: 30, addressErrorTxt: 18, copyBtnTxt: 28, signatureErrorTxt: 18, signMsgBtnTxt: 28, HeaderInfoTxt: 34, syncInfoLabelTxt: 22, messageErrorTxt: 18)
                self.setFontSize(TxtfeeLabel: 30, TxtusdLabel: 28, TxtfromLabel: 32, TxtsubHeaderLabel: 29, TxtHeaderLabel: 34, TxttoLabel: 32, TxtsendInUsd: 30, TxtsendInDcr: 30, TxtdcrLabel: 28, TxtestimatedFeeLabel: 30, TxtbalanceAfterLabel: 30, TxtexchangeRateLabel: 30, TxtBalanceAfter: 30, TxtestimateFee: 30, TxtestimateSize: 30, TxtwalletAddress: 29, TxttfAmount: 29, TxtsendAllBtn: 29, TxtpasteBtn: 28, TxtsendNtwkErrtext: 28, TxtamountErrorText: 25, TxtaddressErrorText: 25, TxtexchangeRateDisplay: 30, TxtconvertionFeeOther: 30, TxtsendBtn: 29, TxtexchangeRateError: 28, TxtcurrencyAmount2: 29, TxtaccountDropdown: 30, TxttoAccountDropDown: 30)
                print("ipad air 10inch")
                break
            case 2732:
                // iPad Pro 12.9-inch
                // self.setFontSize(addressTxt: 38, messageTxt: 38, securityTxtLabel: 50, signatureTxt: 38, addressErrorTxt: 24, copyBtnTxt: 36, signatureErrorTxt: 24, signMsgBtnTxt: 36, HeaderInfoTxt: 42, syncInfoLabelTxt: 30, messageErrorTxt: 24)
                self.setFontSize(TxtfeeLabel: 38, TxtusdLabel: 36, TxtfromLabel: 40, TxtsubHeaderLabel: 37, TxtHeaderLabel: 42, TxttoLabel: 40, TxtsendInUsd: 38, TxtsendInDcr: 38, TxtdcrLabel: 36, TxtestimatedFeeLabel: 38, TxtbalanceAfterLabel: 38, TxtexchangeRateLabel: 38, TxtBalanceAfter: 38, TxtestimateFee: 38, TxtestimateSize: 38, TxtwalletAddress: 37, TxttfAmount: 37, TxtsendAllBtn: 37, TxtpasteBtn: 36, TxtsendNtwkErrtext: 36, TxtamountErrorText: 33, TxtaddressErrorText: 33, TxtexchangeRateDisplay: 38, TxtconvertionFeeOther: 38, TxtsendBtn: 37, TxtexchangeRateError: 36, TxtcurrencyAmount2: 37, TxtaccountDropdown: 38, TxttoAccountDropDown: 38)
                break
            default:
                print("unknown")
                 self.setFontSize(TxtfeeLabel: 28, TxtusdLabel: 26, TxtfromLabel: 30, TxtsubHeaderLabel: 28, TxtHeaderLabel: 32, TxttoLabel: 30, TxtsendInUsd: 28, TxtsendInDcr: 28, TxtdcrLabel: 26, TxtestimatedFeeLabel: 28, TxtbalanceAfterLabel: 28, TxtexchangeRateLabel: 28, TxtBalanceAfter: 28, TxtestimateFee: 28, TxtestimateSize: 28, TxtwalletAddress: 27, TxttfAmount: 27, TxtsendAllBtn: 27, TxtpasteBtn: 26, TxtsendNtwkErrtext: 26, TxtamountErrorText: 23, TxtaddressErrorText: 23, TxtexchangeRateDisplay: 28, TxtconvertionFeeOther: 28, TxtsendBtn: 27, TxtexchangeRateError: 26, TxtcurrencyAmount2: 27, TxtaccountDropdown: 28, TxttoAccountDropDown: 28)
                print(UIScreen.main.nativeBounds.height)
                break
                
                
            }
            
            
        }
    }
    
    func setFontSize(TxtfeeLabel: CGFloat,TxtusdLabel: CGFloat,TxtfromLabel: CGFloat,TxtsubHeaderLabel: CGFloat,TxtHeaderLabel: CGFloat,TxttoLabel: CGFloat,TxtsendInUsd: CGFloat,TxtsendInDcr: CGFloat,TxtdcrLabel: CGFloat,TxtestimatedFeeLabel: CGFloat,TxtbalanceAfterLabel: CGFloat,TxtexchangeRateLabel: CGFloat,TxtBalanceAfter: CGFloat,TxtestimateFee: CGFloat,TxtestimateSize: CGFloat,TxtwalletAddress: CGFloat,TxttfAmount: CGFloat,TxtsendAllBtn: CGFloat,TxtpasteBtn: CGFloat,TxtsendNtwkErrtext: CGFloat,TxtamountErrorText: CGFloat,TxtaddressErrorText: CGFloat,TxtexchangeRateDisplay: CGFloat,TxtconvertionFeeOther: CGFloat,TxtsendBtn: CGFloat,TxtexchangeRateError: CGFloat,TxtcurrencyAmount2: CGFloat,TxtaccountDropdown: CGFloat,TxttoAccountDropDown: CGFloat){
        self.feeLabel.font = feeLabel.font?.withSize(TxtfeeLabel)
        self.usdLabel.font = usdLabel.font?.withSize(TxtusdLabel)
         self.fromLabel.font = fromLabel.font?.withSize(TxtfromLabel)
         self.subHeaderLabel.font = subHeaderLabel.font?.withSize(TxtsubHeaderLabel)
         self.HeaderLabel.font = HeaderLabel.font?.withSize(TxtHeaderLabel)
         self.toLabel.font = toLabel.font?.withSize(TxttoLabel)
         self.sendInUsd.font = sendInUsd.font?.withSize(TxtsendInUsd)
         self.sendInDcr.font = sendInDcr.font?.withSize(TxtsendInDcr)
         self.dcrLabel.font = dcrLabel.font?.withSize(TxtdcrLabel)
         self.estimatedFeeLabel.font = estimatedFeeLabel.font?.withSize(TxtestimatedFeeLabel)
         self.balanceAfterLabel.font = balanceAfterLabel.font?.withSize(TxtbalanceAfterLabel)
         self.exchangeRateLabel.font = exchangeRateLabel.font?.withSize(TxtexchangeRateLabel)
         self.BalanceAfter.font = BalanceAfter.font?.withSize(TxtBalanceAfter)
         self.estimateFee.font = estimateFee.font?.withSize(TxtestimateFee)
         self.estimateSize.font = estimateSize.font?.withSize(TxtestimateSize)
         self.walletAddress.font = walletAddress.font?.withSize(TxtwalletAddress)
         self.tfAmount.font = tfAmount.font?.withSize(TxttfAmount)
         self.sendAllBtn.titleLabel?.font = .systemFont(ofSize: TxtsendAllBtn)
         self.pasteBtn.titleLabel?.font = .systemFont(ofSize: TxtpasteBtn)
         self.sendNtwkErrtext.font = sendNtwkErrtext.font?.withSize(TxtsendNtwkErrtext)
         self.amountErrorText.font = amountErrorText.font?.withSize(TxtamountErrorText)
         self.addressErrorText.font = addressErrorText.font?.withSize(TxtaddressErrorText)
         self.exchangeRateDisplay.font = exchangeRateDisplay.font?.withSize(TxtexchangeRateDisplay)
         self.convertionFeeOther.font = convertionFeeOther.font?.withSize(TxtconvertionFeeOther)
         self.sendBtn.titleLabel?.font = .systemFont(ofSize: TxtsendBtn)
        self.exchangeRateError.titleLabel?.font = .systemFont(ofSize: TxtexchangeRateError)
         self.currencyAmount2.font = currencyAmount2.font?.withSize(TxtcurrencyAmount2)
        self.accountDropdown.titleLabel?.font = .systemFont(ofSize: TxtaccountDropdown)
        self.toAccountDropDown.titleLabel?.font = .systemFont(ofSize: TxttoAccountDropDown)
    }
    
}
class AmountTextfield: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
