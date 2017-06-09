//
//  VerifactionTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/22/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class VerificationPhotoUploadCell: UITableViewCell {
    
    @IBOutlet fileprivate var photoUploadButton: UIButton!
    
    var buttonClickBlock: ((VerificationPhotoUploadCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        photoUploadButton.addTarget(self, action: #selector(self.clickPhotoUploadButton), for: .touchUpInside)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func clickPhotoUploadButton() {
        if let block = buttonClickBlock {
            block(self)
        }
    }
    
}

class CredentialPhotoUploadCell: UITableViewCell {
    
    @IBOutlet var photoUploadButton1: UIButton!
    @IBOutlet var photoUploadButton2: UIButton!
    @IBOutlet var photoUploadButton3: UIButton!
    @IBOutlet var photoUploadButton4: UIButton!
    @IBOutlet var photoUploadButton5: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class VerificationPhotoCell: UITableViewCell {
    
    @IBOutlet var photoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class RightSegmentCell: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var rightSegmentCtrl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class VerificationStatusCell: UITableViewCell {
    
    @IBOutlet fileprivate var bgViewInProcess: UIView!
    @IBOutlet fileprivate var bgViewSuccess: UIView!
    @IBOutlet fileprivate var bgViewFailed: UIView!
    @IBOutlet fileprivate var bgViewFailedLabel: UILabel!
    
    var failedTxt: String = "" {
        didSet {
            bgViewFailedLabel.text = failedTxt
        }
    }
    
    var status: LicenseVerifyStatus = .unverified {
        didSet {
            switch status {
            case .unverified:
                break
            case .waitingForReview:
                bgViewInProcess.isHidden = false
                bgViewSuccess.isHidden = true
                bgViewFailed.isHidden = true
            case .verifyFailed:
                bgViewInProcess.isHidden = true
                bgViewSuccess.isHidden = true
                bgViewFailed.isHidden = false
            case .verified:
                bgViewInProcess.isHidden = true
                bgViewSuccess.isHidden = false
                bgViewFailed.isHidden = true
                
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
