//
//  PayCodeSettingViewController.swift
//  FPTrade
//
//  Created by Kuma on 9/26/15.
//  Copyright © 2015 Windward. All rights reserved.
//

import UIKit

// 提取密码操作类型
enum PayCodeSetType: Int {
    case inputCurrent         //修改支付密码-输入原始密码
    case inputNew             //修改支付密码-新密码
    case inputNewAgain        //修改支付密码-再次输入新密码
//    case ForgetAndSet         //修改支付密码-忘记密码后输入手机号验证码重置
}

class PayCodeSettingViewController: BaseViewController {
    var initialCodeType: PayCodeSetType = .inputCurrent    //操作类型（设置）
    var codeType: PayCodeSetType = .inputCurrent    //操作类型（设置）
    var resetParams: [String: String]?//已经获取
    @IBOutlet var securityPasswdTF: UITextField!
    @IBOutlet var star1: UILabel!
    @IBOutlet var star2: UILabel!
    @IBOutlet var star3: UILabel!
    @IBOutlet var star4: UILabel!
    @IBOutlet var star5: UILabel!
    @IBOutlet var star6: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var forgetCodeBtn: UIButton!
    
    var currentPayCode: String = ""
    var newPayCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "支付密码"
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "CommonBackButton"), style: .plain, target: self, action: #selector(self.backAction))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        forgetCodeBtn.isHidden = false
        forgetCodeBtn.setTitleColor(UIColor.commonBlueColor(), for: UIControlState())
        
        if UserManager.sharedInstance.userInfo?.settedPayPassward == "1" {
            codeType = .inputCurrent
        } else {
            codeType = .inputNew
        }
        initialCodeType = codeType
        
        self.initialViewType()
        securityPasswdTF.becomeFirstResponder()
    }
    
    func initialViewType() {
        switch codeType {
        case .inputCurrent:
            self.descLabel.text = "请输入原密码"
            self.forgetCodeBtn.isHidden = false
        case .inputNew:
            self.descLabel.text = "请设置新密码"
            self.forgetCodeBtn.isHidden = true
        case .inputNewAgain:
            self.descLabel.text = "请再次输入新密码"
            self.forgetCodeBtn.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.passwordDidChange(_:)), name: Notification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func passwordDidChange(_ noti: Notification ) {
        
        if let _ = securityPasswdTF {
            self.changePasswordStar()
            guard let securityPasswdTF = securityPasswdTF else {return}
            if let pwd = securityPasswdTF.text {
                if pwd.characters.count < 6 {
                } else if pwd.characters.count == 6 {
                    securityPasswdTF.resignFirstResponder()
                } else {
                    securityPasswdTF.text = pwd.substring(to: pwd.characters.index(pwd.startIndex, offsetBy: 6))
                    securityPasswdTF.resignFirstResponder()
                }
            }
        }
    }
    
    func changePasswordStar() {
        guard let securityPasswdTF = securityPasswdTF else {return}
        if let pwd = securityPasswdTF.text {
            let textLength = min(pwd.characters.count, 6)
            guard let star1 = star1 else {return}
            guard let star2 = star2 else {return}
            guard let star3 = star3 else {return}
            guard let star4 = star4 else {return}
            guard let star5 = star5 else {return}
            guard let star6 = star6 else {return}
            
            star1.isHidden = true
            star2.isHidden = true
            star3.isHidden = true
            star4.isHidden = true
            star5.isHidden = true
            star6.isHidden = true
            
            switch textLength {
            case 6:
                star6.isHidden = false
                validInputPassword()
                fallthrough
            case 5:
                star5.isHidden = false
                fallthrough
            case 4:
                star4.isHidden = false
                fallthrough
            case 3:
                star3.isHidden = false
                fallthrough
            case 2:
                star2.isHidden = false
                fallthrough
            case 1:
                star1.isHidden = false
            default:
                break
            }
        }
    }
    
    func inputCurrentPasswordNextStep() {
        guard let securityPasswdtext = securityPasswdTF.text else {return}
        if securityPasswdtext.isEmpty {
            Utility.showMBProgressHUDToastWithTxt("请输入原支付密码")
            return
        }
        if securityPasswdtext.characters.count != 6 {
            Utility.showMBProgressHUDToastWithTxt("当前密码不为6位")
            return
        }
        
        currentPayCode = securityPasswdtext
        securityPasswdTF.text = ""
        changePasswordStar()
        
        securityPasswdTF.resignFirstResponder()
        
        requestCheckPayCode()
    }
    
    func valiadCurrentPayCodeSucceed() {
        codeType = .inputNew
        initialViewType()
        
        securityPasswdTF.text = ""
        changePasswordStar()
        securityPasswdTF.becomeFirstResponder()
    }
    
    func inputNewPasswordNextStep() {
        guard let securityPasswdtext = securityPasswdTF.text else {return}
        securityPasswdTF.text = Utility.getTextByTrim(securityPasswdTF.text ?? "")
        if securityPasswdtext.isEmpty {
            Utility.showMBProgressHUDToastWithTxt("请输入新密码")
            return
        }
        if securityPasswdtext.characters.count != 6 {
            Utility.showMBProgressHUDToastWithTxt("当前密码不为6位")
            return
        }
        
        newPayCode = securityPasswdtext
        codeType = .inputNewAgain
        initialViewType()
        
        securityPasswdTF.text = ""
        changePasswordStar()
        securityPasswdTF.becomeFirstResponder()
    }
    
    func inputNewPasswordDone() {
        guard let securityPasswdtext = securityPasswdTF.text else {return}
        securityPasswdTF.text = Utility.getTextByTrim(securityPasswdTF.text ?? "")
        if securityPasswdtext.isEmpty {
            Utility.showMBProgressHUDToastWithTxt("请输入新密码")
            return
        }
        if securityPasswdTF.text?.characters.count != 6 {
            Utility.showMBProgressHUDToastWithTxt("当前密码不为6位")
            return
        }
        
        if securityPasswdTF.text != newPayCode {
            Utility.showAlert(self, message: "两次输入的新密码不一致，请重试", dismissCompletion: {
                self.codeType = .inputNewAgain
                self.initialViewType()
                self.securityPasswdTF.text = ""
                self.changePasswordStar()
                self.securityPasswdTF.becomeFirstResponder()
            })
            return
        }
        
        setupPayCode()
    }
    
    // MARK: - Http request
    
    func requestCheckPayCode() {
        
        let parameters: [String: AnyObject] = [
            "pay_password": currentPayCode as AnyObject]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantCheckPaypassword(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                self.valiadCurrentPayCodeSucceed()
            } else {
                
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
        
    }

    func setupPayCode() {
        var request: AFMRequest!
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        if initialCodeType == .inputNew {
            
            guard let pwdMd5 = securityPasswdTF.text else {return}
            let params = ["pay_password": pwdMd5]
            request = AFMRequest.merchantSetPaypassword(params, aesKey, aesIV)
        } else if initialCodeType == .inputCurrent {
            let oldPwdMd5 = currentPayCode
            guard let newPwdMd5 = securityPasswdTF.text else {return}
            let params = ["ori_pay_password": oldPwdMd5, "new_pay_password": newPwdMd5]
            request = AFMRequest.merchantUpdatePayPassword(params, aesKey, aesIV)
        }
        
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV), completionHandler: { (request, response, object, error, msg) -> Void in
            if error == nil {
                UserManager.sharedInstance.userInfo?.settedPayPassward = "1"
                Utility.showMBProgressHUDToastWithTxt("设置成功")
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                guard let error = error else {return}
                if let msg = error.userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        })
    }
    
    @IBAction func passwordTfClicked(_ sender: UIButton) {
        securityPasswdTF.becomeFirstResponder()
    }

    @IBAction func forgetCodeAction(_ sender: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("PayCodeForget@CenterSettings", source: self, sender: nil)
    }
    
    func backAction() {
        switch codeType {
        case .inputCurrent:
            _ = navigationController?.popViewController(animated: true)
        case .inputNew:
            codeType = .inputCurrent
            securityPasswdTF.text = ""
            currentPayCode = ""
            newPayCode = ""
            changePasswordStar()
        case .inputNewAgain:
            codeType = .inputNew
            securityPasswdTF.text = ""
            newPayCode = ""
            changePasswordStar()
        }
        
        initialViewType()
    }

    private func validInputPassword() {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline:  DispatchTime.now() + 1) {
            switch self.codeType {
            case .inputCurrent:
                self.inputCurrentPasswordNextStep()
            case .inputNew:
                self.inputNewPasswordNextStep()
                break
            case .inputNewAgain:
                self.inputNewPasswordDone()
                
            }
        }
    }
}
