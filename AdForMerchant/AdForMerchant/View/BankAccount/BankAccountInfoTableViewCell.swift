//
//  BankAccountInfoTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 3/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class BankAccountCardTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var cardNumLbl: UILabel!

    var cardNumber: String = "" {
        didSet {
            if cardNumber.characters.count > 4 {
                self.cardNumLbl.text = "**** **** **** \(cardNumber.substring(from: cardNumber.characters.index(cardNumber.startIndex, offsetBy: cardNumber.characters.count - 4)))"
            } else {
                self.cardNumLbl.text = "**** **** **** \(cardNumber)"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

class BankAccountInfoTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var bankImg: UIImageView!
    @IBOutlet fileprivate weak var bankNameLbl: UILabel!
    @IBOutlet fileprivate weak var cardNumLbl: UILabel!
    
    @IBOutlet fileprivate weak var selectedButton: UIButton! // Used for 添加新银行卡
    
    var cardNumber: String = "" {
        didSet {
            self.cardNumLbl.text = cardNumber
        }
    }
    
    var bankCardSelected: Bool = false {
        didSet {
            selectedButton.isHidden = !bankCardSelected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bankImg.image = UIImage(named: "PlaceHolderMianyangBankLogo")
        bankNameLbl.text = "绵阳商业银行"
        cardNumLbl.textColor = UIColor.commonBlueColor()
        selectedButton.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ imageName: String, bankName: String) {
        bankImg.image = UIImage(named: imageName)
        bankNameLbl.text = bankName
    }
    
}
