//
//  SeedBackupUITest.swift
//  Decred WalletUITests
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import XCTest

class SeedBackupUITest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSeedBackup() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        app.launchArguments.append("--UITests")
        app.launch()
        
        let permission = app.alerts["“Decred Wallet Testnet” Would Like to Send You Notifications"].scrollViews.otherElements.buttons["Allow"]
        
        if permission.exists {
            permission.tap()
        }
        
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
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Verify your seed words backup so you can recover your funds when needed."]/*[[".cells.staticTexts[\"Verify your seed words backup so you can recover your funds when needed.\"]",".staticTexts[\"Verify your seed words backup so you can recover your funds when needed.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let element = app.scrollViews.children(matching: .other).element(boundBy: 0)
        element.children(matching: .other).element(boundBy: 0).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 2).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 3).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 4).children(matching: .button).element.tap()
        
        app.buttons["View seed words"].tap()
        
        sleep(2)
        
        self.typePassword(app: app)
        
        let confirmStaticText = app/*@START_MENU_TOKEN@*/.staticTexts["Confirm"]/*[[".buttons[\"Confirm\"].staticTexts[\"Confirm\"]",".buttons[\"createPIN\"].staticTexts[\"Confirm\"]",".staticTexts[\"Confirm\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        confirmStaticText.tap()
        
        sleep(1)
        
        var validSeedWords: [String] = []
        for seed in 0...16 {
            let seedWord = app.staticTexts.element(matching: .staticText, identifier: "seedword\(seed)")
            validSeedWords.append(seedWord.label)
        }
        
        for seed in 0...15 {
            let seedWord = app.staticTexts.element(matching: .staticText, identifier: "secondSeedword\(seed)")
            validSeedWords.append(seedWord.label)
        }
        
        sleep(1)
        
        let iHaveWroteDown = app.buttons.element(matching: .button, identifier: "iHaveWroteDown")
        iHaveWroteDown.tap()
        
        sleep(2)
        
        for i in 0...validSeedWords.count - 1 {
            tablesQuery.cells.containing(.staticText, identifier:"\(i+1)").buttons[validSeedWords[i]].tap()
            sleep(1)
        }
        
        let seedVerify = app.buttons.element(matching: .button, identifier: "seedVerify")
        seedVerify.tap()
        
        sleep(1)
        
        self.typePassword(app: app)
        
        confirmStaticText.tap()
        
        sleep(1)
        
        let backToWallet = app.buttons.element(matching: .button, identifier: "backToWallet")
        if backToWallet.waitForExistence(timeout: 5) {
            backToWallet.tap()
        }
        
        sleep(1)
        
        // display wallet menu
        let walletMenu = app.tables/*@START_MENU_TOKEN@*/.buttons["ic more"]/*[[".cells.buttons[\"ic more\"]",".buttons[\"ic more\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletMenu.tap()
               
        sleep(1)
               
        //select wallet settings
        let setting = app.sheets.scrollViews.otherElements.buttons["Settings"]
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
