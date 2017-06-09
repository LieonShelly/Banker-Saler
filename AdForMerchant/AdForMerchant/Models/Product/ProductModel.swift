//
//  ProductModel.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/10.
//  Copyright © 2016年 Windward. All rights reserved.
//  swiftlint:disable force_unwrapping

import Foundation
import ObjectMapper

struct ProductModel: Mappable {
    var goodsId: String = ""
    var title: String = ""
    var type: String = ""
    var summary = ""
    var onlineTime: String = ""
    var startTime: Date?
    var closeTime: Date?
    var price: String = ""
    var marketPrice: String = ""
    var deliveryCost: String = ""
    var sellNum: String = ""
    var stockNum: String = ""
    var num: String = ""
    var grade: String = ""
    var thumb: String = ""
    var shareUrl: String = ""
    var status: ProductSaleStatus = .waitingForReview
    var isApproved = ""
    var inEvent: String = ""
    var storeCatId = ""
    var storeCatName = ""
    var eventsNum: String = ""
    var properList: [GoodsProperty]?
    var goodConfigTitle = ""
    
    init() {
    
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        goodsId        <- map["goods_id"]
        title                <- map["title"]
        type               <- map["type"]
        summary <- map["summary"]
        onlineTime     <- map["online_time"]
        startTime     <- (map["start_time"], DateStringTransform())
        price              <- map["price"]
        marketPrice  <- map["market_price"]
        deliveryCost  <- map["delivery_cost"]
        sellNum         <- map["sell_num"]
        stockNum      <- map["stock_num"]
        num      <- map["num"]
        grade             <- map["grade"]
        thumb            <- map["thumb"]
        shareUrl        <- map["share_url"]
        // id <- (map["id"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        status <- (map["status"], TransformOf<ProductSaleStatus, String>(fromJSON: { ProductSaleStatus(rawValue: Int($0!) ?? 0) }, toJSON: { $0.map { String(describing: $0) }}))

        inEvent         <- map["in_event"]
        storeCatId         <- map["store_cat_id"]
        storeCatName         <- map["store_cat_name"]
        eventsNum  <- map["events_num"]
        properList <- map["prop_list"]
        goodConfigTitle <- map["goods_config.title"]
        closeTime <- (map["close_time"], DateStringTransform())
    }
}
