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
    var pinInput: String?
    
    @IBOutlet weak var pasteBtn: UIButton!
    weak var delegate: LeftMenuProtocol?
    @IBOutlet var accountDropdown: DropMenuButton!
    @IBOutlet weak var toAccountDropDown: DropMenuButton!
    @IBOutlet var BalanceAfter: UILabel!
    @IBOutlet var estimateFee: UILabel!
    @IBOutlet var estimateSize: UILabel!
    @IBOutlet var walletAddress: UITextField!
    @IBOutlet var tfAmount: UITextField!
    @IBOutlet var sendAllBtn: UIButton!
    @IBOutlet weak var toAccountContainer: UIStackView!
    @IBOutlet weak var toAddressContainer: UIStackView!
    var removedBtn = true
    var wallet :DcrlibwalletLibWallet!
    
    @IBOutlet weak var sendNtwkErrtext: UILabel!
    @IBOutlet weak var amountErrorText: UILabel!
    @IBOutlet weak var addressErrorText: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var qrcodeBtn: UIButton!
    var fromNotQRScreen = true
     var AccountFilter: [AccountsEntity]?
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    var selectedAccount: AccountsEntity?
    var sendToAccount: AccountsEntity?
    var password: String?
    var sendAllTX = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendBtn.layer.cornerRadius = 5;
        self.accountDropdown.backgroundColor = UIColor.clear
        self.toAccountDropDown.backgroundColor = UIColor.clear
        self.tfAmount.delegate = self
        self.pasteBtn.layer.cornerRadius = 4
        self.pasteBtn.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        wallet = SingleInstance.shared.wallet
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name:.UIApplicationWillEnterForeground, object: nil)
        self.walletAddress.delegate = self
        removedBtn = false
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
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
        } else {
            self.amountErrorText.text = ""
            self.tfAmount.text = ""
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
        let barButton = UIBarButtonItem(customView: menu)
        self.navigationItem.rightBarButtonItems = [barButton]
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
            self.confirmSendWithoutPin(sendAll: false, pin: UserDefaults.standard.string(forKey: "TMPPIN")!)
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
        self.prepareTransaction(sendAll: self.sendAllTX)
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
        
        alertController.addAction(cancelAction)
        alertController.addAction(sendToAccount)
        alertController.addAction(clearFields)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendToSwitch(){
        self.toAddressContainer.isHidden = !toAddressContainer.isHidden
        self.toAccountContainer.isHidden = !toAccountContainer.isHidden
        self.addressErrorText.isHidden = !self.addressErrorText.isHidden
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
        if self.validate() {
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
    private func prepareTransaction(sendAll: Bool?) {
        let amountToSend = Double((self.tfAmount.text)!)!
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
                    fee = Double((preparedTransaction?.estimatedSignedSize())!) / 0.001 / 1e8
                    let spendableAmount = spendable(account: (self?.selectedAccount!)!)
                    this.estimateSize.text = "\(preparedTransaction?.estimatedSignedSize() ?? 0) Bytes"
                    this.estimateFee.text = "\(fee) DCR"
                    let Amount =  (spendableAmount - (Decimal(amountToSend) )) as NSDecimalNumber
                    this.BalanceAfter.text = "\(Amount.round(8)) DCR"
                    if(sendAll)!{
                        this.tfAmount.text = "\(DcrlibwalletAmountCoin(amount - DcrlibwalletAmountAtom(fee)) )"
                    }
                }
            } catch let error {
                self.showAlert(message: error.localizedDescription, titles: "Error")
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
        
        let amountToSend = Double((tfAmount?.text)!)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewController") as! ConfirmToSendFundViewController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: confirmSendFundViewController.view, action: #selector(confirmSendFundViewController.vContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        confirmSendFundViewController.view.addGestureRecognizer(tap)
        confirmSendFundViewController.amount = amountToSend
        
        confirmSendFundViewController.confirm = { (password) in
            self.signTransaction(sendAll: sendAll, password: password)
        }
        
        DispatchQueue.main.async {
            self.present(confirmSendFundViewController, animated: true, completion: nil)
        }
        return
    }
    private func confirmSendWithoutPin(sendAll: Bool, pin: String) {
        
        let amountToSend = Double((tfAmount?.text)!)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewPINController") as! ConfirmToSendFundViewPINController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: confirmSendFundViewController.view, action: #selector(confirmSendFundViewController.vContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        confirmSendFundViewController.view.addGestureRecognizer(tap)
        confirmSendFundViewController.amount = amountToSend
        
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
                    if (address?.length)! > 25 && (address?.length)! < 37 {
                        if (address?.starts(with: "T"))! {
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
            if(UserDefaults.standard.bool(forKey: "pref_use_testnet")){
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
        if !self.validateAmount() {
            self.showAlertInvalidAmount()
            return false
        }
        
        self.prepareTransaction(sendAll: false)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (self.tfAmount.text != nil && self.tfAmount.text != "" && self.tfAmount.text != "0" && self.amountErrorText.text == "") {
            self.sendAllTX = false
            self.prepareTransaction(sendAll: self.sendAllTX)
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
            print("am typing")
            if (updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == "") {
                print("zero or invalid address")
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
                            print(" . first")
                        }
                        updatedString = "0."
                        ACCEPTABLE_CHARACTERS = "."
                    }
                    else{
                        print(" . still point inside")
                        ACCEPTABLE_CHARACTERS = "."
                    }
                }
                else{
                    if(updatedString!.length > 8){
                        return false
                        
                    }
                    print(" . no point inside")
                    ACCEPTABLE_CHARACTERS = ""
                    
                }
                
                if !(CharacterSet(charactersIn: string).isSubset(of: cs)){
                    return false
                }
                self.amountErrorText.text = ""
                let tspendable = spendable(account: self.selectedAccount!) as Decimal
                let amountToSend = Decimal(Double((updatedString)!)!)
                
                if (amountToSend > tspendable) {
                    print("zero or invalid address")
                    DispatchQueue.main.async {
                        if(UserDefaults.standard.bool(forKey: "synced")){
                             self.amountErrorText.text = "Not enough funds"
                        }
                        else{
                             self.amountErrorText.text = "Not enough funds (or not connected)"
                        }
                       
                    }
            }
                else{
                    DispatchQueue.main.async {
                        self.amountErrorText.text = ""
                    }
                     return true
                }
           
                return true
            }
        }
        
        return true
            
        }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
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
    
    private func validate() -> Bool {
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
        if !self.validateAmount() {
            self.amountErrorText.text = "Amount can not be zero"
            return false
        }
        if(self.amountErrorText.text != ""){
            return false
        }
        
        return true
    }
    
    private func validateDestinationAddress() -> Bool {
        return (self.walletAddress.text?.count ?? 0) > 25
    }
    
    private func validateAmount() -> Bool {
        if(self.tfAmount?.text == nil || self.tfAmount?.text == "" ){
            return false
        }
        else{
            let amountToSend = Double((self.tfAmount?.text ?? "0.0")!)!
            return amountToSend > 0
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
}
class AmountTextfield: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
