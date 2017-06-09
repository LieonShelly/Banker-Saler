//
//  SaleCouponInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 4/6/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 "id": "1",
 "order_id": "1",
 "goods_id": "1",
 "status": "1",
 "code": "9999-8888-7234",
 "expire_time": "2016-09-03 12:33:33",
 "used_time": "2015-09-03 12:33:33",
 "title": "星巴克7折优惠券",
 "price": "99",
 "user_id": "1",
 "mobile": "18011418888",
 "name": "我不是老司机",
 "avatar": "http:\/\/v1.qzone.cc\/avatar\/201408\/20\/17\/23\/53f468ff9c337550.jpg%21200x200.jpg"
 
 */

struct SaleCouponInfo: Mappable {
    var id: Int = 0
    var orderId: String = ""
    var goodsId: String = ""
    var status: String = ""
    var code: String = ""
    var expireTime: String = ""
    var usedTime: String = ""
    var title: String = ""
    var price: String = ""
    var userId: String = ""
    var mobile: String = ""
    var name: String = ""
    var avatar: String = ""
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id  <- (map["id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        orderId     <- map["order_id"]
        goodsId     <- map["goods_id"]
        status     <- map["status"]
        code     <- map["code"]
        expireTime     <- map["expire_time"]
        usedTime     <- map["used_time"]
        title     <- map["title"]
        price     <- map["price"]
        userId     <- map["user_id"]
        mobile     <- map["mobile"]
        name     <- map["name"]
        avatar     <- map["avatar"]
        
    }
}
