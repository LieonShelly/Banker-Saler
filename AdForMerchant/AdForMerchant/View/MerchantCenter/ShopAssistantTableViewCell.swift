//
//  ShopAssistantTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import SDWebImage

class ShopAssistantTableViewCell: UITableViewCell {
    var model: Staff? {
        didSet {
            nameLabel.text = model?.name
             guard let url = URL(string: model?.avatar ?? "") else { return  }
            iconView.sd_setImage(with: url)
             guard let numText = model?.mobile else { return  }
            numLabel.setTitle(" \(numText)", for: UIControlState())
            guard let dateText = model?.created else { return  }
            dateLaebel.setTitle(" \(dateText)", for: UIControlState())
            typeButton.setTitle(model?.limits.title, for: UIControlState())
            typeButton.backgroundColor = model?.limits.backgroudColor
            if let awardText = model?.awardNum {
                let attribute0 = NSMutableAttributedString(string: "共被打赏\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.colorWithHex("9498a9")])
                let attribute1 = NSMutableAttributedString(string: "\(awardText)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.colorWithHex("141414")])
                let attribute2 = NSMutableAttributedString(string: "次", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.colorWithHex("141414")])
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                attribute0.append(attribute1)
                attribute0.append(attribute2)
                 attribute0.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: attribute1.length))
                awardLebl.attributedText = attribute0
            }
            if model?.status == .inviting {
                awardLebl.attributedText = model?.status.title
            }
            if model?.status == .rejected {
                awardLebl.attributedText = model?.status.title
            }
         }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var numLabel: UIButton!
    
    @IBOutlet weak var dateLaebel: UIButton!
    
    @IBOutlet weak var awardLebl: UILabel!
   
    @IBOutlet weak var typeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        typeButton.layer.cornerRadius = 5
        typeButton.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews {
            guard let stringClass = NSClassFromString("UITableViewCellDeleteConfirmationView") else {return}
            if view.isKind(of: stringClass) {
                view.backgroundColor = superview?.backgroundColor
                for i in  0 ..< view.subviews.count {
                    if view.subviews[i].isKind(of: UIButton.self) {
                        guard let btn = view.subviews[i] as? UIButton  else { return  }
                        guard let imageView = btn.imageView else {return}
                        let dividerline = UIView()
                        dividerline.backgroundColor = UIColor.colorWithHex("e5e5e5")
                        let dw: CGFloat = 0.5
                        let dh: CGFloat = btn.bounds.height
                        let dy: CGFloat = 0.0
                        let dx: CGFloat = 0.0
                        dividerline.frame = CGRect(x: dx, y: dy, width: dw, height: dh)
                        btn.tag = i
                        btn.addSubview(dividerline)
                        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: btn.bounds.width * 0.5 - (imageView.bounds.width) * 0.5, bottom: 0, right: 0)
                        btn.setImage(UIImage(named: "commit_btn_\(i)"), for: UIControlState())
                        btn.backgroundColor = superview?.backgroundColor
                    }
                }
            }
        }
    }
}
