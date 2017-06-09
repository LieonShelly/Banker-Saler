//
//  SignInViewController.swift
//  FPTrade
//
//  Created by Ryuukou on 6/9/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var mobileTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var forgetButton: UIButton!
    @IBOutlet fileprivate weak var secureToggleButton: UIButton!
    
    fileprivate var loginParams: [String : String] = Dictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "登录"
        
        view.backgroundColor = UIColor.backgroundLightGreyColor()
        
        let rightBarItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.signupHandle))
        navigationItem.rightBarButtonItem = rightBarItem
        
        mobileTextField.keyboardType = .numberPad
        mobileTextField.addTarget(self, action: #selector(self.mobileTextFieldEditingChanged(_:)), for: UIControlEvents.editingChanged)
        mobileTextField.delegate = self
        
        //  forget button
        let text = "忘记密码?" as NSString
        
        let attrText = NSMutableAttributedString(string: text as String)
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("#A7A7A7"), range: NSRange(location: 0, length: text.length) )
        attrText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16.0), range: NSRange(location: 0, length: text.length))
        forgetButton.setAttributedTitle(attrText, for: UIControlState())
        forgetButton.addTarget(self, action: #selector(self.forgetPassHandle), for: .touchUpInside)
        
        passwordTextField.isSecureTextEntry = true
        secureToggleButton.isSelected = true
        secureToggleButton.addTarget(self, action: #selector(self.secureToggleSwitch), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let mobile = UserDefaults.standard.value(forKey: kSessionAccount) as? String {
            mobileTextField.text = mobile
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForgetPassSegue" {
        } else if segue.identifier == "SignupSegue" {
        } else if segue.identifier == "ShopCreate@MerchantCenter" {
            guard let desVC = segue.destination as? ShopCreateViewController else { return }
            desVC.phone = mobileTextField.text ?? ""
        }
    }
    
    @IBAction func signupHandle() {
        performSegue(withIdentifier: "SignupSegue", sender: self)
    }
    
    @IBAction func forgetPassHandle() {
        performSegue(withIdentifier: "ForgetPassSegue", sender: nil)
    }
    
    @IBAction func closeHandle() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapGestureHandle() {
        view.endEditing(true)
    }
    
    @IBAction func signinHandle() {
        if mobileTextField.text == nil || (mobileTextField.text ?? "").isEmpty {
            Utility.showAlert(self, message: "请输入手机号码")
            return
        }
        
        if !Utility.isValidateMobile(mobileTextField.text ?? "") {
            Utility.showAlert(self, message: "请输入正确的手机号码")
            return
        }
        
        if (passwordTextField.text ?? "").isEmpty {
            Utility.showAlert(self, message: "请输入密码")
            return
        }
        
        //  login
        view.endEditing(true)
        // TODO: 登录时密码如何加密
        Utility.showMBProgressHUDWithTxt()
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
         guard let mobileText = mobileTextField.text, let pwd = passwordTextField.text else { return  }
        RequestManager.request(AFMRequest.merchantLogin(["mobile": mobileText, "password": pwd], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
            if (object) != nil {
                if let result = object as? [String: String] {
                    let token = result["token"]
                    // TODO: login session
                    let userDef = UserDefaults.standard
                    userDef.setValue(token, forKey: kToken)
                    userDef.setValue(self.mobileTextField.text, forKey: kSessionAccount)
                    userDef.synchronize()
                    AFMRequest.OAuthToken = token
                    UserManager.sharedInstance.signedIn = true
                    //FIXME:用API上传token
                    // // update api ---registerID
                    if let pushToken = Common.AppConfig.applePushToken, let regisetrID = Common.AppConfig.registrationID {
                        NotificationAndMessageController.save(pushToken: pushToken, registerID: regisetrID)
                    }
                    kApp.starTimer()
                    if result["staff_id"]! == "0" {
                        self.requestUserInfo()
                        kApp.starNoticeTiemr()
                        UserManager.sharedInstance.loginType = .boss
                    } else {
                        UserManager.sharedInstance.staffId = result["staff_id"]!
                        Utility.showMBProgressHUDWithTxt()
                        UserManager.sharedInstance.loginType = .clerk
                        let vc = UIStoryboard(name: "ClerksCenter", bundle: nil).instantiateInitialViewController()
                        UIApplication.shared.keyWindow?.rootViewController = vc
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
}

extension SignInViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text: String = ""
        if let cText = textField.text {
            text = cText
        }
        let currentText = text as NSString
        let char = string.cString(using: .utf8)
        let isBackSpace = strcmp(char, "\\b")
        if Utility.isOnlyNumber(string) {
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            return updatedText.characters.count <= 11
        } else if isBackSpace == -92 {
            return true
        } else {
            return false
        }
    }
}

extension SignInViewController {
    func requestUserInfo() {
        Utility.showMBProgressHUDWithTxt()
        
        kApp.requestUserInfoWithCompleteBlock({
            Utility.hideMBProgressHUD()
            if UserManager.sharedInstance.userInfo?.haveAddedStore == true {
                UserManager.sharedInstance.incompleteStoreInfo = false
                self.dismiss(animated: true, completion: { () -> Void in
                    
                })
            } else {
                UserManager.sharedInstance.incompleteStoreInfo = true
                AOLinkedStoryboardSegue.performWithIdentifier("ShopCreate@MerchantCenter", source: self, sender: nil)
            }
        }, failedBlock: {
            Utility.hideMBProgressHUD()
        })
        NotificationCenter.default.post(name: Notification.Name(rawValue: refreshMerchantInfoNotification), object: nil)
        
    }
    
    func mobileTextFieldEditingChanged(_ textField: UITextField) {
//        guard let chars = textField.text?.characters else { return  }
//        if chars.count > 11 {
//            guard let startIndex = textField.text?.startIndex else { return  }
//            let index = chars.index(startIndex, offsetBy: 11)
//            textField.text = textField.text?.substring(to: index)
//        }
    }
    
    func secureToggleSwitch() {
        secureToggleButton.isSelected = !secureToggleButton.isSelected
        passwordTextField.isSecureTextEntry = secureToggleButton.isSelected
    }
}
