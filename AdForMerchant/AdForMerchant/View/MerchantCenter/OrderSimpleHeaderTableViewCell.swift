//
//  OrderSimpleHeaderTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderSimpleHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet internal var userImageView: UIImageView!
    @IBOutlet internal var userNameLabel: UILabel!
    @IBOutlet internal var rightTxtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightTxtLabel.isHidden = true
        rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(_ imgName: String, user: String, otherInfo: String) {
        userImageView.image = UIImage(named: "OrderIconUser")
        userNameLabel.text = user
        if !otherInfo.isEmpty {
            rightTxtLabel.isHidden = false
            rightTxtLabel.text = otherInfo
        }
    }
}
