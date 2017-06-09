//
//  BuyNoteAttributeTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/16/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class BuyNoteAttributeTableViewCell: UITableViewCell {
    
    @IBOutlet internal weak var nameField: UITextField!
    @IBOutlet internal weak var contentTxtView: UITextView!
    @IBOutlet internal weak var deleteBtn: UIButton!

    internal var deleteBlock: ((BuyNoteAttributeTableViewCell) -> Void)? {
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
        contentTxtView.text = content
    }
}
