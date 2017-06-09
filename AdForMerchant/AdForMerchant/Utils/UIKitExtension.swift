//
//  Common.swift
//  feno
//
//  Created by Kuma on 5/20/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit
import MJRefresh

extension UIScreen {
    static let width: CGFloat = UIScreen.main.bounds.width
    static let height: CGFloat = UIScreen.main.bounds.height
}

extension Dictionary {
    func toJSONString() -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) else { return  ""}
        guard let str = String(data: data, encoding: .utf8) else { return  ""}
        return str
    }
}

extension UIView {
    func drawDashLine(length: Int = 2, spacing: Int = 4, color: UIColor = .gray) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: frame.width, y: centerY))
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [NSNumber(value: length), NSNumber(value: spacing)]
        layer.addSublayer(shapeLayer)

    }
}

extension UIColor {
    class func colorWithRGB(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
    
    class func colorWithRGBA(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    class func colorWithHex(_ hex: String) -> UIColor {
        if hex.isEmpty {
            return UIColor.white
        }
        let set = CharacterSet.whitespacesAndNewlines
        var hHex = hex.trimmingCharacters(in: set).uppercased()
        if hHex.characters.count < 6 {
            return UIColor.clear
        }
        if hHex.hasPrefix("0X") {
            hHex = (hHex as NSString).substring(from: 2)
        }
        if hHex.hasPrefix("#") {
            hHex = (hHex as NSString).substring(from: 1)
        }
        if hHex.hasPrefix("##") {
            hHex = (hHex as NSString).substring(from: 2)
        }
        if hHex.characters.count != 6 {
            return UIColor.clear
        }
        var range = NSRange(location: 0, length: 2)
        let rHex = (hHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (hHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (hHex as NSString).substring(with: range)
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
    
    class func commonBlueColor() -> UIColor {return colorWithHex("#0B86EE")}//#3198f9
    class func commonTxtColor() -> UIColor {return colorWithHex("#141414")}//#3198f9
    class func commonGrayTxtColor() -> UIColor {return colorWithHex("#9498A9")}//#3198f9
    class func textfieldPlaceholderColor() -> UIColor {return colorWithHex("#C7C7CD")}
    class func commonBgColor() -> UIColor {return colorWithHex("#F5F5F5")}//#3198f9
    class func commonOrangeColor() -> UIColor {return colorWithHex("#F38900")}//#3198f9
    class func moneyRedColor() -> UIColor {return colorWithHex("#D61A24")}
    class func tagRedColor() -> UIColor {return colorWithHex("#D83138")}
    class func tagYellowColor() -> UIColor {return colorWithHex("#FEC250")}
    
    class func backgroundLightGreyColor() -> UIColor {
        return colorWithHex("#F5F5F5")
    }
    
    class func randomColor() -> UIColor {
        let r = arc4random_uniform(256)
        let g = arc4random_uniform(256)
        let b = arc4random_uniform(256)
        return  UIColor(red: CGFloat(r)/256.0, green: CGFloat(g)/256.0, blue: CGFloat(b)/256.0, alpha: 1.0)
    }
}

extension CALayer {
    var borderUIColor: UIColor? {
        get {
            if let borderColor = self.borderColor {
                return  UIColor(cgColor: borderColor)
            } else {
                return nil
            }
        }
        set(newBorderUIColor) {
             guard let newcolor = newBorderUIColor else { return  }
            self.borderColor = newcolor.cgColor
        }
    }
    
    var shadowUIColor: UIColor? {
        get {
            if let shadowColor = self.shadowColor {
                return  UIColor(cgColor: shadowColor)
            } else {
                return nil
            }
        }
        set(newShadowUIColor) {
            guard let newcolor = newShadowUIColor else { return  }
            self.shadowColor = newcolor.cgColor
        }
    }
}

extension UITableView {
    func addTableViewRefreshHeader(_ target: AnyObject!, refreshingAction: String) {
       guard let refreshHeader = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: Selector(refreshingAction)) else { return  }
        refreshHeader.lastUpdatedTimeLabel.isHidden = true
        self.mj_header  = refreshHeader
    }
    
    func addTableViewRefreshFooter(_ target: AnyObject!, refreshingAction: String) {
        let refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: target, refreshingAction: Selector(refreshingAction))
        self.mj_footer = refreshFooter
    }
}

extension String {
    func vaild(with regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    func deleteLastCharacter() -> String {
        let ns = self as NSString
        let subns = ns.substring(to: self.characters.count - 1)
        return subns as String
    }
    
    // 去掉小数
    static func cutDecimalCharater(_ str: String) -> String {
        let nsString = (str as NSString)
        let range = nsString.range(of: ".")
        return nsString.substring(to: range.location) as String
    }
    // 获得内容高度
    static func getLabHeigh(_ labelStr: String, font: UIFont, width: CGFloat) -> CGFloat {
        let statusLabelText: NSString = labelStr as NSString
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context: nil).size
        return strSize.height
    }
    // 返回折扣
    static func getAttString(_ str: String) -> NSMutableAttributedString {
        let newString = str+"折"
        let attString = NSMutableAttributedString(string: newString)
        let range = (str as NSString).range(of: ".")
        let rangeZhe = (newString as NSString).range(of: "折")
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize:27), range:
            NSRange(location: range.location-1, length: 1))
            
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize:20), range: NSRange(location: 1, length: 2))
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize:15), range: NSRange(location: 3, length: 1))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 0, length: 4))
        attString.addAttribute(NSBaselineOffsetAttributeName, value: 1, range: rangeZhe)
        return attString
    }
    // "2016-03-04 13:15" -> "2016.03.04 14:15"
    static func changeTimeFormat(_ time: String, occurrences: String? = "-", replace: String? = ".") -> String {
        let nsTime = (time as NSString)
        let cutoutTime = nsTime.substring(to: 16)
        let finalTime = cutoutTime.replacingOccurrences(of: occurrences ?? "-", with: replace ?? ".")
        return finalTime
    }
    
    // "2016-03-04 13:15"
    func timeFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        if let date = formatter.date(from: self) {
            return date.timeAgoSince()
        }
        return ""
    }

    static func getCurrentTime() -> String {
        let date = Date()
        let zone = NSTimeZone.system
        let interval = zone.secondsFromGMT(for: date)
        let currentTime = date.addingTimeInterval(TimeInterval(interval))
        return ("\(currentTime)" as NSString).substring(to: 16)
    }
    
    // 保留两位小数，只能输入一个小数点
    func  keepTwoPlacesDecimal() -> String {
        let stringCount = self.characters.count
        let nsString = self as NSString
        let arrDecimal = nsString.components(separatedBy: ".")
        
        if arrDecimal.count > 2 {
            return nsString.substring(to: stringCount-1)
        }
        if self.contains(".") {
            if nsString.substring(from: stringCount-1) == "." {
            } else {
                let strlocation = nsString.range(of: ".")
                let decimalCount = nsString.substring(from: strlocation.location).characters.count
                if decimalCount >= 3 {
                    return  nsString.substring(to: strlocation.location+3)
                }
                return self
            }
        }
        return self
    }
}

