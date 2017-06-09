//
//  ShopCategoryTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ShopCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var rightTxtLabel: UILabel!
    
    @IBOutlet internal var selectionButton: UIButton!
    
    internal var isCategorySelected: Bool = false {
        didSet {
            if isCategorySelected {
                leftTxtLabel.textColor = UIColor.commonBlueColor()
                rightTxtLabel.textColor = UIColor.commonBlueColor()
                selectionButton.isHidden = false
            } else {
                leftTxtLabel.textColor = UIColor.commonTxtColor()
                rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                selectionButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftTxtLabel.textColor = UIColor.commonTxtColor()
        rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(_ name: String, count: String) {
        leftTxtLabel.text = name
        if count.isEmpty {
            rightTxtLabel.text = "共有0件商品"
        } else {
            rightTxtLabel.text = "共有\(count)件商品"
        }
        
    }
    
}
