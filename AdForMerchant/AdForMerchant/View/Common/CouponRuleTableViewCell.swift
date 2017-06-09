//
//  CouponRuleTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 3/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class CouponRuleTableViewCell: UITableViewCell {
    
    @IBOutlet internal var amountField: UITextField!
    @IBOutlet internal var discountField: UITextField!
    @IBOutlet internal var deleteBtn: UIButton!
    
    internal var deleteBlock: ((CouponRuleTableViewCell) -> Void)? {
        didSet {
            deleteBtn.isEnabled = true
            let deleteImg = UIImage(named: "CellItemDelete")
            deleteBtn.setImage(deleteImg, for: UIControlState())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deleteBtn.isEnabled = false
        deleteBtn.tintColor = UIColor.commonGrayTxtColor()
        let deleteImg = UIImage(named: "CellItemDelete")?.withRenderingMode(.alwaysTemplate)
        deleteBtn.setImage(deleteImg, for: UIControlState())
        
        amountField.keyboardType = .numberPad
        discountField.keyboardType = .numberPad
        amountField.isUserInteractionEnabled = false
        discountField.isUserInteractionEnabled = false
        
        deleteBtn.addTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(_ amount: String, discount: String) {
        amountField.text = amount
        discountField.text = discount
    }
    
    func deleteAction() {
        if let block = deleteBlock {
            block(self)
        }
    }
}
