//
//  String.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 13/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//
import Foundation

extension String {
    var utf8Bits: Data {
        return self.data(using: .utf8)!
    }

    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(_ from: Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }
    
    var length: Int {
        return self.count
    }
    
    var withFirstLetterCapital: String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

protocol Localizable {
    var localized: String { get }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

