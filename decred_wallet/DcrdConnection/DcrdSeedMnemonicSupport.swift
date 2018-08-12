//
//  DcrdSeedMnemonicSupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation

protocol DcrdSeedMnemonicProtocol : DcrdBaseProtocol {
    func  generateSeed() -> String
    func verifySeed(seed:String) -> Bool
}

extension DcrdSeedMnemonicProtocol{
    func  generateSeed() -> String{
        do{
            return  (try AppContext.instance.decrdConnection?.wallet!.generateSeed())!
        } catch {
            return ""
        }
    }
    
    func verifySeed(seed:String) -> Bool{
        return (AppContext.instance.decrdConnection?.wallet!.verifySeed(seed))!
    }
}
