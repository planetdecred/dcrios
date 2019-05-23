//
//  Extensions.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 10/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

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

extension UITableViewCell {
    func blink() {
        UITableViewCell.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [.showHideTransitionViews, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 }
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            [weak self] in
            self?.layer.removeAllAnimations()
        }
    }
}

extension UIButton {
    func set(fontSize: CGFloat, name : String) {
        if let titleLabel = titleLabel {
            titleLabel.font = UIFont(name: name, size: fontSize)
        }
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

extension UIRefreshControl {
    //display loading indicator without the aid of user swipping down tableview
    func showLoader(in tableView: UITableView) {
        self.beginRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: -frame.size.height)
        tableView.setContentOffset(offsetPoint, animated: true)
    }
}
