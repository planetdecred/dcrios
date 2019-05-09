//
//  PinPasswordStrength.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 30/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import UIKit

class PinPasswordStrength {
    static func percentageStrength(of pinOrPassword: String) -> (strength: Float, color: UIColor) {
        let strength = (self.shannonEntropy(of: pinOrPassword) / 4)
        if strength > 0.7 {
            return (strength, UIColor.AppColors.Green)
        } else {
            return (strength, UIColor.AppColors.DarkYellowWarning)
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
