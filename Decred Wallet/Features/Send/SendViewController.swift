//
//  SendViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SendViewController: UIViewController {
    static let instance = SendViewController.instantiate(from: .Send).wrapInNavigationcontroller()
    
    @IBOutlet weak var sourceAccountView: WalletAccountView!
    
    @IBOutlet weak var toAddressSection: UIView!
    @IBOutlet weak var destinationAddressTextField: FloatingPlaceholderTextView!
    lazy var scanQRCodeForAddressButton: UIButton = {
        let scanQRCodeForAddressButton = UIButton(frame: .zero)
        scanQRCodeForAddressButton.setImage(UIImage(named: "ic_scan"), for: .normal)
        scanQRCodeForAddressButton.addTarget(self, action: #selector(self.scanQrCodeTapped), for: .touchUpInside)
        return scanQRCodeForAddressButton
    }()
    lazy var pasteAddressFromClipboardButton: UIButton = {
        let pasteAddressFromClipboardButton = UIButton(frame: .zero)
        pasteAddressFromClipboardButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        pasteAddressFromClipboardButton.layer.cornerRadius = 4
        pasteAddressFromClipboardButton.set(fontSize: 14, name: "SourceSansPro-Regular")
        pasteAddressFromClipboardButton.setTitle(LocalizedStrings.paste, for: .normal)
        pasteAddressFromClipboardButton.setTitleColor(UIColor.appColors.lightBlue, for: .normal)
        pasteAddressFromClipboardButton.backgroundColor = UIColor.appColors.lightGray
        pasteAddressFromClipboardButton.addTarget(self, action: #selector(self.pasteAddressTapped), for: .touchUpInside)
        return pasteAddressFromClipboardButton
    }()
    @IBOutlet weak var invalidDestinationAddressLabel: Label!
    
    @IBOutlet weak var toSelfAccountSection: UIView!
    @IBOutlet weak var destinationAccountView: WalletAccountView!
    
    @IBOutlet var sourceAccountSpendableBalanceLabel: UILabel!
    @IBOutlet var amountContainerView: UIView!
    @IBOutlet var amountTextField: SuffixTextField!
    @IBOutlet var usdAmountSeparatorView: UIView!
    @IBOutlet var usdAmountSection: UIView!
    @IBOutlet var secondAmountLabel: UILabel!
    @IBOutlet var retryFetchExchangeRateButton: UIButton!
    @IBOutlet var notEnoughFundsLabel: UILabel!
    
    @IBOutlet var transactionFeeSection: UIView!
    @IBOutlet var transactionFeeLabel: UILabel!
    @IBOutlet var transactionFeeDetailsToggleImageView: UIImageView!
    
    @IBOutlet var transactionFeeDetailsSection: UIView!
    @IBOutlet var processingTimeLabel: UILabel!
    @IBOutlet var feeRateLabel: UILabel!
    @IBOutlet var transactionSizeLabel: UILabel!
    
    @IBOutlet var sendingSummarySection: UIView!
    @IBOutlet var totalCostLabel: UILabel!
    @IBOutlet var balanceAfterSendingLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet weak var swapButton: UIButton!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private lazy var qrImageScanner = QRImageScanner()
    
    var exchangeRate: NSDecimalNumber?
    var sendMax: Bool = false
    var dcrAmountUnit: Bool = true
    var exchangeValue: NSDecimalNumber?
    var amountValue: NSDecimalNumber?
    
    var validSendAmountString: String {
        let amountCrudeText = self.amountTextField.text
        let validTextAmountString = amountCrudeText?.dropLast(4) ?? ""
        return String(validTextAmountString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenForKeyboardVisibilityChanges(delegate: self)
        self.setupViews()
        
        // register for new transactions notifications
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        let currencyConversionDisabled = Settings.currencyConversionOption == .None
        self.dcrAmountUnit = currencyConversionDisabled ? true : self.dcrAmountUnit
        self.usdAmountSeparatorView.isHidden = currencyConversionDisabled
        self.usdAmountSection.isHidden = currencyConversionDisabled
        self.changeTextFieldAmountUnit()
        self.resetFields()
        
        self.refreshFields()
        self.fetchExchangeRate()
        self.showOrHidePasteAddressButton()
    }
    
    func setupViews() {
        self.sourceAccountView.showWatchOnlyWallet = false
        self.sourceAccountView.onAccountSelectionChanged = { _, newSourceAccount in
            let spendableAmount = (Decimal(newSourceAccount.balance!.dcrSpendable) as NSDecimalNumber).round(8).formattedWithSeparator
            self.sourceAccountSpendableBalanceLabel.text = "\(LocalizedStrings.spendable): \(spendableAmount) DCR"
            
            if self.sendMax {
                self.calculateAndSetMaxSendableAmount()
            }
        }
        
        self.destinationAddressTextField.placeholder = LocalizedStrings.destinationAddress
        
        self.destinationAddressTextField.add(button: self.scanQRCodeForAddressButton)
        self.destinationAddressTextField.add(button: self.pasteAddressFromClipboardButton)
        self.destinationAddressTextField.textViewDelegate = self
        
        self.toSelfAccountSection.isHidden = true
        self.destinationAccountView.showWatchOnlyWallet = true
        self.destinationAccountView.onAccountSelectionChanged = { _, _ in
            self.displayFeeDetailsAndTransactionSummary() // re-calculate fee with updated destination info
        }
        
        self.amountTextField.addTarget(self, action: #selector(self.amountTextFieldEditingBegan), for: .editingDidBegin)
        self.amountTextField.addTarget(self, action: #selector(self.amountTextFieldChanged), for: .editingChanged)
        self.amountTextField.addTarget(self, action: #selector(self.amountTextFieldEditingEnded), for: .editingDidEnd)
        self.amountTextField.addDoneButton()
        
        self.transactionFeeSection.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.toggleTransactionFeeDetailsVisibility))
        )
        self.transactionFeeDetailsSection.isHidden = true
    }

    @objc func toggleTransactionFeeDetailsVisibility() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.transactionFeeDetailsSection.isHidden.toggle()
            
            let rotationAngle = self.transactionFeeDetailsSection.isHidden ? 0.0 : CGFloat(Double.pi)
            self.transactionFeeDetailsToggleImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        })
    }
    
    @objc func resetFields() {
        self.sourceAccountView.selectFirstWalletAccount()
        
        // Clearing the destination address textfield will trigger the set textview delegate
        // which will hide the error label and show the paste button if a valid address is in clipboard.
        self.destinationAddressTextField.setText("")
        
        self.sendMax = false
        self.amountValue = nil
        self.exchangeValue = nil
        
        self.destinationAccountView.selectFirstWalletAccount()
        
        // Clearing the primary amount textfield should set the usd amount to 0,
        // hide the address error label, update the transaction fee details and sending summary fields.
        self.amountTextField.text = ""
        self.amountTextFieldEditingEnded()
    }
    
    func refreshFields() {
        self.sourceAccountView.selectFirstWalletAccount()
        self.amountTextFieldEditingBegan()
        self.amountTextFieldChanged()
        self.destinationAccountView.selectFirstWalletAccount()
        self.amountTextFieldEditingEnded()
    }
    
    private func fetchExchangeRate() {
        self.retryFetchExchangeRateButton.isHidden = true
        if self.exchangeRate == nil {
            self.secondAmountLabel.text = self.dcrAmountUnit ? "- USD" : "- DCR"
        }
        
        switch Settings.currencyConversionOption {
        case .None:
            self.exchangeRate = nil
            break
            
        case .Bittrex:
            ExchangeRates.Bittrex.fetch(callback: self.displayExchangeRate)
        }
    }
    
    func displayExchangeRate(_ newExchangeRate: NSDecimalNumber?) {
        // only show error if an exchange rate has never been fetched previously
        if newExchangeRate == nil && self.exchangeRate == nil {
            self.retryFetchExchangeRateButton.isHidden = true
            self.secondAmountLabel.textColor = UIColor.appColors.orange
            self.secondAmountLabel.text = LocalizedStrings.exchangeRateNotFetched
            return
        }
        
        self.exchangeRate = newExchangeRate ?? self.exchangeRate // maintain current value if new value is nil
        
        self.retryFetchExchangeRateButton.isHidden = true
        self.secondAmountLabel.textColor = UIColor.appColors.paleGray
        if dcrAmountUnit {
            self.calculateAndDisplayUSDAmount()
        } else {
            self.calculateAndDisplayDCRAmount()
        }
    }
    
    func showOrHidePasteAddressButton() {
        let shouldShowPasteButton = self.destinationAddressTextField.isInputEmpty()
            && WalletLoader.shared.multiWallet.isAddressValid(UIPasteboard.general.string)

        if self.pasteAddressFromClipboardButton.isHidden == shouldShowPasteButton {
            // if ishidden = true and shouldShow = true, then toggle visibility
            // if ishidden = false and shouldShow = false, then toggle visibility
            self.destinationAddressTextField.toggleButtonVisibility(self.pasteAddressFromClipboardButton)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func infoMenuButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: LocalizedStrings.sendDCR, message: LocalizedStrings.sendHeaderInfo, preferredStyle: .alert)
        let gotItAction = UIAlertAction(title: LocalizedStrings.gotIt, style: .cancel, handler: nil)
        alertController.addAction(gotItAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func overflowMenuButtonTapped(_ sender: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        let clearFieldsAction = UIAlertAction(title: LocalizedStrings.clearFields, style: .default) { action in
            self.resetFields()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(clearFieldsAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendToSelfTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.toAddressSection.isHidden = true
            self.toSelfAccountSection.isHidden = false
            
            self.displayFeeDetailsAndTransactionSummary() // re-calculate fee with updated destination info
        })
    }

    @IBAction func sendToOthersTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.toSelfAccountSection.isHidden = true
            self.toAddressSection.isHidden = false
            
            self.displayFeeDetailsAndTransactionSummary() // re-calculate fee with updated destination info
        })
    }
    
    @objc func scanQrCodeTapped(_ sender: UIButton) {
        self.qrImageScanner.scan(sender: self) { textScannedFromQRCode in
            guard let capturedText = textScannedFromQRCode else {
                self.destinationAddressTextField.text = ""
                return
            }
            
            let addressURI = DecredAddressURI(uriString: capturedText)
            if addressURI.address.count < 25 || addressURI.address.count > 36 {
                Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.invalidAddr)
                return
            }
            
            if BuildConfig.IsTestNet {
                if !addressURI.address.starts(with: "T") {
                    Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.invalidTesnetAddress)
                    return
                }
            } else {
                if !addressURI.address.starts(with: "D") {
                    Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.invalidMainnetAddress)
                    return
                }
            }
            
            self.destinationAddressTextField.setText(addressURI.address)
            if addressURI.amount != nil {
                self.amountTextField.text = String(addressURI.amount!)
                self.amountTextFieldEditingEnded()
            }
        }
    }
    
    @objc func pasteAddressTapped(_ sender: UIButton) {
        guard let textFromClipboard = UIPasteboard.general.string else { return }
        self.destinationAddressTextField.setText(textFromClipboard)
    }

    @IBAction func sendMaxTapped(_ sender: UIButton) {
        self.calculateAndSetMaxSendableAmount()
    }
    
    func calculateAndSetMaxSendableAmount() {
        self.sendMax = true
        
        guard self.isFormValid, let unsignedTx = self.currentUnsignedTx else {
            self.sendMax = false
            return
        }
        
        do {
            let maxSendableAmount = try unsignedTx.estimateMaxSendAmount()
            let maxSendableAmountDecimal = NSDecimalNumber(value: maxSendableAmount.dcrValue)
            if self.dcrAmountUnit {
                self.amountValue = maxSendableAmountDecimal
                self.amountTextField.text = "\(maxSendableAmountDecimal.round(8)) DCR"
            } else {
                guard let exchangeRate = self.exchangeRate else {
                    return
                }
                let maxUSD = NSDecimalNumber(value: maxSendableAmount.dcrValue).multiplying(by: exchangeRate)
                self.amountValue = maxUSD
                self.amountTextField.text = "\(maxUSD.round(2)) USD"
            }
            
            self.amountTextFieldEditingEnded()
        } catch let error {
            print("get send max amount error: \(error.localizedDescription)")
            self.sendMax = false
            self.showAmountError(LocalizedStrings.errorGettingMaxSpendable)
            Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
        }
    }
    
    func changeTextFieldAmountUnit() {
        self.amountTextField.suffixText = self.dcrAmountUnit ? " DCR" : " USD"
        self.amountTextField.placeholder = self.dcrAmountUnit ? "0 DCR" : "0 USD"
    }
    
    @IBAction func swapButtonTapped(_ sender: Any) {
        self.changeAmountInput()
    }
    
    func changeAmountInput() {
        let secondValue = "\((self.exchangeValue ?? 0).round(self.dcrAmountUnit ? 2 : 8))"
        self.amountValue = self.exchangeValue
        self.dcrAmountUnit = !self.dcrAmountUnit
        self.changeTextFieldAmountUnit()
        self.amountTextField.text = secondValue != "0" ? "\(secondValue) \(self.dcrAmountUnit ? "DCR" : "USD")" : ""
        self.caculateAndDisplayAmontAfterChangeInput()
        self.validateAmount()
        self.displayFeeDetailsAndTransactionSummary()
    }
    
    func caculateAndDisplayAmontAfterChangeInput() {
        guard let sendAmount = self.amountValue?.doubleValue, let exchangeRate = self.exchangeRate else {
            self.secondAmountLabel.text = dcrAmountUnit ? "0 USD" : "0 DCR"
            return
        }
        if sendAmount > 0 {
            let dcrAmount = dcrAmountUnit ? NSDecimalNumber(value: sendAmount).multiplying(by: exchangeRate) : NSDecimalNumber(value: sendAmount).dividing(by: exchangeRate)
            self.exchangeValue = dcrAmount
            self.secondAmountLabel.text = dcrAmountUnit ? "\(dcrAmount.round(2).formattedWithSeparator) USD" : "\(dcrAmount.round(8).formattedWithSeparator) DCR"
        } else {
            self.secondAmountLabel.text = dcrAmountUnit ? "0 USD" : "0 DCR"
        }
    }

    @IBAction func retryExchangeRateFetch(_ sender: UIButton) {
        self.fetchExchangeRate()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard self.isFormValid,
            let unsignedTx = self.currentUnsignedTx,
            let txFeeAndSize = self.currentUnsignedTxFeeAndSize else { return }
        
        let sourceWallet = self.sourceAccountView.selectedWallet!
        let sourceAccount = self.sourceAccountView.selectedAccount!
        
        let sourceAccountInfo = "\(sourceAccount.name) (\(sourceWallet.name))"
        let dcrAmount = NSDecimalNumber(value: unsignedTx.totalSendAmount()!.dcrValue)
        let dcrFee = NSDecimalNumber(value: txFeeAndSize.fee!.dcrValue)
        let dcrTotalCost = dcrAmount.adding(dcrFee)
        let dcrBalanceAfterSending = NSDecimalNumber(value: sourceAccount.dcrSpendableBalance).subtracting(dcrTotalCost)
        
        var unsignedTxSummary = UnsignedTxSummary(sourceAccountInfo: sourceAccountInfo,
                                                  destinationAddress: unsignedTx.sendDestination(0)!.address,
                                                  dcrAmount: dcrAmount,
                                                  dcrFee: dcrFee,
                                                  dcrTotalCost: dcrTotalCost,
                                                  dcrBalanceAfterSending: dcrBalanceAfterSending)
        
        if !self.toSelfAccountSection.isHidden,
            let destinationWallet = self.destinationAccountView.selectedWallet,
            let destinationAccount = self.destinationAccountView.selectedAccount {
            unsignedTxSummary.destinationAccountInfo = "\(destinationAccount.name) (\(destinationWallet.name))"
        }
        
        ConfirmToSendFundViewController.display(sender: self,
                                                 sourceWalletID: sourceWallet.id_,
                                                 unsignedTxSummary: unsignedTxSummary,
                                                 unsignedTx: unsignedTx,
                                                 exchangeRate: self.exchangeRate,
                                                 onSendCompleted: self.sendCompleted)
    }
    
    func sendCompleted() {
        Utils.showBanner(in: NavigationMenuTabBarController.instance!.view, type: .success, text: LocalizedStrings.transactionSent)
        self.resetFields()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismissView()
        }
    }
}

