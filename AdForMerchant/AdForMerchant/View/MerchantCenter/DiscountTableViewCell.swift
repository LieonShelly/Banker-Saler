//
//  WantCollectViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/14.
//  Copyright © 2016年 Burning. All rights reserved.
//

import UIKit

typealias DiscountBlockExpand = () -> Void
typealias DiscountBlockShrink = () -> Void
class DiscountTableViewCell: UITableViewCell {

    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var activeNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var topPrivilegeLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var expandView: UIView!
    @IBOutlet weak var activeNameLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var topPrivilegeLabelRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeNameLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeNameLabelBottomConstraint: NSLayoutConstraint!

    var isShrink = true
    var expandBlock: DiscountBlockExpand?
    var shrinkBlock: DiscountBlockShrink?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ priInfo: PrivilegeRuleInfo) {
        if iphone5 {
            expandButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.size.width-40, bottom: 0, right: 0)
            if priInfo.privilegeName.characters.count >= 6 {
                activeNameLabelWidthConstraint.constant = 120
                activeNameLabelBottomConstraint.constant = 13
                activeNameLabelLeftConstraint.constant = 20
            } else {
                activeNameLabelWidthConstraint.constant = 155
                activeNameLabelBottomConstraint.constant = 20
                activeNameLabelLeftConstraint.constant = 30
            }
        } else if iphone6P {
            expandButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.size.width-40, bottom: 0, right: 0)
            activeNameLabelLeftConstraint.constant = 35
            topPrivilegeLabelRightConstraint.constant = 35
        } else if iphone6 {
            expandButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.size.width-60, bottom: 0, right: 0)
        }
        
        timeLabel.text = String.changeTimeFormat(priInfo.created)
        activeNameLabel.text = priInfo.privilegeName
        ruleLabel.text = priInfo.rule
        discountLabel.attributedText = String.getAttString(priInfo.discount)
        if priInfo.topPrivilege.isEmpty {
            topPrivilegeLabel.text = ""
        } else {
            topPrivilegeLabel.text = "优惠额度: 最高减"+"\(String.cutDecimalCharater(priInfo.topPrivilege))" + "元"
        }
        
        if priInfo.isExpand == true {
        let height = String.getLabHeigh(ruleLabel.text ?? "", font: UIFont.systemFont(ofSize: 15), width: 150)
            expandView.height = height + 12
            ruleLabel.numberOfLines = 0
        } else {
            expandView.height = 100
            ruleLabel.numberOfLines = 1
        }
    }
   
    @IBAction func expandHanle(_ sender: AnyObject) {
        if isShrink == true {
            self.expandButton.setImage(UIImage(named: "btn_activity2"), for: UIControlState())
            if let block = self.expandBlock {
                block()
            }
        } else {
            self.expandButton.setImage(UIImage(named: "btn_activity"), for: UIControlState())
            if let block = self.shrinkBlock {
                block()
            }
        }
        isShrink = !isShrink
    }
}

extension DiscountTableViewCell {
    class func getRuleLabelHeight(_ priInfo: PrivilegeRuleInfo) -> CGFloat {
        let height = String.getLabHeigh(priInfo.rule, font: UIFont.systemFont(ofSize: 13), width: screenWidth*0.58)
//        print(height)
        if height > 16 {
            return height + 95 + 14
        } else {
            return 125
        }
    }
}
