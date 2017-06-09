//
//  ProductStockTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/11/10.
//  Copyright © 2016年 Windward. All rights reserved.
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

class ProductStockTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    var endEditingBlock: ((String) -> Void)?
    var maxCharacterCount: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        maxCharacterCount = 4
        textField.delegate = self
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(self.textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        textField.isEnabled = kApp.pleaseAttestationAction(showAlert: false, type: .publish)
    }
    
    func textFieldEditingDidEnd(_ textField: UITextField) {
        
        if let block = endEditingBlock, let text =  textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) {
            block(text)
        }
    }
    
}

extension ProductStockTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        if let text = textField.text, let count = maxCharacterCount {
            var input = text
            input.append(string)
            if input.characters.count > count {
                return false
            }
            return true
        }
        return true
    }
}
