//
//  VerifyasswordViewController.swift
//  AdForMerchant
//
//  Created by 糖otk on 2017/2/27.
//  Copyright © 2017年 Windward. All rights reserved.
//
// swiftlint:disable empty_count
// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast

import UIKit
import MBProgressHUD

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}
/// 支付用途
public enum VerifyPayPassType {
    // 积分充值支付密码
    case rechargePoint
    /// 仅验证支付密码
    case verify
}

/// 验证码状态
public enum CodeStatus {
    /// 允许发送
    case allow
    /// 等待60s
    case wait
}

public enum VerifyPayPassResult {
    case passed
    case failed
    case canceled
}

class VerifypasswordViewController: BaseViewController {
    let pwdCount = 6

    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet fileprivate var dotLabels: [UILabel]!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet var payView: UIView!
    @IBOutlet weak var payPassView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var codeTipLabel: UILabel!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var sendMessageView: UIView!
    internal var numberInput: InputView?
    var mobile = ""
    var token = ""
    var point = ""
    var smsCode = ""
    var resultHandle: ((VerifyPayPassResult, _ data: String?) -> Void)?
    fileprivate var timer: Timer!
    fileprivate var timeInterval: Int = 60
//    fileprivate var userPay: UserPay?
    var type: VerifyPayPassType = .verify
    
    var resultBlock: ( (RedeemPointInfo ) -> Void)?
    
