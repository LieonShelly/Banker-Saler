//
//  MyShopProductDefaultCategoryCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/11/3.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class MyShopProductDefaultCategoryCell: UITableViewCell {
    
    @IBOutlet weak var productCateLabel: UILabel!

    @IBOutlet weak var cateNameLabel: UILabel!
    
    @IBOutlet weak var numLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       productCateLabel.layer.cornerRadius = 10
       productCateLabel.layer.masksToBounds = true
    }
   
    var model: ShopProductCategoryInfo? {
        didSet {
             guard let num = model?.goodsNumb else { return  }
            cateNameLabel.text = model?.catName
            numLabel.text = "共\(num)件商品"
            productCateLabel.text = model?.type.title
            productCateLabel.backgroundColor = model?.type.backgroudColor
        }
    }
}
