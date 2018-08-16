//
//  GeneratedSeedDisplayViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit
import Mobilewallet

class GeneratedSeedDisplayViewController: UIViewController {

    @IBOutlet weak var vWarningIcon: UIView!
    @IBOutlet weak var vWarningLabel: UILabel!

    var seed : String! = ""
    
    @IBOutlet weak var seedContainer: UIView!
    var arrWords : Array<String> = []
    var yPosition: CGFloat?
    var xPostiion: CGFloat?
    var totalWidth: CGFloat?
    var widthOffset: CGFloat?
    var heightOffset: CGFloat?
    var calcultaedHeight: CGFloat?
    let font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seed = AppContext.instance.decrdConnection?.generateSeed() as String?
        arrWords = (seed?.components(separatedBy: " "))!
        vWarningLabel.layer.borderColor = GlobalConstants.Colors.orangeColor.cgColor
        vWarningIcon.layer.borderColor = GlobalConstants.Colors.orangeColor.cgColor
        vWarningLabel.superview?.layer.borderColor = GlobalConstants.Colors.orangeColor.cgColor

        self.drawSeed()
    }
    
    // MARK: - Utility
    
    func setUpUItraits() {
        self.totalWidth = seedContainer.frame.size.width
        self.yPosition = 20.0
        self.xPostiion = 20.0
        self.widthOffset = 0.0
        self.heightOffset = 0.0
        self.calcultaedHeight = 21.0
    }
    
    // Draw seed
    func drawSeed() {
        for view in seedContainer.subviews{
            view.removeFromSuperview()
        }
        self.setUpUItraits()
        for word in arrWords {
            let wordSize = self.getWidth(str: " " + word + " ")
            let rect = self.getLocation(stringSize: wordSize.width)
            let lbl = UILabel(frame: rect)
            lbl.backgroundColor = GlobalConstants.Colors.lightBlue
            lbl.font = self.font
            lbl.clipsToBounds = true
            lbl.layer.cornerRadius = 3
            lbl.textAlignment = NSTextAlignment.center
            lbl.text = word
            seedContainer.addSubview(lbl)
        }
    }
    
    // Get location for new seed word
    func getLocation(stringSize: CGFloat) -> CGRect {
        let pos = xPostiion! + stringSize
        let rect : CGRect
        if( pos < totalWidth! ) {
            rect = CGRect(origin: CGPoint(x: xPostiion!, y: yPosition!), size: CGSize(width: stringSize, height: 21))
            xPostiion = xPostiion! + stringSize + 5
        } else {
            xPostiion = 20.0
            yPosition = yPosition! + 26
            rect = CGRect(origin: CGPoint(x: xPostiion!, y: yPosition!), size: CGSize(width: stringSize, height: 21))
            xPostiion = xPostiion! + stringSize + 5
        }
        return rect
        
    }
    
    
    // Get width for new word
    func getWidth(str: String) -> CGSize {
        let maxLabelSize = CGSize(width: 300, height: 30)
        let contentNSString = str as String
        let expectedLabelSize = contentNSString.boundingRect(with: maxLabelSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: self.font], context: nil)
        print("\(expectedLabelSize)")
        return expectedLabelSize.size
        
        vWarningLabel.layer.borderColor = UIColor(hex: "fd714a").cgColor
        vWarningIcon.layer.borderColor = UIColor(hex: "fd714a").cgColor

    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = seed
    }

}
