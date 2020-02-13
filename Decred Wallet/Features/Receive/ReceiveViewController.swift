//  ReceiveViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class ReceiveViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var moreMenuButton: UIButton!
    @IBOutlet weak var mainContentViewHolder: RoundedView!
    @IBOutlet weak var selectedAccountView: UIView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var totalAccountBalanceLabel: UILabel!
    @IBOutlet weak var addressQRCodeImageView: UIImageView!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var syncInProgressLabel: UILabel!

    var tapGesture = UITapGestureRecognizer()
    var oldAddress = ""

    var selectedWallet: DcrlibwalletWallet?
    var selectedAccount: DcrlibwalletAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayAddressForFirstWalletAccount()
    }

    func setupUI() {
        self.addressQRCodeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        self.walletAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        self.selectedAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showAccountSelectorDialog)))
    }

    private func displayAddressForFirstWalletAccount() {
        let accountsFilterFn: (DcrlibwalletAccount) -> Bool = { $0.totalBalance > 0 || $0.name != "imported" }
        guard let wallet = WalletLoader.shared.wallets.map({ Wallet.init($0, accountsFilterFn: accountsFilterFn) }).first,
            let account = wallet.accounts.first else { return }

        self.updateSelectedAccount(wallet.id, account)
    }

    @objc func copyAddress() {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.walletAddressLabel.text!
            Utils.showBanner(in: self.view.subviews.first!, type: .success, text: LocalizedStrings.walletAddrCopied)
        }
    }

    @objc func showAccountSelectorDialog(_ sender: Any) {
        AccountSelectorDialog.show(sender: self,
                                 title: LocalizedStrings.receivingAccount,
                                 selectedWallet: selectedWallet,
                                 selectedAccount: self.selectedAccount,
                                 callback: self.updateSelectedAccount)
    }

    private func displayAddressAndQRCode(receiveAddress: String) {
        DispatchQueue.main.async {
            self.walletAddressLabel.text = receiveAddress
            self.displayQRCodeImage(for: receiveAddress)
        }
    }

    private func generateNewAddress() {
        self.oldAddress = self.walletAddressLabel.text!
        self.getNextAddress()
    }

    @objc private func getNextAddress() {
        if let wallet = self.selectedWallet,
            let account = self.selectedAccount {
                let receiveAddress = wallet.nextAddress(account.number, error: nil)
                if self.oldAddress != receiveAddress {
                    self.displayAddressAndQRCode(receiveAddress: receiveAddress)
                } else if receiveAddress != "" {
                    self.getNextAddress()
                }
        }
    }

    private func displayQRCodeImage(for address: String) {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            self.addressQRCodeImageView.image = nil
            return
        }

        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(address.utf8Bits, forKey: "inputMessage")

        colorFilter.setDefaults()
        colorFilter.setValue(filter!.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor.black, forKey: "inputColor0")
        colorFilter.setValue(CIColor.clear, forKey: "inputColor1")

        if let qrImage = colorFilter.outputImage {
            let frame = self.addressQRCodeImageView.frame
            let smallerSide = frame.size.width < frame.size.height ? frame.size.width : frame.size.height
            let scale = smallerSide/qrImage.extent.size.width
            let transformedImage = qrImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            self.addressQRCodeImageView.image =  UIImage(ciImage: transformedImage)
        } else {
            self.addressQRCodeImageView.image = nil
        }
    }

    @IBAction func onClose(_ sender: Any) {
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

    func updateSelectedAccount(_ selectedWalletId: Int, _ selectedAccount: DcrlibwalletAccount) {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: selectedWalletId), wallet.isSynced()
        else {
            self.syncInProgressLabel.isHidden = false
            self.moreMenuButton.isEnabled = false
            self.mainContentViewHolder.isHidden = true
            return
        }

        self.mainContentViewHolder.isHidden = false
        self.moreMenuButton.isEnabled = true
        self.syncInProgressLabel.isHidden = true

        self.selectedWallet = wallet
        self.selectedAccount = selectedAccount

        self.walletNameLabel.text = wallet.name
        self.accountNameLabel.text = selectedAccount.name

        let totalBalanceRoundedOff = (Decimal(selectedAccount.dcrTotalBalance) as NSDecimalNumber).round(8)
        self.totalAccountBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalBalanceRoundedOff)", siz: 15.0, TexthexColor: UIColor.appColors.darkBlue)
        self.displayAddressAndQRCode(receiveAddress: wallet.currentAddress(selectedAccount.number, error: nil))
    }

    @IBAction func moreMenuButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)

        let generateNewAddressAction = UIAlertAction(title: LocalizedStrings.genNewAddr, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.generateNewAddress()
        })

        alertController.addAction(cancelAction)
        alertController.addAction(generateNewAddressAction)

        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func onShare(_ sender: Any) {
        guard let addressQRCodeImage = self.addressQRCodeImageView.image,
            let ciImage = addressQRCodeImage.ciImage,
            let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else { return }

        let activityController = UIActivityViewController(activityItems: [ UIImage(cgImage: cgImage) ], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
}
