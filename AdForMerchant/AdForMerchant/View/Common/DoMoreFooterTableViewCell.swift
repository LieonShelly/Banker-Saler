//
//  DoMoreFooterTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 5/10/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class DoMoreFooterTableViewCell: UITableViewCell {
    
    @IBOutlet internal var rightButton1: UIButton!
    @IBOutlet internal var rightButton2: UIButton!
    @IBOutlet internal var rightButton3: UIButton!
    @IBOutlet weak var rightButton4: UIButton!
    @IBOutlet weak var rightButton5: UIButton!
    
    var buttonTitle1: String? {
        didSet {
            if buttonTitle1 == nil {
                rightButton1.isHidden = true
            } else {
                rightButton1.isHidden = false
                rightButton1.setTitle(buttonTitle1, for: UIControlState())
            }
        }
    }
    var buttonTitle2: String? {
        didSet {
            if buttonTitle2 == nil {
                rightButton2.isHidden = true
            } else {
                rightButton2.isHidden = false
                rightButton2.setTitle(buttonTitle2, for: UIControlState())
            }
        }
    }
    var buttonTitle3: String? {
        didSet {
            if buttonTitle3 == nil {
                rightButton3.isHidden = true
            } else {
                rightButton3.isHidden = false
                rightButton3.setTitle(buttonTitle3, for: UIControlState())
            }
        }
    }
    var buttonTitle4: String? {
        didSet {
            if buttonTitle4 == nil {
                rightButton4.isHidden = true
            } else {
                rightButton4.isHidden = false
                rightButton4.setTitle(buttonTitle4, for: UIControlState())
            }
        }
    }
    var buttonTitle5: String? {
        didSet {
            if buttonTitle5 == nil {
                rightButton5.isHidden = true
            } else {
                rightButton5.isHidden = false
                rightButton5.setTitle(buttonTitle5, for: UIControlState())
            }
        }
    }
    
    var buttonBlock1: ((DoMoreFooterTableViewCell) -> Void)?
    var buttonBlock2: ((DoMoreFooterTableViewCell) -> Void)?
    var buttonBlock3: ((DoMoreFooterTableViewCell) -> Void)?
    var buttonBlock4: ((DoMoreFooterTableViewCell) -> Void)?
    var buttonBlock5: ((DoMoreFooterTableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightButton1.isHidden = true
        rightButton2.isHidden = true
        rightButton3.isHidden = true
        
        rightButton1.addTarget(self, action: #selector(self.buttonAction1(_:)), for: .touchUpInside)
        rightButton2.addTarget(self, action: #selector(self.buttonAction2(_:)), for: .touchUpInside)
        rightButton3.addTarget(self, action: #selector(self.buttonAction3(_:)), for: .touchUpInside)
        rightButton4.addTarget(self, action: #selector(self.buttonAction4(_:)), for: .touchUpInside)
        rightButton5.addTarget(self, action: #selector(self.buttonAction5(_:)), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //    func config(leftTxt: String, otherInfo: String) {
    //
    //        leftTxtLabel.text = leftTxt
    //        rightTxtLabel.text = otherInfo
    //    }
    
    func buttonAction1(_ sender: AnyObject) {
        if let block = buttonBlock1 {
            block(self)
        }
    }
    
    func buttonAction2(_ sender: AnyObject) {
        if let block = buttonBlock2 {
            block(self)
        }
    }
    
    func buttonAction3(_ sender: AnyObject) {
        if let block = buttonBlock3 {
            block(self)
        }
    }
    
    func buttonAction4(_ sender: AnyObject) {
        if let block = buttonBlock4 {
            block(self)
        }
    }
    
    func buttonAction5(_ sender: AnyObject) {
        if let block = buttonBlock5 {
            block(self)
        }
    }
}
