//
//  NotificationAndMessageController.swift
//  AdForMerchant
//
//  Created by lieon on 2017/3/17.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit
import Whisper
import ObjectMapper
import CHPushSocket

class NotificationAndMessageController: NSObject {
   private  static var window: UIWindow? = UIApplication.shared.keyWindow
   private static var rootVC: UITabBarController? = window?.rootViewController as? UITabBarController
   private static var rootNavi: UINavigationController? = rootVC?.selectedViewController as? UINavigationController
    /// 记录系统公告
    private static var systemContent: String?
   
    static func save(pushToken: String, registerID: String) {
        let param: [String: Any] = ["dt": pushToken,
                                      "dm": "1",
                                      "registration_id": registerID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.savePushToken(param, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, _, _, _) in
        }
    }
    
    static func display(notification: [String: Any]) {
        print("----\(notification)")
      guard let alter = notification["alert"] as? [String: Any], let title = alter["title"] as? String else { return }
        systemContent = alter["body"] as? String
        let announcement = Announcement(title: title, subtitle: alter["body"] as? String ?? "", image: nil, duration: 4) {
            handle(notification: notification)
        }
        
        show(shout: announcement, to: window?.rootViewController ?? UIViewController())
    }
    
    static func handle(message: [String: Any]) {
        print("******message******: \(message)")
        guard let extras = message["extras"] as? [String: Any] else { return  }
        guard let actionString = extras["action"] as? String, let action = URLAction(rawValue: actionString) else { return  }
        switch action {
        case .gotoPage:
            guard let model = Mapper<GotoPageData>().map(JSON: extras) else { return  }
            handle(pageID: model.extra?.pageID)
        case .showDetail:
            guard let model = Mapper<ShowDetailData>().map(JSON: extras) else { return  }
            showDetailPaage(data: model)
        default:
            break
        }
    }
    
    static func handle(notification: [String: Any]) {
        guard let extras = notification["extras"] as? [String: Any] else { return  }
        guard let actionString = extras["action"] as? String, let action = URLAction(rawValue: actionString) else { return  }
        switch action {
        case .gotoPage:
            guard let model = Mapper<GotoPageData>().map(JSON: extras) else { return  }
            handle(pageID: model.extra?.pageID, isMessage: false)
        case .showDetail:
            guard let model = Mapper<ShowDetailData>().map(JSON: extras) else { return  }
            showDetailPaage(data: model)
        default:
            break
        }
    }
    
    private static func handle(pageID: PageID?, isMessage: Bool = true) {
        guard let id = pageID else { return  }
        
        if let rootvc = window?.rootViewController as? UINavigationController {
            guard let wantVC = (rootvc.visibleViewController ?? UIViewController()) as? WantCollectViewController else {return}
            if wantVC.isKind(of: WantCollectViewController.self) {
                
                wantVC.qrCodeCoverView.dissmiss()
                     guard  let vc = AOLinkedStoryboardSegue.sceneNamed("MyCollect@MerchantCenter") as? MyCollectViewController  else { return }
                    vc.isEdge = true
                    rootvc.pushViewController(vc, animated: true)
                    return
            }
        }
        guard let tabVC = window?.rootViewController as? UITabBarController else { return }
        switch id {
        case .privilegeList:
            guard  let vc = AOLinkedStoryboardSegue.sceneNamed("MyCollect@MerchantCenter") as? MyCollectViewController  else { return }
            
            guard let nvc = tabVC.selectedViewController as? UINavigationController, let visibleVC = nvc.visibleViewController as? WantCollectViewController else { return }
            if !visibleVC.isQRDismiss && isMessage {
                nvc.pushViewController(vc, animated: true)
            }
        case .authenticate:
            pushToAuthenticateVC()
        default:
            break
        }
    }
    
