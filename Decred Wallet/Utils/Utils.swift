//
//  Utils.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
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
    var tag: String?
    var font: UIFont?
    var color: UIColor?
    
    init(tag: String? = nil, font: UIFont, color: UIColor) {
        self.tag = tag
        self.font = font
        self.color = color
    }
    
    init(tag: String? = nil, fontFamily: String, fontSize: CGFloat, color: UIColor) {
        self.tag = tag
        self.font = UIFont(name: fontFamily, size: fontSize)
        self.color = color
    }
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
    
    static func ageString(fromTimestamp timestamp: Int64) -> String {
        let nowSeconds = Date().millisecondsSince1970 / 1000
        let hoursBehind = Float(nowSeconds - timestamp) / Float(Utils.TimeInSeconds.Hour)
        let daysBehind = Int64(round(hoursBehind / 24.0))
        
        if daysBehind < 1 {
            return LocalizedStrings.lessThanOneday
        } else if daysBehind == 1 {
            return LocalizedStrings.oneDay
        } else {
            return String(format: LocalizedStrings.mutlipleDays, daysBehind)
        }
    }
    
    static func timeAgo(timeInterval: Int64) -> String {
        switch timeInterval {
        case Int64.min...0:
            return LocalizedStrings.now
            
        case 0..<Utils.TimeInSeconds.Minute:
            return String(format: LocalizedStrings.secondsAgo, timeInterval)
            
        case Utils.TimeInSeconds.Minute..<Utils.TimeInSeconds.Hour:
            let minutes = timeInterval / Utils.TimeInSeconds.Minute
            return String(format: LocalizedStrings.minAgo, minutes)
            
        case Utils.TimeInSeconds.Hour..<Utils.TimeInSeconds.Day:
            let hours = timeInterval / Utils.TimeInSeconds.Hour
            return String(format: LocalizedStrings.hrsAgo, hours)
            
        case Utils.TimeInSeconds.Day..<Utils.TimeInSeconds.Week:
            let days = timeInterval / Utils.TimeInSeconds.Day
            return String(format: LocalizedStrings.daysAgo, days)
            
        case Utils.TimeInSeconds.Week..<Utils.TimeInSeconds.Month:
            let weeks = timeInterval / Utils.TimeInSeconds.Week
            return String(format: LocalizedStrings.weeksAgo, weeks)
            
        case Utils.TimeInSeconds.Month..<Utils.TimeInSeconds.Year:
            let months = timeInterval / Utils.TimeInSeconds.Month
            return String(format: LocalizedStrings.monthsAgo, months)
            
        default:
            let years = timeInterval / Utils.TimeInSeconds.Year
            return String(format: LocalizedStrings.yearsAgo, years)
        }
    }
    
    static func showProgressHud(withText text: String) -> JGProgressHUD {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = text
        hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
        hud.show(in: (UIApplication.shared.keyWindow?.rootViewController?.view)!)
        return hud
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
    
    static func amountAsAttributedString(amount: Double?, smallerTextSize: CGFloat, textColor: UIColor = UIColor.appColors.darkBlue) -> NSMutableAttributedString {
        let amountRoundedOff = (Decimal(amount ?? 0) as NSDecimalNumber).round(8)
        return Utils.getAttributedString(str: "\(amountRoundedOff)", siz: smallerTextSize, TexthexColor: textColor)
    }
    
    // function should be refactored!
    static func getAttributedString(str: String, siz: CGFloat, TexthexColor: UIColor) -> NSMutableAttributedString {
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
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "MMM dd, yyyy hh:mma"
        let date = Date(timeIntervalSince1970: Double(timestamp))
        return formatter.string(from: date)
    }

    static func showBanner(in superview: UIView, type: BannerType, text: String) {
        let banner = UIView()
        superview.addSubview(banner)

        // Position banner 10% from the top of the view or 64pts from the top of the view,
        // whichever is smaller.
        let bannerYPos = min(superview.frame.height * 0.1, 64)

        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: 8).isActive = true
        banner.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -8).isActive = true
        banner.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: bannerYPos).isActive = true
        banner.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true

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
    
    static func styleAttributedString(_ text: String, font: UIFont? = nil, color: UIColor? = nil) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text, attributes: nil)
        if font != nil {
            attrString.addAttribute(NSAttributedString.Key.font, value: font!, range: NSMakeRange(0, text.count))
        }
        if color != nil {
            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: color!, range: NSMakeRange(0, text.count))
        }
        return attrString
    }

    static func styleAttributedString(_ inString: String,
                                      styles: [AttributedStringStyle],
                                      defaultStyle: AttributedStringStyle? = nil) -> NSMutableAttributedString {
        
        let attrString = Utils.styleAttributedString(inString, font: defaultStyle?.font, color: defaultStyle?.color)
        
        for style in styles {
            if let tag = style.tag {
                let pattern = "<\\s*\(tag)[^>]*>(.*?)<\\s*\\/\\s*\(tag)>"
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
                    for tagPattern in ["<\(tag)>", "</\(tag)>"] {
                        attrString.mutableString.replaceOccurrences(of: tagPattern, with: "", options: NSString.CompareOptions.caseInsensitive, range: NSRange(location: 0, length: attrString.length))
                    }
                }
            }
        }
        return attrString
    }
    
    static func format(bytes: Double) -> String {
        guard bytes > 0 else {
            return "0 bytes"
        }

        let suffixes = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        let k: Double = 1000
        let i = floor(log(bytes) / log(k))

        // Format number with thousands separator and everything below 1 GB with no decimal places.
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = i < 3 ? 0 : 1
        numberFormatter.numberStyle = .decimal

        let numberString = numberFormatter.string(from: NSNumber(value: bytes / pow(k, i))) ?? "Unknown"
        let suffix = suffixes[Int(i)]
        return "\(numberString) \(suffix)"
    }
    
    static func getDirFileSize() -> Int64 {
        let intPointer = UnsafeMutablePointer<Int64>.allocate(capacity: 4)
        defer {
            intPointer.deallocate()
        }
        do {
            try WalletLoader.shared.multiWallet.rootDirFileSize(inBytes: intPointer)
        } catch let error {
            print("dir error:", error.localizedDescription)
        }
        return intPointer.pointee
    }
    
    static func countAllWalletTransaction()-> Int {
        var transactionCount: Int = 0
        for wallet in WalletLoader.shared.wallets {
            transactionCount += wallet.transactionsCount(forTxFilter: DcrlibwalletTxFilterAll)
        }
        return transactionCount
    }
    
    static func calculateTime(timeInterval: Int64) -> String {
        switch timeInterval {
        case Int64.min...0:
            return LocalizedStrings.now
            
        case 0..<Utils.TimeInSeconds.Minute:
            return String(format: LocalizedStrings.seconds, timeInterval)
            
        case Utils.TimeInSeconds.Minute..<Utils.TimeInSeconds.Hour:
            let minutes = timeInterval / Utils.TimeInSeconds.Minute
            return String(format: LocalizedStrings.minutes, minutes)
            
        case Utils.TimeInSeconds.Hour..<Utils.TimeInSeconds.Day:
            let hours = timeInterval / Utils.TimeInSeconds.Hour
            return String(format: LocalizedStrings.hours, hours)
            
        case Utils.TimeInSeconds.Day..<Utils.TimeInSeconds.Week:
            let days = timeInterval / Utils.TimeInSeconds.Day
            return String(format: LocalizedStrings.days, days)
            
        case Utils.TimeInSeconds.Week..<Utils.TimeInSeconds.Month:
            let weeks = timeInterval / Utils.TimeInSeconds.Week
            return String(format: LocalizedStrings.weeks, weeks)
            
        case Utils.TimeInSeconds.Month..<Utils.TimeInSeconds.Year:
            let months = timeInterval / Utils.TimeInSeconds.Month
            return String(format: LocalizedStrings.months, months)
            
        default:
            let years = timeInterval / Utils.TimeInSeconds.Year
            return String(format: LocalizedStrings.years, years)
        }
    }
    
    static func timeStringFor(seconds : Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        let output = formatter.string(from: TimeInterval(seconds))!
        return output
    }
}
