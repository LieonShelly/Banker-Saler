//
//  GuideCollectionViewCell.swift
//  Bank
//
//  Created by Tzzzzz on 16/8/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class GuideCollectionViewCell: UICollectionViewCell {
    
    lazy var guideImageView: UIImageView = {
        let guideImageView = UIImageView(frame:self.bounds)
        return guideImageView
    }()
    lazy var nextBtn: UIButton = {
        let nextBtn = UIButton()
        nextBtn.frame = CGRect(x: 0, y: 0, width: screenWidth-90, height: 45)
        nextBtn.backgroundColor = UIColor.clear
        nextBtn.addTarget(self, action: #selector(self.clickNextBtn), for: .touchUpInside)
        nextBtn.center.y = UIScreen.main.bounds.height * 0.85
        nextBtn.center.x = UIScreen.main.bounds.width * 0.5
        return nextBtn
    }()
    
    func congfigImage(_ image: UIImage?) {
        self.contentView.addSubview(guideImageView)
        self.guideImageView.image = image
    }
    
    func setStarBtnHidden(_ indexPath: IndexPath, count: Int) {
        if indexPath.item == count - 1 {
            self.contentView.addSubview(nextBtn)
            nextBtn.isHidden = false
        } else {
            nextBtn.isHidden = true
        }
    }
    
    func clickNextBtn() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: startAppNotification), object: self, userInfo: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
    
}
