//
//  AddReduceViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class AddReduceViewController: BaseViewController {

    @IBOutlet weak var activeNameTextField: UITextField!
    @IBOutlet weak var satisfyTextField: UITextField!
    @IBOutlet weak var reduceTextField: UITextField!
    @IBOutlet weak var maxPreferentialTextField: UITextField!
    @IBOutlet weak var useRuleTextView: UITextView!
    @IBOutlet weak var placherHodelLabel: UILabel!
    
    var rule: String = ""
    var maxPri = ""
    var privilegeInfo: PrivilegeRuleInfo?
    var id = ""
    var ruleInfo: PrivilegeRuleInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
          setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let rule = ruleInfo else {return}
        activeNameTextField.text = rule.privilegeName
        useRuleTextView.text = rule.rule
        maxPreferentialTextField.text = "\(Int(Float(rule.topPrivilege) ?? 0))"
        satisfyTextField.text = "\(Int(Float(rule.fullSum) ?? 0))"
        reduceTextField.text = "\(Int(Float(rule.minusSum) ?? 0))"
        placherHodelLabel.isHidden = true
        useRuleTextView.textColor = UIColor.black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.y = 64
        }) 
    }
    
    private func setupUI() {
        setBarButtonItem()
        title = "满减新增"
        satisfyTextField.delegate = self
        reduceTextField.delegate = self
        maxPreferentialTextField.delegate = self
        useRuleTextView.delegate = self
    }
    
}

extension AddReduceViewController {
    
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
        guard let full = self.satisfyTextField.text else {
            Utility.showAlert(self, message: "请填写满额")
            return
        }
        guard let _ = Float(full) else {
            Utility.showAlert(self, message: "请填写正确的满额")
            return
        }
        guard let minus = self.reduceTextField.text else {
            Utility.showAlert(self, message: "请填写减额")
            return
        }
        guard let _ = Float(minus) else {
            Utility.showAlert(self, message: "请填写正确的减额")
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
            "type": "2" as AnyObject,
             "privilege_name": activeName as AnyObject,
             "full_sum": full as AnyObject,
             "minus_sum": minus as AnyObject,
             "top_privilege": (maxPri == "" ? "9999" : maxPri) as AnyObject,
             "rule": rule as AnyObject
            ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.privilegeAddRule(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
             if let _ = object as? [String: Any] {
                Utility.hideMBProgressHUD()
                if self.title == "满减编辑" {
                    Utility.showAlert(self, message: "编辑成功", dismissCompletion: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue:"addNewReducePrivilege"), object: self, userInfo: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    Utility.showAlert(self, message: "添加成功", dismissCompletion: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue:"addNewReducePrivilege"), object: self, userInfo: nil)
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

extension AddReduceViewController: UITextViewDelegate, UITextFieldDelegate {
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
        if textField == maxPreferentialTextField {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.y = -50
            })
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == satisfyTextField || textField == reduceTextField || textField == maxPreferentialTextField {
            if let text = textField.text {
                var input = text
                input.append(string)
                if input.characters.count > 4 {
                    return false
                }
                return true
            }
        }
        return true
    }
}
