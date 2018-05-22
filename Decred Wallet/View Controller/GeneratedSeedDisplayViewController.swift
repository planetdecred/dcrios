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
    @IBOutlet weak var txSeed: UITextView!
    @IBOutlet weak var vWarningLabel: UILabel!
    @IBOutlet weak var seedContainer: UIView!
    var arrWords : Array<String> = []
    var yPosition: CGFloat = 20.0
    var xPostiion: CGFloat = 20.0
    var totalWidth: CGFloat = 0.0
    var widthOffset: CGFloat = 0.0
    var heightOffset: CGFloat = 0.0
    var calcultaedHeight: CGFloat = 21.0
    let font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    
    @IBOutlet weak var seedCollection: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let seed = try? AppContext.instance.walletManager?.generateSeed() as String!
        arrWords = (seed?.components(separatedBy: " "))!
        txSeed.text = seed ?? ""
        
        vWarningLabel.layer.borderColor = UIColor(hex: "fd714a").cgColor
        vWarningIcon.layer.borderColor = UIColor(hex: "fd714a").cgColor
        
        self.setUpUItraits()
        self.drawSeed()
    }
    
    // MARK: - Utility
    
    func setUpUItraits() {
        totalWidth = seedContainer.frame.size.width
    }
    
    // Draw seed 
    func drawSeed() {
        for view in seedContainer.subviews{
            view.removeFromSuperview()
        }
        for word in arrWords {
            let wordSize = self.getWidth(str: " " + word + " ")
            let rect = self.getLocation(stringSize: wordSize.width)
            let lbl = UILabel(frame: rect)
            lbl.backgroundColor = UIColor(red: 206.0/255.0, green: 238.0/255.0, blue: 250.0/255.0, alpha: 1.0)
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
        let pos = xPostiion + stringSize
        let rect : CGRect
        if( pos < totalWidth ) {
           rect = CGRect(origin: CGPoint(x: xPostiion, y: yPosition), size: CGSize(width: stringSize, height: 21))
            xPostiion = xPostiion + stringSize + 5
        } else {
            xPostiion = 20.0
            yPosition = yPosition + 26
            rect = CGRect(origin: CGPoint(x: xPostiion, y: yPosition), size: CGSize(width: stringSize, height: 21))
            xPostiion = xPostiion + stringSize + 5
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
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = txSeed.text
    }
    
    

}



