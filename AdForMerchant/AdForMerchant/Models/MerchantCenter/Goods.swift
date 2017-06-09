//
//  Goods.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//  swiftlint:disable operator_whitespace

import UIKit
import ObjectMapper

class Goods: Model {
    var goodsConfigID: String?
    var title: String?
    var code: String?
    var catID: String?
    var catName: String?
    var childCatID: String?
    var childCatName: String?
    var storeCatID: String?
    var storeCatName: String?
    var goodsNum: String?
    var propList: [GoodsProperty]?
    var soldOutGoondsNum: Int = 0 {
        didSet {
             guard let num = goodsNum else { return  }
             guard let totalNum = Int(num) else { return  }
             putawayGoodsNum = totalNum - soldOutGoondsNum
        }
    }
    var putawayGoodsNum: Int = 0
    
    override func mapping(map: Map) {
        goodsConfigID <- map["goods_config_id"]
        title <- map["title"]
        code <- map["code"]
        catID <- map["cat_id"]
        catName <- map["cat_name"]
        childCatID <- map["child_cat_id"]
        childCatName <- map["child_cat_name"]
        storeCatID <- map["store_cat_id"]
        storeCatName <- map["store_cat_name"]
        goodsNum <- map["goods_num"]
        propList <- map["prop_list"]
        soldOutGoondsNum <- (map["soldout_goods_num"], IntStringTransform())
    }
}

class ItemDetailModel: Model {
    var totalPage: Int = 0
    var tottalItems: Int = 0
    var currentPage: Int = 0
    var perpage: Int = 20
    var items: [ProductModel]?
    var summary: SummaryModel?
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        tottalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
        summary <- map["summary"]
    }
}

class SummaryModel: Model {
    var status0: String?
    var status1: String?
    var status2: String?
    var status3: String?
    var status4: String?

    override func mapping(map: Map) {
        status0 <- map["status0"]
        status1 <- map["status1"]
        status2 <- map["status2"]
        status3 <- map["status3"]
        status4 <- map["status4"]
    }
}

enum ItemType: String {
    case normal = "1"
    case service = "2"
}

class GoodsProperty: Model, Equatable {
    var properID: String? = " "
    var title: String? = " "
    var value: String? = " "
    var isDeleted: Bool = false
    var index = 0
    override func mapping(map: Map) {
        properID <- map["prop_id"]
        title <- map["title"]
        isDeleted <- (map["deleted"], BoolStringTransform())
        value <- map["value"]
    }
    
    static func ==(lhs: GoodsProperty, rhs: GoodsProperty) -> Bool {
        return lhs.properID == rhs.properID &&
                lhs.title == rhs.title &&
                lhs.value == rhs.value &&
                lhs.isDeleted == rhs.isDeleted &&
                lhs.index == rhs.index
    }
    
}

class GoodsListModel: Model {
    var totalPage: Int = 0
    var tottalItems: Int = 0
    var currentPage: Int = 0
    var perpage: Int = 20
    var items: [Goods]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        tottalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }
}

class GoodsConfigDetailModel: Model {
    var goodsConfigID: String?
    var title: String?
    var code: String?
    var catID: String?
    var catName: String?
    var childCatID: String?
    var childCatName: String?
    var storeCatID: String?
    var storeCatName: String?
    var goodsNum: String?
    var propList: [GoodsProperty]?
    var goodsList: [GoodsModel]?
    override func mapping(map: Map) {
        goodsConfigID <- map["goods_config_id"]
        title <- map["title"]
        code <- map["code"]
        catID <- map["cat_id"]
        catName <- map["cat_name"]
        childCatID <- map["child_cat_id"]
        childCatName <- map["child_cat_name"]
        storeCatID <- map["store_cat_id"]
        storeCatName <- map["store_cat_name"]
        goodsNum <- map["goods_num"]
        propList <- map["prop_list"]
        goodsList <- map["goods_list"]
    }
}

class GoodsModel: Model {
    var goodsID: String?
    var propList: [GoodsProperty]?
    
    override func mapping(map: Map) {
        goodsID <- map["goods_id"]
        propList <- map["prop_list"]
    }
    
}

class StoreCateSaveParameter: Model {
    var categoryID: Int?
    var categoryName: String = ""
    var type: GoodsType?
    
    override func mapping(map: Map) {
        categoryID <- map["cat_id"]
        categoryName <- map["cat_name"]
        type <- map["type"]
    }
}
