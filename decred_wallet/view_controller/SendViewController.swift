//
//  SendViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import QRCodeReader
import UIKit
import Mobilewallet
import SafariServices

class SendViewController: UIViewController, UITextFieldDelegate, QRCodeReaderViewControllerDelegate {
    weak var delegate: LeftMenuProtocol?
    @IBOutlet var accountDropdown: DropMenuButton!
    @IBOutlet var BalanceAfter: UILabel!
    @IBOutlet var estimateFee: UILabel!
    @IBOutlet var estimateSize: UILabel!
    @IBOutlet var walletAddress: UITextField!
    @IBOutlet var tfAmount: UITextField!
    @IBOutlet var sendAllBtn: UIButton!
    
    @IBOutlet weak var sendBtn: UIButton!
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    var selectedAccount: AccountsEntity?
    var password: String?
    var sendAllTX = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendBtn.layer.cornerRadius = 5;
        self.accountDropdown.backgroundColor = UIColor.clear
        self.tfAmount.text = "0"
        self.tfAmount.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Send"
        self.updateBalance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    @IBAction func onSendAll(_ sender: Any?) {
       self.sendAllTX = true
        let spendableAmount = spendable(account: self.selectedAccount!)
        self.tfAmount.text = "\(spendableAmount)"
       self.prepareTransaction(sendAll: self.sendAllTX)
    }
    

    
    @IBAction private func sendFund(_ sender: Any) {
        if self.validate() {
            self.confirmSend(sendAll: false)
        }
    }
    
    private func prepareTransaction(sendAll: Bool?) {
        let amountToSend = Double((self.tfAmount.text)!)!
        let amount = MobilewalletAmountAtom(amountToSend)
        var walletaddress = self.walletAddress.text!
        let acountN = (self.selectedAccount?.Number)!
        if !(validateDestinationAddress()){
            walletaddress = (try!SingleInstance.shared.wallet?.currentAddress(acountN))!
        }
        var fee = 0.0
       
         DispatchQueue.global(qos: .userInitiated).async {
        do {
            let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
             let preparedTransaction: MobilewalletUnsignedTransaction?
            
             preparedTransaction = try SingleInstance.shared.wallet?.constructTransaction(walletaddress, amount: amount, srcAccount: acountN , requiredConfirmations: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                fee = Double((preparedTransaction?.estimatedSignedSize())!) / 0.001 / 1e8
                let spendableAmount = spendable(account: (self?.selectedAccount!)!)
                this.estimateSize.text = "\(preparedTransaction?.estimatedSignedSize() ?? 0) Bytes"
                this.estimateFee.text = "\(fee) DCR"
                let tnt =  (spendableAmount - (Decimal(amountToSend) + Decimal(fee))) as NSDecimalNumber
                this.BalanceAfter.attributedText = getAttributedString(str: "\(tnt.round(8) ?? 0.0)", siz: 13)
                if(sendAll)!{
                    this.tfAmount.text = "\(MobilewalletAmountCoin(amount - MobilewalletAmountAtom(fee)) )"
                }
                print("total Output")
                print(preparedTransaction?.totalOutputAmount() as Any)
            }
        } catch let error {
            self.showAlert(message: error.localizedDescription, titles: "Error")
        }
        }
        
    }
    
