//
//  OrderHeaderTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet internal var idNumbTxtLabel: UILabel!
    @IBOutlet internal var userImageView: UIImageView!
    @IBOutlet internal var userNameLabel: UILabel!
    @IBOutlet internal var rightTxtLabel: UILabel!
    @IBOutlet internal var moreButton: UIButton!
    
    internal var doMoreBlock: CellDoMoreBlock?
    
    func doMoreAction() {
        guard let block = doMoreBlock else {
            return
        }
        block(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moreButton.addTarget(self, action: #selector(self.doMoreAction), for: .touchUpInside)
        rightTxtLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ imgName: String, user: String, otherInfo: String) {
        userImageView.sd_setImage(with: URL(string: imgName), placeholderImage: UIImage(named: "OrderIconUser"))
        
        userNameLabel.text = user
        idNumbTxtLabel.text = otherInfo
    }

}
