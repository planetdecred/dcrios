//
//  DcrRPCTests.swift
//  DcrRPCTests
//
//  Created by Philipp Maluta on 19.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import XCTest
@testable import DcrRPC

class DcrRPCTests: XCTestCase {
    var rpc: DcrRpc?
    
    override func setUp() {
        super.setUp()
        rpc = DcrRpc()
    }
    
    override func tearDown() {
        rpc = nil
        super.tearDown()
    }
    
}
