//
//  TextCounterTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 7/18/16.
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

class TextCounterTableViewCell: UITableViewCell {
    
    @IBOutlet internal var textField: UITextField!
    @IBOutlet internal var textView: UITextView!
    @IBOutlet internal var counterLabel: UILabel!
    
    var maxCharacterCount: Int = 100
    var endEditingBlock: ((UITextView) -> Void)?
    var placeHolder: String? {
        didSet {
            refreshTextFieldPlaceHolder()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textView.delegate = self
        counterLabel.textColor = UIColor.colorWithHex("A0A0A0")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func refreshTextFieldPlaceHolder() {
        if textView.text.isEmpty {
            textField.placeholder = placeHolder
        } else {
            textField.placeholder = ""
        }
    }
    
}

extension TextCounterTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if textView.text?.characters.count > maxCharacterCount {
            textView.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: maxCharacterCount))
        }
        counterLabel.text = String(format: "%d / %d", Int(textView.text.characters.count), maxCharacterCount)
        refreshTextFieldPlaceHolder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let block = endEditingBlock {
            block(textView)
        }
    }
    
}