    fileprivate var codeStatus: CodeStatus = .wait {
        didSet {
            sendCodeButton.backgroundColor = codeStatus == .allow ? UIColor.colorWithHex("00a8fe") : UIColor.colorWithHex("DFE4E8")
            let title = codeStatus == .allow ? "重新发送" : "60s"
            sendCodeButton.setTitle(title, for: UIControlState())
            let titleColor = codeStatus == .allow ? UIColor.white : UIColor.colorWithHex("666666")
            sendCodeButton.setTitleColor(titleColor, for: UIControlState())
            if codeStatus == .wait {
                // 添加定时器
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
                RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
                sendCodeButton.isEnabled = false
            } else {
                sendCodeButton.isEnabled = true
                timer.invalidate()
                timer = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        passTextField.tag = 1
        codeTextField.tag = 2
        passTextField.addTarget(self, action: #selector(codeHandle(_:)), for: .editingChanged)
        for label in dotLabels {
            label.isHidden = true
        }
        numberInput = Bundle.main.loadNibNamed("InputView", owner: nil, options: nil)?.first as? InputView
        numberInput?.keyInput = passTextField
        passTextField.inputView = numberInput
        passTextField.inputAccessoryView = toolbar
        let tap = UITapGestureRecognizer(target: self, action: #selector(showKeyBoard(_:)))
        stackView.addGestureRecognizer(tap)
        let title = type == .verify ? "确定" : "下一步"
        nextButton.setTitle(title, for: UIControlState())
        mobile = UserManager.sharedInstance.userInfo?.tel ?? ""
        sendMessageView.layer.cornerRadius = 5
        sendMessageView.layer.borderColor = UIColor.lightGray.cgColor
        sendMessageView.layer.borderWidth = 0.5
        sendMessageView.clipsToBounds = true
        nextButton.layer.cornerRadius = 22
        confirmButton.layer.cornerRadius = 22
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dim(.out, coverNavigationBar: true)
        view.endEditing(true)
    }
    
    // 发送短信
    @IBAction func sendMessageAction(_ sender: Any) {
        requestSendCode()
    }
    // 取消
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(.canceled, data: nil)
    }
    @IBAction func sendMsgCancelAction(_ sender: Any) {
        timer.invalidate()
        timer = nil
        dismiss(.canceled, data: nil)
    }
    // 确认支付
    @IBAction func confirmAction(_ sender: UIButton) {
        if type == .rechargePoint {
            // （仅验证支付密码）
            requestVerifyPayPassword(type: .rechargePoint)
        } else {
            // 验证支付密码(用于充值积分)
            requestVerifyPayPassword(type: .verify)
        }
    }
    // 填写短信后 确认支付
    @IBAction func confirmPayAction(_ sender: Any) {
        requestChargeByBankCard()
    }
    
    // 隐藏键盘
    @IBAction func dismissKeyBoard(_ sender: UIButton) {
        view.endEditing(true)
    }
    
    @objc fileprivate func timerAction() {
        timeInterval -= 1
        sendCodeButton.titleLabel?.text = "\(timeInterval)s"
        sendCodeButton.setTitle("\(timeInterval)s", for: UIControlState())
        if timeInterval == 0 {
            codeStatus = .allow
            timeInterval = 60
        }
    }
    
    @objc fileprivate func codeHandle(_ textField: UITextField) {
        switch textField.tag {
        case 1:
            self.setDotWithCount(textField.text?.characters.count ?? 0)
            if textField.text?.characters.count == 6 {
                nextButton.isEnabled = true
                nextButton.backgroundColor = UIColor.colorWithHex("00A8FE")
            } else {
                nextButton.isEnabled = false
                nextButton.backgroundColor = UIColor.colorWithHex("DFE4E8")
            }
        case 2:
            if (textField.text?.characters.count)! <= 5 {
                confirmButton.isEnabled = false
                confirmButton.backgroundColor = UIColor.colorWithHex("DFE4E8")
            } else {
                confirmButton.isEnabled = true
                confirmButton.backgroundColor = UIColor.colorWithHex("00A8FE")
            }
        default:
            break
        }
    }

    @objc fileprivate func showKeyBoard(_ tap: UITapGestureRecognizer) {
        passTextField.becomeFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VerifypasswordViewController {
    fileprivate func dismiss(_ result: VerifyPayPassResult, data: String?) {
        passTextField.resignFirstResponder()
        if let block = resultHandle {
            block(result, data)
        }
    }
    fileprivate func setDotWithCount(_ count: Int) {
        for dot in dotLabels {
            dot.isHidden = true
        }
        
        for i in 0..<min(count, 6) {
            dotLabels[i].isHidden = false
        }
    }
    /// 下一步
    fileprivate func next() {
        payView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: payPassView.frame.height)
        view.addSubview(payView)
        UIView.animate(withDuration: 0.5) {
            self.payView.frame = self.payPassView.frame
        }
        let string = (mobile as NSString).substring(with: NSRange(location: 3, length: 4))
        let mobileText = (mobile as NSString).replacingOccurrences(of: string, with: "****")
        self.requestSendCode()
        codeTipLabel.text = "(短信验证码已发送至)"+"\(mobileText)"
        codeTextField.addTarget(self, action: #selector(codeHandle(_:)), for: .editingChanged)
    }
}

extension VerifypasswordViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        numberInput?.loadOnlyNumbers()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if (textField.text?.characters.count >= pwdCount) && (string.characters.count > 0) {
            return false
        }
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]*$")
        if !predicate.evaluate(with: string) {
            return false
        }
        
        var totalString: String
        if string.characters.count <= 0 {
            let index = textField.text?.characters.index((textField.text?.endIndex)!, offsetBy: -1)
            totalString = textField.text!.substring(to: index!)
        } else {
            totalString = textField.text! + string
        }
        
        self.setDotWithCount(totalString.characters.count)
        return true
    }
}

extension VerifypasswordViewController {
    // 请求购买积分支付密码
    func requestVerifyPayPassword(type: VerifyPayPassType) {
        if passTextField.text?.characters.count != 6 {
            Utility.showMBProgressHUDToastWithTxt("支付密码应为6位数字")
            return
        }
        
        Utility.showMBProgressHUDWithTxt()
        let paypassword = passTextField.text ?? ""
        let parameters: [String: Any] = [
            "pay_password": paypassword
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        let request = type == .verify ? AFMRequest.merchantCheckPaypassword(parameters, aesKey, aesIV) : AFMRequest.verifyPayPassword(parameters, aesKey, aesIV)
          RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            if (object) != nil {
                guard let result = object as? [String: Any] else { return }
                Utility.hideMBProgressHUD()
                if let token = result["token"] as? String {
                    self.token = token
                }
                if type == .verify {
                    self.dismiss(.passed, data: nil)
                } else {
                    self.view.endEditing(true)
                    self.next()
                    self.confirmButton.isEnabled = true
                    self.confirmButton.backgroundColor = UIColor.colorWithHex("00A8FE")
                }
            } else {
                if let msg = msg {
                    self.dismiss(.failed, data: nil)
                    self.tipLabel.text = msg
                    self.tipLabel.isHidden = false
                    self.setDotWithCount(0)
                    self.passTextField.text = nil
                    Utility.hideMBProgressHUD()
                } else {
                    self.dismiss(.failed, data: nil)
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    // 发送验证码
    func requestSendCode() {
        Utility.showMBProgressHUDWithTxt()
        let parameters: [String: Any] = [
            "token": token
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.sendSmsCode(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let result = object as? [String: Any] else {return }
                self.token = result["token"] as! String
                self.codeTextField.text = msg
                self.codeStatus = .wait
            } else {
                if let msg = msg {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    // 请求购买积分
    func requestChargeByBankCard() {
        let parameters: [String: Any] = [
            "token": token,
            "point": point,
            "sms_code": self.codeTextField.text ?? ""
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.pointRechargeByCard(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let result = object as? [String: Any] else {return }
                guard let block = self.resultBlock else {return}
                guard let info = RedeemPointInfo(JSON: result) else {return}
                //                  var resultBlock: ( (_ cardID: String, _ money: String, _ point: String, _ bank: String, _ tips: String)-> Void)?
                block(info)
                self.dismiss(.passed, data: result["point"] as? String)
                
            } else {
                
                if let msg = msg {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
}
