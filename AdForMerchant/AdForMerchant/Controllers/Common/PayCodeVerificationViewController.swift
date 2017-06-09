//
//  PayCodeVerificationViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 8/9/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
//import 

class PayCodeVerificationViewController: BaseViewController {
    
    var payPasswdTF: UITextField?
    
    var star1: UILabel?
    var star2: UILabel?
    var star3: UILabel?
    var star4: UILabel?
    var star5: UILabel?
    var star6: UILabel?
    
    var payPasswd: String = ""
    
    var confirmBlock: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPayCodeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showPayCodeView() {
        payPasswd = ""
        
        let codeAlertView = CustomIOSAlertView()
        codeAlertView?.containerView = payCodeView()
        codeAlertView?.delegate = self
        codeAlertView?.buttonTitles = ["取消", "确定"]
        codeAlertView?.useMotionEffects = true
        codeAlertView?.show()
    }
    
    func payCodeView() -> UIView {
        let viewWidth = screenWidth / 5 * 4
        let titilWidth = viewWidth / 2
        
        let codeView = UIView(frame:CGRect(x: 0, y: 0, width: viewWidth, height: 120))//30+20+60
        let titleLabel = UILabel(frame:CGRect(x: viewWidth / 2 - titilWidth / 2, y: 20, width: titilWidth, height: 20))
        titleLabel.text = "请输入支付密码"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        codeView.addSubview(titleLabel)
        
        let codeTfd = UITextField(frame:CGRect(x: 20, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 20, width: viewWidth - 40, height: 40))
        codeTfd.borderStyle = .none
        codeTfd.placeholder = "密码"
        codeTfd.isSecureTextEntry = true
        codeTfd.borderStyle = .roundedRect
        codeTfd.keyboardType = .numberPad
        codeView.addSubview(codeTfd)
        payPasswdTF = codeTfd
        payPasswdTF?.becomeFirstResponder()
        payPasswdTF?.addTarget(self, action: #selector(self.passwordDidChange), for: .editingChanged)
        
        let starBgView = UIView(frame:codeTfd.frame)
        starBgView.backgroundColor = UIColor.white
        starBgView.layer.cornerRadius = 8.0
        starBgView.layer.masksToBounds = true
        starBgView.layer.borderColor = UIColor.colorWithHex("666666").cgColor
        starBgView.layer.borderWidth = 1.0
        codeView.addSubview(starBgView)
        
        for i in 0 ..< 6 {
            let boxView = UIView(frame:CGRect(x: codeTfd.frame.size.width / 6 * CGFloat(i), y: 0, width: codeTfd.frame.size.width / 6 + 1, height: codeTfd.frame.size.height))
            boxView.layer.borderColor = UIColor.colorWithHex("666666").cgColor
            boxView.layer.borderWidth = 1.0
            starBgView.addSubview(boxView)
            let starLbl = UILabel(frame:boxView.bounds)
            starLbl.textAlignment = .center
            starLbl.backgroundColor = UIColor.clear
            starLbl.isHidden = true
            starLbl.text = "*"
            switch i {
            case 0:
                star1 = starLbl
            case 1:
                star2 = starLbl
            case 2:
                star3 = starLbl
            case 3:
                star4 = starLbl
            case 4:
                star5 = starLbl
            case 5:
                star6 = starLbl
            default:
                break
            }
            boxView.addSubview(starLbl)
        }
        
        return codeView
    }
    
    func passwordDidChange() {
        
        if let _ = payPasswdTF {
            self.changePasswordStar()
            if let pwd = payPasswdTF?.text {
                if pwd.characters.count < 6 {
                } else if pwd.characters.count == 6 {
                    payPasswdTF?.resignFirstResponder()
                } else {
                    payPasswdTF?.text = pwd.substring(to: pwd.characters.index(pwd.startIndex, offsetBy: 6))
                    payPasswdTF?.resignFirstResponder()
                }
            }
        }
    }
    
    func changePasswordStar() {
        if let pwd = payPasswdTF?.text {
            let textLength = min(pwd.characters.count, 6)
            
            star1?.isHidden = true
            star2?.isHidden = true
            star3?.isHidden = true
            star4?.isHidden = true
            star5?.isHidden = true
            star6?.isHidden = true
            
            switch textLength {
            case 6:
                star6?.isHidden = false
                fallthrough
            case 5:
                star5?.isHidden = false
                fallthrough
            case 4:
                star4?.isHidden = false
                fallthrough
            case 3:
                star3?.isHidden = false
                fallthrough
            case 2:
                star2?.isHidden = false
                fallthrough
            case 1:
                star1?.isHidden = false
            default:
                break
            }
        }
    }

}

extension PayCodeVerificationViewController: CustomIOSAlertViewDelegate {
    
    func customIOS7dialogButtonTouchUp(inside alertView: Any!, clickedButtonAt buttonIndex: Int) {
         guard let alter = alertView as? CustomIOSAlertView else { return  }
        switch buttonIndex {
        case 0:
            alter.close()
            dismiss(animated: true, completion: nil)
        case 1:
            if let pwd = payPasswdTF?.text {
                payPasswd = pwd
            } else {
                payPasswd = ""
            }
            if payPasswd.characters.count > 6 {
                payPasswdTF?.text = ""
                payPasswd = ""
                changePasswordStar()
            } else if payPasswd.characters.count == 6 {
                
                alter.close()
                dismiss(animated: true, completion: {
                    self.confirmBlock?(self.payPasswd)
                })
                
            } else {
                
            }
        default:
            break
        }
    }
}
