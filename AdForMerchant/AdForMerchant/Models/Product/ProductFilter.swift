//
//  ProductFilter.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/15.
//  Copyright © 2016年 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct GoodsFilterModel: Mappable {
    var catList: [GoodsCatModel] = [GoodsCatModel]()
    var orderbyList: [GoodsOrderBy] = [GoodsOrderBy]()
    var evetTypelList: [EvetnType] = [.unparticipanting, .participanting]
    var goodsTypList: [GoodsType] = [.normal, .service]
    init?(map: Map) {
        
    }
    init () {
    
    }
    mutating func mapping(map: Map) {
        catList <- map["cat_list"]
        orderbyList <- map["orderby_list"]
    }
}
enum EvetnType: Int {
    case unparticipanting = 0
    case participanting = 1
    var title: String {
        switch self {
        case .unparticipanting:
            return "未参加活动的商品"
        case .participanting:
            return "参加活动的商品"
        }
    }
}

struct GoodsCatModel: Mappable {
    var catId: String = ""
    var catName: String = ""
    init?(map: Map) {
        
    }
    init () {
    
    }
    mutating func mapping(map: Map) {
        catId <- map["cat_id"]
        catName <- map["cat_name"]
    }
}

struct GoodsOrderBy: Mappable {
    var orderby: String = ""
    var orderName: String = ""
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        orderby <- map["orderby"]
        orderName <- map["order_name"]
    }
}
