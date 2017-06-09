//
//  OrderDetail.swift
//  AdForMerchant
//
//  Created by Kuma on 4/21/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 
 "order_id": "1",
 "order_no": "清风厕纸",
 "created": "2015-07-01 18:00",
 "name": "20.00",
 "mobile": "25.00",
 "address": "8.00",
 "total_price": "9000",
 "revised_price": "8900",
 "delivery_cost": 18,
 "status": 1,
 "refund_status": 1,
 "refund_amount": 100,
 "refund_items": [
 {
 "refund_id": 1,
 "status": 3,
 "amount": 3,
 "total_price": 100,
 "applytime": "2015-07-07 17:01:01",
 "dealtime": "2015-07-07 17:01:01"
 }
 ],
 "pay_time": "2015-07-01 18:00",
 "ship_time": "2015-07-01 18:00",
 "arrival_time": "2015-07-01 18:00",
 "arrival_deadline": "2015-08-01 18:00",
 "close_time": "2015-07-01 18:00",
 "goods_num": 1,
 "order_goods": [
 {
 "goods_id": 1,
 "thumb": "http:\/\/v1.qzone.cc\/avatar\/201408\/20\/17\/23\/53f468ff9c337550.jpg%21200x200.jpg",
 "title": "清风厕纸",
 "type": "1",
 "price": "20.00",
 "num": 10
 }
 ],
 "logistics_company": "申通",
 "logistics_no": "1801830813"
 
 */

struct OrderDetail: Mappable {
    /*
    "order_id": "1",
    "order_no": "清风厕纸",
    "created": "2015-07-01 18:00",
    "name": "20.00",
    "mobile": "25.00",
    "address": "8.00",
    "total_price": "9000",
    "revised_price": "8900",
    "delivery_cost": 18,
    "status": 1,
    "refund_status": 1,
    "refund_amount": 100,
    refund_items
    
    "pay_time": "2015-07-01 18:00",
    "ship_time": "2015-07-01 18:00",
    "arrival_time": "2015-07-01 18:00",
    "arrival_deadline": "2015-08-01 18:00",
    "close_time": "2015-07-01 18:00",
    "goods_num": 1,
    "order_goods":
    
    "logistics_company": "申通",
    "logistics_no": "1801830813"
    */
    var id: Int = 0
    var orderNumb: String = ""
    var payNumb: String = ""
    
    var created: String = ""
    var username: String = ""
    var name: String = ""
    var mobile: String = ""
    var address: String = ""
    var postcode: String = ""
    var totalPrice: String = ""
    var revisedPrice: String = ""
    var payPrice: String = ""
    var point: String = ""
    var pointPrice: String = ""
    var actualPrice: String = ""
    var totalDiscount: String = ""
    var deliveryCost: String = ""
    var status: OrderStatus?
    var refundStatus: OrderRefundStatus?
    var refundAmount: String = ""
    var refundItems: [RefundOrderInfo] = []
    
    var payTime: String = ""
    var shipTime: String = ""
    var arrivalTime: String = ""
    var arrivalDeadline: String = ""
    var closeTime: String = ""
    var goodsCount: String = ""
    var orderGoods: [ProductModel] = []
    //是否可以延迟收货
    var canDeferConfirmDelivery: Bool = false
    
    var logisticsCompany: String = ""
    var logisticsNumb: String = ""
    
    init() {
        
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id  <- (map["order_id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        
        orderNumb     <- map["order_no"]
        payNumb <- map["pay_no"]
        created     <- map["created"]
        username     <- map["username"]
        name     <- map["name"]
        mobile     <- map["mobile"]
        address     <- map["address"]
        postcode     <- map["postcode"]
        totalPrice     <- map["total_price"]
        revisedPrice     <- map["revised_price"]
        payPrice     <- map["payable_price"]
        point     <- map["point"]
        pointPrice     <- map["point_price"]
        actualPrice     <- map["actual_price"]
        
        totalDiscount      <- map["total_discount"]
        deliveryCost     <- map["delivery_cost"]
        status <- (map["status"], TransformOf<OrderStatus, String>(fromJSON: { OrderStatus(rawValue: Int($0 ?? "") ?? 0) }, toJSON: { $0.map { String(describing: $0) } }))
        refundStatus <- (map["refund_status"], TransformOf<OrderRefundStatus, String> (fromJSON: {
            if $0 != nil {
                return OrderRefundStatus(rawValue: Int($0 ?? "") ?? 0)
            } else {
                return nil
            }}, toJSON: { $0.map { String(describing: $0) } }))
        
        refundAmount     <- map["refund_amount"]
        refundItems     <- map["refund_items"]
        
        payTime     <- map["pay_time"]
        shipTime     <- map["ship_time"]
        arrivalTime     <- map["arrival_time"]
        arrivalDeadline     <- map["arrival_deadline"]
        closeTime     <- map["close_time"]
        goodsCount     <- map["goods_num"]
        orderGoods     <- map["order_goods"]
        canDeferConfirmDelivery <- (map["can_extend"], BoolStringTransform())
        
        logisticsCompany     <- map["logistics_company"]
        logisticsNumb     <- map["logistics_no"]
        
    }
}
