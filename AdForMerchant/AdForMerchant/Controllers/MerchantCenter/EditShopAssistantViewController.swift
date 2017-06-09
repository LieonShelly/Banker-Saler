//
//  EditShopAssistantViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/19.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class EditShopAssistantViewController: BaseViewController {
    var staffModel: Staff?
    var staffID = ""
    fileprivate lazy var contentView: EditStaffContentView = {
        let contentView = EditStaffContentView.contentView()
        return contentView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        handAction()
    }
    
}

extension EditShopAssistantViewController {
    fileprivate func setupUI() {
        navigationItem.title = "编辑店员"
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(view.snp.size)
        }
        if staffID == "" {
            contentView.staffModel = staffModel
        } else {
            contentView.staffID = staffID            
        }
    }
    
    fileprivate func handAction() {
        contentView.helpAction = {
            self.showAlter()
        }
        contentView.tapAction = {[unowned self] staff in
            if self.isValidInput(staff) {
                self.updateStaff(staff)
            } else {
                self.showAlter()
            }
            
        }
    }
    
    fileprivate  func showAlter() {
        let messageStr = "商家可以设置两种角色，“服务员”只能接受客人打赏，而“收银员”除了可以接受客人打赏之外，还具备收单，扫消费码的权限，请商家根据需要设置"
        let messageText = NSMutableAttributedString(string: messageStr)
        messageText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("007aff"), range: NSRange(location: 11, length: 5))
        messageText.addAttributes([NSForegroundColorAttributeName: UIColor.colorWithHex("007aff"), NSFontAttributeName: UIFont.systemFont(ofSize: 13)], range: NSRange(location: 11, length: 5))
        messageText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("007aff"), range: NSRange(location: 26, length: 5))
        messageText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: messageStr.characters.count))
        let noRemandStr = "不再提醒"
        let alter = UIAlertController(title: "温馨提示", message: messageStr, preferredStyle: .alert)
        alter.setValue(messageText, forKey: "attributedMessage")
        let action0 = UIAlertAction(title: noRemandStr, style: .default, handler: nil)
        let action1 = UIAlertAction(title: "我知道了", style: .default, handler: nil)
        action0.setValue(UIColor.lightGray, forKey: "titleTextColor")
        alter.addAction(action0)
        alter.addAction(action1)
        self.present(alter, animated: true, completion: nil)
    }
    
  fileprivate func isValidInput(_ staffModel: Staff) -> Bool {
    guard  let title = staffModel.limits.title else {
        return false
     }
    return title == "服务员" || title == "收银员"
 }
    
   fileprivate func updateStaff(_ staff: Staff) {
    guard let staffID = staff.staffID else {return}
    guard let name = staff.name else {return}
    let param = ["staff_id": staffID,
                 "name": name]
    let aesKey = AFMRequest.randomStringWithLength16()
    let aesIV = AFMRequest.randomStringWithLength16()
    RequestManager.request(AFMRequest.modifyStaff(param, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, object, error, msg) in
//        print("----------\(msg)")
        if let message = msg, !message.characters.isEmpty {
            let alter = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "我知道了", style: .default, handler: nil)
            alter.addAction(action)
            self.present(alter, animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    }
}
