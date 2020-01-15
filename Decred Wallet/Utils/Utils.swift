//
//  Utils.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD
import Dcrlibwallet

enum BannerType: String {
    case success
    case error
}

struct AttributedStringStyle {
    var tag: String
    var font: UIFont?
    var color: UIColor?
}

struct Utils {
    struct TimeInSeconds {
        static let Minute: Int64 = 60
        static let Hour: Int64 = TimeInSeconds.Minute * 60
        static let Day: Int64 = TimeInSeconds.Hour * 24
        static let Week: Int64 = TimeInSeconds.Day * 7
        static let Month: Int64 = TimeInSeconds.Week * 4
        static let Year: Int64 = TimeInSeconds.Month * 12
    }
    
    static func showProgressHud(withText text: String) -> JGProgressHUD {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = text
        hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
        hud.show(in: (UIApplication.shared.keyWindow?.rootViewController?.view)!)
        return hud
    }
    
    static func spendable(account:DcrlibwalletAccount) -> Decimal{
        let iRequireConfirm = Settings.spendUnconfirmed ? Int32(0) : Int32(2)
        let int64Pointer = UnsafeMutablePointer<Int64>.allocate(capacity: 64)
        do {
            
            try  AppDelegate.walletLoader.wallet?.spendable(forAccount: account.number, requiredConfirmations: iRequireConfirm, ret0_: int64Pointer)
        } catch let error{
            print(error)
            return 0.0
        }
        print("spendable =")
        print(Decimal(int64Pointer.move()))
        return Decimal(int64Pointer.move()) / 100000000.0
    }
    
    static func loadCertificate() throws ->  String {
        let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
        return try String.init(contentsOfFile: filePath)
    }
    
    static func saveCertificate(secretKey: String) {
        do {
            let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
            let filePathURL = URL.init(fileURLWithPath: filePath)
            try secretKey.write(to: filePathURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            debugPrint("Could not create certificate file")
        }
    }
    
    static func getAttributedString(str: String, siz: CGFloat, TexthexColor: UIColor) -> NSAttributedString {
        var tmpString = str
        if tmpString.contains("."){
            var stt = tmpString as NSString?
            let sttbTmp = stt
            var atrStr = NSMutableAttributedString(string: stt! as String)
            var dotRange = sttbTmp?.range(of: ".")
            if ((dotRange!.location) > 3){
                let  tmpstt = Int((sttbTmp!.substring(to: (dotRange!.location))))
                let newValue = tmpstt!.formattedWithSeparator
                stt = newValue.appending(sttbTmp!.substring(from: (dotRange!.location))) as NSString?
                tmpString = newValue.appending(sttbTmp!.substring(from: (dotRange!.location)))
                atrStr = NSMutableAttributedString(string: stt! as String)
                dotRange = stt?.range(of: ".")
                
            }
            
            if (tmpString.length - ((dotRange?.location)!) <= 3) {
                return NSMutableAttributedString(string: tmpString.appending(" DCR") as String)
            }
            else if(tmpString.length > ((dotRange?.location)!+2)) {
                atrStr.append(NSMutableAttributedString(string: " DCR"))
                stt = (stt?.appending(((" DCR")))) as NSString?
                atrStr.addAttribute(NSAttributedString.Key.font,
                                    value: UIFont(name: "SourceSansPro-Regular", size: siz)!,
                                    range: NSRange(location:(dotRange?.location)!+3, length:(stt?.length)!-1 - ((dotRange?.location)!+2)))
                
                atrStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                    value: TexthexColor,
                                    range: NSRange(location:0, length:(stt?.length)!))
            }
            
            return atrStr
        }
        
        if (tmpString.length > 3) {
            return NSMutableAttributedString(string: Int(tmpString)!.formattedWithSeparator.appending(" DCR") )
        }
        
        return NSMutableAttributedString(string: tmpString.appending(" DCR") as String)
    }
    
    static func formatDateTime(timestamp: Int64) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy / hh:mm:ss a"
        let date = Date(timeIntervalSince1970: Double(timestamp))
        return formatter.string(from: date)
    }

    static func showBanner(parentVC: UIViewController, type: BannerType, text: String) {
        let banner = UIView()
        parentVC.view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.leadingAnchor.constraint(greaterThanOrEqualTo: parentVC.view.leadingAnchor, constant: 8).isActive = true
        banner.trailingAnchor.constraint(lessThanOrEqualTo: parentVC.view.trailingAnchor, constant: -8).isActive = true
        banner.topAnchor.constraint(equalTo: parentVC.view.safeAreaLayoutGuide.topAnchor, constant: 84).isActive = true
        banner.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor).isActive = true

        banner.backgroundColor = (type == .error) ? UIColor.appColors.orange : UIColor.appColors.green
        banner.layer.cornerRadius = 7
        banner.layer.shadowColor = UIColor.appColors.darkBlue.cgColor
        banner.layer.shadowRadius = 4
        banner.layer.shadowOpacity = 0.24
        banner.layer.shadowOffset = CGSize(width: 0, height: 1)

        let infoLabel = UILabel()
        banner.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 10).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -10).isActive = true
        infoLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 5).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -5).isActive = true
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.textAlignment = .center
        infoLabel.textColor = .white
        infoLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        infoLabel.text = text

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak banner] in
            banner?.removeFromSuperview()
        }
    }

    static func styleAttributedString(_ inString: String, styles: [AttributedStringStyle]) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: inString, attributes: nil)
        for style in styles {
            let pattern = "<\\s*\(style.tag)[^>]*>(.*?)<\\s*\\/\\s*\(style.tag)>"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            if let matches = regex?.matches(in: inString, options: [], range: NSMakeRange(0, inString.count)) {
                for match in matches {
                    if let color = style.color {
                        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: match.range(at: 1))
                    }
                    if let font = style.font {
                        attrString.addAttribute(NSAttributedString.Key.font, value: font, range: match.range(at: 1))
                    }
                }
                for tagPattern in ["<\(style.tag)>", "</\(style.tag)>"] {
                    attrString.mutableString.replaceOccurrences(of: tagPattern, with: "", options: NSString.CompareOptions.caseInsensitive, range: NSRange(location: 0, length: attrString.length))
                }
            }
        }
        return attrString
    }
}
