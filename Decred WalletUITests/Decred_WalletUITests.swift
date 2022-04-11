//
//  Decred_WalletUITests.swift
//  Decred WalletUITests
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import XCTest

class Decred_WalletUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateNewWalletWithPIN() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--UITests")
        app.launch()
        
        addUIInterruptionMonitor(withDescription: "Notification") { (alert) -> Bool in
                           if alert.staticTexts["“Decred Wallet Testnet” Would Like to Send You Notifications"].exists {
                            alert.buttons["Allow"].tap()
                           } else {
                            alert.buttons["Don’t Allow"].tap()
                           }
            return true
        }
        app.tap()

        let createNewWallet = app.buttons.element(matching: .button, identifier: "createNewWallet")
        if createNewWallet.waitForExistence(timeout: 5) {
            createNewWallet.tap()
        }

        sleep(1)

        // switch to PIN setup
        app/*@START_MENU_TOKEN@*/.staticTexts["PIN"]/*[[".buttons[\"PIN\"].staticTexts[\"PIN\"]",".staticTexts[\"PIN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        sleep(1)

        self.createPIN(app: app)

        let createBtn = app.buttons.element(matching: .button, identifier: "createPIN")
        createBtn.tap()
        
        // If wifi is enabled, the app starts syncing else it will show a dialog, requesting
        // for the user's permission to sync with mobile data
        let elementsQuery = app.scrollViews.otherElements
        let cancelStaticText = elementsQuery.buttons.element(matching: .button, identifier: "connectionButton")
        if cancelStaticText.waitForExistence(timeout: 5) {
            cancelStaticText.tap()
        }
        
        sleep(2)
        
        //switch to wallet menu tab
        let wallets = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 2)
        wallets.tap()
        
        sleep(1)
        
        let walletMenu = app.tables.buttons["more_button"]
        walletMenu.tap()
        
        sleep(1)
        
        let setting = app.tables.cells.element(boundBy: 5)
        setting.tap()
        
        sleep(1)
        
        app.buttons["Remove wallet from device"].tap()
        
        sleep(3)
        
        app.staticTexts["OK"].tap()
        
        self.typePin(app: app)
        
        sleep(1)
        
        app.staticTexts["Remove"].tap()
        
        sleep(6)
    }

    func testCreateNewWalletWithPassword() throws {

        // UI tests must launch the application that they test.

        // Use recording to get started writing UI tests.
        
        let app = XCUIApplication()
        app.launchArguments.append("--UITests")
        app.launch()
        
        addUIInterruptionMonitor(withDescription: "Notification") { (alert) -> Bool in
                           if alert.staticTexts["“Decred Wallet Testnet” Would Like to Send You Notifications"].exists {
                            alert.buttons["Allow"].tap()
                           } else {
                            alert.buttons["Don’t Allow"].tap()
                           }
            return true
        }
        app.tap()
        
        let createNewWallet = app.buttons.element(matching: .button, identifier: "createNewWallet")
        if createNewWallet.waitForExistence(timeout: 5) {
            createNewWallet.tap()
        }
        
        sleep(1)
        
        self.createPassword(app: app)
        
        let createBtn = app.buttons.element(matching: .button, identifier: "createPassword")
        createBtn.tap()
        
        // If wifi is enabled, the app starts syncing else it will show a dialog, requesting
        // for the user's permission to sync with mobile data
        let elementsQuery = app.scrollViews.otherElements
        let cancelStaticText = elementsQuery.buttons.element(matching: .button, identifier: "connectionButton")
        
        if cancelStaticText.waitForExistence(timeout: 5) {
            cancelStaticText.tap()
        }
        
        sleep(2)
        
        // switch to wallet menu tab
        let wallets = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 2)
        wallets.tap()
        
        sleep(1)
        
        // display wallet menu
        let walletMenu = app.tables.buttons["more_button"]
        walletMenu.tap()
        
        sleep(1)
        
        let setting = app.tables.cells.element(boundBy: 5)
        setting.tap()
        
        sleep(1)
        
        app.buttons["Remove wallet from device"].tap()
        
        sleep(3)
        
        app.staticTexts["OK"].tap()
        
        self.typePassword(app: app)
        
        sleep(1)
        
        app.staticTexts["Remove"].tap()
        
        sleep(6)
    }
        
    func createPassword(app: XCUIApplication) {
        typePassword(app: app)
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        typePassword(app: app)
    }
    
    func createPIN(app: XCUIApplication) {
        typePin(app: app)
        app.buttons["Next"].tap()
        typePin(app: app)
    }
    
    func typePassword(app: XCUIApplication) {
        let password = ["d", "e", "c", "r", "e", "d"]
        for i in password {
            app.keys[i].tap()
        }
    }
    
    func typePin(app: XCUIApplication) {
        let pin = ["1", "2", "3", "4", "5", "6"]
        for i in pin {
            app.keys[i].tap()
        }
    }
}
