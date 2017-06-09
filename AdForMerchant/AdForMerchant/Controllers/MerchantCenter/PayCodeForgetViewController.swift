//
//  PayCodeForgetViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 5/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class PayCodeForgetViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tbvLeadingCons: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tbvWidthCont: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var pageView: UIView!
    @IBOutlet fileprivate weak var pageView2: UIView!
    
    @IBOutlet fileprivate weak var captchaButton: UIButton!
    @IBOutlet fileprivate weak var secureToggleButton: UIButton!
    @IBOutlet fileprivate weak var mobileTextField: UITextField!
    @IBOutlet fileprivate weak var captchaTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    
    var captchaAlert: CustomIOSAlertView?
    var captchaImgView: UIImageView?
    var captchaCodeTF: UITextField?
    var captchaCode: String?
    var captchaImg: UIImage?
    
    var activateCaptchaCount: Int = 0
    
    @IBOutlet var currentPwdTxtField: UITextField!
    @IBOutlet fileprivate weak var secureToggleButton2: UIButton!
    
    @IBOutlet fileprivate weak var stepViewBg: UIView!
    fileprivate var stepView: StepPageControl!
    
    @IBOutlet fileprivate weak var nextStepButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "CommonBackButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
        view.backgroundColor = UIColor.backgroundLightGreyColor()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandle)))
        mobileTextField.keyboardType = .numberPad
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = UITextAutocapitalizationType.none
        passwordTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.spellCheckingType = UITextSpellCheckingType.no
        captchaButton.addTarget(self, action: #selector(SignUpViewController.requestCaptcha), for: .touchUpInside)
        
        secureToggleButton.isSelected = true
        secureToggleButton.addTarget(self, action: #selector(self.secureToggleSwitch(_:)), for: .touchUpInside)
        
        secureToggleButton2.isSelected = true
        secureToggleButton2.addTarget(self, action: #selector(self.secureToggleSwitch(_:)), for: .touchUpInside)
        
        currentPwdTxtField.keyboardType = .numberPad
        currentPwdTxtField.isSecureTextEntry = true
        currentPwdTxtField.delegate = self
        
        stepView = StepPageControl(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
        stepView.stepTitleArray = ["验证身份", "设置新密码"]
        stepViewBg.addSubview(stepView)
        changePageStyle()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        tbvWidthCont.constant = self.view.frame.size.width
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: - Private
    
    func moveToPageIndex(_ pageIndex: Int) {
        let width: CGFloat = self.view.frame.size.width
        
        if pageIndex != self.currentPage {
            if pageIndex > 1 || pageIndex < 0 {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.tbvLeadingCons.constant = -CGFloat(self.currentPage) * width
                    self.view.layoutIfNeeded()
                })
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tbvLeadingCons.constant = -CGFloat(pageIndex) * width
                self.view.layoutIfNeeded()
                self.currentPage = pageIndex
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tbvLeadingCons.constant = -CGFloat(self.currentPage) * width
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func changePageStyle() {
        
        stepView.selectSubVeiwByIndex(currentPage)
        switch currentPage {
        case 0:
            
            navigationItem.title = "找回支付密码"
            nextStepButton.setTitle("下一步", for: UIControlState())
        case 1:
            navigationItem.title = "找回支付密码"
            nextStepButton.setTitle("确认", for: UIControlState())
        default:
            break
        }
    }
    
    func validateInputValue() -> Bool {
        
        guard let captchaText = captchaTextField.text else {return false}
        guard let passwordText = passwordTextField.text else {return false}
        guard let currentPwdText = currentPwdTxtField.text else {return false}

        switch currentPage {
        case 0:
            if !Utility.isValidateMobile(mobileTextField.text) {
                Utility.showAlert(self, message: "请输入正确的手机号")
                return false
            }
            if captchaText.isEmpty {
                Utility.showAlert(self, message: "请输入验证码")
                return false
            }
            if passwordText.isEmpty {
                Utility.showAlert(self, message: "请输入登录密码")
                return false
            }
        case 1:
            if currentPwdText.isEmpty {
                Utility.showAlert(self, message: "请输入新的支付密码")
                return false
            }
            if currentPwdText.characters.count != 6 {
                Utility.showAlert(self, message: "当前新密码不为6位")
                return false
            }
        default:
            break
        }
        return true
    }
    
    var currentPage: Int = 0 {
        didSet {
            changePageStyle()
            moveToPageIndex(self.currentPage)
        }
    }
    
    func backAction() {
        if self.currentPage == 0 {
            _ = navigationController?.popViewController(animated: true)
        } else {
            self.currentPage -= 1
        }
    }
    
    @IBAction func nextStepAction(_ sender: UIButton) {
        if self.currentPage == 0 {
            guard validateInputValue() else {
                return
            }
            requestRestPayCodeStepOne()
        } else {
            guard validateInputValue() else {
                return
            }
            requestRestPayCodeStepTwo()
        }
    }
    
    // MARK: - Actions, Methods
    
    func secureToggleSwitch(_ btn: UIButton) {
        if btn == secureToggleButton {
            secureToggleButton.isSelected = !secureToggleButton.isSelected
            passwordTextField.isSecureTextEntry = secureToggleButton.isSelected
        } else if btn == secureToggleButton2 {
            secureToggleButton2.isSelected = !secureToggleButton2.isSelected
            currentPwdTxtField.isSecureTextEntry = secureToggleButton2.isSelected
        }
    }
    
    func selectAgreementAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    
    func showAgreementDetailAction(_ btn: UIButton) {
        performSegue(withIdentifier: "signupAgreementSegue", sender: nil)
    }
    
    @IBAction func requestCaptcha() {
        captchaButton.isEnabled = false
        mobileTextField.resignFirstResponder()
        if let str = mobileTextField.text, Utility.isValidateMobile(str) {
            // check is used
            
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
            guard let mobileText = mobileTextField.text else {return}
            RequestManager.request(AFMRequest.captchaImgCode(["mobile": mobileText, "type": "3"], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) -> Void in
                
                self.captchaButton.isEnabled = true
                if let m = msg {
                    if msg != "" {
                        Utility.showAlert(self, message: m)
                        return
                    }
                    if let _ = error {
                        
                    } else if let data = object as? [String : Any], let imgData64 = data["img_data"] as? String {
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
    
    @IBAction func toggleSecurityShown(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func tapGestureHandle() {
        view.endEditing(true)
    }
    
    // MARK: - Captcha Image
    
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
        guard let captchaCodeTF = captchaCodeTF else {return UIView()}
        captchaCodeTF.becomeFirstResponder()
        
        return codeView
    }
    
    func tapCaptchaImg() {
        requestCaptcha()
    }
    
    // MARK: - Http request
    
    func requestValidateCaptcha() {
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        guard let mobile = mobileTextField.text else {return}
        guard let captchaCode = captchaCode else {return}
            RequestManager.request(AFMRequest.captchaCheckImgCode(["mobile": mobile, "type": "3", "img_code": captchaCode], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
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
    
    func requestRestPayCodeStepOne() {
        
        guard let mobileTextField = mobileTextField else {return}
        guard let passwordTextField = passwordTextField else {return}
        guard let captchaTextField = captchaTextField else {return}
        
        let parameters: [String: AnyObject] = [
            "mobile": mobileTextField.text as AnyObject,
            "password": passwordTextField.text as AnyObject,
            "verify_code": captchaTextField.text as AnyObject]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantResetPayPasswordStepOne(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                self.currentPage += 1
            } else {
                
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestRestPayCodeStepTwo() {
        guard let currentPwdTxtField = currentPwdTxtField else {return}
        let parameters: [String: AnyObject] = [
            "new_pay_password": currentPwdTxtField.text as AnyObject,
            "confirm_pay_password": currentPwdTxtField.text as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantResetPayPasswordStepTwo(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                Utility.showAlert(self, message: "修改成功", dismissCompletion: {
                    guard let vcs = self.navigationController?.viewControllers else {return}
                    _ = self.navigationController?.popToViewController(vcs[vcs.count - 3], animated: true)
                })
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }

}

extension PayCodeForgetViewController: CustomIOSAlertViewDelegate {
    // MARK: - Custom iOS Alert view delegate
    func customIOS7dialogButtonTouchUp(inside alertView: Any!, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            captchaAlert = nil
            captchaImg = nil
            captchaImgView = nil
            guard let alertView = (alertView as? CustomIOSAlertView) else {return}
            alertView.close()
        case 1:
            
            if let pwd = captchaCodeTF?.text {
                captchaCode = Utility.getTextByTrim(pwd)
            } else {
                captchaCode = ""
            }
            guard let captchaCodeTF = captchaCodeTF else {return}
            guard let captchaCode = captchaCode else {return}
            captchaCodeTF.text = captchaCode
            if captchaCode.isEmpty {
                Utility.showMBProgressHUDToastWithTxt("请输入图形验证码")
                return
            }
            
            requestValidateCaptcha()
        default:
            break
        }
    }
}

extension PayCodeForgetViewController: UITextFieldDelegate {
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return false}
        if text.characters.count - range.length + string.characters.count > 6 {
            return false
        }
        return true
    
    }
}
