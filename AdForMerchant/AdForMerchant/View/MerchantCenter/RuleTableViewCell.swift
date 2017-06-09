//
//  RuleTableViewCell.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/19.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
typealias RuleBlockExpand = () -> Void
typealias RuleBlockShrink = () -> Void
class RuleTableViewCell: UITableViewCell {

    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var topPrivilegeLabel: UILabel!
    @IBOutlet weak var typeLabel: UIButton!
    @IBOutlet weak var activeNameLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var ruleLabel: UILabel!
    
    @IBOutlet weak var fullLabel: UILabel!
    @IBOutlet weak var reduceLabel: UILabel!
    @IBOutlet weak var minusLabel: UILabel!
    @IBOutlet weak var selectedButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var topPrivileteLabelRightConstraint: NSLayoutConstraint!
    var isSeleted = false
    // 收缩
    var isShrink = true
    var expandBlock: RuleBlockExpand?
    var shrinkBlock: RuleBlockShrink?
    override func awakeFromNib() {
        super.awakeFromNib()
        if screenHeight == 667 {
            expandButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.size.width-40, bottom: 0, right: 0)
        } else if screenHeight == 736 {
            expandButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.size.width-20, bottom: 0, right: 0)
            selectedButtonLeftConstraint.constant = 30
            topPrivileteLabelRightConstraint.constant = 30
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    func config(_ ruleInfo: PrivilegeRuleInfo) {
        topPrivilegeLabel.text = ruleInfo.topPrivilege
        activeNameLabel.text = ruleInfo.privilegeName
        ruleLabel.text = ruleInfo.rule
        typeLabel.setTitle((ruleInfo.type == "2" ? "满减" : "折扣"), for: UIControlState())
        
        if ruleInfo.type == "2" {
            typeLabel.setBackgroundImage(UIImage(named: "icon_bgh"), for: UIControlState())
        } else {
            typeLabel.setBackgroundImage(UIImage(named: "icon_bg1-1"), for: UIControlState())
        }
        if ruleInfo.type == "" {
            typeLabel.isHidden = true
        } else {
            typeLabel.isHidden = false
        }
        if ruleInfo.topPrivilege.isEmpty {
            topPrivilegeLabel.text = ""
        } else {
            topPrivilegeLabel.text = "优惠额度: 最高减"+"\(String.cutDecimalCharater(ruleInfo.topPrivilege))" + "元"
        }
        if ruleInfo.type == "2" {
            fullLabel.isHidden = true
            reduceLabel.isHidden = true
            minusLabel.isHidden = true
            let text = "满"+"\(String.cutDecimalCharater(ruleInfo.fullSum))"+"减"+"\(String.cutDecimalCharater(ruleInfo.minusSum))"
            self.discountLabel.attributedText = returnAttbutedText(text)
        } else {
            discountLabel.attributedText = String.getAttString(ruleInfo.discount)
            fullLabel.isHidden = true
            reduceLabel.isHidden = true
            minusLabel.isHidden = true
        }
        if ruleInfo.isExpand == true {
            self.ruleLabel.numberOfLines = 0
            
        } else {
            self.ruleLabel.numberOfLines = 1
            
        }
        if ruleInfo.isSeleted {
            selectedButton.isHidden = false
        } else {
            selectedButton.isHidden = true
        }
    }
    
    func returnAttbutedText(_ str: String) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: str)
        
        let rangeJian = (str as NSString).range(of: "减")
        let rangeAll = (str as NSString).range(of: str)
        let rangeMan = (str as NSString).range(of: "满")
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 25), range: rangeAll)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: 1))
        attString.addAttribute(NSBaselineOffsetAttributeName, value: 1, range: rangeJian)
        attString.addAttribute(NSBaselineOffsetAttributeName, value: 1, range: rangeMan)
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 17), range: rangeJian)
        return attString
    }
}

extension RuleTableViewCell {
    class func getRuleLabelHeight(_ priInfo: PrivilegeRuleInfo) -> CGFloat {
        let height = String.getLabHeigh(priInfo.rule, font: UIFont.systemFont(ofSize: 13), width: 150)
        if height > 16 {
            return height + 85
        } else {
           return 120
        }
    }
}
