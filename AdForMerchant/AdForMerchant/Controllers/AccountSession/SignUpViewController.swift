//
//  SignUpViewController.swift
//  FPTrade
//
//  Created by Ryuukou on 7/9/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController, CustomIOSAlertViewDelegate {
    
//    @IBOutlet private weak var signupViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var captchaButton: UIButton!
    @IBOutlet fileprivate weak var secureToggleButton: UIButton!
    @IBOutlet fileprivate weak var mobileTextField: UITextField!
    @IBOutlet fileprivate weak var captchaTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!

    @IBOutlet fileprivate weak var agreementSelectedButton: UIButton!
    @IBOutlet fileprivate weak var agreementDetailButton: UIButton!
    
    var captchaAlert: CustomIOSAlertView?
    var captchaImgView: UIImageView?
    var captchaCodeTF: UITextField?
    var captchaCode: String?
    var captchaImg: UIImage?
    
    var activateCaptchaCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "新用户注册"
        view.backgroundColor = UIColor.backgroundLightGreyColor()
        
        let rightBarItem = UIBarButtonItem(title: "帮助", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showHelpPage))
        navigationItem.rightBarButtonItem = rightBarItem
        
        mobileTextField.keyboardType = .numberPad
        mobileTextField.addTarget(self, action: #selector(self.mobileTextFieldEditingChanged(_:)), for: UIControlEvents.editingChanged)
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = UITextAutocapitalizationType.none
        passwordTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.spellCheckingType = UITextSpellCheckingType.no
        
        captchaButton.addTarget(self, action: #selector(SignUpViewController.requestCaptcha), for: .touchUpInside)
        
        let text = "同意《商家入驻协议》" as NSString

        let attrText = NSMutableAttributedString(string: text as String)
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.commonBlueColor(), range: NSRange(location: 0, length: text.length))
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("#9498A9"), range: NSRange(location: 0, length: ("同意" as NSString).length))
        attrText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14.0), range: NSRange(location: 0, length: text.length))
        agreementDetailButton.setAttributedTitle(attrText, for: UIControlState())
        agreementDetailButton.addTarget(self, action: #selector(SignUpViewController.showAgreementDetailAction(_:)), for: .touchUpInside)
        
        agreementSelectedButton.isSelected = true
        agreementSelectedButton.addTarget(self, action: #selector(SignUpViewController.selectAgreementAction(_:)), for: .touchUpInside)
        
        secureToggleButton.isSelected = true
        secureToggleButton.addTarget(self, action: #selector(self.secureToggleSwitch), for: .touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mobileTextField.addTarget(self, action: #selector(SignUpViewController.mobileTextChanged(_:)), for: UIControlEvents.editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signupAgreementSegue", let destVC = segue.destination as? CommonWebViewController {
            destVC.requestURL = WebviewAgreementTag.signup.detailUrl
            destVC.title = "商家入驻协议"
        } else if segue.identifier == "SignUpSucceed@AccountSession", let desVC = segue.destination as? SignUpSucceedViewController {
            desVC.phone = mobileTextField.text ?? ""
        }
    }
    
    @IBAction func requestCaptcha() {
        captchaButton.isEnabled = false
        mobileTextField.resignFirstResponder()
        if let str = mobileTextField.text, Utility.isValidateMobile(str) {
            // check is used
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
             guard let mobileText  = mobileTextField.text else { return  }
            RequestManager.request(AFMRequest.captchaImgCode(["mobile": mobileText, "type": "1"], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) -> Void in
                self.captchaButton.isEnabled = true
                if let m = msg {
                    if msg != "" {
                        Utility.showAlert(self, message: m)
                        return
                    }
                    if let _ = error {
                        
                    } else if let data = object as? [String : AnyObject], let imgData64 = data["img_data"] as? String {
//                            self.captchaTextField.text = captcha.stringValue
                        
                        if let imgData = Data(base64Encoded: imgData64, options: .ignoreUnknownCharacters) {
                            self.captchaImg = UIImage(data: imgData)
                            
                        }
                        
                        if self.captchaImgView != nil {
                            self.captchaImgView?.image = self.captchaImg
                        } else {
                            self.showCaptchaCodeAction()
                        }
                        
                    }
                }
            })
        } else {
            captchaButton.isEnabled = true
            Utility.showAlert(self, message: "请输入正确的手机号码")
        }
    }
    
    @IBAction func toggleSecurityShown(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func tapGestureHandle() {
        view.endEditing(true)
    }
    
    @IBAction func signupHandle() {
        if mobileTextField.text == nil || !Utility.isValidateMobile(mobileTextField.text ?? "") {
            Utility.showAlert(self, message: "请输入正确的手机号码")
            return
        }
        
        if captchaTextField.text == nil || (captchaTextField.text
            ?? "").isEmpty {
            Utility.showAlert(self, message: "请输入验证码")
            return
        }
        
        if passwordTextField.text == nil || (passwordTextField.text ?? "").isEmpty {
            Utility.showAlert(self, message: "请输入密码")
            return
        }
        
        if !Utility.isValidatePassword(passwordTextField.text ?? "" ) {
            Utility.showAlert(self, message: "密码应为6-16位英文字母、数字或字符")
            return
        }
        
        if !agreementSelectedButton.isSelected {
            Utility.showAlert(self, message: "请同意商家入驻协议")
            return
        }
        
        view.endEditing(true)
        // TODO: 登录时密码如何加密
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
      guard  let mobileText = mobileTextField.text, let password = passwordTextField.text, let captext = captchaTextField.text else { return }
        RequestManager.request(AFMRequest.merchantRegist(["mobile": mobileText, "password": password, "verify_code": captext], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
                if let result = object as? [String: String] {
                    let token = result["token"]
                    // TODO: login session
                    let userDef = UserDefaults.standard
                    userDef.setValue(token, forKey: kToken)
                    userDef.synchronize()
                    AFMRequest.OAuthToken = token
                    UserManager.sharedInstance.signedIn = true
                    UserManager.sharedInstance.incompleteStoreInfo = true
                    
                    AOLinkedStoryboardSegue.performWithIdentifier("SignUpSucceed@AccountSession", source: self, sender: nil)
                }
            } else {
                if let m = msg {
                    Utility.showAlert(self, message: m)
                }
                
            }
        })
    }
    
    @IBAction func showCaptchaCodeAction() {
        captchaAlert?.close()
        captchaAlert = nil
        
        let codeAlertView = CustomIOSAlertView()
        codeAlertView?.containerView = loginCodeView()
        codeAlertView?.delegate = self
        codeAlertView?.buttonTitles = ["取消", "确定"]
        codeAlertView?.useMotionEffects = true
        codeAlertView?.show()
        captchaAlert = codeAlertView
    }
}

