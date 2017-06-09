//
//  NormalDescTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class NormalDescTableViewCell: UITableViewCell {
    
    @IBOutlet internal var txtLabel: UILabel!
    
    internal var isEditableColor: Bool = false {
        didSet {
            if !isEditableColor {
                txtLabel.textColor = UIColor.commonGrayTxtColor()
            } else {
                txtLabel.textColor = UIColor.black
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        txtLabel.textColor = UIColor.commonGrayTxtColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
