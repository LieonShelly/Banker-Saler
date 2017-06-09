//
//  CampaignTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/2/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class CampaignTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var topRightLabel: UILabel!
    
    @IBOutlet fileprivate var campImageView: UIImageView!
    @IBOutlet fileprivate var campTagView: UIImageView!
    @IBOutlet fileprivate var productTitleLabel: UILabel!
    @IBOutlet fileprivate var tagLabel: UILabel!
    @IBOutlet fileprivate var countRightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        campTagView.backgroundColor = UIColor.colorWithRGBA(0, green: 0, blue: 0, alpha: 0.7)
        campTagView.isHidden = true
        timeLabel.font = UIFont.systemFont(ofSize: 13.0)
        timeLabel.textColor = UIColor.colorWithHex("A1A2A6")
        topRightLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal var type: CampaignType = .sale {
        didSet {
            switch type {
            case .sale:
                countRightLabel.textColor = UIColor.commonGrayTxtColor()
                countRightLabel.font = UIFont.systemFont(ofSize: 12)
            case .place:
                countRightLabel.textColor = UIColor.commonBlueColor()
                countRightLabel.font = UIFont.boldSystemFont(ofSize: 18)
            }
        }
    }
    
    internal var status: CampaignStatus?
    
    internal var willShowCountLabel: Bool = true {
        didSet {
            countRightLabel.isHidden = !willShowCountLabel
        }
    }
    
    internal var isApplyingForStop: Bool = false {
        didSet {
            campTagView.isHidden = !isApplyingForStop
        }
    }
    
    internal var topRightText: String = "" {
        didSet {
            topRightLabel.text = topRightText
        }
    }
    
    internal var topRightTextColor: UIColor? {
        didSet {
            if topRightTextColor != nil {
                topRightLabel.textColor = topRightTextColor
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagLabel.isHidden = false
        countRightLabel.isHidden = false
    }
    
    func config(_ cInfo: CampaignInfo) {
        
        campImageView.sd_setImage(with: URL(string: cInfo.cover), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
        timeLabel.text = (cInfo.startTime + " 至 " + cInfo.endTime).replacingOccurrences(of: "-", with: "/")
        productTitleLabel.text = cInfo.title
        
        tagLabel.textColor = UIColor.white
        switch cInfo.type {
        case .coupon:
            tagLabel.text = " 满减 "
            tagLabel.backgroundColor = UIColor.colorWithHex("#F6B533")
        case .sale:
            tagLabel.text = " 打折 "
            tagLabel.backgroundColor = UIColor.colorWithHex("#9964AB")
        case .price:
            tagLabel.text = " 活动价 "
            tagLabel.backgroundColor = UIColor.colorWithHex("#5DBF9F")
        }
        
        isApplyingForStop = (cInfo.stopApplyStatus == .inProgress)
        countRightLabel.text = "商品件数: \(cInfo.eventGoodsNumb)"
    }
    
    func config(_ pInfo: PlaceCampaignInfo) {
        print(pInfo.closedType)
        campImageView.sd_setImage(with: URL(string: pInfo.cover), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
        timeLabel.text = (pInfo.startTime + " 至 " + pInfo.endTime).replacingOccurrences(of: "-", with: "/")

        productTitleLabel.text = pInfo.title
        
        let signUpAttTxt = NSMutableAttributedString(string: "报名人数: ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#A1A2A6")])
        signUpAttTxt.append(NSAttributedString(string: "\(pInfo.appointmentNumb)", attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 20) ?? UIFont.systemFont(ofSize: 20), NSForegroundColorAttributeName: UIColor.commonBlueColor()]))
        
        let pointAttTxt = NSMutableAttributedString(string: "已消耗积分: ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#A1A2A6")])
        pointAttTxt.append(NSAttributedString(string: "\(pInfo.costPoint)", attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 20) ?? UIFont.systemFont(ofSize: 20), NSForegroundColorAttributeName: UIColor.commonBlueColor()]))
        
        let joinAttTxt = NSMutableAttributedString(string: "参与人数: ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#A1A2A6")])
        joinAttTxt.append(NSAttributedString(string: "\(pInfo.joinNumb)", attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 20) ?? UIFont.systemFont(ofSize: 20), NSForegroundColorAttributeName: UIColor.commonBlueColor()]))
        
        if let s = status {
            switch s {
            case .notBegin:
                countRightLabel.attributedText = signUpAttTxt
                tagLabel.attributedText = nil
            case .inReview:
                countRightLabel.attributedText = nil
                tagLabel.attributedText = nil
            case .inProgress, .over:
                tagLabel.backgroundColor = UIColor.clear
                tagLabel.attributedText = pointAttTxt
                countRightLabel.attributedText = joinAttTxt
            case .exception:
                switch pInfo.closedType {
                case .ongoingClosed:
                    tagLabel.backgroundColor = UIColor.clear
                    tagLabel.attributedText = pointAttTxt
                    countRightLabel.attributedText = joinAttTxt
                case .noInfo:
                    countRightLabel.attributedText = nil
                    tagLabel.attributedText = nil
                case .normallyClosed:
                    tagLabel.backgroundColor = UIColor.clear
                    tagLabel.attributedText = pointAttTxt
                    countRightLabel.attributedText = joinAttTxt
                case .frozenClosed:
                    countRightLabel.attributedText = nil
                    tagLabel.attributedText = nil
                case .auditClosed:
                    countRightLabel.attributedText = signUpAttTxt
                    tagLabel.attributedText = nil
                }
            case .draft:
                break
            }
        } else {
            countRightLabel.attributedText = nil
        }
    }
    
}
