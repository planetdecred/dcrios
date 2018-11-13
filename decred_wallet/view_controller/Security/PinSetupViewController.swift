//
//  PinSetupViewController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.


import UIKit

class PinSetupViewController: UIViewController {
    @IBOutlet weak var pinMarks: PinMarksView!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    let pinStrength = PinWeakness()
    let pinInputController = PinInputController(max: 5)
    
    var pin : String = ""{
        didSet {
            pinMarks.entered = pin.count
            pinMarks.update()
            prgsPinStrength.progressTintColor = pinStrength.strengthColor(forPin: pin)
            prgsPinStrength.progress = pinStrength.strength(forPin: pin)
        }
    }
    
    @IBAction func on1(_ sender: Any) {
        pin = pinInputController.input(digit: 1)
    }
    
    @IBAction func on2(_ sender: Any) {
        pin = pinInputController.input(digit: 2)
    }
    
    @IBAction func on3(_ sender: Any) {
        pin = pinInputController.input(digit: 3)
    }
    
    @IBAction func on4(_ sender: Any) {
        pin = pinInputController.input(digit: 4)
    }
    
    @IBAction func on5(_ sender: Any) {
        pin = pinInputController.input(digit: 5)
    }
    
    @IBAction func on6(_ sender: Any) {
        pin = pinInputController.input(digit: 6)
    }
    
    @IBAction func on7(_ sender: Any) {
        pin = pinInputController.input(digit: 7)
    }
    
    @IBAction func on8(_ sender: Any) {
        pin = pinInputController.input(digit: 8)
    }
    
    @IBAction func on9(_ sender: Any) {
        pin = pinInputController.input(digit: 9)
    }
    
    @IBAction func on0(_ sender: Any) {
        pin = pinInputController.input(digit: 0)
    }
    
    @IBAction func onBackspace(_ sender: Any) {
        pin = pinInputController.backspace()
    }

}