extension UIButton {
    convenience init(image: String, backgroundImage: String? = nil) {
        self.init()
        let normalImage = UIImage(named: image)
        self.setImage(normalImage, for: .normal)
        self.sizeToFit()
        guard let bg = backgroundImage else { return  }
        let backImage = UIImage(named: bg)
        self.setBackgroundImage(backImage, for: .normal)
    }
    
    convenience init(backgroundImage: String) {
        self.init()
        let backImage = UIImage(named: backgroundImage)
        self.setBackgroundImage(backImage, for: .normal)
        self.sizeToFit()
    }
}

extension UITabBar {
    
    func showBadgeOnItemIndex(index: Int) {
        self.removeBadgeOnItemIndex(index: index)
        let badgeView = UIView()
        badgeView.tag = 888 + index
        badgeView.layer.cornerRadius = 5
        badgeView.backgroundColor = UIColor.red
        let percentX = (CGFloat(index) + 0.6) / 5
        let x = ceil(percentX * (self.frame.size.width))
        let y = (0.1*self.frame.size.height)
        badgeView.frame = CGRect(x: x, y: y, width: 8, height: 8)
        self.addSubview(badgeView)
    }
    
    func hideBadgeOnItemIndex(index: Int) {
        self.removeBadgeOnItemIndex(index: index)
    }
    
    func removeBadgeOnItemIndex(index: Int) {
        for subView in self.subviews where subView.tag == 888 + index {
            subView.removeFromSuperview()
        }
    }
    
}

extension Date {
    func timeAgoSince() -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: self, to: now, options: [])
        guard let year = components.year else { return "" }
        if year >= 1 {
            return self.dateToString(format: "yyyy/MM/dd")
        }
        
        return self.dateToString(format: "MM/dd")
        
    }
    
    func dateToString(format: String? = "yyyy-MM-dd") -> String {
        
        let dateFmt = DateFormatter()
        dateFmt.timeZone = TimeZone(secondsFromGMT: 0)
        dateFmt.locale = Locale.init(identifier: "zh_CN")
        
        if let fmt = format {
            dateFmt.dateFormat = fmt
        }
        
        return dateFmt.string(from: self)
    }
}

extension String {
    func toDate() -> Date? {
        let dateFmt = DateFormatter()
        let zone = TimeZone.current
        dateFmt.timeZone = zone
        dateFmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFmt.date(from: self)
    }
    
    func judgeTime() -> String? {
        let yearMonthDayTime = self.toDate()?.toString("yyyy/MM/dd")
        let yearTime = self.toDate()?.toString("yyyy")
        let monthTime = self.toDate()?.toString("MM")
        let dayTime = self.toDate()?.toString("dd")
        let monthDayTime = self.toDate()?.toString("MM/dd")
        let hoursMinutesTime = self.toDate()?.toString("HH:mm")
        
        let date = Date()
        let unitFlags = Set<Calendar.Component>([.hour, .year, .minute, .day, .month])
        let calendar = Calendar.current
        let components = calendar.dateComponents(unitFlags, from: date)
         guard let year = components.year, let month = components.month, let day = components.day else { return nil }
        if String(year) == yearTime {
            if String(format: "%02d", month) == monthTime {
                if String(format: "%02d", day) == dayTime {
                    return hoursMinutesTime ?? nil
                } else {
                    return monthDayTime ?? nil
                }
            }
             return monthDayTime ?? nil
        } else {
            return yearMonthDayTime ?? nil
        }
    }
     
    func toFloat() -> CGFloat {
        var cgFloat: CGFloat = 0
        if let doubleValue = Double(self) {
            cgFloat = CGFloat(doubleValue)
        }
        return cgFloat
    }
}

// MARK: - Add UIView IBInspectable

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}
