//
//  SetItemCodeTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class SetItemCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    var endEditingBlock: ((_ text: String, _ indexPath: IndexPath) -> Void)?
    var maxCharacterCount: Int?
    var model: SetItemCodeViewHelpModel? {
        didSet {
            titleLabel.text = model?.desc
            textField.placeholder = model?.titleValue
            textField.text = model?.title
        }
    }
   fileprivate weak var ownerTableView: UITableView?
    override func awakeFromNib() {
        super.awakeFromNib()
        maxCharacterCount = 10
        textField.delegate = self
        textField.addTarget(self, action: #selector(self.textFieldEditingDidEnd(_:)), for: .editingDidEnd)
          textField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let tableView = (newSuperview?.superview) as? UITableView else { return  }
        ownerTableView = tableView
    }
    
    func textFieldEditingDidEnd(_ textField: UITextField) {
        textField.layoutIfNeeded()
         guard let text = textField.text else { return   }
         guard let tableView = ownerTableView else { return  }
         guard let indexPath = tableView.indexPath(for: self) else {  return }
        if text.isEmpty {
            return
        }
        if let block = endEditingBlock {
                block(text, indexPath)
        }
    }
    
    func textFieldEditingChanged(_ textField: UITextField) {
        guard let tableView = ownerTableView else { return  }
        guard let indexPath = tableView.indexPath(for: self) else {  return }
        if textField.text == "" {
            guard let block = endEditingBlock else { return }
            block("", indexPath)
        }
        if let maxCount = maxCharacterCount {
            guard let text = textField.text else {return}
            if (text.characters.count) > maxCount {
                textField.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: maxCount))
            }
        }
        
    }
}

extension SetItemCodeTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.resignFirstResponder()
//        textField.setNeedsLayout()
//        textField.layoutIfNeeded()
//    }
    
}
