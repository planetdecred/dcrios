//
//  SendViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import QRCodeReader
import UIKit

class SendViewController: UIViewController, UITextFieldDelegate, QRCodeReaderViewControllerDelegate {
    weak var delegate: LeftMenuProtocol?
    @IBOutlet var accountDropdown: DropMenuButton!
    @IBOutlet var totalAmountSending: UILabel!
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
  //  private var constatnt: DcrdConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tfAmountValue.addDoneButton()
        self.sendBtn.layer.cornerRadius = 5; self.accountDropdown.backgroundColor = UIColor.clear
        self.tfAmount.text = "0"
        self.tfAmount.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Send"
       // constatnt = AppContext.instance.decrdConnection as? DcrdConnection
        // let isValidAddressInClipboard = validate(address:UIPasteboard.general.string!)
        // if isValidAddressInClipboard {destinationAddress.text = UIPasteboard.general.string ?? ""}
        self.updateBalance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        SingleInstance.shared.wallet?.runGC()

    }
    
    @IBAction func onSendAll(_ sender: Any) {
        if self.sendAllTX == false {
            self.sendAllTX = false
            self.tfAmount.isEnabled = true
            self.sendAllBtn.setTitleColor(UIColor(hex: "#868BAA"), for: .normal)
        } else {
            self.sendAllTX = true
            self.tfAmount.isEnabled = false
            self.sendAllBtn.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        }
        self.tfAmount.text = "\(self.selectedAccount?.Balance?.dcrSpendable ?? 0)"
        self.prepareTransaction(sendAll: self.sendAllTX)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if self.tfAmount.text != nil && self.tfAmount.text != ""  && self.walletAddress.text != nil && self.validateDestinationAddress(){
            self.prepareTransaction(sendAll: false)
            return true
        }
        if textField == self.tfAmount{
            self.tfAmount.text = ""
        }
        return true
    }
    
    func getAttributedString(str: String) -> NSAttributedString {
        let stt = str as NSString?
        let atrStr = NSMutableAttributedString(string: stt! as String)
        let dotRange = stt?.range(of: "[")
        if str.length > 0 {
            atrStr.addAttribute(
                NSAttributedStringKey.font,
                value: UIFont(
                    name: "Helvetica-bold",
                    size: 15.0
                )!,
                range: NSRange(
                    location: 0,
                    length: (dotRange?.location)!
                )
            )
            
            atrStr.addAttribute(
                NSAttributedStringKey.font,
                value: UIFont(
                    name: "Helvetica",
                    size: 15.0
                )!,
                range: NSRange(
                    location: (dotRange?.location)!,
                    length: (str.length - (dotRange?.location)!)
                )
            )
            
            atrStr.addAttribute(
                NSAttributedStringKey.foregroundColor,
                value: UIColor.darkGray,
                range: NSRange(
                    location: 0,
                    length: str.length
                )
            )
        }
        return atrStr
    }
    let pass = "qr"

    
    @IBAction private func sendFund(_ sender: Any) {
        if self.validate() {
            // prepareTransaction(sendAll:false)
            DispatchQueue.main.async {
            self.askPassword(sendAll: false)
            }
        }
    }
    
    private func askPassword(sendAll: Bool) {
        
        let alert = UIAlertController(title: "Security", message: "Please enter password of your wallet", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        let okAction = UIAlertAction(title: "Proceed", style: .default) { _ in
            let tfPasswd = alert.textFields![0] as UITextField
            self.password = tfPasswd.text!
            alert.dismiss(animated: false, completion: nil)
            self.confirmSend(sendAll: sendAll)
        }
        alert.addAction(okAction)
       
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func prepareTransaction(sendAll: Bool?) {
        let amountToSend = Double((self.tfAmount.text)!)!
        let walletaddress = self.walletAddress.text!
        let acountN = (self.selectedAccount?.Number)!
        var preparedTransaction: MobilewalletUnsignedTransaction?
         DispatchQueue.global(qos: .userInitiated).async {
        do {
            let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
            
           preparedTransaction = try SingleInstance.shared.wallet?.constructTransaction(walletaddress, amount: Int64(amountToSend), srcAccount: acountN , requiredConfirmations: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
            print("Account Number is")
            print(acountN as Any)
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                this.estimateSize.text = "\(preparedTransaction?.estimatedSignedSize() ?? 0) Bytes"
                this.estimateFee.text = "\(Double((preparedTransaction?.estimatedSignedSize())!) / 0.001 / 1e8) DCR"
                this.totalAmountSending.text = "\(amountToSend) DCR"
             
            }
        } catch let error {
            self.showAlert(message: error.localizedDescription)
        }
        }
    }
    
    private func signTransaction(sendAll: Bool?) {
        DispatchQueue.main.async {
        let password = (self.password?.data(using: .utf8))!
        let walletAddress = self.walletAddress.text!
        let amount = Double((self.tfAmount.text)!)! * 100000000
        let account = (self.selectedAccount?.Number)!
        DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
        do {
            let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
            let result = try SingleInstance.shared.wallet?.sendTransaction(password, destAddr: walletAddress, amount: Int64(amount) , srcAccount: account , requiredConfs: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
         
            DispatchQueue.main.async {
                self.transactionSucceeded(hash: result?.hexEncodedString())
                self.walletAddress.text = ""
                self.tfAmount.text = ""
                self.estimateFee.text = ""
                self.estimateSize.text = ""
               
                return

            }
            return
            
        } catch let error {
            self.showAlert(message: error.localizedDescription)
         
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
        
        confirmSendFundViewController.confirm = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let this = self else { return }
                SingleInstance.shared.wallet?.runGC()
                this.signTransaction(sendAll: sendAll)
               // self?.selectedAccount = nil
                return
                
                
            }
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
                if (address?.length)! > 0 {
                    if (address?.starts(with: "decred:"))! {
                        address = address?.replacingOccurrences(of: "decred:", with: "")
                        if (address?.length)! > 25 && (address?.length)! < 37 {
                            if (address?.starts(with: "T"))! {
                                this.walletAddress?.text = address
                            }
                        }
                    }
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
            
            let storyboard = UIStoryboard(
                name: "TransactionFullDetailsViewController",
                bundle: nil
            )
            
            let txnDetails = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
            txnDetails.transactionHash = hashe
            self.delegate?.changeViewController(LeftMenu.overview)
            
            
        
            
           // self.navigationController?.pushViewController(txnDetails, animated: true)
        }
       
        self.present(sendCompletedVC, animated: true, completion: nil)
        
        print("sent transaction")
        self.dismiss(animated: true, completion: nil)
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
            let tspendable = spendable(account: acc)
            return "\(acc.Name) [\(tspendable) DCR]"
        })!
        
        let defaultNumber = UserDefaults.standard.integer(forKey: "wallet_default")
        
        if let defaultAccount = account?.Acc.filter({ $0.Number == defaultNumber }).first {
            let tspendable = spendable(account: defaultAccount)
            
            accountDropdown.setAttributedTitle(
                getAttributedString(str: "\(defaultAccount.Name) [\(tspendable) DCR]"),
                for: UIControlState.normal
            )
            
            selectedAccount = account?.Acc[0]
           /* self.accountDropdown.backgroundColor = UIColor(
                red: 173.0 / 255.0,
                green: 231.0 / 255.0,
                blue: 249.0 / 255.0,
                alpha: 1.0
            )*/
        }
        
        self.accountDropdown.initMenu(accounts) { [weak self] ind, val in
            guard let this = self else { return }
            
            this.accountDropdown.setAttributedTitle(
                this.getAttributedString(str: val),
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
        return (self.totalAmountSending.text?.count ?? 0) > 0
    }
    
    private func validateWallet() -> Bool {
        return self.selectedAccount != nil
    }
    
    private func showAlertForInvalidDestinationAddress() {
        self.showAlert(message: "Please paste a correct destination address")
    }
    
    private func showAlertForInvalidWallet() {
        self.showAlert(message: "Please select your source wallet")
    }
    
    private func showAlertInvalidAmount() {
        self.showAlert(message: "Please input amount of DCR to send")
    }
    
    private func showAlert(message: String?) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
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
