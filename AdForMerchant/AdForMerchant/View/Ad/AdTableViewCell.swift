//
//  AdTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/2/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class AdTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func doMoreAction() {
        guard let block = doMoreBlock else {
            return
        }
        block(self)
    }
    
    internal var doMoreBlock: CellDoMoreBlock?
    
    @IBOutlet fileprivate var adImageView: UIImageView!
    //    @IBOutlet private var productTagView: UIImageView!
    @IBOutlet fileprivate var productTitleLabel: UILabel!
    @IBOutlet fileprivate var noteLabel: UILabel!
    @IBOutlet fileprivate var countLeftLabel: UILabel!
    @IBOutlet fileprivate var countRightLabel: UILabel!
    @IBOutlet fileprivate weak var costPointLabel: UILabel!
    @IBOutlet weak var pointConstraintLeft: NSLayoutConstraint!
    
    func config(_ adInfo: AdModel) {
        //        productImageView: UIImageView!
        
        adImageView.sd_setImage(with: URL(string: adInfo.thumb), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
        //        productTagView: UIImageView!
        productTitleLabel.text = adInfo.title
        if adInfo.joinNum.isEmpty == false {
            countRightLabel.text = "\(adInfo.joinNum)"
        } else {
            countRightLabel.text = "0"
        }
        
        if adInfo.costPoint.isEmpty == false {
            costPointLabel.text = "\(adInfo.costPoint)"
        } else {
            costPointLabel.text = "0"
        }
        
        switch adInfo.type {
        case "1":
            noteLabel.text = " 图片 "
            noteLabel.backgroundColor = UIColor.colorWithHex("FEC250")
        case "2":
            noteLabel.text = " 视频 "
            noteLabel.backgroundColor = UIColor.colorWithHex("98D2E7")
        case "3":
            noteLabel.text = " 网页 "
            noteLabel.backgroundColor = UIColor.colorWithHex("879FE2")
        default: break
        }
    }
    
}

extension AdTableViewCell {
    override func layoutSubviews() {
        if iphone5 {
            pointConstraintLeft.constant = 7
        }
    }
}
