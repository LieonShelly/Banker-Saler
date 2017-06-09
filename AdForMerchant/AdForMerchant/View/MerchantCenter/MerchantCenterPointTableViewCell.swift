//
//  MerchantCenterPointTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/23/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MerchantCenterPointTableViewCell: UITableViewCell {
    
    internal var walletClickBlock: ((Void) -> Void)?
    internal var pointsClickBlock: ((Void) -> Void)?
    
    @IBOutlet fileprivate weak var walletButton: UIButton!
    @IBOutlet fileprivate weak var pointsButton: UIButton!
    
    @IBOutlet fileprivate weak var walletLbl: UILabel!
    @IBOutlet fileprivate weak var pointsLbl: UILabel!
    
    var walletText: String = "" {
        didSet {
            walletLbl.text = walletText
        }
    }
    
    var pointsText: String = "" {
        didSet {
            pointsLbl.text = pointsText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        walletButton.addTarget(self, action: #selector(MerchantCenterPointTableViewCell.walletClickAction), for: .touchUpInside)
        pointsButton.addTarget(self, action: #selector(MerchantCenterPointTableViewCell.pointsClickAction), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func walletClickAction() {
        guard let block = walletClickBlock else {
            return
        }
        block()
    }
    
    func pointsClickAction() {
        guard let block = pointsClickBlock else {
            return
        }
        block()
    }

}