// delegate for destination address text view.
extension SendViewController: FloatingPlaceholderTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.showOrHidePasteAddressButton()
        self.validateSendDestination()
        self.displayFeeDetailsAndTransactionSummary() // re-calculate fee with updated destination info
    }
}

// extension for amount calculations and display
extension SendViewController {
    @objc func amountTextFieldEditingBegan() {
        self.hideAmountError()
    }

    @objc func amountTextFieldChanged() {
        self.amountValue = NSDecimalNumber(string: self.validSendAmountString.isEmpty ? "0" : self.validSendAmountString)
        self.sendMax = false
        self.amountTextFieldEditingEnded()
    }
    
    @objc func amountTextFieldEditingEnded() {
        self.validateAmount()
        if (self.dcrAmountUnit) {
            self.calculateAndDisplayUSDAmount()
        } else {
            self.calculateAndDisplayDCRAmount()
        }
        self.displayFeeDetailsAndTransactionSummary()
        amountTextField.reloadText()
    }

    func calculateAndDisplayUSDAmount() {

        guard let dcrAmount = self.amountValue?.doubleValue, let exchangeRate = self.exchangeRate else {
            self.exchangeValue = nil
            self.secondAmountLabel.text = "0 USD"
            self.secondAmountLabel.textColor = UIColor.appColors.paleGray
            return
        }

        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
        self.exchangeValue = usdAmount
        self.secondAmountLabel.text = "\(usdAmount.round(2).formattedWithSeparator) USD"
        self.secondAmountLabel.textColor = UIColor.appColors.bluishGray
    }
    
