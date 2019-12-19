//  ReceiveViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class ReceiveViewController: UIViewController,UIDocumentInteractionControllerDelegate {
    
    var receiveAccountListView: ReceiveAccountListView!
    
    @IBOutlet weak var accountNameLab: UILabel!
    @IBOutlet weak var walletLab: UILabel!
    @IBOutlet weak var totalLab: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var dropdownBtn: UIButton!
    @IBOutlet weak var imgWalletAddrQRCode: UIImageView!
    @IBOutlet weak var shareBtn: UIButton!
    
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
    var myacc: DcrlibwalletAccount?
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
        
        self.starttime = Int64(NSDate().timeIntervalSince1970)
        setupSyncInProgressLabelConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LocalizedStrings.receive
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_close")?.withRenderingMode(.alwaysOriginal),
                                                                style: .done, target: self,
                                                                action: #selector(navigateToBackScreen))
        checkSyncStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.leftBarButtonItem = nil
    }
    @objc func dropdownBtnClick() {
        self.dropdownBtn.isSelected = !self.dropdownBtn.isSelected
        
        if self.receiveAccountListView == nil {
            self.receiveAccountListView = ReceiveAccountListView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            UIApplication.shared.keyWindow?.addSubview(self.receiveAccountListView!)
            
            self.receiveAccountListView.selectedAccount = {
                [weak self] (account:DcrlibwalletAccount,walletName:String) in
                
                guard let this = self else { return }
                
                this.myacc = account
                
                this.accountNameLab.text = this.myacc?.name
                this.walletLab.text = walletName
                
                let total = "\(this.myacc?.balance?.total ?? 0)"
                let length:Int = total.length>4 ? 4:total.length
                let totalStr = total + " DCR"
                let attr:NSMutableAttributedString = NSMutableAttributedString.init(string: totalStr)
                attr.addAttributes([NSMutableAttributedString.Key.font:UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: length))
                this.totalLab.attributedText = attr;
                                
                this.getAddress(accountNumber: (this.myacc!.number))
            }
            self.receiveAccountListView.hide = {
                [weak self] () in
                guard let this = self else { return }
                this.dropdownBtn.isSelected = !this.dropdownBtn.isSelected
            }
        }
        
        self.receiveAccountListView.showView()
    }

    func setupExtraUI() {
        
        self.dropdownBtn.addTarget(self, action: #selector(dropdownBtnClick), for: .touchUpInside)
        self.totalLab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dropdownBtnClick)))
        
        self.shareBtn.addTarget(self, action: #selector(shareImgOnTap), for: .touchUpInside)

        self.imgWalletAddrQRCode.addGestureRecognizer(tapToCopyAddressGesture())
        self.walletAddressLabel.addGestureRecognizer(tapToCopyAddressGesture())
    }
    
    func tapToCopyAddressGesture() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(self.copyAddress))
    }
    
    @objc func copyAddress() {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.walletAddressLabel.text!

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
            
            self.setupExtraUI()
            
            self.showFirstWalletAddressAndQRCode()
            self.populateWalletDropdownMenu()
            syncInProgressLabel.isHidden = true

            let shareBtn = UIButton(type: .custom)
            shareBtn.setImage(UIImage(named: "ic_info"), for: .normal)
            shareBtn.addTarget(self, action: #selector(tips), for: .touchUpInside)
            shareBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            let shareuBtnItem:UIBarButtonItem = UIBarButtonItem(customView: shareBtn)

            let generateAddressBtn = UIButton(type: .custom)
            generateAddressBtn.setImage(UIImage(named: "ic_more"), for: .normal)
            generateAddressBtn.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
            generateAddressBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            barButton = UIBarButtonItem(customView: generateAddressBtn)
            self.navigationItem.rightBarButtonItems = [barButton!, shareuBtnItem]
        } else {
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
        self.oldAddress = self.walletAddressLabel.text!
        self.getNextAddress(accountNumber: (self.myacc?.number)!)
    }
    
    private func showFirstWalletAddressAndQRCode() {
        
        if let acc = AppDelegate.walletLoader.wallet?.walletAccounts(confirmations: 0) {
            let accNames: [String] = (acc.map({ $0.name }))
            self.myacc = acc.first
            
            if let firstWalletAddress = accNames.first {
                self.selectedAccount = firstWalletAddress
                self.walletAddressLabel.text = self.selectedAccount

                let total = "\(self.myacc?.balance?.total ?? 0)"
                let length:Int = total.length>4 ? 4:total.length
                
                let totalStr = total + " DCR"
                let attr:NSMutableAttributedString = NSMutableAttributedString.init(string: totalStr)
                attr.addAttributes([NSMutableAttributedString.Key.font:UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: length))
                self.totalLab.attributedText = attr;
                
                self.getAddress(accountNumber: self.myacc!.number)
            }
        } else {
            print("no account")
        }
    }
    
    private func populateWalletDropdownMenu() {

        if let acc = AppDelegate.walletLoader.wallet?.walletAccounts(confirmations: 0) {
           if let defaultAccount = acc.filter({ $0.isDefault}).first {
               
                self.accountNameLab.text = defaultAccount.name

                let total = "\(defaultAccount.balance?.total ?? 0)"
                let length:Int = total.length>4 ? 4:total.length
                
                let totalStr = total + " DCR"
                let attr:NSMutableAttributedString = NSMutableAttributedString.init(string: totalStr)
                attr.addAttributes([NSMutableAttributedString.Key.font:UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: length))
                self.totalLab.attributedText = attr;
            
                self.myacc = defaultAccount
                self.getAddress(accountNumber: (self.myacc!.number))
            }
        }
    }
    
    @objc func tips(){
        let alertController = UIAlertController(title: LocalizedStrings.receiveDCR, message: LocalizedStrings.receiveDes, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt, style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
        
    @objc func getNext(){
        self.getNextAddress(accountNumber: (self.myacc?.number)!)
    }
    
    @objc func shareImgOnTap(){
        
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
            
            this.walletAddressLabel.text = receiveAddress!
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
                this.walletAddressLabel.text = receiveAddress!
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
