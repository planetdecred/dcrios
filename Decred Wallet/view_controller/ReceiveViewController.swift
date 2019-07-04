//  ReceiveViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class ReceiveViewController: UIViewController,UIDocumentInteractionControllerDelegate {
    
    @IBOutlet private var accountDropdown: DropMenuButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var lblWalletAddress: UILabel!
    @IBOutlet var contentStackView: UIStackView!
    
    private var barButton: UIBarButtonItem?
    private lazy var syncInProgressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = LocalizedStrings.secureMenuSyncInfo
        return label
    }()

    var firstTrial = true
    var starttime: Int64 = 0
    var myacc: WalletAccount!
    var account: WalletAccounts?
    var tapGesture = UITapGestureRecognizer()
    var oldAddress = ""
    var wallet = AppDelegate.walletLoader.wallet

    private var selectedAccount = ""

    override func loadView() {
        super.loadView()
        view.addSubview(syncInProgressLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.subheader.text = LocalizedStrings.receiveHeaderInfo
        // TAP Gesture
        self.setupExtraUI()
        self.starttime = Int64(NSDate().timeIntervalSince1970)
        setupSyncInProgressLabelConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(withTitle: LocalizedStrings.receive)
        checkSyncStatus()
    }

    func setupExtraUI() {
        self.imgWalletAddrQRCode.addGestureRecognizer(tapToCopyAddressGesture())
        self.lblWalletAddress.addGestureRecognizer(tapToCopyAddressGesture())
        self.accountDropdown.backgroundColor = UIColor.white
    }
    
    func tapToCopyAddressGesture() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(self.copyAddress))
    }
    
    @objc func copyAddress() {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.lblWalletAddress.text!
            
            //Alert
            let alertController = UIAlertController(title: "", message: LocalizedStrings.walletAddrCopied, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func showMenu(sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        
        let generateNewAddressAction = UIAlertAction(title: LocalizedStrings.genNewAddr, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.generateNewAddress()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(generateNewAddressAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }

        self.present(alertController, animated: true, completion: nil)
    }

    private func checkSyncStatus() {
        let isSynced = AppDelegate.walletLoader.isSynced
        let isNewWalletSetup: Bool = Settings.readValue(for: Settings.Keys.NewWalletSetUp)
        let initialSyncCompleted: Bool = Settings.readOptionalValue(for: Settings.Keys.InitialSyncCompleted) ?? false
        if isSynced || isNewWalletSetup || initialSyncCompleted {
            self.showFirstWalletAddressAndQRCode()
            self.populateWalletDropdownMenu()
            contentStackView.isHidden = false
            syncInProgressLabel.isHidden = true

            let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
            let generateAddressBtn = UIButton(type: .custom)
            generateAddressBtn.setImage(UIImage(named: "right-menu"), for: .normal)
            generateAddressBtn.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
            generateAddressBtn.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
            barButton = UIBarButtonItem(customView: generateAddressBtn)
            self.navigationItem.rightBarButtonItems = [barButton!, shareBtn ]
        } else {
            contentStackView.isHidden = true
            syncInProgressLabel.isHidden = false
        }
    }

    private func setupSyncInProgressLabelConstraints() {
        /// This will position the label at the center of the view
        syncInProgressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        syncInProgressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        syncInProgressLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }

    private func generateNewAddress() {
        self.oldAddress = self.lblWalletAddress.text!
        self.getNextAddress(accountNumber: (self.myacc.Number))
    }
    
    private func showFirstWalletAddressAndQRCode() {
        self.account?.Acc.removeAll()
        do {
            var getAccountError: NSError?
            let strAccount = self.wallet?.getAccounts(0, error: &getAccountError)
            if getAccountError != nil {
                throw getAccountError!
            }
            
            self.account = try JSONDecoder().decode(WalletAccounts.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
        }
        
        let acc = self.account?.Acc
        if (acc != nil) {
            let accNames: [String] = (self.account?.Acc.map({ $0.Name }))!
            self.myacc = self.account?.Acc.first
            
            if let firstWalletAddress = accNames.first {
                self.selectedAccount = firstWalletAddress
                self.accountDropdown.setTitle(self.selectedAccount, for: .normal)
                self.getAddress(accountNumber: (self.myacc.Number))
            }
        } else {
            print("no account")
        }
    }
    
    private func populateWalletDropdownMenu() {
        self.account?.Acc.removeAll()
        do {
            var getAccountError: NSError?
            let strAccount = self.wallet?.getAccounts(0, error: &getAccountError)
            if getAccountError != nil {
                throw getAccountError!
            }
            self.account = try JSONDecoder().decode(WalletAccounts.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
        }
        
        if let defaultAccount = account?.Acc.filter({ $0.isDefault}).first {
            
            accountDropdown.setTitle(
                defaultAccount.Name,
                for: UIControl.State.normal
            )
            self.accountDropdown.backgroundColor = UIColor.white
        }
        
        let accNames: [String] = (self.account?.Acc.filter({!$0.isHidden && $0.Number != INT_MAX }).map({ $0.Name }))!
        
        accountDropdown.initMenu(
            accNames
        ) { [weak self] _, val in
            guard let this = self else { return }
            this.selectedAccount = val
            if self?.account?.Acc.filter({ $0.Name == val }).first != nil {
                print("value is \(val)")
                self?.myacc = self?.account?.Acc.filter({ $0.Name == val }).map({ $0 }).first
                self?.getAddress(accountNumber: (self?.myacc.Number)!)
            }
        }
    }
    
    @objc func share(){
        self.shareImgOnTap()
    }
    
    @objc func getNext(){
        self.getNextAddress(accountNumber: self.myacc.Number)
    }
    
    func shareImgOnTap(){
        
        var img: UIImage = self.imgWalletAddrQRCode.image!
        
        if img.cgImage == nil {
            guard let ciImage = img.ciImage, let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {return}
            img = UIImage(cgImage: cgImage)
        }
        
        let activityController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        if let popoverPresentationController = activityController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    private func getAddress(accountNumber : Int32) {
        let receiveAddress = self.wallet?.currentAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.lblWalletAddress.text = receiveAddress!
            this.imgWalletAddrQRCode.image = this.generateQRCodeFor(
                with: receiveAddress!,
                forImageViewFrame: this.imgWalletAddrQRCode.frame
            )
        }
    }
    
    @objc private func getNextAddress(accountNumber : Int32){
        let receiveAddress = self.wallet?.nextAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if (this.oldAddress != receiveAddress!) {
                this.lblWalletAddress.text = receiveAddress!
                this.imgWalletAddrQRCode.image = this.generateQRCodeFor(
                    with: receiveAddress!,
                    forImageViewFrame: this.imgWalletAddrQRCode.frame
                )
                return
            }
            else{
                self!.getNext()
            }
        }
    }
    
    func generateQRCodeFor(with addres: String, forImageViewFrame: CGRect) -> UIImage? {
        guard let addrData = addres.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(addrData, forKey: "inputMessage")
        
        /// Foreground color of the output
        let color = CIColor(red: 26/255, green: 29/255, blue: 47/255)
        
        /// Background color of the output
        let backgroundColor = CIColor.clear
        
        colorFilter.setDefaults()
        colorFilter.setValue(filter!.outputImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
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
}
