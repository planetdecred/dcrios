//
//  SendViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import UIKit

class SendViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var accountDropdown: DropMenuButton!
    @IBOutlet weak var totalAmountSending: UILabel!
    @IBOutlet weak var estimateFee: UILabel!
    @IBOutlet weak var estimateSize: UILabel!
    @IBOutlet weak var walletAddress: UITextField!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var tfAmount: UITextField!
    
    var selectedAccount : AccountsEntity?
    var preparedTransaction: WalletConstructTxResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountDropdown.backgroundColor = UIColor.clear
        let accounts = AppContext.instance.decrdConnection?.getAccounts()
        let accountsDisplay = accounts?.Acc.map {
            return "\($0.Name) [\($0.dcrTotalBalance) DCR]"
        }
        tfAmount.delegate = self
        accountDropdown.initMenu(accountsDisplay!, actions: ({ (ind, val) -> (Void) in
            self.accountDropdown.setAttributedTitle(self.getAttributedString(str: val), for: UIControlState.normal)
            self.selectedAccount = accounts?.Acc[ind]
            self.accountDropdown.backgroundColor = UIColor(red: 173.0/255.0, green: 231.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        }))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Send"
        let isValidAddressInClipboard = validate(address:UIPasteboard.general.string!)
        if isValidAddressInClipboard {destinationAddress.text = UIPasteboard.general.string ?? ""}
    }
    
    @IBAction func onPasteAddress(_ sender: Any) {
        
    }
    
    func textFieldShouldEndEditing(_ textField:UITextField) -> Bool{
        prepareTransaction()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        prepareTransaction()
        return true
    }
    
    func getAttributedString(str: String) -> NSAttributedString {
        let stt = str as NSString?
        let atrStr = NSMutableAttributedString(string: stt! as String)
        let dotRange = stt?.range(of: "[")
        //print("Index = \(dotRange?.location)")
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
            confirmSend()
        }
    }
    
    private func prepareTransaction(){
        let amountToSend = Double((tfAmount.text)!)!
        do{
             preparedTransaction = try AppContext.instance.decrdConnection?.prepareTransaction(from: (self.selectedAccount?.Number)!, to: self.destinationAddress.text!, amount: amountToSend)
            estimateSize.text = "\( preparedTransaction?.estimatedSignedSize() ?? 0)"
            estimateFee.text = "\(Double(( preparedTransaction?.estimatedSignedSize())!) / 0.001 / 1e8)"
        } catch let error{
            self.showAlert(message: error.localizedDescription)
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
            do{
                let signedTransaction = try AppContext.instance.decrdConnection?.signTransaction(transaction: self.preparedTransaction!, password: <#T##Data#>)
            } catch let error{
                self.showAlert(message: error.localizedDescription)
            }
            debugPrint(self)
        }
        
        present(confirmSendFundViewController, animated: true, completion: nil)
    }
    
    private func transactionSucceeded() {
        let storyboard = UIStoryboard(
            name: "SendCompletedViewController",
            bundle: nil
        )
        
        let sendCompletedVC = storyboard.instantiateViewController(withIdentifier: "SendCompletedViewController") as! SendCompletedViewController
        sendCompletedVC.modalTransitionStyle = .crossDissolve
        sendCompletedVC.modalPresentationStyle = .overCurrentContext
        sendCompletedVC.transactionHash = "00000001d4c5fb6c9b…225c4e33"
        
        sendCompletedVC.openDetails = { [weak self] in
            guard let `self` = self else { return }
            debugPrint(self)
            
            let storyboard = UIStoryboard(
                name: "TransactionFullDetailsViewController",
                bundle: nil
            )
            
           let txnDetails = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
            self.navigationController?.pushViewController(txnDetails, animated: true)
        }
        
        self.present(sendCompletedVC, animated: true, completion: nil)
    }
    
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
        return (destinationAddress.text?.count ?? 0) > 8
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
