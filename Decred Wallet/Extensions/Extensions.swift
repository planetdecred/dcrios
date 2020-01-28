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
