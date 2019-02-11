//
//  PinInputController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.


import Foundation

class PinInputController {
    var buffer: String = ""
    var max: Int = Int(LONG_LONG_MAX)
    
    init(max:Int){
        self.max = max
    }
    
    func input(digit: Int) -> String {
        if buffer.count < max{
            buffer = "\(buffer)\(digit)"
        }
        return buffer
    }
    
    func backspace() -> String{
        buffer = String(buffer.dropLast())
        return buffer
    }
    func clear() -> String{
        buffer = ""
        return buffer
    }
}
