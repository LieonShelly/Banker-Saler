//
//  ShopInfoAttributeTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/16/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ShopInfoAttributeTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var shopNameTF: UITextField!
    @IBOutlet fileprivate weak var contactTF: UITextField!
    @IBOutlet fileprivate weak var phoneTF: UITextField!
    @IBOutlet fileprivate weak var addressTV: UITextView!
    
    @IBOutlet internal var deleteBtn: UIButton!
    
    internal var deleteBlock: ((ShopInfoAttributeTableViewCell) -> Void)? {
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

        shopNameTF.isUserInteractionEnabled = false
        contactTF.isUserInteractionEnabled = false
        phoneTF.isUserInteractionEnabled = false
        addressTV.isUserInteractionEnabled = false
        
        deleteBtn.addTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(_ addrInfo: ShopAddressInfo) {
        shopNameTF.text = addrInfo.shopName
        contactTF.text = addrInfo.contact
        phoneTF.text = addrInfo.phone
        addressTV.text = addrInfo.address
    }
    
    func deleteAction() {
        if let block = deleteBlock {
            block(self)
        }
    }
    
}
