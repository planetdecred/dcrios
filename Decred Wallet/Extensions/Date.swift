//
//  Date.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

extension Date {
    func isBefore(_ otherDate: Date) -> Bool {
        return self < otherDate
    }
    
    func isSame(with otherDate: Date) -> Bool {
        return self == otherDate
    }
    
    func isAfter(_ otherDate: Date) -> Bool {
        return self > otherDate
    }
}
