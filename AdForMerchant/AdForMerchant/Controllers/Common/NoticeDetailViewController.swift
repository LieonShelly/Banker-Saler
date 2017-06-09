//
//  NoticeDetailViewController.swift
//  AdForMerchant
//
//  Created by 糖otk on 2016/12/14.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class NoticeDetailViewController: BaseViewController {

    lazy var noticeLabel: UILabel = {
       let noticeLabel = UILabel()
        noticeLabel.frame = CGRect(x: 20, y: 70, width: screenWidth-40, height: 0)
        noticeLabel.numberOfLines = 0
        noticeLabel.font = UIFont.systemFont(ofSize: 15)
        return noticeLabel
    }()
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.frame = CGRect(x: 20, y: 50, width: screenWidth-40, height: 20)
        timeLabel.numberOfLines = 0
        timeLabel.textColor = UIColor.gray
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        return timeLabel
    }()
    
    lazy var headTitleLabel: UILabel = {
        let headTitleLabel = UILabel()
        headTitleLabel.frame = CGRect(x: 20, y: 20, width: screenWidth-40, height: 0)
        headTitleLabel.numberOfLines = 0
        headTitleLabel.font = UIFont.systemFont(ofSize: 17)
        return headTitleLabel
    }()
    
    var notice = ""
    var time = ""
    var headTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupUI() {
        title = "消息详情"
        view.addSubview(noticeLabel)
        view.addSubview(timeLabel)
        view.addSubview(headTitleLabel)
        
        view.backgroundColor = UIColor.white
        noticeLabel.text = notice
        timeLabel.text = time
        headTitleLabel.text = headTitle
        
        noticeLabel.height = String.getLabHeigh(notice, font: UIFont.systemFont(ofSize: 15), width: screenWidth-40)
        headTitleLabel.height = String.getLabHeigh(notice, font: UIFont.systemFont(ofSize: 17), width: screenWidth-40)
        noticeLabel.y = headTitleLabel.height + 70
        timeLabel.y = headTitleLabel.height + 30
    }
    
}
