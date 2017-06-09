//
//  AddDiscountViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class AddDiscountViewController: BaseViewController {

    @IBOutlet weak var activeNameTextField: UITextField!
    @IBOutlet weak var discountTextField: UITextField!
    @IBOutlet weak var maxPreferentialTextField: UITextField!
    @IBOutlet weak var useRuleTextView: UITextView!
    @IBOutlet weak var placherHodelLabel: UILabel!

    var rule: String = ""
    var maxPri = ""
    var id = ""
    var ruleInfo: PrivilegeRuleInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarButtonItem()
        maxPreferentialTextField.delegate = self
        useRuleTextView.delegate = self
        discountTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let rule = ruleInfo else {return}
        activeNameTextField.text = rule.privilegeName
        useRuleTextView.text = rule.rule
        maxPreferentialTextField.text = "\( Int(Float(rule.topPrivilege) ?? 0))"
        discountTextField.text = rule.discount
        placherHodelLabel.isHidden = true
        useRuleTextView.textColor = UIColor.black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.y = 64
        }) 
    }
    
  }

extension AddDiscountViewController {
    func setupUI() {
        title = "折扣新增"
        UserDefaults.standard.set("", forKey: "rule")
    }
    func setBarButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(self.save))
    }

    func save() {
        guard let activeName = self.activeNameTextField.text else {
            Utility.showAlert(self, message: "请填写活动名称")
            return
        }
        if activeName.characters.count > 8 {
            Utility.showAlert(self, message: "活动名称规定8个字内")
            return
        }
        guard let discount = self.discountTextField.text else {
            Utility.showAlert(self, message: "请填写折扣")
            return
        }
        guard let _ = Float(discount) else {
            Utility.showAlert(self, message: "请填写正确的折扣")
            return
        }
        guard let rule = self.useRuleTextView.text else {
            Utility.showAlert(self, message: "请填写使用规则")
            return
        }
        if rule.characters.count > 400 {
            Utility.showAlert(self, message: "活动规则上限400个汉字")
            return
        }
        if let pre = maxPreferentialTextField.text {
           
            if pre.isEmpty {
                maxPri = ""
            } else {
                guard let _ = Int(pre == "" ? "0" : pre) else {
                    Utility.showAlert(self, message: "请填写正确的最高优惠金额")
                    return
                }
                maxPri = pre
            }
        }
        if rule.isEmpty {
            Utility.showAlert(self, message: "请填写使用规则")
            return
        }
        let params: [String: AnyObject] = [
            "privilege_id": self.id as AnyObject,
            "type": "1" as AnyObject,
            "privilege_name": activeName as AnyObject,
            "top_privilege": (maxPri == "" ? "9999" : maxPri) as AnyObject,
            "rule": rule as AnyObject,
            "discount": discount as AnyObject
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.privilegeAddRule(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if let _ = object as? [String: Any] {
                Utility.hideMBProgressHUD()
                if self.title == "折扣编辑" {
                    Utility.showAlert(self, message: "编辑成功", dismissCompletion: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "addNewReducePrivilege"), object: self, userInfo: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    Utility.showAlert(self, message: "添加成功", dismissCompletion: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "addNewReducePrivilege"), object: self, userInfo: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                }
            } else {
                Utility.hideMBProgressHUD()
                if let msg = error?.userInfo["message"] as? String {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
}

extension AddDiscountViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        placherHodelLabel.isHidden = true
        textView.textColor = UIColor.black
        UIView.animate(withDuration: 0.25, animations: {
            self.view.y = -100
        }) 
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placherHodelLabel.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count > 400 {
            textView.text = (textView.text as NSString).substring(to: 400)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField != discountTextField {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.y = -50
            })
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == discountTextField {
            let updatedString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string as String)
            if updatedString.characters.count > 3 {
                return false
            }
            if NSPredicate(format: "SELF MATCHES %@", "^([0-9]{1})+(.[0-9]{0})?$").evaluate(with: updatedString) {
                return true
            }
            if NSPredicate(format: "SELF MATCHES %@", "^([0-9]{1})+(.[0-9]{1})?$").evaluate(with: updatedString) {
                return true
            }
            if NSPredicate(format: "SELF MATCHES %@", "^.{0}$").evaluate(with: updatedString) {
                return true
            }
            return false
        }
        
        if textField == maxPreferentialTextField {
            let updatedString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string as String)
            if updatedString.characters.count > 4 {
                return false
            }
        }
        return true
    }
    
}
