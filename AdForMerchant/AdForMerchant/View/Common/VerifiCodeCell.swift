//
//  VerifiCodeCell.swift
//  AdForMerchant
//
//  Created by lieon on 2017/2/24.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit

class VerifiCodeCell: UITableViewCell {
    var tapAction: (() -> Void)?
    var maxCharacterCount: Int = 11
    var endEditingBlock: ((UITextField) -> Void)?
    @IBOutlet  var leftTxtLabel: UILabel!
    @IBOutlet  var rightTxtField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    var sourceIsAllowEdit: Bool = false {
        didSet {
            if sourceIsAllowEdit {
                rightTxtField.isUserInteractionEnabled = true
            }
        }
    }
    @IBAction fileprivate func buttonAction(_ sender: Any) {
        tapAction?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rightTxtField.isUserInteractionEnabled = false
        rightTxtField.returnKeyType = UIReturnKeyType.done
        rightTxtField.placeholder = ""
        rightTxtField.text = ""
        
        rightTxtField.addTarget(self, action: #selector(self.textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        rightTxtField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        
    }

    func textFieldEditingDidEnd(_ textField: UITextField) {
        if let block = endEditingBlock {
            block(textField)
        }
    }
    
    func textFieldEditingChanged(_ textField: UITextField) {
         guard let textCount = textField.text?.characters.count else { return  }
        if textCount > maxCharacterCount, let text =  textField.text {
            textField.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: maxCharacterCount))
        }
        
    }
    
}