extension SignUpViewController {
    func showHelpPage() {
        guard  let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else {  return }
        helpWebVC.requestURL = WebviewHelpDetailTag.signup.detailUrl
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func mobileTextFieldEditingChanged(_ textField: UITextField) {
        guard let chars = textField.text?.characters else { return  }
        if chars.count > 11, let startIndex = textField.text?.startIndex {
            guard let index = textField.text?.characters.index(startIndex, offsetBy: 11) else { return  }
            textField.text = textField.text?.substring(to: index)
        }
    }
    
    func secureToggleSwitch() {
        secureToggleButton.isSelected = !secureToggleButton.isSelected
        passwordTextField.isSecureTextEntry = secureToggleButton.isSelected
    }
    
    func selectAgreementAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    
    func showAgreementDetailAction(_ btn: UIButton) {
        performSegue(withIdentifier: "signupAgreementSegue", sender: nil)
    }
    
    func activeCaptchaButton(_ timer: Timer) {
        activateCaptchaCount += 1
        if activateCaptchaCount >= 60 {
            captchaButton.setTitle("获取验证码", for: UIControlState())
            captchaButton.isEnabled = true
            timer.invalidate()
            return
        }
        captchaButton.isEnabled = false
        captchaButton.setTitle("\(60 - activateCaptchaCount)秒后重发", for: UIControlState())
    }
    
    func loginCodeView() -> UIView {
        
        let viewWidth = screenWidth / 5 * 4
        let titilWidth = viewWidth / 2
        
        let codeView = UIView(frame:CGRect(x: 0, y: 0, width: viewWidth, height: 174))//30+20+60
        //        codeView.backgroundColor = UIColor.whiteColor()
        let titleLabel = UILabel(frame:CGRect(x: viewWidth / 2 - titilWidth / 2, y: 0, width: titilWidth, height: 36))
        titleLabel.text = "图形验证"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        codeView.addSubview(titleLabel)
        let starBgView = UIImageView(frame:CGRect(x: 0, y: 36, width: viewWidth, height: 85))
        starBgView.clipsToBounds = true
        starBgView.backgroundColor = UIColor.black
        starBgView.contentMode = .scaleAspectFit
        starBgView.image = captchaImg
        starBgView.isUserInteractionEnabled = true
        starBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapCaptchaImg)))
        codeView.addSubview(starBgView)
        captchaImgView = starBgView
        
        let codeTfd = UITextField(frame:CGRect(x: 20, y: starBgView.frame.maxY + 8, width: viewWidth - 40, height: 40))
        codeTfd.backgroundColor = UIColor.commonBgColor()
        codeTfd.borderStyle = UITextBorderStyle.none
        codeTfd.placeholder = "请输入上图答案"
        codeTfd.keyboardType = UIKeyboardType.asciiCapable
        codeTfd.autocapitalizationType = .none
        codeTfd.autocorrectionType = .no
        codeView.addSubview(codeTfd)
        captchaCodeTF = codeTfd
        captchaCodeTF?.becomeFirstResponder()
        
        return codeView
    }
    
    func tapCaptchaImg() {
        requestCaptcha()
    }
    
    func requestValidateCaptcha() {
        
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        guard  let mobileText = mobileTextField.text, let captext = captchaCode else { return }
        RequestManager.request(AFMRequest.captchaCheckImgCode(["mobile": mobileText, "type": "1", "img_code": captext], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
            if (object) != nil {
                if let _ = object as? [String: String] {
                    self.captchaAlert?.close()
                    self.captchaAlert = nil
                    self.captchaImg = nil
                    self.captchaImgView = nil
                    
                    Utility.showMBProgressHUDToastWithTxt("验证码发送成功", customView: nil, hideAfterDelay: 1.0)
                    
                    self.captchaButton.isEnabled = false
                    self.activateCaptchaCount = 0
                    
                    _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SignUpViewController.activeCaptchaButton(_:)), userInfo: nil, repeats: true)
                }
            } else {
                self.tapCaptchaImg()
                if let m = msg {
                    Utility.showMBProgressHUDToastWithTxt(m)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        })
    }
    
    func mobileTextChanged(_ sender: UITextField) {
        secureToggleButton.isEnabled = !(sender.text ?? "").isEmpty
    }
    
    func customIOS7dialogButtonTouchUp(inside alertView: Any!, clickedButtonAt buttonIndex: Int) {
        guard let alter = alertView as? CustomIOSAlertView else { return  }
        switch buttonIndex {
        case 0:
            captchaAlert = nil
            captchaImg = nil
            captchaImgView = nil
            alter.close()
        case 1:
            
            if let pwd = captchaCodeTF?.text {
                captchaCode = Utility.getTextByTrim(pwd)
            } else {
                captchaCode = ""
            }
            captchaCodeTF?.text = captchaCode
            guard let captext = captchaCode else { return }
            if captext.isEmpty {
                Utility.showMBProgressHUDToastWithTxt("请输入图形验证码")
                return
            }
            
            requestValidateCaptcha()
        default:
            break
        }
    }
}
