//
//  CenterResetPasswordViewController.swift
//  FPTrade
//
//  Created by Kuma on 9/26/15.
//  Copyright © 2015 Windward. All rights reserved.
//
// swiftlint:disable type_name

import UIKit

class MerchantCenterResetPasswordViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var currentPwdTxtField: UITextField!
    @IBOutlet fileprivate weak var newPwdTxtField: UITextField!
    
    @IBOutlet fileprivate weak var secureToggleButton: UIButton!
    
    var params: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "修改登录密码"
        
        currentPwdTxtField.isSecureTextEntry = true
        newPwdTxtField.isSecureTextEntry = true
        
        secureToggleButton.isSelected = true
        secureToggleButton.addTarget(self, action: #selector(self.secureToggleSwitch(_:)), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.resignTF))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Private
    
    func resignTF() {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions, Methods
    
    func secureToggleSwitch(_ btn: UIButton) {
        if btn == secureToggleButton {
            secureToggleButton.isSelected = !secureToggleButton.isSelected
            newPwdTxtField.isSecureTextEntry = secureToggleButton.isSelected
        }
    }
    
    // MARK : - Http request
    
    func requestNewPwd() {
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        guard let currentPwdTxt = currentPwdTxtField.text else {return}
        guard let newPwdTxt = newPwdTxtField.text else {return}
        RequestManager.request(AFMRequest.merchantUpdatePassword(["ori_password": currentPwdTxt, "new_password": newPwdTxt], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if error == nil {
                Utility.hideMBProgressHUD()
                Utility.showAlert(self, message: "修改密码成功", dismissCompletion: {
                    _ = self.navigationController?.popViewController(animated: true)
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
    
    // MARK: - Button Action
    
    @IBAction func confirmAction() {
        self.view.endEditing(false)
        guard let currentPwdTxt = currentPwdTxtField.text else {return}
        guard let newPwdTxt = newPwdTxtField.text else {return}

        if currentPwdTxt.isEmpty {
            Utility.showAlert(self, message: "请输入原登录密码")
            return
        }
        if newPwdTxt.isEmpty {
            Utility.showAlert(self, message: "请输入新密码")
            return
        }
        if !Utility.isValidatePassword(newPwdTxtField.text) {
            Utility.showAlert(self, message: "登录密码应为6-16位英文字母、数字或字符")
            return
        }
        
        requestNewPwd()
        
    }
    
    @IBAction func forgetPasswordAction() {
        
        Utility.showConfirmAlert(self,
          title: "提示",
          cancelButtonTitle: "确认退出",
          confirmButtonTitle: "暂时不要",
          message: "此操作将退出账号，是否退出？",
          cancelCompletion: {
            self.signOut()
            },
          confirmCompletion: nil)
    }
    
    func signOut() {
        UserManager.sharedInstance.signedIn = false
        UserManager.sharedInstance.userInfo = nil
        kApp.needLogin()
    }
    
}
