//
//  ItemDetailTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/25.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import SDWebImage

class ItemDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var picImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var propertyLabel: UILabel!
    
    override func awakeFromNib() {
        if iphone5 {
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            priceLabel.font = UIFont.systemFont(ofSize: 13)
            
        }
    }
    
    var model: ProductModel? {
        didSet {
            guard let pricestr = model?.price else { return  }
            picImageView.sd_setImage(with: URL(string: model?.thumb ?? ""))
            titleLabel.text = model?.title
            priceLabel.text = "￥\(pricestr)"
            guard let propertyArray = model?.properList else {
                return
            }
          let titleArray = propertyArray.map { $0.title ?? ""}
           let titles = titleArray.joined(separator: ",")
            propertyLabel.text = "规格: \(titles)"
        }
    }
    
}
