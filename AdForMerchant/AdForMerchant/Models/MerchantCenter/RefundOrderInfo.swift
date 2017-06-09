//
//  RefundOrderInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 4/21/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct RefundOrderInfo: Mappable {
    var id: Int = 0
    var orderId: Int = 0
    var orderNumb: String = ""
    var orderType: String = ""
//    var status: String = ""
    var refundStatus: OrderRefundStatus = .noInfo
    var refundAmount: String = ""
    
    var created: String = ""
    var applyTime: String = ""
    var dealTime: String = ""
    
    var username: String = ""
    var name: String = ""
    var mobile: String = ""
    var address: String = ""
    var goodsCount: String = ""
    var totalPrice: String = ""
    var revisedPrice: String = ""
    var payablePrice: String = ""
    var point: String = ""
    var pointPrice: String = ""
    var actualPrice: String = ""
    var images: [String] = []
    var remark = ""
    var reason = ""
    var totalDiscount: String = ""
    var deliveryCost: String = ""
    var orderGoods: [ProductModel] = []
    
    init(map: Map) {
        
    }
    
    /*
     refund_id": "1",
     "order_id": "1",
     "order_no": "清风厕纸",
     "order_type": 1,
     "refund_status": 1,
     "refund_amount": 900,
     "created": "2015-07-01 18:00",
     "name": "20.00",
     "mobile": "25.00",
     "address": "8.00",
     "goods_num": "2",
     
     "applytime": "2015-07-07 17:01:01",
     "dealtime": "2015-07-07 17:01:01"
     
     "total_price": "9000",
     "revised_price": "8900",
     "payable_price": "8900",
     "total_discount": 100,
     "delivery_cost": 18,
     "order_goods
     */
    mutating func mapping(map: Map) {
        id  <- (map["refund_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        orderId  <- (map["order_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        orderNumb     <- map["order_no"]
        orderType     <- map["order_type"]
        
        refundStatus <- (map["refund_status"], TransformOf<OrderRefundStatus, String>(fromJSON: {
            if $0 != nil {
                return OrderRefundStatus(rawValue: Int($0 ?? "") ?? 0)
            } else {
                return OrderRefundStatus.noInfo
            }}, toJSON: { $0.map { String(describing: $0) } }))
        
        refundAmount     <- map["refund_amount"]
        refundAmount     <- map["amount"] // Fix issue where Order Info Model has no "refund_amount" but "amount"
        
        created     <- map["created"]
        applyTime     <- map["applytime"]
        dealTime     <- map["dealtime"]
        
        username     <- map["username"]
        name     <- map["name"]
        mobile     <- map["mobile"]
        address     <- map["address"]
        goodsCount     <- map["goods_num"]
        
        totalPrice     <- map["total_price"]
        revisedPrice     <- map["revised_price"]
        payablePrice     <- map["payable_price"]
        point     <- map["point"]
        pointPrice     <- map["point_price"]
        actualPrice     <- map["actual_price"]
        totalDiscount     <- map["total_discount"]
        deliveryCost     <- map["delivery_cost"]
        orderGoods     <- map["order_goods"]
        images <- map["images"]
        remark <- map["remark"]
        reason <- map["reason"]
    }
}
