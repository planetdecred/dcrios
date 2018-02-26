//
//  String.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 10/02/2018.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import Foundation
extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.index(self.startIndex, offsetBy: from))
    }
    
    var length: Int {
        return self.count
    }
}
