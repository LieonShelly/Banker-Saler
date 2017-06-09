//
//  NetworkCommon.swift
//  AdForMerchant
//
//  Created by Kuma on 7/26/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation

let webviewPreviewProductPrefix = "https://ebusiness." + domainURL + "/webview/goods_detail?id="
let webviewPreviewSaleCampaignPrefix = "https://ebusiness." + domainURL + "/webview/event_detail?id="
let webviewPreviewPlaceCampaignPrefix = "https://marketing." + domainURL + "/webview/event_detail?id="
let webviewPreviewAdPrefix = "https://marketing." + domainURL + "/webview/ad_detail?id="

let webviewHelpDetailPrefix = "https://content." + domainURL + "/help/help_detail?tag="
let webviewAgreementPrefix = "https://content." + domainURL + "/webview/protocol?tag="
// https://content.msh.chcts.cc/help/index?platform=2
let webviewHelpNullTagDetailPrefix = "https://content." + domainURL + "/help/index?platform=2"

enum WebSeverErrorCode: Int {
    case needCharge = 1111
    case unknown = 9999
}

enum WebviewHelpDetailTag: String {
    /// 登录&注册
    
    // 登录/注册
    case signup = "0201"
    // 开店
    //case forgetPassword = "0202"
    case openShopCover = "0202"

    /// 商品
    
    // 发布普通商品
    case productAddCover = "0203"
    case productAddPoint = "0204"
    // 编辑普通商品
    case productEditCover = "0205"
    case productEditPoint = "0206"
    // 发布生活服务类商品
    case serviceProductAddCover = "0207"
    case serviceProductAddPoint = "0208"
    // 编辑生活服务类商品
    case serviceProductEditCover = "0209"
    case serviceProductEditPoint = "0210"
    
    /// 活动
    
    // 新建现场活动
    case campaignAddCover = "0211"
    case campaignAddPoint = "0212"
    case campaignAddNav = "0213"
    // 编辑现场活动
    case campaignEditCover = "0214"
    case campaignEditPoint = "0215"
    case campaignEditNav = "0216"
    // 新建促销活动
    case saleCampaignAddCover = "0217"
    case saleCampaignAddNav = "0218"
    // 编辑促销活动
    case saleCampaignEditCover = "0219"
    case saleCampaignEditNav = "0220"

    /// 商户中心
    
    // 商户认证
    case merchantVerificationNav = "0221"
    // 我的积分
    case pointRechargeNav = "0222"
    // 我的订单
    case merchantOrderNav = "0223"
    
    // 没有tag时 返回帮助中心
    case noHelpTag = "0"
    
    var desc: String {
        return "\(self.rawValue)"
    }
    
    var detailUrl: String {
        return webviewHelpDetailPrefix + "\(self.rawValue)"
    }
    
    var notagUrl: String {
        return webviewHelpNullTagDetailPrefix
    }
}

enum WebviewAgreementTag: String {
    case signup = "0201"
    //商户版	注册页面	填写列表按钮左下方	同意《商家入驻协议》	《商家入驻协议》	已有协议入口位置，需调整文案	0201
    case bankCard = "0202"
    //认证第四步－绑定银行卡页面	填写列表按钮左下方	同意《绑定银行卡协议》	《绑定银行卡协议》商户版	已有协议入口位置，需调整文案	0202
    case campaign = "0203"
    //新建&编辑现场活动页面	“发布”按钮左上方	同意《活动发布协议》	《活动发布协议》	需新增协议入口位置	0203
    case pointRecharge = "0204"
    //积分充值页面	填写列表按钮左下方	同意《积分充值协议》	《积分充值协议》	需新增协议入口位置	0204
    var desc: String {
        return "\(self.rawValue)"
    }
    
    var detailUrl: String {
        return webviewAgreementPrefix + "\(self.rawValue)"
    }
}
