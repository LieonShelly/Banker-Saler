//
//  SetItemCatTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/27.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class SetItemCatTableViewCell: UITableViewCell {

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var selectedAction: ( () -> Void)?
    var model: SetItemCatViewHelpModel? {
        didSet {
            titleLabel.text = model?.title
            subTitleLabel.text = model?.subTitle
            selectedAction = model?.selectedRowAction
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
