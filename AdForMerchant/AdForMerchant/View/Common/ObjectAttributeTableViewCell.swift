//
//  ObjectAttributeTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ObjectAttributeTableViewCell: UITableViewCell {
    
    @IBOutlet internal var nameLabel: UILabel!
    @IBOutlet internal var nameField: UITextField!
    
    @IBOutlet internal var contentLabel: UILabel!
    @IBOutlet internal var contentField: UITextField!
    
    @IBOutlet internal var deleteButton: UIButton!
    
    @IBOutlet internal var buttonTrailingConstr: NSLayoutConstraint!
    
    var type: AttributeType = .productParameter {
        didSet {
            if type == .productParameter {
                nameLabel.text = "参数名称"
                contentLabel.text = "参数内容"
            } else {
                nameLabel.text = "规格名称"
                contentLabel.text = "规格内容"
            }
        }
    }
    
    internal var deleteBlock: ((ObjectAttributeTableViewCell) -> Void)? {
        didSet {
            if deleteBlock != nil {
                buttonTrailingConstr.constant = 15
                deleteButton.isEnabled = true
                let deleteImg = UIImage(named: "CellItemDelete")
                deleteButton.setImage(deleteImg, for: UIControlState())
            } else {
                buttonTrailingConstr.constant = -65
            }
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deleteButton.isEnabled = false
        deleteButton.tintColor = UIColor.commonGrayTxtColor()
        let deleteImg = UIImage(named: "CellItemDelete")?.withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(deleteImg, for: UIControlState())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func delAction(_ sender: AnyObject) {
        if let block = deleteBlock {
            block(self)
        }
    }
    
    func config(_ name: String, content: String) {
        nameField.text = name
        contentField.text = content
    }
    
}
