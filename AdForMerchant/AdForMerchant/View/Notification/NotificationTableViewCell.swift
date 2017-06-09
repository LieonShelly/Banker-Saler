//
//  NotificationTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/2/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var contentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var checkDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ info: NotificationModel) {
        if info.isReaded == .isRead {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
            nameLabel.textColor = UIColor.lightGray
            contentLabel.textColor = UIColor.lightGray
            checkDetailLabel.textColor = UIColor.lightGray
        } else {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
            nameLabel.textColor = UIColor.black
            contentLabel.textColor = UIColor.black
            checkDetailLabel.textColor = UIColor.black
        }
        if info.buttonTxt == "编辑商品"{
            self.checkDetailLabel.text = "编辑商品 >"
            self.lineView.backgroundColor = UIColor.groupTableViewBackground
        } else if info.buttonTxt == "查看详情" {
            self.checkDetailLabel.text = "查看详情 >"
            self.lineView.backgroundColor = UIColor.groupTableViewBackground
        } else if info.buttonTxt == "补充库存" {
            self.checkDetailLabel.text = "补充库存 >"
            self.lineView.backgroundColor = UIColor.groupTableViewBackground
        } else {
            self.checkDetailLabel.text = ""
            self.lineView.backgroundColor = UIColor.white
        }
        contentLabel.text = info.content
        nameLabel.text = info.title
        timeLabel.text = info.created.judgeTime()
    }

    func config(_ info: MyNotificationModel) {
        if info.isReaded == .isRead {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
            nameLabel.textColor = UIColor.lightGray
            contentLabel.textColor = UIColor.lightGray
            checkDetailLabel.textColor = UIColor.lightGray
        } else {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
            nameLabel.textColor = UIColor.black
            contentLabel.textColor = UIColor.black
            checkDetailLabel.textColor = UIColor.black
        }
        if info.buttonTxt == "编辑商品"{
            self.checkDetailLabel.text = "编辑商品 >"
            self.lineView.backgroundColor = UIColor.groupTableViewBackground
        } else if info.buttonTxt == "查看详情"{
            self.checkDetailLabel.text = "查看详情 >"
            self.lineView.backgroundColor = UIColor.groupTableViewBackground
        } else if info.buttonTxt == "补充库存"{
            self.checkDetailLabel.text = "补充库存 >"
            self.lineView.backgroundColor = UIColor.groupTableViewBackground
        } else {
            checkDetailLabel.text = ""
            lineView.backgroundColor = UIColor.white
        }
        contentLabel.text = info.content
        nameLabel.text = info.title
        timeLabel.text = info.created.judgeTime()
    }
}
