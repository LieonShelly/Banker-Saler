//
//  OrderAddressDetailTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderAddressDetailTableViewCell: UITableViewCell {

    @IBOutlet internal var txtView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtView.textColor = UIColor.commonGrayTxtColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
