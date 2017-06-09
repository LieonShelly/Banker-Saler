//
//  MyShopHeaderTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MyShopHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet  var shopAvatarImgView: UIImageView!
    @IBOutlet var shopBgImgView: UIImageView!
    @IBOutlet var shopNameLbl: UILabel!
    @IBOutlet var shopRatingLbl: UILabel!
    
    fileprivate  lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.backgroundColor = UIColor.colorWithHex("0x000000")
        coverView.alpha = 0.4
        coverView.width = screenWidth
        coverView.height = 130
        return coverView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shopBgImgView.insertSubview(coverView, at: 0)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
