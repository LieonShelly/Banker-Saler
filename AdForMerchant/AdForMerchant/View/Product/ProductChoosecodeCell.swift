//
//  ProductChoosecodeCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/30.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class ProductChoosecodeCell: UITableViewCell {

    @IBOutlet weak var arrowTrailingCons: NSLayoutConstraint!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal var isEditableColor: Bool = false {
        didSet {
            if !isEditableColor {
                subTitleLabel.textColor = UIColor.commonGrayTxtColor()
            } else {
                subTitleLabel.textColor = UIColor.black
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
