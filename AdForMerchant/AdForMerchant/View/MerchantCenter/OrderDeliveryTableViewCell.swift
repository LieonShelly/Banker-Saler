//
//  OrderDeliveryTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderDeliveryTableViewCell: UITableViewCell {

    @IBOutlet internal var leftTxtLabel: UILabel!
//    @IBOutlet internal var rightButton: UIButton!
    @IBOutlet internal var centerTxtField: UITextField!
    
    var endEditingBlock: ((UITextField) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        centerTxtField.delegate = self
        
//        let qrCodeImg = UIImage(named: "NaviIconQRCode")?.imageWithRenderingMode(.AlwaysTemplate)
//        rightButton.setImage(qrCodeImg, forState: .Normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension OrderDeliveryTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let block = endEditingBlock {
            block(textField)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
