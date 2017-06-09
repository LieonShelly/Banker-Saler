//
//  AddShopAssistantContentView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/18.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class AddShopAssistantContentView: UIView {
    lazy var staffModel: Staff = Staff()
    var tapAction:((_ staffModel: Staff) -> Void)?
    var helpAction: (() -> Void)?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cashierYesIcon: UIImageView!
    @IBOutlet weak var waiterYesIcon: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var numTextfield: UITextField!
    
    @IBAction func helpButtonClick(_ sender: AnyObject) {
        if let block = helpAction {
            block()
        }
    }
    
    @IBAction func casherButtonClick(_ sender: AnyObject) {

         staffModel.limits = .casher
         cashierYesIcon.isHidden = false
         waiterYesIcon.isHidden = true
    }
    
    @IBAction func waiterButtonClick(_ sender: AnyObject) {
        
        staffModel.limits = .waiter
        waiterYesIcon.isHidden = false
        cashierYesIcon.isHidden = true
    }
    @IBAction func addButtonClick(_ sender: UIButton) {
        staffModel.name = nameTextField.text
        staffModel.mobile = numTextfield.text
        if let block = tapAction {
            block(staffModel)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.addTarget(self, action: #selector(textFieldDidEnd(textField:)), for: .editingDidEnd)
        numTextfield.addTarget(self, action: #selector(textFieldDidEnd(textField:)), for: .editingDidEnd)
    }
    
}

extension AddShopAssistantContentView {
    
    func textFieldDidEnd(textField: UITextField) {
        let string = textField.text ?? ""
        if textField == nameTextField {
            
            if string.characters.count >= 5 {
                textField.text = (string as NSString).substring(to: 5)
            }
        } else {
            if string.characters.count >= 11 {
                textField.text = (string as NSString).substring(to: 11)
            }
        }
    }
    
}

extension AddShopAssistantContentView {
    class func contentView() -> AddShopAssistantContentView {
        guard let view = Bundle.main.loadNibNamed("AddShopAssistantContentView", owner: nil, options: nil)?.first, let contentView = view as? AddShopAssistantContentView  else { return AddShopAssistantContentView() }
        return contentView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
