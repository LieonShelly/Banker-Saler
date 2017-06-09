//
//  AdAddAnswerTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/18/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class AdAddAnswerTableViewCell: UITableViewCell {
    
    @IBOutlet internal weak var selectionButton: UIButton!
    @IBOutlet internal weak var leftTxtLabel: UILabel!
    @IBOutlet internal weak var detailTxtView: UITextView!
    
    @IBOutlet internal weak var disclousureImage: UIImageView!
    
    var answer: AnswerModel?
    
    var selectionChangeBlock: ((_ answer: AnswerModel) -> Void)? {
        didSet {
            disclousureImage.isHidden = false
            
            selectionButton.setImage(UIImage(named: "CellItemCheckmark"), for: .selected)
            selectionButton.isUserInteractionEnabled = true
        }
    }
    
    var maxCharacterCount: Int?
    
    internal var isRight: Bool = false {
        didSet {
            if isRight {
                selectionButton.isSelected = false
            } else {
                selectionButton.isSelected = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionButton.isUserInteractionEnabled = false
        detailTxtView.isUserInteractionEnabled = false
        disclousureImage.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func selectionBtnAction(_ sender: UIButton) {
        if let block = selectionChangeBlock {
            if let answer = self.answer {
                block(answer)
            }
        }
    }
    
    func config(_ answer: AnswerModel) {
        self.answer = answer
        if answer.isCorrect == "1" {
            self.isRight = true
        } else if answer.isCorrect == "0" {
            self.isRight = false
        }
        detailTxtView.text = answer.text
    }
}

extension AdAddAnswerTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.answer?.text = textField.text ?? ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let maxCount = maxCharacterCount {
            guard let text = textField.text else {return false}
            if (text.characters.count) - range.length + string.characters.count > maxCount {
                return false
            }
        }
        
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
}
