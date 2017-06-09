//
//  NotificationModel.swift
//  AdForMerchant
//
//  Created by YYQ on 16/4/5.
//  Copyright © 2016年 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

class NotificationModel: Mappable {
    var noticeID: String = ""
    var title: String = ""
    var publishTime: String = ""
    var detailUrl: String = ""
    var isReaded: MessageType = .unRead
    var content: String = ""
    var created: String = ""
    var extra: ExtraModel?
    var buttonTxt = ""
    init () {
    
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        noticeID    <- map["notice_id"]
        title   <-  map["title"]
        publishTime    <- map["pubtime"]
        detailUrl   <- map["detail_url"]
        isReaded    <- map["is_readed"]
        content <- map["content"]
        created <- map["created"]
        extra <- map["extra"]
        buttonTxt <- map["button_txt"]
    }
}

class MyNotificationModel: Mappable {
    var noticeID: String = ""
    var title: String = ""
//    var type: String = ""
    var created: String = ""
    var detailUrl: String = ""
    var isReaded: MessageType = .unRead
    var content: String = ""
    var type = ""
    var buttonTxt = ""
    var action = ""
    
    var goodsId: Int = 0
    var goodsType: Int = 0
    var eventId: Int = 0
    var eventCat: Int = 0
    var adId: Int = 0
    var approvedFailed: Int = -1
    var orderId: Int = 0
    var refundId: Int = 0
    var extra: ExtraModel?
    
    init () {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        noticeID    <- map["notice_id"]
        title   <-  map["title"]
        created    <- map["created"]
        detailUrl   <- map["detail_url"]
        isReaded    <- map["is_readed"]
        content <- map["content"]
        type <- map["type"]
        buttonTxt <- map["button_txt"]
        /*
         "notice_id": "7",
         "type": "10504",
         "title": "用户完成付款",
         "content": "订单号20161014082137132773\n用户完成
         "created": "2016-10-14 08:21:44",
         "is_readed": "0",
         "button_txt": "查看详情"
         */
        
//        type <- (map["type"], TransformOf<MyNotificationType, String>(fromJSON: { MyNotificationType(rawValue: Int($0!) ?? 0) }, toJSON: { $0.map { String($0) } }))
        
        action <- (map["extra.action"])
        extra <- map["extra"]
        goodsId <- (map["extra.goods_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))
        goodsType <- (map["extra.goods_type"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))
        eventId <- (map["extra.event_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))
        eventCat <- (map["extra.event_cat"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))
        adId <- (map["extra.ad_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))
        approvedFailed <- (map["extra.approved_failed"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))
        orderId <- (map["extra.order_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))
        refundId <- (map["extra.refund_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "") }, toJSON: { $0.map { String($0) }}))

    }
}

class ExtraModel: Mappable {
    var action: ActionType = .noActionType
    var noticeID = ""
    var extra: Extra2Model?
    var buttonTxt = ""
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        noticeID    <- map["notice_id"]
        action   <-  map["action"]
        extra <- map["extra"]
        buttonTxt <- map["buttonTxt"]
    }
}

class Extra2Model: Mappable {
    
    var url = ""
    var contentType: DetailContentType = .invest
    var contentID = ""
    var isEdit = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        contentType    <- map["content_type"]
        isEdit   <- map["is_edit"]
        contentID    <- map["content_id"]
        url <- map["url"]
    }
}
