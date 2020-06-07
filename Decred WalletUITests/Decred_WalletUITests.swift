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
        
        let walletMenu = app.tables/*@START_MENU_TOKEN@*/.buttons["ic more"]/*[[".cells.buttons[\"ic more\"]",".buttons[\"ic more\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletMenu.tap()
        
        sleep(1)
        
        let setting = app.sheets.scrollViews.otherElements.buttons["Settings"]
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
        
        // display wallet menu
        let walletMenu = app.tables/*@START_MENU_TOKEN@*/.buttons["ic more"]/*[[".cells.buttons[\"ic more\"]",".buttons[\"ic more\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletMenu.tap()
        
        sleep(1)
        
        // select wallet settings
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

    func testRestoreExistingWalletWithPassword() throws {
        
        let app = XCUIApplication()
        app.launchArguments.append("--UITests")
        app.launch()
        
        let permission = app.alerts["“Decred Wallet Testnet” Would Like to Send You Notifications"].scrollViews.otherElements.buttons["Allow"]
        
        if permission.exists {
            permission.tap()
        }
        
        let restoreExistingWallet = app.buttons.element(matching: .button, identifier: "restoreExistingWallet")
        if restoreExistingWallet.waitForExistence(timeout: 5) {
            restoreExistingWallet.tap()
        }
        
        sleep(1)
        
        self.seedUIInput(app: app)

        app/*@START_MENU_TOKEN@*/.staticTexts["Restore"]/*[[".buttons[\"Restore\"].staticTexts[\"Restore\"]",".staticTexts[\"Restore\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        sleep(3)
        
        self.createPassword(app: app)
        
        let createBtn = app.buttons.element(matching: .button, identifier: "createPassword")
        createBtn.tap()
        
        let getStarted = app.buttons.element(matching: .button, identifier: "getStarted")
        
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }
        
        self.typePassword(app: app)
        
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
    
    func testRestoreExistingWalletWithPIN() throws {
        
        let app = XCUIApplication()
        app.launchArguments.append("--UITests")
        app.launch()
        
        let permission = app.alerts["“Decred Wallet Testnet” Would Like to Send You Notifications"].scrollViews.otherElements.buttons["Allow"]
        
        if permission.exists {
            permission.tap()
        }
        
        let restoreExistingWallet = app.buttons.element(matching: .button, identifier: "restoreExistingWallet")
        if restoreExistingWallet.waitForExistence(timeout: 5) {
            restoreExistingWallet.tap()
        }
        
        sleep(1)
        
        self.seedUIInput(app:app)
        
        app/*@START_MENU_TOKEN@*/.staticTexts["Restore"]/*[[".buttons[\"Restore\"].staticTexts[\"Restore\"]",".staticTexts[\"Restore\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        sleep(3)
        app/*@START_MENU_TOKEN@*/.staticTexts["PIN"]/*[[".buttons[\"PIN\"].staticTexts[\"PIN\"]",".staticTexts[\"PIN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        self.createPIN(app: app)
        
        let createBtn = app.buttons.element(matching: .button, identifier: "createPIN")
        createBtn.tap()
        
        sleep(4)
        
        let getStarted = app.buttons.element(matching: .button, identifier: "getStarted")
        
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }
        
        self.typePin(app: app)
        
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
        
        self.typePin(app: app)
               
        sleep(1)
               
        app.staticTexts["Remove"].tap()
               
        sleep(6)
    }
    
    func createPassword(app: XCUIApplication) {
        app.keys["d"].tap()
        app.keys["e"].tap()
        app.keys["c"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["d"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.keys["d"].tap()
        app.keys["e"].tap()
        app.keys["c"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["d"].tap()
    }
    
    func createPIN(app: XCUIApplication) {
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
    }
    
    func typePassword(app: XCUIApplication) {
        app.keys["d"].tap()
        app.keys["e"].tap()
        app.keys["c"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["d"].tap()
    }
    
    func typePin(app: XCUIApplication) {
        app.keys["1"].tap()
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["4"].tap()
        app.keys["5"].tap()
        app.keys["6"].tap()
    }
    
    func seedUIInput(app: XCUIApplication) {
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"1").children(matching: .textField).element.tap()
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["f"].tap()
        app.keys["o"].tap()
        tablesQuery.staticTexts["reform"].tap()
        app.keys["a"].tap()
        app.keys["f"].tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        tablesQuery.staticTexts["aftermath"].tap()
        
        app.keys["p"].tap()
        app.keys["r"].tap()
        app.keys["i"].tap()
        app.keys["n"].tap()
        tablesQuery.staticTexts["printer"].tap()
        
        app.keys["w"].tap()
        app.keys["a"].tap()
        app.keys["r"].tap()
        app.keys["r"].tap()
        tablesQuery.staticTexts["warranty"].tap()
        
        app.keys["g"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["m"].tap()
        tablesQuery.staticTexts["gremlin"].tap()
        
        app.keys["p"].tap()
        app.keys["a"].tap()
        app.keys["r"].tap()
        app.keys["a"].tap()
        tablesQuery.staticTexts["paragraph"].tap()
        
        app.keys["b"].tap()
        app.keys["e"].tap()
        app.keys["e"].tap()
        app.keys["h"].tap()
        tablesQuery.staticTexts["beehive"].tap()
        
        app.keys["s"].tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        app.keys["t"].tap()
        tablesQuery.staticTexts["stethoscope"].tap()
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["g"].tap()
        app.keys["a"].tap()
        tablesQuery.staticTexts["regain"].tap()
        
        app.keys["d"].tap()
        app.keys["i"].tap()
        app.keys["s"].tap()
        app.keys["r"].tap()
        tablesQuery.staticTexts["disruptive"].tap()
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["g"].tap()
        app.keys["a"].tap()
        tablesQuery.staticTexts["regain"].tap()
        
        app.keys["b"].tap()
        app.keys["r"].tap()
        app.keys["a"].tap()
        app.keys["d"].tap()
        tablesQuery.staticTexts["Bradbury"].tap()
        
        app.keys["c"].tap()
        app.keys["h"].tap()
        app.keys["i"].tap()
        app.keys["s"].tap()
        tablesQuery.staticTexts["chisel"].tap()
        
        app.keys["o"].tap()
        app.keys["c"].tap()
        app.keys["t"].tap()
        app.keys["o"].tap()
        tablesQuery.staticTexts["October"].tap()
        
        app.keys["t"].tap()
        app.keys["r"].tap()
        app.keys["o"].tap()
        app.keys["u"].tap()
        tablesQuery.staticTexts["trouble"].tap()
        
        app.keys["f"].tap()
        app.keys["o"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        tablesQuery.staticTexts["forever"].tap()
        
        app.keys["a"].tap()
        app.keys["l"].tap()
        app.keys["g"].tap()
        app.keys["o"].tap()
        tablesQuery.staticTexts["Algol"].tap()
        
        app.keys["a"].tap()
        app.keys["p"].tap()
        app.keys["p"].tap()
        app.keys["l"].tap()
        tablesQuery.staticTexts["applicant"].tap()
        
        app.keys["i"].tap()
        app.keys["s"].tap()
        app.keys["l"].tap()
        app.keys["a"].tap()
        tablesQuery.staticTexts["island"].tap()
        
        app.keys["i"].tap()
        app.keys["n"].tap()
        app.keys["f"].tap()
        app.keys["a"].tap()
        tablesQuery.staticTexts["infancy"].tap()
        
        app.keys["p"].tap()
        app.keys["h"].tap()
        app.keys["y"].tap()
        app.keys["s"].tap()
        tablesQuery.staticTexts["physique"].tap()
        
        app.keys["p"].tap()
        app.keys["a"].tap()
        app.keys["r"].tap()
        app.keys["a"].tap()
        tablesQuery.staticTexts["paragraph"].tap()
        
        app.keys["w"].tap()
        app.keys["o"].tap()
        app.keys["o"].tap()
        app.keys["d"].tap()
        tablesQuery.staticTexts["woodlark"].tap()
        
        app.keys["h"].tap()
        app.keys["y"].tap()
        app.keys["d"].tap()
        app.keys["r"].tap()
        tablesQuery.staticTexts["hydraulic"].tap()
        
        app.keys["s"].tap()
        app.keys["n"].tap()
        app.keys["a"].tap()
        app.keys["p"].tap()
        tablesQuery.staticTexts["snapshot"].tap()
        
        app.keys["b"].tap()
        app.keys["a"].tap()
        app.keys["c"].tap()
        app.keys["k"].tap()
        tablesQuery.staticTexts["backwater"].tap()
        
        app.keys["r"].tap()
        app.keys["a"].tap()
        app.keys["t"].tap()
        app.keys["c"].tap()
        tablesQuery.staticTexts["ratchet"].tap()
        
        app.keys["s"].tap()
        app.keys["u"].tap()
        app.keys["r"].tap()
        app.keys["r"].tap()
        tablesQuery.staticTexts["surrender"].tap()
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["v"].tap()
        app.keys["e"].tap()
        tablesQuery.staticTexts["revenge"].tap()
        
        app.keys["c"].tap()
        app.keys["u"].tap()
        app.keys["s"].tap()
        app.keys["t"].tap()
        tablesQuery.staticTexts["customer"].tap()
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["t"].tap()
        app.keys["o"].tap()
        tablesQuery.staticTexts["retouch"].tap()
        
        app.keys["i"].tap()
        app.keys["n"].tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        tablesQuery.staticTexts["intention"].tap()
        
        app.keys["m"].tap()
        app.keys["i"].tap()
        app.keys["n"].tap()
        app.keys["n"].tap()
        tablesQuery.staticTexts["minnow"].tap()
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
