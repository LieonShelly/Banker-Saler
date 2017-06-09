//
//  ProductAddNewAttributeViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class ProductAddNewAttributeViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var nameTF: UITextField!
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    @IBOutlet fileprivate weak var valueTF: UITextField!
    
    @IBOutlet fileprivate weak var footerNoteLabel: UILabel!
    
    var completeBlock: ((String, String) -> Void)?
    
    @IBOutlet fileprivate weak var bottomBtn: UIButton!
    
    var type: AttributeType = .productParameter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .productParameter {
            navigationItem.title = "添加商品参数"
            footerNoteLabel.isHidden = true
        } else {
            navigationItem.title = "添加商品规格"
            nameLabel.text = "规格名称"
            nameTF.placeholder = "颜色"
            valueLabel.text = "规格内容"
            valueTF.placeholder = "如：红色，黄色，蓝色"
            
            let attrTxt = NSMutableAttributedString(string: "ⓘ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor()])
            let attrTxt2 = NSAttributedString(string: " 不同的规格内容之间需用逗号分隔", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonGrayTxtColor()])
            attrTxt.append(attrTxt2)
            footerNoteLabel.attributedText = attrTxt
        }
        nameTF.addTarget(self, action: #selector(self.textfieldEditingDidEnd(_:)), for: UIControlEvents.editingChanged)
        valueTF.addTarget(self, action: #selector(self.textfieldEditingDidEnd(_:)), for: UIControlEvents.editingChanged)
    }
    
    deinit {
        nameTF.removeTarget(self, action: #selector(self.textfieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
        valueTF.removeTarget(self, action: #selector(self.textfieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
    }

    @IBAction func comfirmAction(_ sender: AnyObject) {
        if nameTF.text?.characters.count < 1 {
            if type == .productParameter {
                Utility.showAlert(self, message: "请输入参数名称")
            } else {
                Utility.showAlert(self, message: "请输入规格名称")
            }
            return
        }
        if valueTF.text?.characters.count < 1 {
            if type == .productParameter {
                Utility.showAlert(self, message: "请输入参数内容")
            } else {
                Utility.showAlert(self, message: "请输入规格内容")
            }
            return
        }
        if let block = completeBlock {
            block(nameTF.text ?? "", valueTF.text ?? "")
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textfieldEditingDidEnd(_ textField: UITextField) {
         guard let text = textField.text else { return  }
        if textField.isEqual(self.nameTF) {
            if text.characters.count > 5 {
                guard  let index = textField.text?.characters.index((text.startIndex), offsetBy: 5) else { return }
                textField.text = text.substring(to: index)
            }
        } else if textField.isEqual(self.valueTF) {
            if text.characters.count > 50 {
               guard let index = textField.text?.characters.index((text.startIndex), offsetBy: 50) else { return }
                textField.text = textField.text?.substring(to: index)
            }
        }
    }
}