   private static func showDetailPaage(data: ShowDetailData) {
        guard let extraData = data.extra, let contentID = data.extra?.contentID else { return  }
        switch extraData.contentType {
        case .goods:
            pushToProductDetailVC(productID: contentID)
        case .placeCampaign:
            pushToPlaceCampaignVC(campId: contentID)
        case .saleCampaign:
            pushToSaleCampaignVC(campId: contentID)
        case .advertise:
            pushAdDetailVC(adID: contentID)
        case .goodsRefund, .serviceRefund:
            pushToRefundDetailVC(orderID: contentID)
        case .order:
            pushToOrderDetailVC(orderID: contentID)
        case .staff:
            pushToMystuffVC()
        case .addStockNum:
            pushToEditProductVCAddStockNum(productID: contentID)
        case .deferService:
            pushToEditServiceProductVCDefer(productID: contentID)
        case .system:
             guard let content = systemContent else { return  }
            pushToSystemNotificationDetail(content: content)
            break
        default:
            break
        }
    }
    
   private static func pushToProductDetailVC(productID: String?) {
        guard let destVC = R.storyboard.product.productDetail(), let productID = productID  else { return }
        destVC.productID = productID
        rootNavi?.pushViewController(destVC, animated: true)
    }
    private static func pushToPlaceCampaignVC(campId: String) {
        guard let destVC = R.storyboard.campaign.campaignPlaceDetail(), let campId = Int(campId) else { return  }
        destVC.campId = campId
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    private static func pushToSaleCampaignVC(campId: String) {
         guard let destVC = R.storyboard.campaign.campaignSaleDetail(), let campId = Int(campId) else { return  }
        destVC.campId = campId
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    /// 商品编辑页仅可补充库存
    private static func pushToEditProductVCAddStockNum(productID: String) {
        guard let destVC = R.storyboard.product.productEdit() else {  return  }
        destVC.isAddStockNum = true
        destVC.modifyType = .edit
        destVC.productID = productID
        destVC.productType = .normal
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    /// 商品编辑页仅可延期
    private static func pushToEditServiceProductVCDefer(productID: String) {
        guard let destVC = R.storyboard.product.productEdit() else {  return  }
        destVC.productID = productID
        destVC.modifyType = .edit
        destVC.productType = .service
        destVC.productID = productID
        destVC.isdefer = true
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    /// 商品编辑页
    private static func pushToEditServiceProductVC(productID: String, productType: ProductType) {
        guard let destVC = R.storyboard.product.productEdit() else {  return  }
        destVC.productID = productID
        destVC.modifyType = .edit
        destVC.productType = productType
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    /// 广告详情页
    private static func pushAdDetailVC(adID: String) {
        guard let destVC = R.storyboard.ad.adDetail() else {  return  }
        destVC.adID = adID
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    /// 我的店员页面
    private static func pushToMystuffVC() {
         guard let destVC = R.storyboard.merchantCenter.myShopAssistantViewController() else { return  }
         rootNavi?.pushViewController(destVC, animated: true)
    }

    /// 认证页面
    private static func pushToAuthenticateVC() {
         guard let destVC = R.storyboard.merchantCenter.verificationStatus() else { return  }
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    /// 优惠买单列表页
    private static func pushToPrivilist() {
        guard  let vc = AOLinkedStoryboardSegue.sceneNamed("MyCollect@MerchantCenter") as? MyCollectViewController  else { return }
        rootNavi?.pushViewController(vc, animated: true)
    }
    
    /// 订单详情
    private static func pushToOrderDetailVC(orderID: String) {
        guard let destVC = R.storyboard.merchantCenter.orderDetail(), let orderID = Int(orderID) else { return  }
        destVC.orderId = orderID
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    /// 退款订单详情
    private static func pushToRefundDetailVC(orderID: String) {
        guard let destVC = R.storyboard.merchantCenter.refundOrderDetail(), let orderID = Int(orderID) else { return  }
        destVC.orderId = orderID
        rootNavi?.pushViewController(destVC, animated: true)
    }
    
    private static func pushToSystemNotificationDetail(content: String) {
        let destVC = NoticeDetailViewController()
        destVC.notice = content
        rootNavi?.pushViewController(destVC, animated: true)
    }
}
