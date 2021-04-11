//
//  Extensions.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

extension NSDecimalNumber {
    public func round(_ decimals:Int) -> NSDecimalNumber {
        return self.rounding(accordingToBehavior:
            NSDecimalNumberHandler(roundingMode: .plain,
                                   scale: Int16(decimals),
                                   raiseOnExactness: false,
                                   raiseOnOverflow: false,
                                   raiseOnUnderflow: false,
                                   raiseOnDivideByZero: false))
    }
    
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? "\(self)"
    }
}

extension BinaryInteger {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? "\(self)"
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        return formatter
    }()
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension Error {
    var isInvalidPassphraseError: Bool {
        return self.localizedDescription == DcrlibwalletErrInvalidPassphrase
    }
}

extension UIRefreshControl {
    //display loading indicator without the aid of user swipping down tableview
    func showLoader(in tableView: UITableView) {
        self.beginRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: -frame.size.height)
        tableView.setContentOffset(offsetPoint, animated: true)
    }
}

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension URL {
    // Creates a QR code for the current URL in the given color.
    func qrImage(using color: UIColor, logo: UIImage? = nil, frame: CGRect) -> CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = absoluteString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")
        let frame = frame
        let smallerSide = frame.size.width < frame.size.height ? frame.size.width : frame.size.height
        let scale = smallerSide/(qrFilter.outputImage?.extent.size.width)!
        let transformedImage = qrFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let qrImage = transformedImage
        
        let tintedQRImage = qrImage?.tinted(using: color)
        guard let logo = logo?.cgImage else {
               return tintedQRImage
        }
        
        return tintedQRImage?.combined(with: CIImage(cgImage: logo))
    }

}

extension Float {
    func round(decimals: Int) -> Float {
        return NSDecimalNumber(value: self).round(decimals).floatValue
    }
}
