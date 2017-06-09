//
//  ProductAddNewAddressViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ProductAddNewAddressViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var shopNameTF: UITextField!
    @IBOutlet fileprivate weak var contactTF: UITextField!
    @IBOutlet fileprivate weak var phoneTF: UITextField!
    @IBOutlet fileprivate weak var addressTV: UITextView!
    
    @IBOutlet fileprivate weak var confirmBtn: UIButton!
    
    fileprivate var isAddressPlaceholderRemoved: Bool = false
    var addressInfo: ShopAddressInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        shopNameTF.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
        contactTF.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
        phoneTF.keyboardType = .numberPad
        addressTV.delegate = self
        
        confirmBtn.addTarget(self, action: #selector(ProductAddNewAddressViewController.confirmAction), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProductAddNewAddressViewController.resignAllViewFirstResponder))
        view.addGestureRecognizer(tap)
        setInfo()
    }

    func setInfo() {
        shopNameTF.text = addressInfo?.shopName
        phoneTF.text = addressInfo?.phone
        addressTV.text = addressInfo?.address
        contactTF.text = addressInfo?.contact
        addressTV.textColor = UIColor.black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resignAllViewFirstResponder() {
        view.endEditing(false)
    }
    
    func confirmAction() {
        shopNameTF.text = Utility.getTextByTrim(shopNameTF.text ?? "")
        contactTF.text = Utility.getTextByTrim(contactTF.text ?? "")
        phoneTF.text = Utility.getTextByTrim(phoneTF.text ?? "")
        addressTV.text = Utility.getTextByTrim(addressTV.text)
         guard let shopName =  shopNameTF.text, let contact = contactTF.text, let phoneNumber = phoneTF.text else { return  }
        if shopName.isEmpty {
            Utility.showAlert(self, message: "请输入店铺名")
            return
        } else if contact.isEmpty {
            Utility.showAlert(self, message: "请输入联系人")
            return
        } else if phoneNumber.isEmpty {
            Utility.showAlert(self, message: "请输入电话")
            return
        } else if !Utility.isValidateMobile(phoneTF.text) {
            Utility.showAlert(self, message: "请输入正确的电话")
            return
        } else if addressTV.text == "请输入" || addressTV.text.isEmpty {
            Utility.showAlert(self, message: "请输入地址")
            return
        }
        
        requestAddNewAddress()
    }
    
    func requestAddNewAddress() {
        guard let shopName =  shopNameTF.text, let contact = contactTF.text, let phoneNumber = phoneTF.text, let address = addressTV.text  else { return  }
        var parameters: [String: Any] = [
            "name": shopName,
            "contact": contact,
            "tel": phoneNumber,
            "address": address ]
        if addressInfo?.id != 0 {
            parameters["add_id"] = addressInfo?.id
        }
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.storeSaveAddress(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else { return }
                if let _ = result["add_id"] as? String {
                    Utility.showMBProgressHUDToastWithTxt("添加店铺成功")
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    Utility.hideMBProgressHUD()
                }
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
}

extension ProductAddNewAddressViewController {
    func textFieldDidEnd(_ textField: UITextField) {
        let string = textField.text ?? ""
        if textField == shopNameTF {
            if string.characters.count >= 15 {
                textField.text = (string as NSString).substring(to: 15)
            }
        }
        if textField == contactTF {
            if string.characters.count >= 10 {
                textField.text = (string as NSString).substring(to: 10)
            }
        }
    }
}

extension ProductAddNewAddressViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if !isAddressPlaceholderRemoved {
            isAddressPlaceholderRemoved = true
            addressTV.textColor = UIColor.commonTxtColor()
            addressTV.text = addressInfo?.address ?? ""
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let string = textView.text ?? ""
        if string.characters.count >= 30 {
            textView.text = (string as NSString).substring(to: 30)
        }
    }
}
