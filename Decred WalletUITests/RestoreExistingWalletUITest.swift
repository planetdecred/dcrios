//
//  RestoreExistingWalletUITest.swift
//  Decred WalletUITests
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import XCTest

class RestoreExistingWalletUITest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRestoreExistingWalletWithPassword() throws {
        
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
        
        if getStarted.waitForExistence(timeout: 10) {
            getStarted.tap()
        }
        
        sleep(2)
        
        self.typePassword(app: app)
        
        createBtn.tap()
        
        // If wifi is enabled, the app starts syncing else it will show a dialog, requesting
        // for the user's permission to sync with mobile data
        let elementsQuery = app.scrollViews.otherElements
        let cancelStaticText = elementsQuery.buttons.element(matching: .button, identifier: "connectionButton")
               
        if cancelStaticText.waitForExistence(timeout: 10) {
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
    
    func testRestoreExistingWalletWithPIN() throws {
        
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
        
        let restoreExistingWallet = app.buttons.element(matching: .button, identifier: "restoreExistingWallet")
        if restoreExistingWallet.waitForExistence(timeout: 10) {
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
        
        if getStarted.waitForExistence(timeout: 10) {
            getStarted.tap()
        }
        
        self.typePin(app: app)
        
        createBtn.tap()
        
        // If wifi is enabled, the app starts syncing else it will show a dialog, requesting
        // for the user's permission to sync with mobile data
        let elementsQuery = app.scrollViews.otherElements
        let cancelStaticText = elementsQuery.buttons.element(matching: .button, identifier: "connectionButton")
               
        if cancelStaticText.waitForExistence(timeout: 10) {
            cancelStaticText.tap()
        }
               
        sleep(2)
        
        //switch to wallet menu tab
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
        
        self.typePin(app: app)
               
        sleep(1)
               
        app.staticTexts["Remove"].tap()
               
        sleep(6)
    }
    
    func seedUIInput(app: XCUIApplication) {
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"1").children(matching: .textField).element.tap()
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["f"].tap()
        app.keys["o"].tap()
        sleep(1)
        tablesQuery.staticTexts["reform"].tap()
        sleep(1)
        
        app.keys["a"].tap()
        app.keys["f"].tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        sleep(1)
        tablesQuery.staticTexts["aftermath"].tap()
        sleep(1)
        
        app.keys["p"].tap()
        app.keys["r"].tap()
        app.keys["i"].tap()
        app.keys["n"].tap()
        sleep(1)
        tablesQuery.staticTexts["printer"].tap()
        sleep(1)
        
        app.keys["w"].tap()
        app.keys["a"].tap()
        app.keys["r"].tap()
        app.keys["r"].tap()
        sleep(1)
        tablesQuery.staticTexts["warranty"].tap()
        sleep(1)
        app.gentleSwipe(.Up)
        sleep(1)
        
        app.keys["g"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["m"].tap()
        sleep(1)
        tablesQuery.staticTexts["gremlin"].tap()
        sleep(1)
        
        app.keys["p"].tap()
        app.keys["a"].tap()
        app.keys["r"].tap()
        app.keys["a"].tap()
        sleep(1)
        tablesQuery.staticTexts["paragraph"].tap()
        sleep(1)
        
        app.keys["b"].tap()
        app.keys["e"].tap()
        app.keys["e"].tap()
        app.keys["h"].tap()
        sleep(1)
        tablesQuery.staticTexts["beehive"].tap()
        sleep(1)
        
        app.keys["s"].tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        app.keys["t"].tap()
        sleep(1)
        tablesQuery.staticTexts["stethoscope"].tap()
        sleep(1)
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["g"].tap()
        app.keys["a"].tap()
        tablesQuery.staticTexts["regain"].tap()
        sleep(1)
        app.gentleSwipe(.Up)
        sleep(1)
        
        app.keys["d"].tap()
        app.keys["i"].tap()
        app.keys["s"].tap()
        app.keys["r"].tap()
        sleep(1)
        tablesQuery.staticTexts["disruptive"].tap()
        sleep(1)
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["g"].tap()
        app.keys["a"].tap()
        sleep(1)
        tablesQuery.staticTexts["regain"].tap()
        sleep(1)
        
        app.keys["b"].tap()
        app.keys["r"].tap()
        app.keys["a"].tap()
        app.keys["d"].tap()
        sleep(1)
        tablesQuery.staticTexts["Bradbury"].tap()
        sleep(1)
        
        app.keys["c"].tap()
        app.keys["h"].tap()
        app.keys["i"].tap()
        app.keys["s"].tap()
        sleep(1)
        tablesQuery.staticTexts["chisel"].tap()
        sleep(1)
        
        app.keys["o"].tap()
        app.keys["c"].tap()
        app.keys["t"].tap()
        app.keys["o"].tap()
        sleep(1)
        tablesQuery.staticTexts["October"].tap()
        sleep(1)
        app.gentleSwipe(.Up)
        sleep(1)
        
        app.keys["t"].tap()
        app.keys["r"].tap()
        app.keys["o"].tap()
        app.keys["u"].tap()
        sleep(1)
        tablesQuery.staticTexts["trouble"].tap()
        sleep(1)
        
        app.keys["f"].tap()
        app.keys["o"].tap()
        app.keys["r"].tap()
        app.keys["e"].tap()
        sleep(1)
        tablesQuery.staticTexts["forever"].tap()
        sleep(1)
        
        app.keys["a"].tap()
        app.keys["l"].tap()
        app.keys["g"].tap()
        app.keys["o"].tap()
        sleep(1)
        tablesQuery.staticTexts["Algol"].tap()
        sleep(1)
        
        app.keys["a"].tap()
        app.keys["p"].tap()
        app.keys["p"].tap()
        app.keys["l"].tap()
        sleep(1)
        tablesQuery.staticTexts["applicant"].tap()
        sleep(1)
       
        app.keys["i"].tap()
        app.keys["s"].tap()
        app.keys["l"].tap()
        app.keys["a"].tap()
        sleep(1)
        tablesQuery.staticTexts["island"].tap()
        sleep(1)
        
        app.keys["i"].tap()
        app.keys["n"].tap()
        app.keys["f"].tap()
        app.keys["a"].tap()
        sleep(1)
        tablesQuery.staticTexts["infancy"].tap()
        app.gentleSwipe(.Up)
        sleep(1)
        
        app.keys["p"].tap()
        app.keys["h"].tap()
        app.keys["y"].tap()
        app.keys["s"].tap()
        sleep(1)
        tablesQuery.staticTexts["physique"].tap()
        sleep(1)
        
        app.keys["p"].tap()
        app.keys["a"].tap()
        app.keys["r"].tap()
        app.keys["a"].tap()
        sleep(1)
        tablesQuery.staticTexts["paragraph"].tap()
        sleep(1)
        
        app.keys["w"].tap()
        app.keys["o"].tap()
        app.keys["o"].tap()
        app.keys["d"].tap()
        sleep(1)
        tablesQuery.staticTexts["woodlark"].tap()
        sleep(1)
        
        app.keys["h"].tap()
        app.keys["y"].tap()
        app.keys["d"].tap()
        app.keys["r"].tap()
        sleep(1)
        tablesQuery.staticTexts["hydraulic"].tap()
        sleep(1)
        
        app.keys["s"].tap()
        app.keys["n"].tap()
        app.keys["a"].tap()
        app.keys["p"].tap()
        sleep(1)
        tablesQuery.staticTexts["snapshot"].tap()
        sleep(1)
        
        app.keys["b"].tap()
        app.keys["a"].tap()
        app.keys["c"].tap()
        app.keys["k"].tap()
        sleep(1)
        tablesQuery.staticTexts["backwater"].tap()
        sleep(1)
        app.gentleSwipe(.Up)
        sleep(1)
        
        app.keys["r"].tap()
        app.keys["a"].tap()
        app.keys["t"].tap()
        app.keys["c"].tap()
        sleep(1)
        tablesQuery.staticTexts["ratchet"].tap()
        sleep(1)
        
        app.keys["s"].tap()
        app.keys["u"].tap()
        app.keys["r"].tap()
        app.keys["r"].tap()
        sleep(1)
        tablesQuery.staticTexts["surrender"].tap()
        sleep(1)
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["v"].tap()
        app.keys["e"].tap()
        sleep(1)
        tablesQuery.staticTexts["revenge"].tap()
        sleep(1)
        
        app.keys["c"].tap()
        app.keys["u"].tap()
        app.keys["s"].tap()
        app.keys["t"].tap()
        sleep(1)
        tablesQuery.staticTexts["customer"].tap()
        sleep(1)
        
        app.keys["r"].tap()
        app.keys["e"].tap()
        app.keys["t"].tap()
        app.keys["o"].tap()
        sleep(1)
        tablesQuery.staticTexts["retouch"].tap()
        sleep(1)
        
        app.keys["i"].tap()
        app.keys["n"].tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        sleep(1)
        tablesQuery.staticTexts["intention"].tap()
        sleep(1)
        
        app.keys["m"].tap()
        app.keys["i"].tap()
        app.keys["n"].tap()
        app.keys["n"].tap()
        sleep(1)
        tablesQuery.staticTexts["minnow"].tap()
        sleep(1)
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


extension XCUIElement {
    
    enum direction : Int {
    case Up, Down, Left, Right
    
    }
    
    func gentleSwipe(_ direction : direction) {
        let half : CGFloat = 0.5
        var adjustment : CGFloat = 0.17
//        if iPhoneX(size: UIScreen.main.bounds.size) {
//            adjustment = 0.18
//        }
        
        let pressDuration : TimeInterval = 0.05
        let lessThanHalf = half - adjustment
        let moreThanHalf = half + adjustment
        let centre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: half))
        let aboveCentre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: lessThanHalf))
        let belowCentre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: moreThanHalf))
        let leftOfCentre = self.coordinate(withNormalizedOffset: CGVector(dx: lessThanHalf, dy: half))
        let rightOfCentre = self.coordinate(withNormalizedOffset: CGVector(dx: moreThanHalf, dy: half))
        switch direction {
        case .Up:
            centre.press(forDuration: pressDuration, thenDragTo: aboveCentre)
            break
        case .Down:
            centre.press(forDuration: pressDuration, thenDragTo: belowCentre)
            break
        case .Left:
            centre.press(forDuration: pressDuration, thenDragTo: leftOfCentre)
            break
        case .Right:
            centre.press(forDuration: pressDuration, thenDragTo: rightOfCentre)
            break
        }
    }
    
     func iPhoneX(size: CGSize) -> Bool {
        // This check works regardless of orientation.
        let result = CGFloat(812 + 375)
        let currentPhone = size.width + size.height
        // print(currentPhone)

        return currentPhone == result
    }
}
