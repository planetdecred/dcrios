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
    @IBOutlet private var addressQRCodeImageView: UIImageView!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var syncInProgressLabel: UILabel!

    var tapGesture = UITapGestureRecognizer()
    var oldAddress = ""

    var selectedWallet: DcrlibwalletWallet?
    var selectedAccount: DcrlibwalletAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupExtraUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSyncStatus()
    }

    func setupExtraUI() {
        self.addressQRCodeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        self.walletAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        self.selectedAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showAccountSelectorDialog)))
    }

    @objc func copyAddress() {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.walletAddressLabel.text!
            Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.walletAddrCopied)
        }
    }

    @objc func showAccountSelectorDialog(_ sender: Any) {
        AccountSelectorDialog.show(sender: self,
                                 title: LocalizedStrings.receivingAccount,
                                 selectedWallet: selectedWallet,
                                 selectedAccount: self.selectedAccount,
                                 callback: self.updateSelectedAccount)
    }

    private func checkSyncStatus() {
        self.moreMenuButton.isEnabled = false
    
        let accountsFilterFn: (DcrlibwalletAccount) -> Bool = { $0.totalBalance > 0 || $0.name != "imported" }
        guard let wallet = WalletLoader.shared.wallets.map({ Wallet.init($0, accountsFilterFn: accountsFilterFn) }).first,
            let account = wallet.accounts.first else {
                self.mainContentViewHolder.isHidden = true
                self.syncInProgressLabel.isHidden = false
                return
        }

        self.updateSelectedAccount(wallet.id, account)

        mainContentViewHolder.isHidden = false
        syncInProgressLabel.isHidden = true
        self.moreMenuButton.isEnabled = true
    }

    private func generateNewAddress() {
        self.oldAddress = self.walletAddressLabel.text!
        self.getNextAddress()
    }

    private func updateWalletAddressAndQRCode(receiveAddress: String) {
        DispatchQueue.main.async {
            self.walletAddressLabel.text = receiveAddress
            self.addressQRCodeImageView.image = self.generateQRCodeFor(
                with: receiveAddress,
                forImageViewFrame: self.addressQRCodeImageView.frame
            )
        }
    }

    @objc private func getNextAddress() {
        if let wallet = self.selectedWallet,
            let account = self.selectedAccount {
                let receiveAddress = wallet.nextAddress(account.number, error: nil)
                if self.oldAddress != receiveAddress {
                    self.updateWalletAddressAndQRCode(receiveAddress: receiveAddress)
                } else if receiveAddress != "" {
                    self.getNextAddress()
                }
        }
    }

    private func generateQRCodeFor(with addres: String, forImageViewFrame: CGRect) -> UIImage? {
        guard let addrData = addres.data(using: String.Encoding.utf8) else {
            return nil
        }

        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(addrData, forKey: "inputMessage")

        let foregroundColor = CIColor.black
        let backgroundColor = CIColor.clear

        colorFilter.setDefaults()
        colorFilter.setValue(filter!.outputImage, forKey: "inputImage")
        colorFilter.setValue(foregroundColor, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")

        if let imgQR = colorFilter.outputImage {
            var tempFrame: CGRect? = forImageViewFrame
            if tempFrame == nil {
                tempFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
            }

            guard let frame = tempFrame else { return nil }
            let smallerSide = frame.size.width < frame.size.height ? frame.size.width : frame.size.height
            let scale = smallerSide/imgQR.extent.size.width
            let transformedImage = imgQR.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            let imageQRCode = UIImage(ciImage: transformedImage)

            return imageQRCode
        }
        return nil
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismissView()
    }

    @IBAction func showInfo(_ sender: Any) {
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
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: selectedWalletId) else {
            return
        }
        self.selectedWallet = wallet
        self.selectedAccount = selectedAccount

        self.walletNameLabel.text = wallet.name
        self.accountNameLabel.text = selectedAccount.name

        let totalBalanceRoundedOff = (Decimal(selectedAccount.dcrTotalBalance) as NSDecimalNumber).round(8)
        self.totalAccountBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalBalanceRoundedOff)", siz: 15.0, TexthexColor: UIColor.appColors.darkBlue)
        self.updateWalletAddressAndQRCode(receiveAddress: wallet.currentAddress(selectedAccount.number, error: nil))
    }

    @IBAction func showMenu(_ sender: Any) {
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
        var img: UIImage = self.addressQRCodeImageView.image!

        if img.cgImage == nil {
            guard let ciImage = img.ciImage, let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {return}
            img = UIImage(cgImage: cgImage)
        }

        let activityController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
}
