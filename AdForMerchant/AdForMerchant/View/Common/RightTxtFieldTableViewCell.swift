//
//  RightTxtFieldTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
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

class RightTxtFieldTableViewCell: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var rightTxtField: UITextField!
    @IBOutlet var textFieldLeadingConstraint: NSLayoutConstraint!

    var maxCharacterCount: Int?
    
    var endEditingBlock: ((UITextField) -> Void)?
    var changeEditingBlock: ((String) -> Void)?
    var sourceIsAllowEdit: Bool = false {
        didSet {
            if sourceIsAllowEdit {
                rightTxtField.isEnabled = true
            }
        }
    }
    internal var txtFieldEnabled: Bool = false {
        didSet {
            rightTxtField.isUserInteractionEnabled = txtFieldEnabled
        }
    }
    
    internal var isEditableColor: Bool = false {
        didSet {
            if !isEditableColor {
                rightTxtField.textColor = UIColor.commonGrayTxtColor()
            } else {
                rightTxtField.textColor = UIColor.black
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightTxtField.isUserInteractionEnabled = false
        rightTxtField.returnKeyType = UIReturnKeyType.done
        rightTxtField.placeholder = ""
        rightTxtField.text = ""
        
        rightTxtField.addTarget(self, action: #selector(self.textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        rightTxtField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        rightTxtField.isEnabled = kApp.pleaseAttestationAction(showAlert: false, type: .publish)
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldEditingDidEnd(_ textField: UITextField) {
        if let block = endEditingBlock {
            block(textField)
        }
    }
    
    func textFieldEditingChanged(_ textField: UITextField) {
        if let maxCount = maxCharacterCount {
            if textField.text?.characters.count > maxCount, let text =  textField.text {
                textField.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: maxCount))
            }
        }
        if let block = changeEditingBlock {
            block(textField.text ?? "")
        }
    }
    
}

class RightTxtViewTableViewCell: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet fileprivate var rightTxtField: UITextField!
    @IBOutlet fileprivate var rightTxtView: UITextView!
    var maxCharacterCount: Int?
    var rows = 0
    var blockChangeHeight: ((CGFloat, String, Int, Int?) -> Void)?
    var beginEditingBlock: ((Int) -> (Void))?
    var height1: CGFloat = 0
    var height2: CGFloat = 0
    var count = 0
    lazy var array: [Int] = { [] }()
    var sourceIsAllowEdit: Bool = false {
        didSet {
            if sourceIsAllowEdit {
                rightTxtView.isUserInteractionEnabled = true
            }
        }
    }
    var endEditingBlock: ((CGFloat, String, String) -> Void)? {
        didSet {
            rightTxtView.isUserInteractionEnabled = true
        }
    }

    internal var rightPlaceholder: String = "" {
        didSet {
            rightTxtField.placeholder = rightPlaceholder
        }
    }
    
    internal var rightTxt: String = "" {
        didSet {
            rightTxtView.text = rightTxt
            rightTxtView.setContentOffset(CGPoint(x:0, y:0), animated: false)
            if rightTxtView.text.isEmpty {
                rightTxtField.text = ""
            } else {
                rightTxtField.text = " "
            }
        }
    }
    
    internal var adressRightTxt: String = "" {
        didSet {
            rightTxtView.text = adressRightTxt
            rightTxtView.setContentOffset(CGPoint(x:0, y:0), animated: false)
            let height = rightTxtView.contentSize.height
            let count = rightTxtView.text.characters.count
            if height > 70 {
                let range = NSRange(location: 60-5, length: 5+count-60)

                rightTxtView.text = (adressRightTxt as NSString).replacingCharacters(in: range, with: ".........")
            }
            if rightTxtView.text.isEmpty {
                rightTxtField.text = ""
            } else {
                rightTxtField.text = " "
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightTxtField.isUserInteractionEnabled = false
        rightTxtField.placeholder = ""
        rightTxtField.text = ""
        rightTxtView.delegate = self
        rightTxtView.isUserInteractionEnabled = kApp.pleaseAttestationAction(showAlert: false, type: .publish)
        rightTxtView.showsVerticalScrollIndicator = false
        rightTxtView.showsHorizontalScrollIndicator = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension RightTxtViewTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let height = textView.contentSize.height
        let count  = textView.text.characters.count 
        height1 = height
        self.rows =  0
        if (height1 > height2) && (height2 == 70) {
            if height>70 {
                self.count = count
                let rows = (height - 70) / 18
                self.rows = Int(rows)
                textView.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y, width: textView.frame.width, height: 65.5+rows*18)
                textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                guard let block = self.blockChangeHeight else {return}
                block(height, textView.text ?? "", Int(rows), count)
            }
        }
        if (height2 == height) && (height2 >= 70) {
            let rows = (height - 70) / 18
            self.rows = Int(rows)
            textView.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y, width: textView.frame.width, height: 65.5+rows*18)
            textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            guard let block = self.blockChangeHeight else {return}
            block(height, textView.text ?? "", Int(rows), count)
        }
        height2 = height1
        if textView.text.isEmpty {
            rightTxtField.text = ""
        } else {
            rightTxtField.text = " "
            if textView.text.characters.count >= 100 {
                guard let count = maxCharacterCount else {return}
                textView.text = (textView.text as NSString).substring(to: count)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let height = textView.contentSize.height
        let charactersCount = textView.text.characters.count
        let string = textView.text ?? ""
        guard let block = endEditingBlock else {return}
//        let rows = (height - 70) / 18
        if height > 70 {
             textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            let range = NSRange(location: count-5, length: 5+charactersCount-count)
            let string2 = (string as NSString).replacingCharacters(in: range, with: "...........")
            textView.text = string2 as String
            print(string2)
            block(85, string, string2)
        } else {
            block(85, string, string)
        }
        textView.isScrollEnabled = false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
//        let height = textView.text == "" ? 70 : textView.contentSize.height
//        let rows = (height - 70) / 18
        textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        guard let block = beginEditingBlock else {return}
        block(Int(self.rows))
        textView.isScrollEnabled = true
    }
}
