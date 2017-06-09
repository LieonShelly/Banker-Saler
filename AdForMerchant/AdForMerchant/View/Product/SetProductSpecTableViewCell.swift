//
//  SetProductSpecTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/30.
//  Copyright © 2016年 Windward. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit

class SetProductSpecTableViewCell: UITableViewCell {
    @IBOutlet weak var roleNumberLabel: UILabel!
    @IBOutlet weak var roleCateLabel: UILabel!
    @IBOutlet weak var roleContentLabel: UITextField!
    @IBOutlet weak var dividerLine: UIView!
    var endEditingBlock: ((_ model: GoodsProperty) -> Void)?
    var maxCharacterCount: Int = 10
    var property: GoodsProperty? {
        didSet {
            roleCateLabel.text = property?.title
            roleContentLabel.text = property?.value
            roleContentLabel.placeholder = "请输入相关规格"
        }
    }
    fileprivate  weak var ownerTableView: ItemTableView?
    override func awakeFromNib() {
        super.awakeFromNib()
        roleContentLabel.placeholder = "请输入相关"
        roleContentLabel.addTarget(self, action: #selector(self.textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        roleContentLabel.addTarget(self, action: #selector(self.textFieldEditingChanged(textField:)), for: .editingChanged)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let tableView = (newSuperview?.superview) as? ItemTableView else { return  }
        ownerTableView = tableView
    }
    
    func textFieldEditingDidEnd(_ textField: UITextField) {
        if let block = endEditingBlock {
             guard let proper = self.property else { return  }
            proper.value = textField.text
            block(proper)
        }
    }
    
    func textFieldEditingChanged(textField: UITextField) {
        guard let text = textField.text else { return }
        if (textField.text?.characters.count)! > maxCharacterCount {
            textField.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: maxCharacterCount))
        }
    }
}
