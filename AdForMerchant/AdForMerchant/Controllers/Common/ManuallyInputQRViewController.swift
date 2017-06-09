//
//  ManuallyInputQRViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/26/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ManuallyInputQRViewController: UIViewController {
    
    @IBOutlet fileprivate var scanButton: UIButton!
    @IBOutlet fileprivate var confirmButton: UIButton!
    
    @IBOutlet fileprivate var bgView: UIView!
    @IBOutlet fileprivate var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.backgroundColor = UIColor.black
//        view.backgroundColor = UIColor.whiteColor()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        textField.leftViewMode = .always
        textField.keyboardType = .numbersAndPunctuation
        textField.keyboardAppearance = .dark
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        scanButton.addTarget(self, action: #selector(self.scanAction(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirmInputAction(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Action
    
    @IBAction func backAction() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func scanAction(_ btn: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func confirmInputAction(_ btn: UIButton) {
        view.endEditing(true)
        let txt = Utility.getTextByTrim(textField.text ?? "")
        if txt.isEmpty {
            Utility.showAlert(self, message: "请输入数字码")
            return
        }
        requestQRCodeConfirm(txt)
    }
    
    // MARK: - Http request
    
    func requestQRCodeConfirm(_ qrCode: String) {
        let parameters: [String: Any] = [
            "code": qrCode,
            "scan_type": QRCodeType.input.rawValue
        ]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.qrCodeConfirm(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if object != nil {
                guard let result = object as? [String: AnyObject] else { return }
               guard let tips = result["tip"] as? String else { return }
                Utility.hideMBProgressHUD()
                Utility.showConfirmAlert(self, title: "提示", cancelButtonTitle: "取消", confirmButtonTitle: "确认", message: tips, cancelCompletion: nil, confirmCompletion: { () in
                        self.requestUseQRCode(qrCode)
                })
            } else {
                Utility.hideMBProgressHUD()
                if let msg = message {
                    Utility.showAlert(self, message: msg)
                } else {
                }
            }
        }
    }

    func requestUseQRCode(_ qrCode: String) {
        let parameters: [String: Any] = [
            "code": qrCode,
            "scan_type": QRCodeType.input.rawValue
        ]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.qrCodeScan(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let msg = message else { return }
                Utility.showAlert(self, message: msg.isEmpty ? "使用二维码成功": msg, dismissCompletion: { () in
                })
            } else {
                Utility.hideMBProgressHUD()
                if let msg = message {
                    Utility.showAlert(self, message: msg)
                } else {
                }
            }
        }
    }
}
