//
//  OrderFooterTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderFooterTableViewCell: UITableViewCell {
    
    @IBOutlet internal var rightButton1: UIButton!
    @IBOutlet internal var rightButton2: UIButton!
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var rightTxtLabel: UILabel!
    
    @IBOutlet internal var leftBottomTxtLabel: UILabel!
    
    var buttonTitle1: String? {
        didSet {
            rightButton1.isHidden = false
            rightButton1.setTitle(buttonTitle1, for: UIControlState())
        }
    }
    var buttonTitle2: String? {
        didSet {
            rightButton2.isHidden = false
            rightButton2.setTitle(buttonTitle2, for: UIControlState())
        }
    }
    var buttonEnable2: Bool = true {
        didSet {
            rightButton2.setTitleColor(buttonEnable2 ? UIColor.colorWithHex("116FE9") : UIColor.colorWithHex("a1a2a6"), for: .normal)
            rightButton2.layer.borderColor = buttonEnable2 ? UIColor.colorWithHex("116FE9").cgColor : UIColor.colorWithHex("a1a2a6").cgColor          
        }
    }
    
    var buttonBlock1: ((OrderFooterTableViewCell) -> Void)?
    var buttonBlock2: ((OrderFooterTableViewCell) -> Void)?
    
    var refundInfo: String? {
        didSet {
            if refundInfo == nil {
                leftBottomTxtLabel.isHidden = true
            } else {
                leftBottomTxtLabel.isHidden = false
            }
            leftBottomTxtLabel.text = refundInfo
        }
    }
    
    var refundInfoAttributedString: NSAttributedString? {
        didSet {
            if refundInfoAttributedString == nil {
                leftBottomTxtLabel.isHidden = true
            } else {
                leftBottomTxtLabel.isHidden = false
            }
            leftBottomTxtLabel.attributedText = refundInfoAttributedString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightButton1.isHidden = true
        rightButton2.isHidden = true
        
        rightButton1.addTarget(self, action: #selector(self.buttonAction1(_:)), for: .touchUpInside)
        rightButton2.addTarget(self, action: #selector(self.buttonAction2(_:)), for: .touchUpInside)
        
        leftTxtLabel.numberOfLines = 2
        rightTxtLabel.numberOfLines = 3
        
        leftBottomTxtLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(productCount: Int, price: String, pointPrice: String, actualPrice: String, discount: String = "", revisedPrice: String) {
        let orderchangePrice = (Double(revisedPrice) ?? 0.0) - (Double(price) ?? 0.0)
        let txtPart1 = "共\(productCount)件商品  优惠:"
        let attrTxt = NSMutableAttributedString(string: txtPart1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
        
        let txtPart2 = "￥\(discount)"
        let attrTxt2 = NSAttributedString(string: txtPart2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("F49F0B")])
        
        attrTxt.append(attrTxt2)
        
        let pointPartText1 = "\n订单支付积分总金额:"
        let pointPartAttrText1 = NSMutableAttributedString(string: pointPartText1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
        
        let pointPartText2 = "￥\(pointPrice)"
        let pointPartAttrText2 = NSAttributedString(string: pointPartText2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("F49F0B")])
        
        attrTxt.append(pointPartAttrText1)
        attrTxt.append(pointPartAttrText2)
        let rightPart1 = "合计:"
        let rightPartAttrTxt1 = NSMutableAttributedString(string: rightPart1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
        let total = (Double(revisedPrice) ?? 0.00) != 0 ? revisedPrice : price
        let rightPart2 = "￥\(total)"
        let rightPartAttrTxt2 = NSMutableAttributedString(string: rightPart2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("F49F0B")])
        
        rightPartAttrTxt1.append(rightPartAttrTxt2)
        if (Int(Double(revisedPrice) ?? 0.0) != 0) && (orderchangePrice != 0) {
            let orderChangePartText1 = "\n订单改价:"
            let orderChangePartAttrTxt1 = NSMutableAttributedString(string: orderChangePartText1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
            
            let orderChangePartText2 = orderchangePrice > 0 ? "￥\(String(format: "%.2f", orderchangePrice))" : "-￥\(String(format: "%.2f", abs(orderchangePrice)))"
            
            let orderChangePartAttrTxt2 = NSMutableAttributedString(string: orderChangePartText2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("F49F0B")])
            rightPartAttrTxt1.append(orderChangePartAttrTxt1)
            rightPartAttrTxt1.append(orderChangePartAttrTxt2)
        }

        let actualPricePartText1 = "\n订单实际收入:"
        let actualPricePartAttrText1 = NSMutableAttributedString(string: actualPricePartText1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
        
        let actualPricePartText2 = "￥\(actualPrice)"
        let actualPricePartAttrText2 = NSAttributedString(string: actualPricePartText2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("F49F0B")])
        
        rightPartAttrTxt1.append(actualPricePartAttrText1)
        rightPartAttrTxt1.append(actualPricePartAttrText2)

        let paraRightStyle = NSMutableParagraphStyle()
        paraRightStyle.lineSpacing = 5
        paraRightStyle.alignment = .right
        let paraLeftStyle = NSMutableParagraphStyle()
        paraLeftStyle.lineSpacing = 5
        paraLeftStyle.alignment = .left
        attrTxt.addAttributes([NSParagraphStyleAttributeName: paraLeftStyle], range: NSRange(location: 0, length: attrTxt.length))
        rightPartAttrTxt1.addAttributes([NSParagraphStyleAttributeName: paraRightStyle], range: NSRange(location: 0, length: rightPartAttrTxt1.length))
    
        leftTxtLabel.attributedText = attrTxt
        rightTxtLabel.attributedText = rightPartAttrTxt1
    }

    func buttonAction1(_ sender: AnyObject) {
        if let block = buttonBlock1 {
            block(self)
        }
    }
    
    func buttonAction2(_ sender: AnyObject) {
        if let block = buttonBlock2 {
            block(self)
        }
    }
    
}
