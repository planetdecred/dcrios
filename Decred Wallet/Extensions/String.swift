//
//  String.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

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
