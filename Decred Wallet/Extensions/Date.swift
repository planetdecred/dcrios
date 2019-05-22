//
//  Date.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 21/05/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

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
