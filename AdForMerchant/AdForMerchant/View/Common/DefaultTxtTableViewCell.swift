//
//  DefaultTxtTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/18/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class DefaultTxtTableViewCell: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var rightTxtLabel: UILabel!
    
    internal var isEditableColor: Bool = false {
        didSet {
            if !isEditableColor {
                rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            } else {
                rightTxtLabel.textColor = UIColor.black
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
