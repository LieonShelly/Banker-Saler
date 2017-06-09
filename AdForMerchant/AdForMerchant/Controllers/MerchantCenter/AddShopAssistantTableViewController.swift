//
//  AddShopAssistantTableViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import SnapKit

class AddShopAssistantTableViewController: BaseViewController {
    fileprivate lazy var contenView: AddShopAssistantContentView = {
        let contenView = AddShopAssistantContentView.contentView()
        return contenView
    }()

    fileprivate var shopStaff: Staff = Staff()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        handleAction()
        
    }

}

extension AddShopAssistantTableViewController {
    fileprivate func setupUI() {
        navigationItem.title = "添加店员"
        view.addSubview(contenView)
        contenView.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(view.snp.size)
        }
    }
    
    fileprivate  func handleAction() {
        contenView.tapAction = {[unowned self] staffModel in
            guard let mobile = staffModel.mobile else {return}
            guard let name = staffModel.name else {return}
            if name.isEmpty {
                Utility.showAlert(self, message: "店员姓名不能为空")
                return
            }
            if !Utility.isValidatePersonName(name) {
                Utility.showAlert(self, message: "请输入五位汉字或英文，不支持字符")
                return
            }
            if !Utility.isValidateMobile(mobile) {
                
                Utility.showAlert(self, message: "请输入正确的手机号码")
                return
            }
            
            let param = ["mobile": mobile,
                         "name": name,
                         "limits": staffModel.limits.rawValue]
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
            RequestManager.request(AFMRequest.addStaff(param, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV), completionHandler: { [unowned self] (_, _, object, error, msg) in
                if let message = msg, !message.characters.isEmpty {
                    let alter = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let action = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                    alter.addAction(action)
                    self.present(alter, animated: true, completion: nil)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
            
        }
        contenView.helpAction = { [unowned self] in
            self.showAlter()
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
//        alter.addAction(action0)
        alter.addAction(action1)
        self.present(alter, animated: true, completion: nil)
  }
}
