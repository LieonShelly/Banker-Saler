//
//  OrderDescTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderDescTableViewCell: UITableViewCell {
    
    @IBOutlet internal var txtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtLabel.textColor = UIColor.commonGrayTxtColor()
//        txtView.scrollEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
