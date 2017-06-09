//
//  SocketMessage.swift
//  AdForMerchant
//
//  Created by lieon on 2017/1/6.
//  Copyright © 2017年 Windward. All rights reserved.
//  swiftlint:disable redundant_string_enum_value

import UIKit
import ObjectMapper

/// 显示详情页
class ShowDetailData: URLData<ShowDetailExtra> {}

/// 跳转到指定页面的数据
class GotoPageData: URLData<GotoPageExtra> {
    override init() {
        super.init()
        action = URLAction.gotoPage
        extra = GotoPageExtra()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
}

class URLData<T: Mappable>: Mappable {
    var action: URLAction?
    var extra: T?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        action <- map["action"]
        extra <- map["extra"]
    }
}

public enum URLAction: String {
    /// 展示详情页
    case showDetail = "showDetail"
    /// 跳到指定页面
    case gotoPage = "gotoPage"
    /// 图片预览
    case previewImage = "previewImage"
    /// 展示普通商品参与所有的优惠
    case showGoodsPromos = "showGoodsPromos"
    /// 显示服务商品参与的店铺地址
    case showGoodsAddress = "showGoodsAddresses"
    /// 显示促销活动介绍
    case showEventIntro = "showEventIntroduce"
    /// 显示信用会员邀请普通会员
    case showUserInvitation = "showUserInvitation"
    /// 显示管家邀请信用会员
    case showButlerInvitation = "showBankerInvitation"
    /// 播放视频
    case showPlayVideo = "playVideo"
    /// 打开 URL
    case openURL = "openUrl"
    /// 添加店员
    case addStaff = "addMerchantStaff"
    /// 商家删除店员
    case delStaff = "showDelMerchantStaff"
    /// 店员绑定成功
    case bindingStaff = "bindingMerchantStaff"
    /// 获得免费打赏机会
    case getFreeAwardChance = "couponAwardStaff"
    /// 成功打赏服务员
    case staffGetTipsSuccess = "couponAwardStaffSuccess"
    /// 普通商品货号下的备选规格
    case alternativeGoods = "showAlternativeGoods"
    
    var path: String {
        switch self {
        case .gotoPage:
            return "goto_page"
        case .previewImage:
            return "preview_image"
        case .showDetail:
            return "show_detail"
        case .showGoodsAddress:
            return "show_goods_address"
        case .showGoodsPromos:
            return "show_goods_promos"
        case .showEventIntro:
            return "show_event_introduce"
        case .showUserInvitation:
            return "show_user_invitation"
        case .showButlerInvitation:
            return "show_butler_invitation"
        case .showPlayVideo:
            return "play_video"
        case .openURL:
            return "open_url"
        case .alternativeGoods:
            return "show_alternative_goods"
        default:
            return ""
        }
    }
}

class ShowDetailExtra: Mappable {
    var contentType: DetailContentType = .invest
    var contentID: String = ""
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        contentType <- map["content_type"]
        contentID <- map["content_id"]
    }
}

class GotoPageExtra: Mappable {
    var pageID: PageID?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        pageID <- map["page_id"]
    }
}

/// 内容分类
// FIXME:修改以下枚举的rawvalue
public enum DetailContentType: String {
    case invest = "1"
    case goods = "2"
    case shop = "3"
    case advertise = "4"
    case placeCampaign = "5"
    case saleCampaign = "6"
    case headline = "7"
    /// 订单
    case order = "8"
    case serviceGoods = "9"
    case coupon = "10"
    case butler = "11"
    case goodsRefund = "12"
    case serviceRefund = "13"
    case system = "14"
    case goodsCats = "15"
    case staff = "16"
    case addStockNum = "17"
    case deferService = "18"
}

public enum PageID: String {
    /// 优惠买单列表
    case privilegeList = "merchant/privilegeList"
    /// 认证
    case authenticate = "merchant/certify"
    case undefine = "undefine"
}
