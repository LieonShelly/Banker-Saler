//
//  MyCollectTableViewCell.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/13.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class MyCollectTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var actualLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cashierLabel: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if UserManager.sharedInstance.loginType == .clerk {
            staffNameLabel.isHidden = true
            cashierLabel.isHidden = true
        } else {
            staffNameLabel.isHidden = false
            cashierLabel.isHidden = false
        }
        
        if iphone5 {
            nameLabel.font = UIFont.systemFont(ofSize: 15)
            timeLabel.font = UIFont.systemFont(ofSize: 15)
            for childView in self.contentView.subviews {
                if childView.isKind(of: UILabel.self) {
                    (childView as? UILabel)?.font = UIFont.systemFont(ofSize: 15)
                }
            }
        }
    }

    func config(_ privilegeInfo: PrivilegeInfo) {
        nameLabel.text = privilegeInfo.storeNmae
        staffNameLabel.text = privilegeInfo.staffName
        orderNumberLabel.text = privilegeInfo.orderNo
        totalLabel.text = privilegeInfo.total
        actualLabel.text = privilegeInfo.actual
        timeLabel.text = privilegeInfo.updateTime
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
