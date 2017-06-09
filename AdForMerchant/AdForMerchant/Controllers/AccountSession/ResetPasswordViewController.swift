//
//  ResetPasswordViewController.swift
//  FPTrade
//
//  Created by Ryuukou on 7/9/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

import Foundation

class ResetPasswordViewController: BaseViewController, CustomIOSAlertViewDelegate {
    
    @IBOutlet fileprivate weak var captchaButton: UIButton!
    @IBOutlet fileprivate weak var mobileTextField: UITextField!
    @IBOutlet fileprivate weak var captchaTextField: UITextField!
    
    @IBOutlet fileprivate weak var commitButton: UIButton!
    
    var captchaAlert: CustomIOSAlertView?
    var captchaImgView: UIImageView?
    var captchaCodeTF: UITextField?
    var captchaCode: String?
    var captchaImg: UIImage?
    
    var activateCaptchaCount: Int = 0
    var validatedHash: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "重置登录密码"
        view.backgroundColor = UIColor.backgroundLightGreyColor()
        let rightBarItem = UIBarButtonItem(title: "帮助", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showHelpPage))
        navigationItem.rightBarButtonItem = rightBarItem
        
        mobileTextField.keyboardType = .numberPad
        
        captchaButton.addTarget(self, action: #selector(self.requestCaptcha), for: .touchUpInside)
        commitButton.addTarget(self, action: #selector(self.commitHandle), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resetPassNextStepSegue", let destVC = segue.destination as? ResetPasswordSecondStepViewController {
            destVC.params = ["mobile": mobileTextField.text as AnyObject]
            destVC.isPayCodeSet = (sender as? Bool) ?? true
            destVC.validatedHashValue = validatedHash
        }
    }
    
    @IBAction func tapGestureHandle() {
        view.endEditing(true)
    }
    
    @IBAction func requestCaptcha() {
        captchaButton.isEnabled = false
        if let str = mobileTextField.text, Utility.isValidateMobile(str) {
            // check is used
            
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
            RequestManager.request(AFMRequest.captchaImgCode(["mobile": mobileTextField.text ?? "", "type": "2"], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) -> Void in
                self.captchaButton.isEnabled = true
                if let m = msg {
                    if msg != "" {
                        Utility.showAlert(self, message: m)
                        return
                    }
                    if let data = object as? [String : AnyObject], let imgData64 = data["img_data"] as? String {
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
            Utility.showAlert(self, message: "手机号格式不正确，请输入正确的手机号码")
        
        }
    }
    
    @IBAction func commitHandle() {
        if mobileTextField.text == nil || !Utility.isValidateMobile(mobileTextField.text ?? "") {
            Utility.showAlert(self, message: "请输入手机号码")
            return
        }
        
        if captchaTextField.text == nil || (captchaTextField.text ?? "").isEmpty {
            Utility.showAlert(self, message: "请输入验证码")
            return
        }
        
        view.endEditing(true)
        requestPayCodeSetted()
        
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

extension ResetPasswordViewController {
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
    
    func showHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else {  return }
        // help-忘记密码
        helpWebVC.requestURL = WebviewHelpDetailTag.noHelpTag.notagUrl
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func requestValidateCaptcha() {
        
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        guard let mobileText = mobileTextField.text, let capText = captchaCode else { return  }
        RequestManager.request(AFMRequest.captchaCheckImgCode(["mobile": mobileText, "type": "2", "img_code": capText], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
            if (object) != nil {
                if let _ = object as? [String: String] {
                    self.captchaAlert?.close()
                    self.captchaAlert = nil
                    self.captchaImg = nil
                    self.captchaImgView = nil
                    
                    Utility.showMBProgressHUDToastWithTxt("验证码发送成功", customView: nil, hideAfterDelay: 1.0)
                    
                    self.captchaButton.isEnabled = false
                    self.activateCaptchaCount = 0
                    
                    _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.activeCaptchaButton(_:)), userInfo: nil, repeats: true)
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
    
    func requestPayCodeSetted() {
        
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        guard let mobileText = mobileTextField.text, let capText = captchaTextField.text else { return  }
        RequestManager.request(AFMRequest.merchantResetPasswordStepOne(["mobile": mobileText, "verify_code": capText], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                if let responseObj = object as? [String: String] {
                    self.validatedHash = responseObj["hash"]!
                    if responseObj["setted_pay_password"] == "1" {
                        self.performSegue(withIdentifier: "resetPassNextStepSegue", sender: true)
                    } else {
                        self.performSegue(withIdentifier: "resetPassNextStepSegue", sender: false)
                    }
                }
            } else {
                Utility.hideMBProgressHUD()
                if let m = msg {
                    Utility.showAlert(self, message: m)
                }
                
            }
        })
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
            if (captchaCode ?? "").isEmpty {
                Utility.showMBProgressHUDToastWithTxt("请输入图形验证码")
                return
            }
            
            requestValidateCaptcha()
        default:
            break
        }
    }
    
    func loginCodeView() -> UIView {
        
        let viewWidth = screenWidth / 5 * 4
        let titilWidth = viewWidth / 2
        
        let codeView = UIView(frame:CGRect(x: 0, y: 0, width: viewWidth, height: 174))//30+20+60
        let titleLabel = UILabel(frame:CGRect(x: viewWidth / 2 - titilWidth / 2, y: 0, width: titilWidth, height: 36))
        titleLabel.text = "图形验证"
        titleLabel.textAlignment = .center
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
}
