//  ReceiveViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class ReceiveViewController: UIViewController {
    @IBOutlet weak var moreMenuButton: UIButton!
    @IBOutlet weak var selectedAccountView: WalletAccountView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var addressQRCodeContainerView: UIView!
    @IBOutlet weak var addressQRCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeLogoImageView: UIImageView!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var tapToCopyContainerView: UIView!
    @IBOutlet weak var shareButtonContainerView: UIView!

    var selectedWallet: DcrlibwalletWallet?
    var selectedAccount: DcrlibwalletAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    func setupUI() {
        self.separatorView.isHidden = true
        self.addressQRCodeContainerView.isHidden = true
        self.walletAddressLabel.isHidden = true
        self.tapToCopyContainerView.isHidden = true
        
        self.addressQRCodeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        self.walletAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        
        self.selectedAccountView.accountFilterFn = {account in
            if account.number == Int32.max || account.isMixerMixedAccount {
                return false
            }
            
            return true
        }
        self.selectedAccountView.onAccountSelectionChanged = self.updateSelectedAccount
        self.selectedAccountView.selectFirstValidWalletAccount()
        // register for new transactions notifications
        try? WalletLoader.shared.multiWallet.add(self, async: true, uniqueIdentifier: "\(self)")
    }

    @objc func copyAddress() {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.walletAddressLabel.text!
            Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.walletAddrCopied)
        }
    }

    func updateSelectedAccount(_ selectedAccount: DcrlibwalletAccount) {
        self.selectedWallet = WalletLoader.shared.multiWallet.wallet(withID: selectedAccount.walletID)!
        self.selectedAccount = selectedAccount
        self.shareButtonContainerView.isHidden = false
        self.addressQRCodeContainerView.isHidden = false
        self.moreMenuButton.isEnabled = true
        self.tapToCopyContainerView.isHidden = false
        self.walletAddressLabel.isHidden = false
        self.separatorView.isHidden = false

        self.displayAddressAndQRCode(receiveAddress: selectedWallet!.currentRecieveAddress(for: selectedAccount.number))
    }

    private func displayAddressAndQRCode(receiveAddress: String) {
        DispatchQueue.main.async {
            self.walletAddressLabel.text = receiveAddress
            self.displayQRCodeImage(for: receiveAddress)
        }
    }

    private func displayQRCodeImage(for address: String) {
        guard CIFilter(name: "CIFalseColor") != nil else {
            self.addressQRCodeImageView.image = nil
            return
        }
        
        let data = address.data(using: String.Encoding.ascii)
         if let filter = CIFilter(name: "CIQRCodeGenerator") {
             filter.setValue(data, forKey: "inputMessage")
             let transform = CGAffineTransform(scaleX: 3, y: 3)

             if let output = filter.outputImage?.transformed(by: transform) {
                self.qrCodeLogoImageView.isHidden = false
                self.addressQRCodeImageView.image = UIImage(ciImage: output)
             } else {
                self.addressQRCodeImageView.image = nil
             }
         }
    }

    @IBAction func onClose(_ sender: Any) {
        WalletLoader.shared.multiWallet.removeTxAndBlockNotificationListener("\(self)")
        self.dismissView()
    }

    @IBAction func infoMenuButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: LocalizedStrings.receiveDCR,
                                                    message: LocalizedStrings.receiveInfo,
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt,
                                                    style: UIAlertAction.Style.default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func moreMenuButtonTapped(_ sender: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let generateNewAddressAction = UIAlertAction(title: LocalizedStrings.genNewAddr, style: .default) { _ in
            self.generateNewAddress()
        }
        alertController.addAction(generateNewAddressAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }

        self.present(alertController, animated: true, completion: nil)
    }

    private func generateNewAddress() {
        if let wallet = self.selectedWallet, let account = self.selectedAccount {
             let nextReceiveAddress = wallet.nextAddress(account.number, error: nil)
             if self.walletAddressLabel.text! != nextReceiveAddress {
                 self.displayAddressAndQRCode(receiveAddress: nextReceiveAddress)
             } else if nextReceiveAddress != "" {
                 self.generateNewAddress()
             }
        }
    }

    @IBAction func shareButtonTapped(_ sender: UIView) {
        guard let addressQRCodeImage = self.addressQRCodeImageView.image,
            let ciImage = addressQRCodeImage.ciImage,
            let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else { return }

        let activityController = UIActivityViewController(activityItems: [ UIImage(cgImage: cgImage) ], applicationActivities: nil)
        
        if let popoverPresentationController = activityController.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
}

extension ReceiveViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
    }
    
    func onTransaction(_ transaction: String?) {
        DispatchQueue.main.async {
            self.selectedAccountView.selectFirstValidWalletAccount()
        }
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
    }
}
