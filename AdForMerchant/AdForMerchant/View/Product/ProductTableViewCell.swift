//
//  ProductTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import SDWebImage

class ProductTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        initialViews()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initialViews()
//    }
    
    func doMoreAction() {
        guard let block = doMoreBlock else {
            return
        }
        block(self)
    }
    
    internal var doMoreBlock: CellDoMoreBlock?
    
//    @IBOutlet internal var ratingLabel: UILabel!
//    @IBOutlet internal var moreButton: UIButton!
    
    @IBOutlet internal var productImageView: UIImageView!
    @IBOutlet internal var productTagView: UIImageView!
    @IBOutlet internal var productTitleLabel: UILabel!
    @IBOutlet internal var priceLabel: UILabel!
    @IBOutlet internal var productTypeTagLabel: UILabel!
    
    @IBOutlet weak var properListLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet internal var deliveryFeeLabel: UILabel!
    @IBOutlet internal var otherInfoLabel: UILabel!
    @IBOutlet fileprivate weak var inventoryLabel: UILabel!
    @IBOutlet fileprivate weak var activityLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    fileprivate var isServiceProduct: Bool = false {
        didSet {
            activityLabel.isHidden = isServiceProduct
        }
    }
    
    func config(_ pInfo: ProductModel) {
        productImageView.sd_setImage(with: URL(string: pInfo.thumb), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
        productTagView.image = UIImage(named: "TagHot")
        productImageView.contentMode = UIViewContentMode.scaleAspectFill

        if pInfo.inEvent == "1" {
            productTagView.isHidden = false
        } else {
            productTagView.isHidden = true
        }
        var rule = ""
        guard let properList = pInfo.properList else {return}
        for i in 0..<properList.count {
            guard let value = properList[i].value else {return}
            if i+1 == properList.count {
                rule += value
            } else {
                rule = value+"、" + rule
            }
        }
        numberLabel.text = pInfo.goodConfigTitle
        properListLabel.text  = "规格：" + rule
        productTitleLabel.text = pInfo.title
        let pricePart1 = "￥" + String(format: "%.2f", Float(pInfo.price) ?? 0)
        let pricePart2 = " 市场价"
        let pricePart3 = "￥" + String(format: "%.2f", Float(pInfo.marketPrice) ?? 0)
        
        let attTxt1 = NSMutableAttributedString(string:pricePart1, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#EC042A")])
        
        let attTxt2 = NSMutableAttributedString(string:pricePart2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#9498A9")])
        
        let attTxt3 = NSMutableAttributedString(string:pricePart3, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#9498A9"), NSStrikethroughStyleAttributeName: NSNumber(value: 1.0 as Double)])
        
        attTxt1.append(attTxt2)
        attTxt1.append(attTxt3)
        
        priceLabel.attributedText = attTxt1
        switch pInfo.type {
        case "1":
            productTypeTagLabel.text = " 商品 "
            productTypeTagLabel.backgroundColor = UIColor.colorWithHex("0B86EE")
            numberLabel.isHidden = false
            properListLabel.isHidden = false
            heightConstraint.constant = 110
        case "2":
            productTypeTagLabel.text = " 服务 "
            productTypeTagLabel.backgroundColor = UIColor.colorWithHex("11D8CC")
            numberLabel.isHidden = true
            properListLabel.isHidden = true
            heightConstraint.constant = 75
        default:
            break
        }
        
        deliveryFeeLabel.text = "运费:￥" + String(format: "%.2f", Float(pInfo.deliveryCost) ?? 0)
        otherInfoLabel.text = "销量：" + "\(pInfo.sellNum)" + "件"
        inventoryLabel.text = "库存:  " + "\(pInfo.stockNum)" + "件"
        activityLabel.text = "参与活动:  " + "\(pInfo.eventsNum)"
        if pInfo.type == "1" {
            isServiceProduct = false
        } else {
            isServiceProduct = true
        }
        
    }
}
