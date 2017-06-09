//
//  OrderProductDescTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderProductDescTableViewCell: UITableViewCell {
    
    @IBOutlet internal var bgView: UIView!
    @IBOutlet internal var productImageView: UIImageView!
    @IBOutlet internal var productTitleLabel: UILabel!
    @IBOutlet internal var priceLabel: UILabel!
    @IBOutlet internal var countLabel: UILabel!
    
    @IBOutlet weak var specLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.backgroundColor = UIColor.backgroundLightGreyColor()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ imgName: String, title: String, price: String, count: String, properList: [GoodsProperty]?) {
        productImageView.sd_setImage(with: URL(string: imgName), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
        
        productTitleLabel.text = title
        priceLabel.text = price
        countLabel.text = "X\(count)"
        specLabel.text = ""
         guard let list = properList else { return  }
      _ =  list.map { (proper) -> Void in
        if let title = proper.title, let value = proper.value {
            guard let text = specLabel.text else { return }
            specLabel.text = text + "\(title): \(value)  "          
        }
        }
    }

}
