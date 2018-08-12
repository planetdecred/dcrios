//
//  SendViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import UIKit
import QRCodeReader

class SendViewController: UIViewController, UITextFieldDelegate, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var accountDropdown: DropMenuButton!
    @IBOutlet weak var totalAmountSending: UILabel!
    @IBOutlet weak var estimateFee: UILabel!
    @IBOutlet weak var estimateSize: UILabel!
    @IBOutlet weak var walletAddress: UITextField!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var tfAmountValue: UITextField!
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()


    var selectedAccount : AccountsEntity?
    var preparedTransaction: MobilewalletConstructTxResponse?
    var password : String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tfAmountValue.addDoneButton()
        self.accountDropdown.backgroundColor = UIColor.clear
        tfAmount.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Send"
       // let isValidAddressInClipboard = validate(address:UIPasteboard.general.string!)
       // if isValidAddressInClipboard {destinationAddress.text = UIPasteboard.general.string ?? ""}
        updateBalance()
    }
    
    @IBAction func onSendAll(_ sender: Any) {
        self.tfAmount.text = "\(selectedAccount?.Balance?.dcrSpendable ?? 0)"
        self.tfAmount.isEnabled = false
        prepareTransaction(sendAll:true)
    }
    
    func textFieldShouldEndEditing(_ textField:UITextField) -> Bool{
        prepareTransaction(sendAll:false)
        return true
    }

    func getAttributedString(str: String) -> NSAttributedString {
        let stt = str as NSString?
        let atrStr = NSMutableAttributedString(string: stt! as String)
        let dotRange = stt?.range(of: "[")
        if(str.length > 0) {
            atrStr.addAttribute(NSAttributedStringKey.font,
                                value: UIFont(
                                    name: "Helvetica-bold",
                                    size: 15.0)!,
                                range: NSRange(
                                    location:0,
                                    length:(dotRange?.location)!))

            atrStr.addAttribute(NSAttributedStringKey.font,
                                value: UIFont(
                                    name: "Helvetica",
                                    size: 15.0)!,
                                range: NSRange(
                                    location:(dotRange?.location)!,
                                    length:(str.length - (dotRange?.location)!)))

            atrStr.addAttribute(NSAttributedStringKey.foregroundColor,
                                value: UIColor.darkGray,
                                range: NSRange(
                                    location:0,
                                    length:str.length))

        }
        return atrStr
    }
   
    @IBAction private func sendFund(_ sender: Any) {
        if validate(){
            prepareTransaction(sendAll:false)
            askPassword()
        }
    }
    
    private func askPassword(){
        let alert = UIAlertController(title: "Security", message: "Please enter password of your wallet", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        let okAction = UIAlertAction(title: "Proceed", style: .default) { (action) in
            let tfPasswd = alert.textFields![0] as UITextField
             self.password = tfPasswd.text!
            alert.dismiss(animated: false, completion:nil)
            self.confirmSend()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func prepareTransaction(sendAll:Bool?){
        let amountToSend = Double((tfAmount.text)!)!
        do{
            preparedTransaction = try AppContext.instance.decrdConnection?.prepareTransaction(from: (self.selectedAccount?.Number)!, to: self.walletAddress.text!, amount: amountToSend, isSendAll: sendAll ?? false)
            estimateSize.text = "\( preparedTransaction?.estimatedSignedSize() ?? 0) Bytes"
            estimateFee.text = "\(Double(( preparedTransaction?.estimatedSignedSize())!) / 0.001 / 1e8) DCR"
            totalAmountSending.text = "\(preparedTransaction?.totalOutputAmount() ?? 0) DCR"
        } catch let error{
            self.showAlert(message: error.localizedDescription)
        }
    }
    
    private func signTransaction(){
        do{
            let signedTransaction = try AppContext.instance.decrdConnection?.signTransaction(transaction: self.preparedTransaction!, password: (password?.data(using:.utf8))!)
            publish(transaction: signedTransaction)
        } catch let error{
            self.showAlert(message: error.localizedDescription)
        }
    }
    
    private func publish(transaction:Data?){
        do{
            let result = try AppContext.instance.decrdConnection?.publish(transaction: transaction!)
            //print(String(format: "%hh", result as! CVarArg))
            transactionSucceeded(hash:result?.hexEncodedString())
        } catch let error{
            DispatchQueue.main.async {
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func confirmSend() {
        let amountToSend = Double((tfAmount?.text)!)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewController") as! ConfirmToSendFundViewController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        confirmSendFundViewController.amount = amountToSend
        
        confirmSendFundViewController.confirm = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.signTransaction()
            }
        }
        
        present(confirmSendFundViewController, animated: true, completion: nil)
    }
    
    @IBAction private func scanQRCodeAction(_ sender: UIButton) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            print(result)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.dismiss(animated: true, completion: nil)
    }
    
    private func transactionSucceeded(hash:String?) {

        let storyboard = UIStoryboard(
            name: "SendCompletedViewController",
            bundle: nil
        )
        
        let sendCompletedVC = storyboard.instantiateViewController(withIdentifier: "SendCompletedViewController") as! SendCompletedViewController
        sendCompletedVC.modalTransitionStyle = .crossDissolve
        sendCompletedVC.modalPresentationStyle = .overCurrentContext
        sendCompletedVC.transactionHash = hash
        
        sendCompletedVC.openDetails = { [weak self] in
            guard let `self` = self else { return }
            
            let storyboard = UIStoryboard(
                name: "TransactionFullDetailsViewController",
                bundle: nil
            )
            
           let txnDetails = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
            txnDetails.transactionHash = hash
            self.navigationController?.pushViewController(txnDetails, animated: true)
        }
        
        self.present(sendCompletedVC, animated: true, completion: nil)
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        prepareTransaction(sendAll:false)
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    private func updateBalance(){
        AppContext.instance.decrdConnection?.rescan()
        let accounts = AppContext.instance.decrdConnection?.getAccounts()
        let accountsDisplay = accounts?.Acc.map {(acc)-> String in
            let spendable = AppContext.instance.decrdConnection?.spendable(account: acc)
            return "\(acc.Name) [\(spendable!) DCR]"
        }
        accountDropdown.initMenu(accountsDisplay!, actions: ({ (ind, val) -> (Void) in
            self.accountDropdown.setAttributedTitle(self.getAttributedString(str: val), for: UIControlState.normal)
            self.selectedAccount = accounts?.Acc[ind]
            self.accountDropdown.backgroundColor = UIColor(red: 173.0/255.0, green: 231.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        }))
    }
    
    //MARK: - Validation
    private func validate() -> Bool{
        if !validateWallet(){
            showAlertForInvalidWallet()
            return false
        }
        if !validateDestinationAddress(){
            showAlertForInvalidDestinationAddress()
            return false
        }
        if !validateAmount(){
            showAlertInvalidAmount()
            return false
        }
        return true
    }
    
    private func validateDestinationAddress() -> Bool{
        return (walletAddress.text?.count ?? 0) > 25
    }
    
    private func validateAmount() -> Bool{
        return (totalAmountSending.text?.count ?? 0) > 0
    }
    
    private func validateWallet() -> Bool{
        return selectedAccount != nil
    }
    
    private func showAlertForInvalidDestinationAddress(){
        showAlert(message: "Please paste a correct destination address")
    }
    
    private func showAlertForInvalidWallet(){
        showAlert(message: "Please select your source wallet")
    }
    
    private func showAlertInvalidAmount(){
        showAlert(message: "Please input amount of DCR to send")
    }
    
    private func showAlert(message:String?){
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func validate(address:String) -> Bool{
        return (AppContext.instance.decrdConnection?.wallet?.isAddressValid(address)) ?? false
    }
}
