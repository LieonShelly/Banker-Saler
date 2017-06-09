//
//  MyShopProductManageTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable function_parameter_count

import UIKit

class MyShopProductManageTableViewCell: UITableViewCell {
    
    internal var type: ShopProductManageType = .normal {
        didSet {
            if type == .normal {
                leadingConstr.constant = 10
                selectionButton.isHidden = true
            } else {
                leadingConstr.constant = 38
                selectionButton.isHidden = false
            }
        }
    }
    
    @IBOutlet fileprivate weak var leadingConstr: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var productImgView: UIImageView!
    @IBOutlet fileprivate weak var productNameLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var otherInfoLabel: UILabel!
    
    @IBOutlet fileprivate weak var selectionButton: UIButton!
    
    internal var isProductSelected: Bool = false {
        didSet {
            if isProductSelected {
                selectionButton.isSelected = true
            } else {
                selectionButton.isSelected = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        selectionButton.isUserInteractionEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(_ imgName: String, title: String, price: Float, saleCount: String, stockCount: String, category: String) {
        productImgView.sd_setImage(with: URL(string: imgName), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
        
        productNameLabel.text = title
        priceLabel.text = "￥" + String(format: "%.2f", price)
        otherInfoLabel.text = "销量: \(saleCount)件  库存: \(stockCount)件  分类: \(category)"
    }
}
