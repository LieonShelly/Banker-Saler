//
//  OrderLogisticsTracksTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 8/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderLogisticsTracksTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var contentLabel: UILabel!
    
    @IBOutlet fileprivate var topLineView: UIView!
    @IBOutlet fileprivate var centerCircleView: UIView!
    @IBOutlet fileprivate var bottomLineView: UIView!
    
    var willShowHighlight: Bool = false {
        didSet {
            if willShowHighlight {
                topLineView.isHidden = true
                centerCircleView.backgroundColor = UIColor.commonBlueColor()
                
                timeLabel.textColor = UIColor.commonBlueColor()
                contentLabel.textColor = UIColor.commonBlueColor()
                
            } else {
                
                topLineView.isHidden = false
                centerCircleView.backgroundColor = UIColor.commonBgColor()
                
                timeLabel.textColor = UIColor.commonGrayTxtColor()
                contentLabel.textColor = UIColor.commonGrayTxtColor()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        topLineView.backgroundColor = UIColor.commonBgColor()
        centerCircleView.backgroundColor = UIColor.commonBgColor()
        bottomLineView.backgroundColor = UIColor.commonBgColor()
        
        timeLabel.font = UIFont.systemFont(ofSize: 14.0)
        contentLabel.font = UIFont.systemFont(ofSize: 14.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(_ time: String, content: String) {
        contentLabel.text = content
        timeLabel.text = time
    }
    
}
