//
//  CenterTxtFieldTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable force_unwrapping

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

class CenterTxtFieldTableViewCell: UITableViewCell {
    @IBOutlet internal weak var leftTxtLabel: UILabel!
    @IBOutlet internal weak var rightTxtLabel: UILabel!
    @IBOutlet internal weak var centerTxtField: UITextField!
    
    var maxCharacterCount: Int?
    fileprivate var observer: NSObjectProtocol?
    var isNumberInputType: Bool = false {
        didSet {
            if isNumberInputType {
                self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: centerTxtField, queue: nil) { (notifi) -> Void in
                     guard let centerText = self.centerTxtField.text else { return  }
                    if centerText.isEmpty {
                        
                    } else {
                        if !centerText.contains(".") {
                            self.centerTxtField.text = "￥0.0" + centerText
                        } else {
                            let components = centerText.components(separatedBy: ".")
                            if let numberAfterPoint = components.last {
                                let numberStr = centerText.replacingOccurrences(of: "￥", with: "")
                                
                                if numberAfterPoint.characters.count >= 3 {
                                    let multiplier = pow(10.0, 2.0)
                                    let num = (Double(numberStr) ?? 0.0)  * 10
                                    let rounded = round(num * multiplier) / multiplier
                                    self.centerTxtField.text = String(format: "￥%.2f", rounded)
                                } else if numberAfterPoint.characters.count <= 1 {
                                    
                                    let multiplier = pow(10.0, 2.0)
                                    let num = Double(numberStr)! / 10
                                    let rounded = round(num * multiplier) / multiplier
                                    
                                    self.centerTxtField.text = String(format: "￥%.2f", rounded)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    internal var isEditableColor: Bool = false {
        didSet {
            if !isEditableColor {
                centerTxtField.textColor = UIColor.commonGrayTxtColor()
                rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            } else {
                centerTxtField.textColor = UIColor.black
                rightTxtLabel.textColor = UIColor.black
            }
        }
    }
    
    var endEditingBlock: ((String) -> Void)? {
        didSet {
            if endEditingBlock == nil {
                centerTxtField.isUserInteractionEnabled = false
            } else {
                centerTxtField.isUserInteractionEnabled = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        centerTxtField.isUserInteractionEnabled = false
        centerTxtField.keyboardType = .numberPad
        //centerTxtField.delegate = self
        centerTxtField.addTarget(self, action: #selector(self.textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        centerTxtField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        centerTxtField.isEnabled = kApp.pleaseAttestationAction(showAlert: false, type: .publish)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldEditingDidEnd(_ textField: UITextField) {
        guard var str: String = textField.text else { return }
        if !str.isEmpty {
            if let block = endEditingBlock {
                let char = str.characters[(str.characters.startIndex)]
                if char == "￥"{
                    str.remove(at: str.characters.startIndex)
                }
                block(str)
            }
        } else {
            if let block = endEditingBlock {
                block("")
            }
        }
    }
    
    func textFieldEditingChanged(_ textField: UITextField) {
        if let maxCount = maxCharacterCount, let text = textField.text {
            if textField.text?.characters.count > maxCount {
                textField.text = textField.text?.substring(to: text.characters.index(text.startIndex, offsetBy: maxCount))
            }
        }
    }
    
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let text = textField.text {
//            return text.vaild(with: "^\\d{n}$")
//        }
//        return false
//    }
}
/*
extension CenterTxtFieldTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "￥" {
            return true
        }
        if string == "." {
            return true
        }
        return Utility.isOnlyNumber(string)
    }
}*/

extension CenterTxtFieldTableViewCell {
    func enableNormalInput() {
        self.isNumberInputType = false
        centerTxtField.isUserInteractionEnabled = true
        centerTxtField.keyboardType = .numberPad
        centerTxtField.addTarget(self, action: #selector(self.textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        centerTxtField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
    }
}