    func calculateAndDisplayDCRAmount() {
        guard let usdAmount = self.amountValue?.doubleValue, let exchangeRate = self.exchangeRate else {
            self.exchangeValue = nil
            self.secondAmountLabel.text = "0 DCR"
            self.secondAmountLabel.textColor = UIColor.appColors.paleGray
            return
        }
        
        let drcAmount = NSDecimalNumber(value: usdAmount).dividing(by: exchangeRate)
        self.exchangeValue = drcAmount
        self.secondAmountLabel.text = "\(drcAmount.round(8).formattedWithSeparator) DCR"
        self.secondAmountLabel.textColor = UIColor.appColors.bluishGray
    }

    func displayFeeDetailsAndTransactionSummary() {
        guard let tempTx = self.currentUnsignedTx, let txFeeAndSize = self.currentUnsignedTxFeeAndSize else {
            self.transactionFeeLabel.text = self.parseDCRAmount(0, usdDecimalPlaces: 4)
            
            self.processingTimeLabel.text = "-"
            self.feeRateLabel.text = "-"
            self.transactionSizeLabel.text = "-"
            
            self.totalCostLabel.text = self.parseDCRAmount(0, usdDecimalPlaces: 2)
            self.balanceAfterSendingLabel.text = "0 DCR"
            
            self.nextButton.isEnabled = false
            return
        }
        
        self.transactionFeeLabel.text = self.parseDCRAmount(txFeeAndSize.fee!.dcrValue, usdDecimalPlaces: 4)
        
        self.processingTimeLabel.text = "-" // todo fix!
        
        let feeRate = NSDecimalNumber(value: txFeeAndSize.fee!.dcrValue / Double(txFeeAndSize.estimatedSignedSize))
        self.feeRateLabel.text = "\(feeRate.round(8).formattedWithSeparator) DCR/byte"
        
        self.transactionSizeLabel.text = "\(txFeeAndSize.estimatedSignedSize) bytes"
        
        let sendAmountDcr = tempTx.totalSendAmount()?.dcrValue ?? 0
        let sourceAccountBalance = self.sourceAccountView.selectedAccount?.balance!.dcrSpendable ?? 0
        
        let totalCost = NSDecimalNumber(value: sendAmountDcr + txFeeAndSize.fee!.dcrValue)
        let balanceAfterSending = NSDecimalNumber(value: sourceAccountBalance).subtracting(totalCost)
        
        self.totalCostLabel.text = self.parseDCRAmount(totalCost.doubleValue, usdDecimalPlaces: 2)
        self.balanceAfterSendingLabel.text = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
        
        self.nextButton.isEnabled = true
    }
}

