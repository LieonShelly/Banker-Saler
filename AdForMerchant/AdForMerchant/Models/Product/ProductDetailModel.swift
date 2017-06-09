//
//  ProductDetailModel.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/10.
//  Copyright © 2016年 Windward. All rights reserved.
//  swiftlint:disable force_unwrapping
//  swiftlint:disable operator_whitespace

import Foundation
import ObjectMapper

struct ProductDetailModel: Mappable, Equatable {
    
    var goodsId: String = ""
    var type: String = ""
    var status: ProductSaleStatus = .waitingForReview
    var title: String = ""
    var summary: String = ""
    var cover: String = ""
    var thumb: String = ""
    var catId: String = ""
    var catName: String = ""
    var childCatId: String = ""
    var childCatName: String = ""
    var storeCatId: String = ""
    var storeCatName: String = ""
    var detail: String = ""
    var shareUrl: String = ""
    var imgsStruct: [Imgs]! = [Imgs]()
    var price: String = ""
    var marketPrice: String = ""
    var pointPrice: String = ""
    var stockNum: String = ""
    var deliveryCost: String = ""
    var sellNum: String = ""
    var grade: String = ""
    var onlineTime: String = ""
    var startTime: String = ""
    var joinNnum: Int = 0
    var paramsStruct: [Params]! = [Params]()
    var properties: [Property] = [Property]()
    var rulesStruct: [Rules]! = [Rules]()
    var storesStruct: [ShopAddressInfo]! = [ShopAddressInfo]()
    var events: [ProEvents]! = [ProEvents]()
    var closeTime: String = ""
    var properList: [GoodsProperty] = [GoodsProperty]()
    var goodsConfig = ""
    var goodsConfigID: String?
    var goodsConfigTitle = ""
    var goodsConfigGoodConfigID = ""
    var goodsConfigCode = ""
    var isApproved: ApproveStatus = .waitingForReview
    private var approveStatus: Int = 0 {
        didSet {
            self.isApproved = ApproveStatus(rawValue: approveStatus) ?? .waitingForReview
        }
    }
    