    private func signTransaction(sendAll: Bool?, password:String) {
        DispatchQueue.main.async {
        let walletAddress = self.walletAddress.text!
        let amount = Double((self.tfAmount.text)!)! * 100000000
        let account = (self.selectedAccount?.Number)!
        DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
        do {
            let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
            let result = try SingleInstance.shared.wallet?.sendTransaction(password.data(using: .utf8), destAddr: walletAddress, amount: Int64(amount) , srcAccount: account , requiredConfs: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
         
            DispatchQueue.main.async {
                self.transactionSucceeded(hash: result?.hexEncodedString())
                self.walletAddress.text = ""
                self.tfAmount.text = "0"
                self.estimateFee.text = ""
                self.estimateSize.text = ""
                self.BalanceAfter.text = ""
                self.updateBalance()
               
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
        
      //   self.dismiss(animated: true, completion: nil)
    }
    
    private func confirmSend(sendAll: Bool) {
        let amountToSend = Double((tfAmount?.text)!)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewController") as! ConfirmToSendFundViewController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        confirmSendFundViewController.amount = amountToSend
        
        confirmSendFundViewController.confirm = { (password) in
                SingleInstance.shared.wallet?.runGC()
                self.signTransaction(sendAll: sendAll, password: password)
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
                print("address is")
                print(address as Any)
                let lenght = min((address?.length)!,40)
                let errorText = address?.prefix(lenght)
                let message = "This is not a decred wallet address.\n".appending((errorText)!)
                if (address?.length)! > 0 {
                    if (address?.starts(with: "decred:"))! {
                        address = address?.replacingOccurrences(of: "decred:", with: "")
                    }
                    if (address?.length)! > 25 && (address?.length)! < 37 {
                        if (address?.starts(with: "T"))! {
                            this.walletAddress?.text = address
                        }
                        else{
                            self?.showAlert(message: message, titles: "Info")
                            print("address does not start with a T")
                            }
                        }
                        else{
                       self?.showAlert(message: message, titles: "Info")
                            print("invalid address lenght")
                        }
                    }
                else{
                    
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
            self.openLink(urlString: "https://testnet.dcrdata.org/tx/" + hashe! )
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
        if self.tfAmount.text != nil && self.tfAmount.text != "" && self.tfAmount.text != "0"{
            self.prepareTransaction(sendAll: false)
            return true
            
        }
        if textField == self.tfAmount{
            self.tfAmount.text = "0"
            self.estimateFee.text = ""
            self.estimateSize.text = ""
            self.BalanceAfter.text = ""
            
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.tfAmount{
            return string.rangeOfCharacter(from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) == nil
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    private func updateBalance() {
        var accounts = [String]()
        var account: GetAccountResponse?
        do {
            let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
            account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
           
        } catch let error {
            print(error)
        }
        accounts = (account?.Acc.map { (acc) -> String in
            let tspendable = spendable(account: acc) as NSDecimalNumber
            
           
            return "\(acc.Name) [\( tspendable.round(8) ?? 0.0)]"
        })!
        
        let defaultNumber = UserDefaults.standard.integer(forKey: "wallet_default")
        
        if let defaultAccount = account?.Acc.filter({ $0.Number == defaultNumber }).first {
            let tspendable = spendable(account: defaultAccount) as NSDecimalNumber
            
            accountDropdown.setAttributedTitle(
                getAttributedString(str: "\(defaultAccount.Name) [\(tspendable.round(8) ?? 0.0)]", siz: 13),
                for: UIControlState.normal
            )
            
            selectedAccount = account?.Acc[0]
        }
        
        self.accountDropdown.initMenu(accounts) { [weak self] ind, val in
            guard let this = self else { return }
            
            this.accountDropdown.setAttributedTitle(
                getAttributedString(str: val, siz: 13),
                for: UIControlState.normal
            )
            
            this.selectedAccount = account?.Acc[ind]
         this.accountDropdown.setTitle("default", for: .normal)

        }
    }
    
    //MARK: - Validation
    
    private func validate() -> Bool {
        if !self.validateWallet() {
            self.showAlertForInvalidWallet()
            return false
        }
        if !self.validateDestinationAddress() {
            self.showAlertForInvalidDestinationAddress()
            return false
        }
        if !self.validateAmount() {
            self.showAlertInvalidAmount()
            return false
        }
        return true
    }
    
    private func validateDestinationAddress() -> Bool {
        return (self.walletAddress.text?.count ?? 0) > 25
    }
    
    private func validateAmount() -> Bool {
        return (self.BalanceAfter.text?.count ?? 0) > 0
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
        
        let tmp = (SingleInstance.shared.wallet?.isAddressValid(address)) ?? false
        return tmp
    }
}
