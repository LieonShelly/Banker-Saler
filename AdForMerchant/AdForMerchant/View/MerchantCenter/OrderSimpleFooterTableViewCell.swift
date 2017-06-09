//
//  OrderSimpleFooterTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 4/5/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderSimpleFooterTableViewCell: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var rightTxtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftTxtLabel.numberOfLines = 0
        rightTxtLabel.numberOfLines = 3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
//    func config(leftTxt: String, otherInfo: String) {
//        
//        leftTxtLabel.text = leftTxt
//        rightTxtLabel.text = otherInfo
//    }
//    
    
    func config(productCount: Int, price: String, pointPrice: String, actualPrice: String, discount: String = "", refundAmount: String? = nil, revisedPrice: String) {
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
        
        if let refund = refundAmount {
            let refundPriceAttrTxt = NSAttributedString(string: "\n退款金额:", attributes: [NSForegroundColorAttributeName: UIColor.commonTxtColor()])
            let refundPriceAttrTxt2 = NSAttributedString(string: "￥\(refund)", attributes: [NSForegroundColorAttributeName: UIColor.commonBlueColor()])
            attrTxt.append(refundPriceAttrTxt)
            attrTxt.append(refundPriceAttrTxt2)
        }

        let rightPart1 = "合计:"
        let rightPartAttrTxt1 = NSMutableAttributedString(string: rightPart1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
        let total = (Double(revisedPrice) ?? 0.00) != 0 ? revisedPrice : price
        let rightPart2 = "￥\(total)"
        let rightPartAttrTxt2 = NSMutableAttributedString(string: rightPart2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("F49F0B")])
        
        rightPartAttrTxt1.append(rightPartAttrTxt2)
        
        if (Int(Double(revisedPrice) ?? 0.0) != 0) && (orderchangePrice != 0) {
            let orderChangePartText1 = "\n订单改价:"
            let orderChangePartAttrTxt1 = NSMutableAttributedString(string: orderChangePartText1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
            
            let orderChangePartText2 = orderchangePrice > 0 ? "￥\(String(format: "%.2f", orderchangePrice ))" : "-￥\(String(format: "%.2f", abs(orderchangePrice )))"
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
}
