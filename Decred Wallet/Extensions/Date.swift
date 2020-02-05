//
//  Date.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

extension Date {
    var daysFromNow: Int {
      return Calendar.current.dateComponents([.day], from: Date(), to: self).day!
    }

    func isBefore(_ otherDate: Date) -> Bool {
        return self < otherDate
    }
    
    func isSame(with otherDate: Date) -> Bool {
        return self == otherDate
    }
    
    func isAfter(_ otherDate: Date) -> Bool {
        return self > otherDate
    }

    func toString(format: String, localeIdentifier: String = "en_US_POSIX") -> String {
        let dateformater = DateFormatter()
        dateformater.locale = Locale(identifier: localeIdentifier)
        dateformater.dateFormat = format
        return dateformater.string(from: self)
    }
}
