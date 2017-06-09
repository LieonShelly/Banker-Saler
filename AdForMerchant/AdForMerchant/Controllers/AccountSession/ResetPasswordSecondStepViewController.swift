//
//  ResetPasswordSecondStepViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 6/7/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ResetPasswordSecondStepViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var payCodeBgViewTopConstr: NSLayoutConstraint!
    @IBOutlet fileprivate weak var payCodeBgView: UIView!
    @IBOutlet fileprivate weak var secureToggleButton: UIButton!
    @IBOutlet fileprivate weak var payCodeTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var commitButton: UIButton!
    
    var params: [String: AnyObject]!
    
    var isPayCodeSet: Bool = true
    var validatedHashValue: String = ""
    
    var haveIntial: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "重置登录密码"
        view.backgroundColor = UIColor.backgroundLightGreyColor()
        
        payCodeTextField.isSecureTextEntry = true
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = UITextAutocapitalizationType.none
        passwordTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.spellCheckingType = UITextSpellCheckingType.no
        
        commitButton.addTarget(self, action: #selector(self.commitHandle), for: .touchUpInside)
        
        secureToggleButton.isSelected = true
        secureToggleButton.addTarget(self, action: #selector(self.secureToggleSwitch), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isPayCodeSet {
            initialView()
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !isPayCodeSet {
            payCodeBgViewTopConstr.constant = -45
            payCodeBgView.isHidden = true
        }
    }
    
    @IBAction func tapGestureHandle() {
        view.endEditing(true)
    }
    
    @IBAction func commitHandle() {
        
        if passwordTextField.text == nil || (passwordTextField.text ?? "").isEmpty {
            Utility.showAlert(self, message: "请设置新密码")
            return
        }
        if !Utility.isValidatePassword(passwordTextField.text ?? "") {
            Utility.showAlert(self, message: "密码应为6-16位英文字母、数字或字符")
            return
        }
        
        if isPayCodeSet && (payCodeTextField.text == nil) {
            Utility.showAlert(self, message: "请输入支付密码")
            return
        }
        params["hash"] = validatedHashValue as AnyObject?
        params["new_password"] = passwordTextField.text as AnyObject?
        if isPayCodeSet {
            params["pay_password"] = payCodeTextField.text as AnyObject?
        }
        
        view.endEditing(true)
        // TODO: 登录时密码如何加密
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.merchantResetPasswordStepTwo(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                
                if let _ = object as? [String: String] {
                    let alertVC = UIAlertController(title: "提示", message: "恭喜你新密码设置成功", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                        guard  let ncArray = self.navigationController?.viewControllers else { return }
                        _ = self.navigationController?.popToViewController(ncArray[ncArray.count - 3], animated: true)
                    }))
                    self.present(alertVC, animated: true, completion: nil)
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
extension ResetPasswordSecondStepViewController {
    func initialView() {
        
        if haveIntial {
            return
        }
        haveIntial = true
        
        let text = "如忘记以上两种密码，请联系客服028-8569-5623" as NSString
        
        let textView = UITextView(frame: CGRect(x: 0, y: 30, width: screenWidth, height: 50))
        guard let url =  URL(string: "tel://028-85695623") else { return  }
        textView.backgroundColor = UIColor.clear
        let attributedText = NSMutableAttributedString(string: text as String, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonGrayTxtColor()])
        attributedText.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSLinkAttributeName: url], range: text.range(of: "028-8569-5623"))
        textView.attributedText = attributedText
        textView.textAlignment = .center
        textView.dataDetectorTypes = .link
        textView.isEditable = false
        
        let titleBg = UIView(frame: CGRect(x: 0, y: 90 + 64, width: screenWidth, height: 80))
        titleBg.addSubview(textView)
        
        view.addSubview(titleBg)
    }
    
    func secureToggleSwitch() {
        secureToggleButton.isSelected = !secureToggleButton.isSelected
        passwordTextField.isSecureTextEntry = secureToggleButton.isSelected
    }
}
