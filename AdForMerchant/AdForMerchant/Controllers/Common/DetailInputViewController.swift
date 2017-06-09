//
//  DetailInputViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/4/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class DetailInputViewController: UIViewController {
    
    @IBOutlet fileprivate var scrlView: UIScrollView!
    @IBOutlet fileprivate var txtView: UITextView!
    @IBOutlet fileprivate var bottomButton: UIButton!
    @IBOutlet fileprivate var bottomBtnBottomConstr: NSLayoutConstraint!
    
    internal var navTitle: String! = ""
    internal var txt: String! = ""
    internal var placeholder: String = "随便说点什么吧"
    internal var emptyContentAlert: String! = "没有输入任何内容"
    internal var maxCharacterLimit: Int = 1000
    /// 限制使用标点符号
    internal var limitPunctuation: Bool = false
    
    var completeBlock: ((String) -> Void)?
    var confirmBlock: ((String) -> Void)?
    
    var canEdit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if canEdit {
            navigationItem.title = navTitle
        } else {
            if navTitle.hasPrefix("输入") {
                navigationItem.title = navTitle.substring(from: navTitle.index(navTitle.startIndex, offsetBy: 2))
            } else {
                navigationItem.title = navTitle
            }
        }
        
        if placeholder == "随便说点什么吧" {
            placeholder += String(format: "(限%d字)", maxCharacterLimit)
        }
        
        txtView.delegate = self
        bottomButton.setTitle("确定", for: UIControlState())
        
        if txt.isEmpty {
            txtView.text = placeholder
            txtView.textColor = UIColor.colorWithHex("9498A9")
        } else {
            txtView.text = txt
        }
        
        if !canEdit {
            txtView.textColor = UIColor.commonGrayTxtColor()
            txtView.isEditable = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailInputViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailInputViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        if !canEdit {
            bottomBtnBottomConstr.constant = -49
        }
    }

    @IBAction func saveButtonAction(_ sender: Any) {
        txtView.text = Utility.getTextByTrim(txtView.text)
        if txtView.text == placeholder || txtView.text.isEmpty {
            Utility.showAlert(self, message: emptyContentAlert)
            return
        } else {
            if let c = completeBlock {
                c(txtView.text)
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            if let block = confirmBlock {
                block(txtView.text)
            }
        }
    }
    
    func keyboardWillShow(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else { return }
        guard let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else { return }
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.txtView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - 40, right: 0)
            self.txtView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - 40, right: 0)
            self.view.layoutIfNeeded()
        }) 
    }
    
    func keyboardWillHide(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else { return }
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.txtView.contentInset = UIEdgeInsets.zero
            self.txtView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.layoutIfNeeded()
        }) 
    }
}

extension DetailInputViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if txt.isEmpty {
            txtView.text = ""
            txtView.textColor = UIColor.commonTxtColor()
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        txt = txtView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let char = text.cString(using: .utf8)
        let isBackSpace = strcmp(char, "\\b")
        if Utility.isIllegalCharacter(text) {
            let updatedText = currentText.replacingCharacters(in: range, with: text)
            return updatedText.characters.count <= maxCharacterLimit
        } else if isBackSpace == -92 {
            return true
        } else {
            return false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.characters.count > maxCharacterLimit {
//            let index = textView.text.index(textView.text.startIndex, offsetBy: maxCharacterLimit)
//            textView.text = textView.text.substring(to: index)
//        }
    }
    
}
