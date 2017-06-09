//
//  ProductCategoryTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ProductCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var selectionButton: UIButton!
    
    internal var isCategorySelected: Bool = false {
        didSet {
            if isCategorySelected {
                leftTxtLabel.textColor = UIColor.commonBlueColor()
                selectionButton.isSelected = true
                
            } else {
                leftTxtLabel.textColor = UIColor.black
                selectionButton.isSelected = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionButton.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(_ name: String) {
        leftTxtLabel.text = name
    }
    
}
