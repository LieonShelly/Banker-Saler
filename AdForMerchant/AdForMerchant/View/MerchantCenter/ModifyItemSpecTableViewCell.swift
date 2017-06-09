//
//  ModifyItemSpecTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/28.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class ModifyItemSpecTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitle: UILabel!
    
    var model: GoodsProperty? {
        didSet {
            subtitle.text = model?.title
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
