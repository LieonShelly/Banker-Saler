//
//  Utility.swift
//  feno
//
//  Created by Kuma on 6/30/15.
//  Copyright (c) 2015 Windward. All rights reserved.
// swiftlint:disable type_body_length
// swiftlint:disable function_parameter_count

import Foundation
import MBProgressHUD

class Utility: NSObject {
    
    override init() {
        super.init()
    }
    
    var progressHUD: MBProgressHUD!  = MBProgressHUD()
    var dateFormatter: DateFormatter = DateFormatter()
    var numberFormatter: NumberFormatter = NumberFormatter()
    
    static let sharedInstance: Utility = {
        let instance = Utility()
        instance.dateFormatter.dateFormat = "yyyy-MM-dd"
        instance.numberFormatter.numberStyle = NumberFormatter.Style.currency
        instance.progressHUD = MBProgressHUD()
        kApp.window?.addSubview(instance.progressHUD)
        return instance
    }()
    
    // MARK: - Normal Alert Type. Only one button with "确认"
    
    class func showAlert(_ sender: UIViewController, message: String) {
        showAlert(sender, message: message, dismissCompletion: nil)
    }
    
    class func showAlert(_ sender: UIViewController, message: String, dismissCompletion: ((Void) -> Void)?) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        if dismissCompletion != nil {
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (action) in
                dismissCompletion?()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: nil))
        }
        sender.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Confirm Alert Type. Two buttons with Cutsom button titles
    
    class func showConfirmAlert(_ sender: UIViewController, message: String, confirmCompletion: ((Void) -> Void)?) {
        self.showConfirmAlert(sender, title: "提示", message: message, confirmCompletion: confirmCompletion)
    }
    
    class func showConfirmAlert(_ sender: UIViewController, title: String, message: String, confirmCompletion: ((Void) -> Void)?) {
        self.showConfirmAlert(sender, title: title, cancelButtonTitle: "取消", confirmButtonTitle: "确认", message: message, confirmCompletion: confirmCompletion)
    }
    
    class func showConfirmAlert(_ sender: UIViewController, title: String, cancelButtonTitle: String, confirmButtonTitle: String, message: String, confirmCompletion: ((Void) -> Void)?) {
        self.showConfirmAlert(sender, title: title, cancelButtonTitle: cancelButtonTitle, confirmButtonTitle: confirmButtonTitle, message: message, cancelCompletion:nil, confirmCompletion: confirmCompletion)
    }
    
    class func showConfirmAlert(_ sender: UIViewController, title: String, cancelButtonTitle: String, confirmButtonTitle: String, message: String, cancelCompletion: ((Void) -> Void)?, confirmCompletion: ((Void) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelCompletion != nil {
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: { (action) in
                cancelCompletion?()
            }))
        } else {
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: nil))
        }
        
        if confirmCompletion != nil {
            alert.addAction(UIAlertAction(title: confirmButtonTitle, style: .default, handler: { (action) in
                confirmCompletion?()
            }))
        } else {
            alert.addAction(UIAlertAction(title: confirmButtonTitle, style: .default, handler: nil))
        }
        sender.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 去除两边空格的字符串
    class func getTextByTrim(_ text: String) -> String {
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // MARK: - 改变图像尺寸
    class func scaleFromImage(_ image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    // MARK: - 字符串验证
    
    /*手机号码验证 MODIFIED BY HELENSONG*/
    class func isValidateMobile(_ mobile: String?) -> Bool {
        if mobile == nil {
            return false
        }
        //手机号以13， 15，18开头，八个 \d 数字字符
        let phoneRegex = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        //    NSLog(@"phoneTest is %@",phoneTest)
        return phoneTest.evaluate(with: mobile)
    }
    /*中文英文 长度为 1-5*/
    class func isValidatePersonName(_ name: String?) -> Bool {
        if name == nil {
            return false
        }
        //手机号以13， 15，18开头，八个 \d 数字字符
        let nameRegex = "[\\u4e00-\\u9fa5a-zA-Z]{1,5}"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        //    NSLog(@"phoneTest is %@",phoneTest)
        return nameTest.evaluate(with: name)
    }
    
    /*Email验证 MODIFIED BY HELENSONG*/
    class func isValidateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    /*ID身份证验证*/
    class func isValidateIDNumber(_ idNumb: String) -> Bool {
        let emailRegex = "^[0-9]{17}[0-9X]$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: idNumb)
    }
    
    class func isValidatePassword(_ password: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z_]{6,16}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: password)
    }
    
    class func isOnlyNumber(_ str: String?) -> Bool {
        let numberRegex = "[0-9.-]+"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        return numberTest.evaluate(with: str)
    }
    
    class func isValidLegalPersonName(_ str: String?) -> Bool {
        let numberRegex = "[\\u4e00-\\u9fa5]{2,13}"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        return numberTest.evaluate(with: str)
    }
    
    class func isValidBankCardNumber(_ str: String?) -> Bool {
        let numberRegex = "[0-9]{19}"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        return numberTest.evaluate(with: str)
    }
    
    /*工商注册号验证*/
    class func isValidLegalCode(_ idNumb: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z]{18}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: idNumb)
    }
    
    /*验证店铺名应为15个字以内汉字、英文字母或数字组成*/
    class func isValidateShopName(_ name: String) -> Bool {
        let emailRegex = "[\\u4e00-\\u9fa5A-Z0-9a-z]{1,15}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: name)
    }
    
    class func containsChineseEnglishAndNumber(_ str: String, length: Int) -> Bool {
        let regex = "[\\u4e00-\\u9fa5A-Z0-9a-z]{1,\(length)}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: str)
    }
    
    class func isValidURL(_ url: String) -> Bool {
        let urlRegex = "^http[s]{0,1}://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$"
        let test = NSPredicate(format: "SELF MATCHES %@", urlRegex)
        return test.evaluate(with: url)
    
    }
    
    /// 判断字符串是合法字符(仅包含数字 字母 汉字)
    class func isIllegalCharacter(_ string: String) -> Bool {
        let regex = "^[A-Za-z0-9\\u4e00-\\u9fa5\\u278a-\\u2793]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: string)
    }
    
    // MARK: - Status bar retwork activity indicator
    
    class func showNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    class func hideNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: - MBProgressHUD
    
    class func bringMBProgressHUDToFront() {
        if sharedInstance.progressHUD != nil {
            kApp.window?.bringSubview(toFront: sharedInstance.progressHUD)
        }
    }
    class func showMBProgressHUDWithTxt(_ txt: String = "", dimBackground: Bool = false) {
        if sharedInstance.progressHUD == nil {
            sharedInstance.progressHUD = MBProgressHUD()
            kApp.window?.addSubview(sharedInstance.progressHUD)
        } else {
            kApp.window?.bringSubview(toFront: sharedInstance.progressHUD)
        }
        
        sharedInstance.progressHUD.mode = MBProgressHUDMode.indeterminate
        if let window = kApp.window {
           sharedInstance.progressHUD.center = CGPoint(x: window.frame.size.width / 2, y: window.frame.size.height / 2)
        }
        sharedInstance.progressHUD.label.text = txt
        sharedInstance.progressHUD.detailsLabel.text = nil
        sharedInstance.progressHUD.show(animated: true)
    }
    
    class func hideMBProgressHUD() {
        sharedInstance.progressHUD.hide(animated: true)
    }
    
    class func showMBProgressHUDToastWithTxt(_ txt: String!, customView: UIView? = nil, hideAfterDelay delay: TimeInterval! = 1.5) {
        
        if sharedInstance.progressHUD == nil {
            sharedInstance.progressHUD = MBProgressHUD()
            kApp.window?.addSubview(sharedInstance.progressHUD)
        } else {
            kApp.window?.bringSubview(toFront: sharedInstance.progressHUD)
        }
        if let window = kApp.window {
            sharedInstance.progressHUD.center = CGPoint(x: window.frame.size.width / 2, y: window.frame.size.height / 2)
        }
        if customView != nil {
            sharedInstance.progressHUD.mode = MBProgressHUDMode.customView
            sharedInstance.progressHUD.customView = customView
        } else {
            sharedInstance.progressHUD.mode = MBProgressHUDMode.text
//            sharedInstance.progressHUD.
            sharedInstance.progressHUD.margin = 20.0
        }
        sharedInstance.progressHUD.detailsLabel.text = txt
        sharedInstance.progressHUD.detailsLabel.font = UIFont.systemFont(ofSize: 16.0)
        sharedInstance.progressHUD.show(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            sharedInstance.progressHUD.hide(animated: true)
        }
    }

    // MARK: - color绘制img
    class func createImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: screenWidth/4, height: 49)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage ?? UIImage()
        
    }
    
    // MARK: - Number Formatter process
    class func currencyNumberFormatter(_ number: NSNumber) -> String {
        sharedInstance.numberFormatter.numberStyle = NumberFormatter.Style.currency
        sharedInstance.numberFormatter.currencySymbol = "￥"
        sharedInstance.numberFormatter.maximumFractionDigits = 2
        sharedInstance.numberFormatter.minimumFractionDigits = 2
        return sharedInstance.numberFormatter.string(from: number) ?? ""
    }

    class func micrometerNumberFormatter(_ number: NSNumber) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencySymbol = ""
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumFractionDigits = 0
        let str = numberFormatter.string(from: number) ?? ""
        return str
    }
    
}

extension Date {
    func toString(_ format: String? = "yyyy-MM-dd") -> String {
        let dateFmt = Utility.sharedInstance.dateFormatter
        dateFmt.timeZone = TimeZone.current
        if let fmt = format {
            dateFmt.dateFormat = fmt
        }
        return dateFmt.string(from: self)
    }
    
    func isSameDate(_ date: Date) -> Bool {
        return self.toString() == date.toString()
    }
}

class UserManager: NSObject {

    override init() {
        super.init()
    }
    
    var signedIn: Bool  = false 
    var incompleteStoreInfo: Bool = false
    var userInfo: MerchantInfo?
    var userFullName: String?
    var systemNoticeCount: Int = 0
    var userNoticeCount: Int = 0
    var loginType: LoginType = .boss
    var staffId = ""
    static let sharedInstance: UserManager = {
        let instance = UserManager()
        return instance
        }()
    
}
