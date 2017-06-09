//
//  ProductAddNewBuyNoteViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ProductAddNewBuyNoteViewController: UIViewController {

    @IBOutlet fileprivate weak var nameTF: UITextField!
    @IBOutlet fileprivate weak var contentTextView: UITextView!
    @IBOutlet fileprivate weak var bottomBtn: UIButton!
    fileprivate var isContentPlaceholderRemoved: Bool = false
    
    var navTitle: String?
    var nameCharacterMaxLimit: Int?
    var contentCharacterMaxLimit: Int?
    
    var completeBlock: ((String, String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nvTitle = navTitle {
            navigationItem.title = nvTitle
        } else {
            navigationItem.title = "添加购买须知"
        }
        
        contentTextView.delegate = self
        self.nameTF.addTarget(self, action: #selector(self.textfieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
    }
    
    deinit {
        self.nameTF.removeTarget(self, action: #selector(self.textfieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func comfirAction(_ sender: AnyObject) {
        if (nameTF.text ?? "").isEmpty {
            Utility.showAlert(self, message: "名称不能为空")
            return
        }
        if contentTextView.text.isEmpty || contentTextView.text == "请输入" {
            Utility.showAlert(self, message: "内容不能为空")
            return
        }
        if let contentMax = contentCharacterMaxLimit {
            if contentTextView.text.characters.count > contentMax {
                Utility.showAlert(self, message: "内容最多只能输入\(contentMax)个字")
                return
            }
        }
        if let block = completeBlock, let name = nameTF.text, let content = contentTextView.text {
            block(name, content)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textfieldEditingDidEnd(_ textField: UITextField) {
        if let nameMax = nameCharacterMaxLimit, let text = nameTF.text {
            if text.characters.count > nameMax {
                nameTF.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: nameMax))
            }
        }
    }
}

extension ProductAddNewBuyNoteViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if !isContentPlaceholderRemoved {
            isContentPlaceholderRemoved = true
            contentTextView.textColor = UIColor.commonTxtColor()
            contentTextView.text = ""
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if let contentMax = contentCharacterMaxLimit {
            if contentTextView.text.characters.count > contentMax {
                contentTextView.text = contentTextView.text.substring(to: contentTextView.text.index(contentTextView.text.startIndex, offsetBy: contentMax))
            }
        }
    }
    
}
