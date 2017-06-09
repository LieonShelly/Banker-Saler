//
//  RefundImgageTableViewCell.swift
//  AdForMerchant
//
//  Created by 糖otk on 2017/4/18.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class RefundImgageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    var clickImageBlock: ((_ index: Int) -> Void)?

    var imageUrlArray = [String]() {
        didSet {
            for (index, value) in imageUrlArray.enumerated() {
                switch index {
                case 0:
                    imageView1.isHidden = false
                    imageView1.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
                    imageView1.tag = 0
                    imageView1.isUserInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: #selector(clickImageAction(tap:)))
                    imageView1.addGestureRecognizer(tap)
                case 1:
                    imageView2.isHidden = false
                     imageView2.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
                    imageView2.tag = 1
                    imageView2.isUserInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: #selector(clickImageAction(tap:)))
                    imageView2.addGestureRecognizer(tap)
                case 2:
                     imageView3.isHidden = false
                     imageView3.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
                     imageView3.tag = 2
                     imageView3.isUserInteractionEnabled = true

                     let tap = UITapGestureRecognizer(target: self, action: #selector(clickImageAction(tap:)))
                     imageView3.addGestureRecognizer(tap)
                case 3:
                     imageView4.isHidden = false
                     imageView4.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
                     imageView4.tag = 3
                     imageView4.isUserInteractionEnabled = true
                     let tap = UITapGestureRecognizer(target: self, action: #selector(clickImageAction(tap:)))
                     imageView4.addGestureRecognizer(tap)
                case 4:
                    imageView5.isHidden = false
                    imageView5.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
                    imageView5.tag = 4
                    imageView5.isUserInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: #selector(clickImageAction(tap:)))
                    imageView5.addGestureRecognizer(tap)
                default:
                    break
                }
            }
        }
    }
    
    func clickImageAction(tap: UITapGestureRecognizer) {
        guard let img = tap.view as? UIImageView, let block = clickImageBlock else {return}
        block(img.tag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
