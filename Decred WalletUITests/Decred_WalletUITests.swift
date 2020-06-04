//
//  Decred_WalletUITests.swift
//  Decred WalletUITests
//
//  Created by Suleiman Abubakar on 02/06/2020.
//  Copyright © 2020 Decred. All rights reserved.
//

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
        
        let permission = app.alerts["“Decred Wallet Testnet” Would Like to Send You Notifications"].scrollViews.otherElements.buttons["Allow"]
        
        if permission.exists {
            permission.tap()
        }
        
        let createNewWallet = app.buttons.element(matching: .button, identifier: "createNewWallet")
        if createNewWallet.waitForExistence(timeout: 5) {
            createNewWallet.tap()
        }
        
        sleep(1)
        
        app/*@START_MENU_TOKEN@*/.staticTexts["PIN"]/*[[".buttons[\"PIN\"].staticTexts[\"PIN\"]",".staticTexts[\"PIN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        sleep(1)
        
        app.keys["1"].tap()
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["4"].tap()
        app.keys["5"].tap()
        app.keys["6"].tap()
        app.buttons["Next"].tap()
        app.keys["1"].tap()
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["4"].tap()
        app.keys["5"].tap()
        app.keys["6"].tap()
        
        let createBtn = app.buttons.element(matching: .button, identifier: "createPIN")
        createBtn.tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cancelStaticText = elementsQuery.buttons.element(matching: .button, identifier: "connectionButton")
        if cancelStaticText.waitForExistence(timeout: 5) {
            cancelStaticText.tap()
        }
        
        sleep(2)
        
        let wallets = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 2)
        wallets.tap()
        
        sleep(1)
        
        let walletMenu = app.tables/*@START_MENU_TOKEN@*/.buttons["ic more"]/*[[".cells.buttons[\"ic more\"]",".buttons[\"ic more\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        walletMenu.tap()
        
        sleep(1)
        
        let setting = app.sheets.scrollViews.otherElements.buttons["Settings"]
        setting.tap()
        
        sleep(1)
        
        app.buttons["Remove wallet from device"].tap()
        
        sleep(3)
        
        app.staticTexts["OK"].tap()
        app.keys["1"].tap()
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["4"].tap()
        app.keys["5"].tap()
        app.keys["6"].tap()
        
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
        
        let permission = app.alerts["“Decred Wallet Testnet” Would Like to Send You Notifications"].scrollViews.otherElements.buttons["Allow"]
        
        if permission.exists {
            permission.tap()
        }
        
        let createNewWallet = app.buttons.element(matching: .button, identifier: "createNewWallet")
        if createNewWallet.waitForExistence(timeout: 5) {
            createNewWallet.tap()
        }
        
        sleep(1)
        
        app.keys["d"].tap()
        app.keys["e"].tap()
        app.keys["c"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["d"].tap()
        
        app.buttons["Return"].tap()
        
        app.keys["d"].tap()
        app.keys["e"].tap()
        app.keys["c"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["d"].tap()
        
        let createBtn = app.buttons.element(matching: .button, identifier: "createPassword")
        createBtn.tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cancelStaticText = elementsQuery.buttons.element(matching: .button, identifier: "connectionButton")
        
        if cancelStaticText.waitForExistence(timeout: 5) {
            cancelStaticText.tap()
        }
        
        sleep(2)
        
        let wallets = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 2)
        wallets.tap()
        
        sleep(1)
        
        let walletMenu = app.tables/*@START_MENU_TOKEN@*/.buttons["ic more"]/*[[".cells.buttons[\"ic more\"]",".buttons[\"ic more\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletMenu.tap()
        
        sleep(1)
        
        let setting = app.sheets.scrollViews.otherElements.buttons["Settings"]
        setting.tap()
        
        sleep(1)
        
        app.buttons["Remove wallet from device"].tap()
        
        sleep(3)
        
        app.staticTexts["OK"].tap()
        app.keys["d"].tap()
        app.keys["e"].tap()
        app.keys["c"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["d"].tap()
        
        sleep(1)
        
        app.staticTexts["Remove"].tap()
        
        sleep(6)
    }

   /* func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }*/
}
