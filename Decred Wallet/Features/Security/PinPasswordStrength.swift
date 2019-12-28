//
//  PinPasswordStrength.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class PinPasswordStrength {
    static func percentageStrength(of pinOrPassword: String) -> (strength: Float, color: UIColor) {
        let strength = (self.shannonEntropy(of: pinOrPassword) / 4)
        if strength > 0.7 {
            return (strength, UIColor.appColors.turquoise)
        } else {
            return (strength, UIColor.appColors.darkYellowWarning)
        }
    }
    
    private static func shannonEntropy(of x: String) -> Float {
        return x
            .reduce(into: [String: Int](), {cur, char in
                cur[String(char), default: 0] += 1
            })
            .values
            .map({i in Float(i) / Float(x.count) } as (Int) -> Float)
            .map({p in -p * log2(p) } as (Float) -> Float)
            .reduce(0.0, +)
    }
}
