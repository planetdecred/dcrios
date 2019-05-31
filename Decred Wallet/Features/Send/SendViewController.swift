//
//  SendViewController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 22/05/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit
import Dcrlibwallet

class SendViewController: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: SendViewController.self).wrapInNavigationcontroller()
    
    @IBOutlet weak var sourceAccountDropdown: DropMenuButton!
    
    @IBOutlet weak var addressRecipientView: UIStackView!
    @IBOutlet weak var destinationAccountView: UIStackView!
    @IBOutlet weak var destinationAccountDropdown: DropMenuButton!
    @IBOutlet weak var destinationAddressTextField: UITextField!
    @IBOutlet weak var pasteAddressButton: Button!
    @IBOutlet weak var scanQrCodeButton: UIButton!
    @IBOutlet weak var destinationErrorLabel: UILabel!
    
    @IBOutlet weak var dcrAmountTextField: UITextField!
    @IBOutlet weak var usdAmountTextField: UITextField!
    @IBOutlet weak var sendAmountErrorLabel: UILabel!
    
    @IBOutlet weak var estimatedFeeLabel: UILabel!
    @IBOutlet weak var estimatedTxSizeLabel: UILabel!
    @IBOutlet weak var balanceAfterSendingLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRateErrorLabel: UILabel!
    
    @IBOutlet weak var sendErrorLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    // Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode.
    private lazy var qrImageScanner = QRImageScanner()
    
    var overflowNavBarButton: UIBarButtonItem!
    
    var walletAccounts: [WalletAccount]!
    var exchangeRate: NSDecimalNumber?
    var sendMaxAmount: Bool = false
    
    var requiredConfirmations: Int32 {
        return Settings.spendUnconfirmed ? 0 : GlobalConstants.Wallet.defaultRequiredConfirmations
    }
    
    var isValidDestination: Bool {
        if self.addressRecipientView.isHidden {
            return self.destinationAccountDropdown.selectedItemIndex >= 0
        }
        let destinationAddress = self.destinationAddressTextField.text ?? ""
        return AppDelegate.walletLoader.wallet!.isAddressValid(destinationAddress)
    }
    
    var isValidAmount: Bool {
        self.sendAmountErrorLabel.text = ""
        guard let dcrAmountString = self.dcrAmountTextField.text, dcrAmountString != "" else { return false }
        
        let decimalPointIndex = dcrAmountString.firstIndex(of: ".")
        if decimalPointIndex != nil && dcrAmountString[decimalPointIndex!...].count > 9 {
            self.sendAmountErrorLabel.text = "Amount has more then 8 decimal places."
            return false
        }
        
        let dcrAmount = Decimal(string: dcrAmountString) as NSDecimalNumber?
        if dcrAmount == nil || dcrAmount!.doubleValue <= 0 {
            self.sendAmountErrorLabel.text = "Invalid amount."
            return false
        }
        
        let sourceAccountBalance = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].Balance!.dcrSpendable
        if dcrAmount!.doubleValue > sourceAccountBalance {
            self.sendAmountErrorLabel.text = self.insufficientFundsErrorMessage
            return false
        }
        
        return true
    }
    
    var insufficientFundsErrorMessage: String {
        if AppDelegate.walletLoader.syncer.connectedPeersCount > 0 {
            return "Not enough funds."
        } else {
            return "Not enough funds (or not connected)."
        }
    }
    
    override func viewDidLoad() {
        self.destinationAddressTextField.addTarget(self, action: #selector(self.addressTextFieldChanged), for: .editingChanged)
        self.dcrAmountTextField.addTarget(self, action: #selector(self.dcrAmountTextFieldChanged), for: .editingChanged)
        self.usdAmountTextField.addTarget(self, action: #selector(self.usdAmountTextFieldChanged), for: .editingChanged)
        
        self.hideKeyboardOnTapAround()
        self.resetViews()
    }
    
    func resetViews() {
        self.destinationAddressTextField.text = ""
        self.checkClipboardForValidAddress()
        self.scanQrCodeButton.isHidden = false
        self.destinationErrorLabel.text = ""
        
        self.dcrAmountTextField.text = ""
        self.usdAmountTextField.text = ""
        self.sendAmountErrorLabel.text = ""
        
        self.estimatedFeeLabel.text = "0.00 DCR"
        self.estimatedTxSizeLabel.text = "0 bytes"
        self.balanceAfterSendingLabel.text = "0.00 DCR"
        
        self.sendErrorLabel.isHidden = true
        self.toggleSendButtonState(addressValid: false, amountValid: false)
    
        let overflowMenuButton = UIButton(type: .custom)
        overflowMenuButton.setImage(UIImage(named: "right-menu"), for: .normal)
        overflowMenuButton.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        overflowMenuButton.addTarget(self, action: #selector(self.showOverflowMenu), for: .touchUpInside)
        self.overflowNavBarButton = UIBarButtonItem(customView: overflowMenuButton)
    }
    
    @IBAction func fetchExchangeRate(_ sender: Any?) {
        self.exchangeRateErrorLabel.isHidden = true
        if self.exchangeRate == nil {
            self.usdAmountTextField.superview?.isHidden = true
            self.exchangeRateLabel.superview?.isHidden = true
        }
        
        switch Settings.currencyConversionOption {
        case .None:
            self.exchangeRate = nil
            self.usdAmountTextField.superview?.isHidden = true
            self.exchangeRateLabel.superview?.isHidden = true
            break
            
        case .Bittrex:
            ExchangeRates.Bittrex.fetch(callback: self.displayExchangeRate)
        }
    }
    
    func displayExchangeRate(_ exchangeRate: NSDecimalNumber?) {
        self.exchangeRate = exchangeRate
        let currencyConversionOption = Settings.currencyConversionOption.rawValue
        
        guard let exchangeRate = exchangeRate else {
            self.usdAmountTextField.superview?.isHidden = true
            self.exchangeRateLabel.superview?.isHidden = true
            self.exchangeRateErrorLabel.text = "\(currencyConversionOption.withFirstLetterCapital) rate unavailable (tap to retry)."
            self.exchangeRateErrorLabel.isHidden = false
            return
        }
        
        self.exchangeRateLabel.text = exchangeRate.round(2).stringValue + " USD/DCR (\(currencyConversionOption))"
        self.exchangeRateLabel.superview?.isHidden = false
        self.usdAmountTextField.superview?.isHidden = false // show usd amount field AFTER fetching exchange rate
        self.dcrAmountTextFieldChanged(sendMax: self.sendMaxAmount) // trigger dcr amount field changed to update usd amount field
    }
    
    @objc func showOverflowMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let alternateSendOption = self.destinationAccountView.isHidden ? "Send to account" : "Send to address"
        let alternateSendAction = UIAlertAction(title: alternateSendOption, style: .default) { _ in
            self.toggleDestinationAddressAccount()
        }
        alertController.addAction(alternateSendAction)
        
        let resetAction = UIAlertAction(title: "Clear fields", style: .default) { _ in
            self.resetViews()
        }
        alertController.addAction(resetAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // iPads show alert controller as pop ups which requires an anchor point to display.
        // Anchor the pop up to the overflow button on the nav bar.
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = self.overflowNavBarButton
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupAccountDropdowns() {
        let walletAccounts = AppDelegate.walletLoader.wallet!.walletAccounts(confirmations: self.requiredConfirmations)
            .filter({ !$0.isHidden && $0.Number != INT_MAX }) // remove hidden wallets from array
        self.walletAccounts = walletAccounts
        
        // convert accounts array to string array where each account is represented in the format: Account Name [#,###.###]
        let accountDropdownItems = walletAccounts.map({ (account) -> String in
            let spendableBalance = Decimal(account.Balance!.dcrSpendable) as NSDecimalNumber
            return "\(account.Name) [\(spendableBalance.round(8).formattedWithSeparator)]"
        })
        self.sourceAccountDropdown.initMenu(accountDropdownItems) { selectedAccountIndex, _ in
            self.displayTransactionSummary()
        }
        self.destinationAccountDropdown.initMenu(accountDropdownItems)
        
        // select default account or first account
        var selectedAccountIndex = 0
        for (index, account) in walletAccounts.enumerated() {
            if account.isDefault {
                selectedAccountIndex = index
                break
            }
        }
        self.sourceAccountDropdown.setSelectedItemIndex(selectedAccountIndex)
        self.destinationAccountDropdown.setSelectedItemIndex(selectedAccountIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(withTitle: "Send")
        self.navigationItem.rightBarButtonItems = [self.overflowNavBarButton]
        
        self.checkClipboardForValidAddress()
        self.setupAccountDropdowns()
        self.fetchExchangeRate(nil)
    }
    
    @IBAction func pasteAddressButtonTapped(_ sender: Any) {
        self.destinationAddressTextField.text = UIPasteboard.general.string
        self.addressTextFieldChanged()
    }
    
    @IBAction func scanQrCodeTapped(_ sender: Any) {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
    }
    
    @IBAction func sendMaxTap(_ sender: Any) {
        let sourceAccount = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex]
        if sourceAccount.Balance?.Spendable == 0 {
            // nothing to send
            self.sendAmountErrorLabel.text = self.insufficientFundsErrorMessage
            return
        }
        
        let destinationAddress = self.getDestinationAddress(isSendAttempt: false)
        let wallet = AppDelegate.walletLoader.wallet
        
        do {
            let maxSendableAmount = try wallet!.estimateMaxSendAmount(sourceAccount.Number,
                                                                      toAddress: destinationAddress,
                                                                      requiredConfirmations: self.requiredConfirmations)
            
            let maxSendableAmountDecimal = Decimal(maxSendableAmount.dcrValue) as NSDecimalNumber
            self.dcrAmountTextField.text = "\(maxSendableAmountDecimal.round(8))"
            self.dcrAmountTextFieldChanged(sendMax: true)
        } catch let error {
            print("get send max amount error: \(error.localizedDescription)")
            self.sendAmountErrorLabel.text = "Error getting maximum sendable amount."
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard AppDelegate.walletLoader.isSynced else {
            self.showSendError("Please wait for network synchronization.")
            return
        }
        guard AppDelegate.walletLoader.syncer.connectedPeersCount > 0 else {
            self.showSendError("Not connected to the network.")
            return
        }
        
        self.prepareTxSummary(isSendAttempt: true) { sendAmountDcr, destinationAddress, txFeeAndSize in
            var sendAmount = ConfirmToSendFundViewController.Amount(dcrValue: NSDecimalNumber(value: sendAmountDcr), usdValue: nil)
            var fee = ConfirmToSendFundViewController.Amount(dcrValue: NSDecimalNumber(value: txFeeAndSize.fee!.dcrValue), usdValue: nil)
            if self.exchangeRate != nil {
                sendAmount.usdValue = sendAmount.dcrValue.multiplying(by: self.exchangeRate!)
                fee.usdValue = fee.dcrValue.multiplying(by: self.exchangeRate!)
            }
            
            var destinationAccount: String?
            if !self.destinationAccountView.isHidden {
                destinationAccount = self.walletAccounts[self.destinationAccountDropdown.selectedItemIndex].Name
            }
            
            let requestSendConfirmation = ConfirmToSendFundViewController.requestConfirmation
            requestSendConfirmation(sendAmount, fee, destinationAddress, destinationAccount) {
                (spendingPassword: String?) in
                // Send tx confirmation page may return a password if the spending security type is password.
                // If the password returned is nil, prompt user for spending pin, otherwise proceed to send with the provided password.
                if spendingPassword != nil {
                    self.finalizeSending(destinationAddress: destinationAddress, pinOrPassword: spendingPassword!)
                    return
                }
                
                let requestPinVC = RequestPinViewController.instantiate()
                requestPinVC.securityFor = "Spending"
                requestPinVC.showCancelButton = true
                requestPinVC.onUserEnteredPin = { spendingPin in
                    self.finalizeSending(destinationAddress: destinationAddress, pinOrPassword: spendingPin)
                }
                self.present(requestPinVC, animated: true, completion: nil)
            }
        }
    }
    
    func prepareTxSummary(isSendAttempt: Bool, completion: (Double, String, DcrlibwalletTxFeeAndSize) -> Void) {
        guard let dcrAmountString = self.dcrAmountTextField.text, dcrAmountString != "" else {
            if isSendAttempt {
                self.sendAmountErrorLabel.text = "Amount cannot be zero."
            }
            return
        }
        
        guard let destinationAddress = self.getDestinationAddress(isSendAttempt: isSendAttempt) else {
            if !isSendAttempt {
                // clear tx summary and disable send button
                self.clearTxSummary()
                self.toggleSendButtonState(addressValid: false, amountValid: false)
            }
            return
        }
        
        do {
            let sendAmountDcr = Double(dcrAmountString)!
            let sendAmountAtom = DcrlibwalletAmountAtom(sendAmountDcr)
            let sourceAccountNumber = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].Number
            
            let txFeeAndSize = try AppDelegate.walletLoader.wallet!.calculateNewTxFeeAndSize(sendAmountAtom,
                                                                                             fromAccount: sourceAccountNumber,
                                                                                             toAddress: destinationAddress,
                                                                                             requiredConfirmations: self.requiredConfirmations,
                                                                                             spendAllFundsInAccount: self.sendMaxAmount)
            completion(sendAmountDcr, destinationAddress, txFeeAndSize)
        } catch let error {
            // there's an error somewhere, clear tx summary and disable send button
            self.clearTxSummary()
            self.toggleSendButtonState(addressValid: false, amountValid: false)
            
            if error.localizedDescription == "insufficient_balance" {
                self.sendAmountErrorLabel.text = self.insufficientFundsErrorMessage
            } else {
                print("get tx fee/size error: \(error.localizedDescription)")
                if isSendAttempt {
                    self.showSendError("Unexpected error.")
                }
            }
        }
    }
    
    func finalizeSending(destinationAddress: String, pinOrPassword: String) {
        let sourceAccountNumber = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].Number

        let sendAmountDcr = Double(self.dcrAmountTextField.text!)
        let sendAmountAtom = DcrlibwalletAmountAtom(sendAmountDcr!)
        
        let progressHud = Utils.showProgressHud(withText: "Sending Transaction...")
        DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
            do {
                let hash = try AppDelegate.walletLoader.wallet!.sendTransaction(sendAmountAtom,
                                                                                fromAccount: sourceAccountNumber,
                                                                                toAddress: destinationAddress,
                                                                                requiredConfirmations: self.requiredConfirmations,
                                                                                spendAllFundsInAccount: self.sendMaxAmount,
                                                                                privatePassphrase: pinOrPassword.utf8Bits)
                
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    self.transactionSucceeded(hash.hexEncodedString())
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    self.showOkAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    private func transactionSucceeded(_ txHash: String) {
        self.resetViews()
        
        SendCompletedViewController.showSendCompletedDialog(for: txHash) { showTxDetails in
            let slideMenuController = self.slideMenuController()!
            (slideMenuController.leftViewController as! NavigationMenuViewController).changeActivePage(to: .overview)
            
            if showTxDetails {
                let txDetailsVC = Storyboards.TransactionFullDetailsViewController.instantiateViewController(for: TransactionFullDetailsViewController.self)
                txDetailsVC.transactionHash = txHash
                (slideMenuController.mainViewController as! UINavigationController).pushViewController(txDetailsVC, animated: true)
            }
        }
    }
    
    func showSendError(_ errorMessage: String) {
        self.sendErrorLabel.text = errorMessage
        self.sendErrorLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.sendErrorLabel.isHidden = true
        }
    }
    
    func toggleSendButtonState(addressValid: Bool, amountValid: Bool) {
        if addressValid && amountValid {
            self.sendButton.backgroundColor = UIColor(hex: "#007AFF") // todo declare color constants
            self.sendButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.sendButton.backgroundColor = UIColor(hex: "#E6EAED")
            self.sendButton.setTitleColor(UIColor(hex: "#000000", alpha: 0.61), for: .normal)
        }
    }
}

/**
 Destination address/account related code.
 */
extension SendViewController {
    func toggleDestinationAddressAccount() {
        if self.destinationAccountView.isHidden {
            // switch to destination account view
            self.destinationAccountView.isHidden = false
            self.addressRecipientView.isHidden = true
            self.destinationErrorLabel.text = ""
            self.toggleSendButtonState(addressValid: true, amountValid: self.isValidAmount)
        } else {
            // switch to destination address view
            self.destinationAccountView.isHidden = true
            self.addressRecipientView.isHidden = false
            // Trigger address text field change event to validate any previously entered address; and toggle send button state.
            self.addressTextFieldChanged()
        }
    }
    
    func checkAddressFromQrCode(textScannedFromQRCode: String?) {
        guard var capturedText = textScannedFromQRCode else {
            self.destinationAddressTextField.text = ""
            return
        }
        
        if capturedText.starts(with: "decred:") {
            capturedText = capturedText.replacingOccurrences(of: "decred:", with: "")
        }
        
        if capturedText.count < 25 {
            self.invalidAddressFromQrCode(errorMessage: "Wallet address is too short.")
            return
        }
        if capturedText.count > 36 {
            self.invalidAddressFromQrCode(errorMessage: "Wallet address is too long.")
            return
        }
        
        if BuildConfig.IsTestNet {
            if capturedText.starts(with: "T") {
                self.destinationAddressTextField.text = capturedText
            } else {
                self.invalidAddressFromQrCode(errorMessage: "This is not a valid Decred testnet3 address.")
            }
        } else {
            if capturedText.starts(with: "D") {
                self.destinationAddressTextField.text = capturedText
            } else {
                self.invalidAddressFromQrCode(errorMessage: "This is not a valid Decred mainnet address.")
            }
        }
    }
    
    func invalidAddressFromQrCode(errorMessage: String) {
        self.destinationAddressTextField.text = ""
        AppDelegate.shared.showOkAlert(message: errorMessage)
    }
    
    @objc func addressTextFieldChanged() {
        let destinationAddress = self.destinationAddressTextField.text ?? ""
        let addressValid = AppDelegate.walletLoader.wallet!.isAddressValid(destinationAddress)
        
        self.toggleSendButtonState(addressValid: addressValid, amountValid: self.isValidAmount)
        self.scanQrCodeButton.isHidden = destinationAddress != ""
        self.checkClipboardForValidAddress()
        
        if destinationAddress == "" || addressValid {
            self.destinationErrorLabel.text = ""
        } else {
            self.destinationErrorLabel.text = "Destination address is not valid."
        }
    }
    
    func checkClipboardForValidAddress() {
        let canShowPasteButton = (self.destinationAddressTextField.text ?? "") == "" &&
            AppDelegate.walletLoader.wallet!.isAddressValid(UIPasteboard.general.string)
        self.pasteAddressButton.isHidden = !canShowPasteButton
    }
    
    func getDestinationAddress(isSendAttempt: Bool) -> String? {
        // Display destination address error only if this a send attempt.
        let validDestinationAddress = self.getValidDestinationAddress(displayErrorOnUI: isSendAttempt)
        
        if !isSendAttempt && validDestinationAddress == nil {
            // Generate temporary address from wallet.
            let sourceAccount = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex]
            return self.generateAddress(from: sourceAccount)
        }
        
        return validDestinationAddress
    }
    
    func getValidDestinationAddress(displayErrorOnUI: Bool) -> String? {
        if self.addressRecipientView.isHidden {
            // Sending to account, generate an address to use.
            let destinationAccount = self.walletAccounts[self.destinationAccountDropdown.selectedItemIndex]
            return self.generateAddress(from: destinationAccount)
        }
        
        // Sending to address, ensure that destinationAddressTextField.text is not nil and it's not empty string either.
        guard let destinationAddress = self.destinationAddressTextField.text, destinationAddress != "" else {
            if displayErrorOnUI {
                self.destinationErrorLabel.text = "Destination address cannot be empty."
            }
            return nil
        }
        
        // Also ensure that destinationAddressTextField.text is a valid address.
        guard AppDelegate.walletLoader.wallet!.isAddressValid(destinationAddress) else {
            if displayErrorOnUI {
                self.destinationErrorLabel.text = "Destination address is not valid."
            }
            return nil
        }
        
        return destinationAddress
    }
    
    func generateAddress(from account: WalletAccount) -> String? {
        var generateAddressError: NSError?
        let destinationAddress = AppDelegate.walletLoader.wallet!.currentAddress(account.Number, error: &generateAddressError)
        if generateAddressError != nil {
            print("send page -> generate address for destination account error: \(generateAddressError!.localizedDescription)")
            return nil
        }
        return destinationAddress
    }
}

/**
 Send amount (dcr/usd) related code.
 */
extension SendViewController {
    // Default value for sendMax is meant for use when this function is triggered as a result of user editing the dcr amount field.
    // If manually triggering dcr amount field change, a sendMax value is required/important
    // to ensure that a previously true value does not become false even though user did not edit the field directly.
    @objc func dcrAmountTextFieldChanged(sendMax: Bool = false) {
        self.sendMaxAmount = sendMax
        self.toggleSendButtonState(addressValid: self.isValidDestination, amountValid: self.isValidAmount)
        self.displayTransactionSummary()
        
        let dcrAmountString = self.dcrAmountTextField.text ?? ""
        
        guard let dcrAmount = Decimal(string: dcrAmountString) as NSDecimalNumber?, let exchangeRate = self.exchangeRate else {
            self.updateAmountField(self.usdAmountTextField, "", #selector(self.usdAmountTextFieldChanged))
            return
        }
        
        let usdAmount = dcrAmount.multiplying(by: exchangeRate)
        self.updateAmountField(self.usdAmountTextField, "\(usdAmount.round(8))", #selector(self.usdAmountTextFieldChanged))
    }
    
    @objc func usdAmountTextFieldChanged() {
        self.sendMaxAmount = false
        self.toggleSendButtonState(addressValid: self.isValidDestination, amountValid: self.isValidAmount)
        self.displayTransactionSummary()
        
        let usdAmountString = self.usdAmountTextField.text ?? ""
        
        guard let usdAmount = Decimal(string: usdAmountString) as NSDecimalNumber?, let exchangeRate = self.exchangeRate else {
            self.updateAmountField(self.dcrAmountTextField, "", #selector(self.dcrAmountTextFieldChanged))
            return
        }
        
        let dcrAmount = usdAmount.dividing(by: exchangeRate)
        self.updateAmountField(self.dcrAmountTextField, "\(dcrAmount.round(8))", #selector(self.dcrAmountTextFieldChanged))
    }
    
    func updateAmountField(_ textField: UITextField, _ amountString: String, _ textFieldChangeAction: Selector) {
        textField.removeTarget(self, action: nil, for: .editingChanged)
        textField.text = amountString
        textField.addTarget(self, action: textFieldChangeAction, for: .editingChanged)
    }
    
    func displayTransactionSummary() {
        self.prepareTxSummary(isSendAttempt: false) { sendAmountDcr, _, txFeeAndSize in
            let sourceAccountBalance = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].Balance!.dcrSpendable
            let balanceAfterSending = Decimal(sourceAccountBalance - sendAmountDcr - txFeeAndSize.fee!.dcrValue) as NSDecimalNumber
            
            self.displayEstimatedFee(dcrFee: txFeeAndSize.fee!.dcrValue)
            self.estimatedTxSizeLabel.text = "\(txFeeAndSize.estimatedSignedSize) bytes"
            self.balanceAfterSendingLabel.text = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
        }
    }
    
    func displayEstimatedFee(dcrFee: Double) {
        guard let txFee = Decimal(dcrFee) as NSDecimalNumber? else {
            self.estimatedFeeLabel.text = "0.00 DCR"
        }
        
        if self.exchangeRate == nil {
            self.estimatedFeeLabel.text = "\(txFee.formattedWithSeparator) DCR"
        } else {
            let usdFee = exchangeRate!.multiplying(by: txFee).formattedWithSeparator
            self.estimatedFeeLabel.text = "\(txFee.formattedWithSeparator) DCR\n(\(usdFee) USD)"
        }
    }
    
    func clearTxSummary() {
        self.estimatedFeeLabel.text = "0.00 DCR"
        self.estimatedTxSizeLabel.text = "0 bytes"
        self.balanceAfterSendingLabel.text = "0.00 DCR"
    }
}
