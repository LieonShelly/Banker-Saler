//
//  ShareViewController.swift
//  AdForMerchant
//
//  Created by KUMA on 16/2/26.
//  Copyright © 2016年 KUMA. All rights reserved.
//

import UIKit
import MonkeyKing

public enum ShareType: Int {
    case wechatFriends
    case wechatCircle
    case qqFriends
    case copyLink
}

class ShareViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    
    var shareTitle: String! //标题
    var shareDetailLink: String! //链接
    
    var shareItems: [ShareType] = []
    
    var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViews()
        // monkeyking 注册微信和QQ 绵商行商户版
        MonkeyKing.registerAccount(.qq(appID: kQQAppId))
        MonkeyKing.registerAccount(.weChat(appID: kWeixinAppID, appKey: nil))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let availableShareBtnCount = shareItems.count
        let shareButtonSingleLine = availableShareBtnCount > 4 ? false : true
        let footerViewHeight: CGFloat =  230 - (shareButtonSingleLine ? 85 : 0)
        UIView.animate(withDuration: 0.3) {
            self.footerView.frame = CGRect(x: 0, y: screenHeight - footerViewHeight, width: screenWidth, height: footerViewHeight)
        }
        
    }
    
    // MARK: - Initial Views
    
    func initialViews() {
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.7
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cancelShare)))
        view.addSubview(bgView)
        
        let availableShareBtnCount = shareItems.count
        
        let shareButtonSingleLine = availableShareBtnCount > 4 ? false : true
        
        let footerViewHeight: CGFloat =  230 - (shareButtonSingleLine ? 85 : 0)
        
        footerView = UIView(frame:CGRect(x: 0, y: screenHeight, width: screenWidth, height: footerViewHeight))
        footerView.backgroundColor = UIColor.white
        view.addSubview(footerView)
        
        for (index, itemType) in shareItems.enumerated() {
            
            let row: CGFloat = CGFloat(index / 4)
            let column: CGFloat = CGFloat(index % 4)
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: ceil(screenWidth / 4 * column), y: 85 * row + 12, width: ceil(screenWidth / 4), height: 60)
            btn.tag = 1000 + itemType.rawValue
            btn.addTarget(self, action: #selector(self.shareButtonClicked), for: .touchUpInside)
            footerView.addSubview(btn)
            
            let titleLbl = UILabel(frame:CGRect(x: btn.frame.minX, y: btn.frame.maxY, width: btn.frame.width, height: 15))
            titleLbl.textAlignment = .center
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor(red: 81/255.0, green:92/255.0, blue:104/255.0, alpha:1.0)
            footerView.addSubview(titleLbl)
            
            switch itemType {
            case .wechatFriends:
                btn.setImage(UIImage(named: "ShareBtnWechat"), for: .normal)
                titleLbl.text = "微信好友"
            case .wechatCircle:
                btn.setImage(UIImage(named: "ShareBtnTimeline"), for: .normal)
                titleLbl.text = "微信朋友圈"
            case .qqFriends:
                btn.setImage(UIImage(named: "ShareBtnQQ"), for: .normal)
                titleLbl.text = "QQ好友"
            case .copyLink:
                btn.setImage(UIImage(named: "ShareLink"), for: .normal)
                titleLbl.text = "复制链接"
            }
            
        }
        
        let lineView = UIView(frame:CGRect(x: 0, y: 10 + (shareButtonSingleLine ? 85 : 85 * 2), width: screenWidth, height: 1 / UIScreen.main.scale))
        lineView.backgroundColor = UIColor.lightGray
        footerView.addSubview(lineView)
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.frame = CGRect(x: 0, y: 10 + (shareButtonSingleLine ? 85 : 85 * 2), width: screenWidth, height: 50)
        cancelBtn.addTarget(self, action: #selector(self.cancelShare), for: .touchUpInside)
        cancelBtn.tintColor = UIColor.lightGray
        cancelBtn.setTitle("取消", for: .normal)
        footerView.addSubview(cancelBtn)
    }
    
    // MARK: - Transitioning Delegate
    
    ///实现转场 present 代理方法
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SharePresentingAnimationor()
    }
    ///实现转场 dismissed 代理方法
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShareDismissingAnimator()
    }
    
    // MARK: - Methods
    
    @objc func cancelShare() {
        dismiss(animated: true, completion: nil)
    }
    
    func shareButtonClicked(_ btn: UIButton) {
        
        let itemType = ShareType(rawValue: btn.tag - 1000) ?? .wechatFriends
        
        switch itemType {
        case .wechatFriends:
            weChatFriendsBtn(btn)
        case .wechatCircle:
            weChatFriendsCircleBtn(btn)
        case .qqFriends:
            QQFriendsBtn(btn)
        case .copyLink:
            copyLinkBtn(btn)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Button Action
    
    ///微信好友
    func weChatFriendsBtn(_ sender: UIButton) {
        //print("微信好友")
        weChatShare(0)
    }
    
    ///微信朋友圈
    func weChatFriendsCircleBtn(_ sender: UIButton) {
        //print("微信朋友圈")
        weChatShare(1)
    }
    
    ///QQ好友
    func QQFriendsBtn(_ sender: UIButton) {
        //print("QQ好友")
        guard let url = URL(string: shareDetailLink) else { return }
        let message = MonkeyKing.Message.qq(.friends(info: (title: shareTitle, description: nil, thumbnail: nil, media: .url(url))))
        
        MonkeyKing.deliver(message, completionHandler: { [weak self] (result) in
            let title = result ? "分享到QQ成功" : "分享到QQ失败"
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        })
    }
    
    ///复制链接
    func copyLinkBtn(_ sender: UIButton) {
        //print("复制链接")
        let paste = UIPasteboard.general
        paste.string = shareDetailLink
        Utility.showMBProgressHUDToastWithTxt("复制链接成功")
    }
    
    ///微信分享
    func weChatShare(_ messageType: Int32) {
        
        var message: MonkeyKing.Message? = nil
        guard let url = URL(string: shareDetailLink) else { return }
        if messageType == 0 {
            message = MonkeyKing.Message.weChat(.session(info: (title: shareTitle, description: nil, thumbnail: nil, media: .url(url))))
        } else {
            message = MonkeyKing.Message.weChat(.timeline(info: (title: shareTitle, description: nil, thumbnail: nil, media: .url(url))))
        }
        if let message = message {
            MonkeyKing.deliver(message, completionHandler: { [weak self] (result) in
                let title = result ? "分享到微信成功" : "分享到微信失败"
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    ///点击灰色部分 dismissed 控制器 事件
    func clickGrayView() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