// extension for utility/helper variables and functions
extension SendViewController {
    var insufficientFundsErrorMessage: String {
        if WalletLoader.shared.multiWallet.connectedPeers() > 0 {
            return LocalizedStrings.notEnoughFunds
        } else {
            return LocalizedStrings.notEnoughFundsOrNotConnected
        }
    }
    
    var destinationAddress: String? {
        if self.toSelfAccountSection.isHidden {
            return self.destinationAddressTextField.text ?? ""
        }

        // Sending to account, generate an address to use.
        guard let destinationWallet = self.destinationAccountView.selectedWallet,
            let destinationAccount = self.destinationAccountView.selectedAccount else { return nil }
        
        return destinationWallet.currentRecieveAddress(for: destinationAccount.number)
    }
    
    var isFormValid: Bool {
        guard let _ = self.sourceAccountView.selectedWallet,
            let sourceAccount = self.sourceAccountView.selectedAccount else {
            
                Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.selectFromAccount)
                return false
        }
        
        guard let sourceAccountBalance = sourceAccount.balance, sourceAccountBalance.spendable > 0 else {
            Utils.showBanner(in: self.view, type: .error, text: self.insufficientFundsErrorMessage)
            return false
        }
        
        guard let destinationAddress = self.destinationAddress,
            WalletLoader.shared.multiWallet.isAddressValid(destinationAddress) else {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.invalidDestAddr)
            return false
        }

        let sendAmountDcr = Double(validSendAmountString) ?? 0
        if !self.sendMax {
            guard sendAmountDcr > 0, sendAmountDcr <= DcrlibwalletMaxAmountDcr else {
                Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.invalidAmount)
                return false
            }
        }
        
        return true
    }
    
    var currentUnsignedTx: DcrlibwalletTxAuthor? {
        guard let sourceWallet = self.sourceAccountView.selectedWallet,
            let sourceAccount = self.sourceAccountView.selectedAccount,
            let sourceAccountBalance = sourceAccount.balance, sourceAccountBalance.spendable > 0,
            
            let destinationAddress = self.destinationAddress, WalletLoader.shared.multiWallet.isAddressValid(destinationAddress)
            else { return nil }
        var sendAmontInput = self.amountValue?.doubleValue ?? 0
        if !self.dcrAmountUnit {
            guard let exchangeRate = self.exchangeRate else {
                return nil
            }
            
            sendAmontInput = Double(truncating: NSDecimalNumber(value: sendAmontInput).dividing(by: exchangeRate))
        }
        
        let sendAmountDcr = sendAmontInput
        if !self.sendMax {
            guard sendAmountDcr > 0, sendAmountDcr <= DcrlibwalletMaxAmountDcr else {
                return nil
            }
        }
        
        let unsignedTx = WalletLoader.shared.multiWallet.newUnsignedTx(sourceWallet,
                                                                       sourceAccountNumber: sourceAccount.number)
        
        do {
            try unsignedTx?.addSendDestination(destinationAddress,
                                               atomAmount: DcrlibwalletAmountAtom(sendAmountDcr),
                                               sendMax: self.sendMax)
        } catch let error {
            print("get unsignedTx add send destination error: \(error.localizedDescription)")
            return nil
        }
        
        return unsignedTx
    }
    
    var currentUnsignedTxFeeAndSize: DcrlibwalletTxFeeAndSize? {
        guard let tempTx = self.currentUnsignedTx else { return nil }
        
        do {
            return try tempTx.estimateFeeAndSize()
        } catch let error {
            if error.localizedDescription == DcrlibwalletErrInsufficientBalance {
                self.showAmountError(self.insufficientFundsErrorMessage)
            } else {
                print("get tx fee/size error: \(error.localizedDescription)")
                self.showAmountError(error.localizedDescription)
            }
            
            self.nextButton.isEnabled = false
            return nil
        }
    }
    
    func validateSendDestination() {
        self.invalidDestinationAddressLabel.isHidden = true
        
        if toSelfAccountSection.isHidden {
            let destinationAddress = self.destinationAddressTextField.text ?? ""
            let addressValid = WalletLoader.shared.multiWallet.isAddressValid(destinationAddress) 
            self.invalidDestinationAddressLabel.isHidden = destinationAddress.isEmpty || addressValid
            return
        }
    }
    
    func validateAmount() {
        self.hideAmountError()
        guard validSendAmountString != "" else {
            return
        }
        
        if validSendAmountString.components(separatedBy: ".").count > 2 {
            // more than 1 decimal place
            self.showAmountError(LocalizedStrings.invalidAmount)
            return
        }
        
        let decimalPointIndex = validSendAmountString.firstIndex(of: ".")
        if decimalPointIndex != nil && validSendAmountString[decimalPointIndex!...].count > 9 {
            self.showAmountError(LocalizedStrings.amount8Decimal)
            return
        }
        
        if decimalPointIndex != nil && validSendAmountString[decimalPointIndex!...].count > 3 && !self.dcrAmountUnit {
            self.showAmountError(LocalizedStrings.amount2Decimal)
            return
        }
        
        guard let sendAmount = Double(validSendAmountString), sendAmount > 0 else {
            self.showAmountError(LocalizedStrings.invalidAmount)
            return
        }
        
        var sendAountDrc = 0.0
        
        if self.dcrAmountUnit {
            sendAountDrc = sendAmount
        } else {
            guard let exchangeRate = self.exchangeRate else {
                //TODO: can't get exchangeRate rate value
                return
            }
            
            sendAountDrc = Double(truncating: NSDecimalNumber(value: sendAmount).dividing(by: exchangeRate))
        }
        
        if sendAountDrc > DcrlibwalletMaxAmountDcr {
            self.showAmountError(LocalizedStrings.amountMaximumAllowed)
            return
        }
        
        if sendAountDrc > self.sourceAccountView.selectedAccount?.balance!.dcrSpendable ?? 0 {
            self.showAmountError(self.insufficientFundsErrorMessage)
            return
        }
    }
    
    func hideAmountError() {
        self.notEnoughFundsLabel.text = " "
        if self.amountTextField.isEditing {
            self.amountContainerView.layer.borderColor = UIColor.appColors.lightBlue.cgColor
        } else {
            self.amountContainerView.layer.borderColor = UIColor.appColors.gray.cgColor
        }
    }
    
    func showAmountError(_ errorText: String) {
        self.notEnoughFundsLabel.text = errorText
        self.amountContainerView.layer.borderColor = UIColor.appColors.orange.cgColor
    }

    func parseDCRAmount(_ amount: Double, usdDecimalPlaces: Int) -> String {
        let dcrAmount = NSDecimalNumber(value: amount)
        if self.exchangeRate == nil {
            return "\(dcrAmount.formattedWithSeparator) DCR"
        } else {
            let usdAmount = exchangeRate!.multiplying(by: dcrAmount).round(usdDecimalPlaces).formattedWithSeparator
            return "\(dcrAmount.formattedWithSeparator) DCR ($\(usdAmount))"
        }
    }
}

extension SendViewController: KeyboardVisibilityDelegate {
    @objc func onKeyboardWillShowOrHide(_ notification: Notification) {
        guard let window = self.view.window?.frame,
            let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        let keyboardHeight = window.size.height - keyboardFrame.origin.y
        let sendingSummarySectionHeight = self.sendingSummarySection.frame.size.height
        let scrollViewBottomConstraintValue = max(keyboardHeight - sendingSummarySectionHeight, 8)
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else {
                self.scrollViewBottomConstraint.constant = scrollViewBottomConstraintValue
                return
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.scrollViewBottomConstraint.constant = scrollViewBottomConstraintValue
        })
    }
}

extension SendViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
    }
    
    func onTransaction(_ transaction: String?) {
        DispatchQueue.main.async {
            self.refreshFields()
        }
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
    }
}
