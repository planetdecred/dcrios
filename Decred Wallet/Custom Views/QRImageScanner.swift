//
//  QRImageScanner.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 30/05/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import QRCodeReader

// Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
// initialization and each time we need to scan a QRCode.
class QRImageScanner: NSObject, QRCodeReaderViewControllerDelegate {
    private var qrCodeReaderVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    var sender: UIViewController?
    
    override init() {
        super.init()
        qrCodeReaderVC.delegate = self
        qrCodeReaderVC.modalPresentationStyle = .formSheet
    }
    
    func scan(sender: UIViewController, onTextScanned: ((String?) -> Void)?) {
        self.sender = sender
        self.qrCodeReaderVC.completionBlock = { onTextScanned?($0?.value) }
        sender.present(qrCodeReaderVC, animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        self.sender?.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        self.sender?.dismiss(animated: true, completion: nil)
    }
}
