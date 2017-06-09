//
//  MyShopProductCategoryTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MyShopProductCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet internal var leftTopTxtLabel: UILabel!
    @IBOutlet internal var leftBottomTxtLabel: UILabel!
    @IBOutlet weak var cateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
