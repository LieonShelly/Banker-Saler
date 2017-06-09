//
//  IncomeOutgoingTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/23/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class IncomeOutgoingTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate var contentLabel: UILabel!
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentLabel.font = UIFont.systemFont(ofSize: 15.0)
        contentLabel.textColor = UIColor.commonTxtColor()
        timeLabel.font = UIFont.systemFont(ofSize: 14.0)
        timeLabel.textColor = UIColor.commonGrayTxtColor()
        amountLabel.font = UIFont.systemFont(ofSize: 16.0)
        amountLabel.textColor = UIColor.colorWithHex("F38900")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ title: String, time: String, amount: String) {
        contentLabel.text = title
        timeLabel.text = time
        amountLabel.text = "￥" + String(format: "%@", amount)
    }
    
    func configPoint(_ title: String, time: String, point: String) {
        contentLabel.text = title
        timeLabel.text = time
        amountLabel.text = String(format: "%@", point)
    }

}