    init() {
    
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        goodsId    <- map["goods_id"]
        type    <- map["type"]
        status <- (map["status"], TransformOf<ProductSaleStatus, String>(fromJSON: { ProductSaleStatus(rawValue: Int($0!) ?? 0) }, toJSON: { $0.map { String(describing: $0) }}))

        title   <- map["title"]
        summary   <- map["summary"]
        cover   <- map["cover"]
        thumb   <- map["thumb"]
        catId  <- map["cat_id"]
        catName    <- map["cat_name"]
        childCatId    <- map["child_cat_id"]
        childCatName  <- map["child_cat_name"]
        storeCatId    <- map["store_cat_id"]
        storeCatName  <- map["store_cat_name"]
        detail  <- map["detail"]
        shareUrl   <- map["share_url"]
        imgsStruct    <- map["imgs"]
        price   <- map["price"]
        pointPrice   <- map["point_price"]
        marketPrice    <- map["market_price"]
        stockNum   <- map["stock_num"]
        deliveryCost   <- map["delivery_cost"]
        sellNum    <- map["sell_num"]
        grade   <- map["grade"]
        onlineTime <- map["online_time"]
        startTime     <- map["start_time"]
        joinNnum <- (map["join_num"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        paramsStruct  <- map["params"]
        properties  <- map["property"]
        rulesStruct <- map["rules"]
        storesStruct    <- map["stores"]
        events   <- map["events"]
        closeTime  <- map["close_time"]
        properList <- map["prop_list"]
        goodsConfigID <- map["goods_config_id"]
        goodsConfigTitle <- map["goods_config.title"]
        goodsConfigGoodConfigID <- map["goods_config.goods_config_id"]
        goodsConfig <- map["goods_config"]
        goodsConfigCode <- map["goods_config.code"]
        approveStatus <- (map["is_approved"], IntStringTransform())
        
    }
    
    static func ==(lhs: ProductDetailModel, rhs: ProductDetailModel) -> Bool {
        return lhs.title == rhs.title &&
            lhs.goodsId == rhs.goodsId &&
            lhs.type == rhs.type &&
            lhs.status == rhs.status &&
            lhs.summary == rhs.summary &&
            lhs.cover == rhs.cover &&
            lhs.thumb == rhs.thumb &&
            lhs.catId == rhs.catId &&
            lhs.catName == rhs.catName &&
            lhs.childCatId == rhs.childCatId &&
            lhs.childCatName == rhs.childCatName &&
            lhs.storeCatId == rhs.storeCatId &&
            lhs.storeCatName == rhs.storeCatName &&
            lhs.detail == rhs.detail &&
            lhs.shareUrl == rhs.shareUrl &&
            lhs.imgsStruct == rhs.imgsStruct &&
            lhs.stockNum == rhs.stockNum &&
            lhs.deliveryCost == rhs.deliveryCost &&
            lhs.sellNum == rhs.sellNum &&
            lhs.grade == rhs.grade &&
            lhs.onlineTime == rhs.onlineTime &&
            lhs.startTime == rhs.startTime &&
            lhs.joinNnum == rhs.joinNnum &&
            lhs.paramsStruct == rhs.paramsStruct &&
            lhs.properties == rhs.properties &&
            lhs.rulesStruct == rhs.rulesStruct &&
            lhs.storesStruct == rhs.storesStruct &&
            lhs.events == rhs.events &&
            lhs.closeTime == rhs.closeTime &&
            lhs.properList == rhs.properList &&
            lhs.goodsConfigID == rhs.goodsConfigID &&
            lhs.goodsConfigTitle == rhs.goodsConfigTitle &&
            lhs.goodsConfigGoodConfigID == rhs.goodsConfigGoodConfigID &&
            lhs.goodsConfig == rhs.goodsConfig &&
            lhs.goodsConfigCode == rhs.goodsConfigCode &&
            lhs.marketPrice == rhs.marketPrice &&
            lhs.price == rhs.price &&
            lhs.pointPrice == rhs.pointPrice
    }
}

//extension Array: Equatable {
//    public static func ==(lhs: Array, rhs: Array) -> Bool {
//        
//        return lhs == rhs
//    }
//}

struct Imgs: Mappable, Equatable {
    var imgId: String = ""
    var thumb: String = ""
    var file: String = ""
    init() {
    
    }
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        imgId  <- map["img_id"]
        thumb   <- map["thumb"]
        file    <- map["file"]
    }
    public static func ==(lhs: Imgs, rhs: Imgs) -> Bool {
        return lhs.imgId == rhs.imgId && lhs.thumb == rhs.thumb && lhs.file == rhs.file
    }
}

struct  Params: Mappable, Equatable {
    var paramName: String = ""
    var paramValue: String = ""
    init() {
        
    }
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        paramName  <- map["param_name"]
        paramValue <- map["param_value"]
    }
    
    public static func ==(lhs: Params, rhs: Params) -> Bool {
        return lhs.paramName == rhs.paramName && lhs.paramValue == rhs.paramValue
    }
}

struct Property: Mappable, Equatable {
    var propertyName: String = ""
    var propertyValue: String = ""
    init() {
        
    }
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        propertyName  <- map["property_name"]
        propertyValue <- map["property_value"]
    }
    
    public static func ==(lhs: Property, rhs: Property) -> Bool {
        return lhs.propertyName == rhs.propertyName && lhs.propertyValue == rhs.propertyValue
    }
}

struct Rules: Mappable, Equatable {
    var name: String = ""
    var content: String = ""
    init() {
    
    }
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name    <- map["name"]
        content <- map["content"]
    }
    
    public static func ==(lhs: Rules, rhs: Rules) -> Bool {
        return lhs.name == rhs.name && lhs.content == rhs.content
    }
}

struct ProEvents: Mappable, Equatable {
    var eventId: String = ""
    var title: String = ""
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        eventId  <- map["event_id"]
        title  <- map["title"]
    }
    
    public static func ==(lhs: ProEvents, rhs: ProEvents) -> Bool {
        return lhs.eventId == rhs.eventId && lhs.title == rhs.title
    }
}
