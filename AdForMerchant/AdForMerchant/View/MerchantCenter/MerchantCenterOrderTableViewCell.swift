//
//  MerchantCenterOrderTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MerchantCenterOrderTableViewCell: UITableViewCell {
    
    internal var partClickBlock1: ((Void) -> Void)?
    internal var partClickBlock2: ((Void) -> Void)?
    internal var partClickBlock3: ((Void) -> Void)?
    
    @IBOutlet fileprivate weak var partButton1: UIButton!
    @IBOutlet fileprivate weak var partButton2: UIButton!
    @IBOutlet fileprivate weak var partButton3: UIButton!
    
    @IBOutlet fileprivate weak var waitForPayLbl: UILabel!
    @IBOutlet fileprivate weak var paidLbl: UILabel!
    @IBOutlet fileprivate weak var finishedLbl: UILabel!
    
    internal var waitForPayNumb: Int = 0 {
        didSet {
            waitForPayLbl.text = "\(waitForPayNumb)"
            if waitForPayNumb == 0 {
                waitForPayLbl.isHidden = true
            } else {
                waitForPayLbl.isHidden = false
            }
        }
    }
    
    internal var paidNumb: Int = 0 {
        didSet {
            paidLbl.text = "\(paidNumb)"
            if paidNumb == 0 {
                paidLbl.isHidden = true
            } else {
                paidLbl.isHidden = false
            }
        }
    }
    
    internal var finishedNumb: Int = 0 {
        didSet {
            finishedLbl.text = "\(finishedNumb)"
            if finishedNumb == 0 {
                finishedLbl.isHidden = true
            } else {
                finishedLbl.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        partButton1.addTarget(self, action: #selector(MerchantCenterOrderTableViewCell.partClickAction(_:)), for: .touchUpInside)
        partButton2.addTarget(self, action: #selector(MerchantCenterOrderTableViewCell.partClickAction(_:)), for: .touchUpInside)
        partButton3.addTarget(self, action: #selector(MerchantCenterOrderTableViewCell.partClickAction(_:)), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func partClickAction(_ btn: UIButton) {
        switch btn {
        case partButton1:
            
            guard let block = partClickBlock1 else {
                return
            }
            block()
        case partButton2:
            
            guard let block = partClickBlock2 else {
                return
            }
            block()
        case partButton3:
            
            guard let block = partClickBlock3 else {
                return
            }
            block()
        default:
            break
        }
    }

}
