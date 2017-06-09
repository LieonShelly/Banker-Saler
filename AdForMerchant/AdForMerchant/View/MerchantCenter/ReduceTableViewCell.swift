//
//  WantCollectViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/14.
//  Copyright © 2016年 Burning. All rights reserved.
//

import UIKit
typealias ReduceBlockExpand = () -> Void
typealias ReduceBlockShrink = () -> Void
class ReduceTableViewCell: UITableViewCell {

    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var activeNameLabel: UILabel!
    @IBOutlet weak var topPrivilegeLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!

    @IBOutlet weak var minusLabel: UILabel!
    @IBOutlet weak var fullLabel: UILabel!
    
    @IBOutlet weak var activeNameLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var topPrivilegeLabelRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeNameLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeNameLabelBottomConstraint: NSLayoutConstraint!

    var priInfo: PrivilegeRuleInfo?
    var expandBlock: ReduceBlockExpand?
    var shrinkBlock: ReduceBlockShrink?
    // 收缩
   var isShrink = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        fullLabel.text = String.cutDecimalCharater(priInfo.fullSum)
        minusLabel.text = String.cutDecimalCharater(priInfo.minusSum)
        ruleLabel.text = priInfo.rule
        if priInfo.topPrivilege.isEmpty {
            topPrivilegeLabel.text = ""
        } else {
            topPrivilegeLabel.text = "优惠额度: 最高减"+"\(String.cutDecimalCharater(priInfo.topPrivilege))" + "元"
        }
        if priInfo.isExpand == true {
            self.ruleLabel.numberOfLines = 0
        } else {
            self.ruleLabel.numberOfLines = 1
        }
    }
    
    @IBAction func expandHandle(_ sender: AnyObject) {
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

extension ReduceTableViewCell {
    class func getRuleLabelHeight(_ priInfo: PrivilegeRuleInfo) -> CGFloat {
         let height = String.getLabHeigh(priInfo.rule, font: UIFont.systemFont(ofSize: 13), width: screenWidth*0.58)
        if height > 16 {
            return height + 95 + 14
        } else {
            return 125
        }
    }
}
