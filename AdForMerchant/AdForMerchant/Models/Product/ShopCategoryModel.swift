//
//  ShopCategoryModel.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/21.
//  Copyright © 2016年 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct ShopCategoryModel: Mappable {
    var catID: String = ""
    var catName: String = ""
    var goodsNum: String = ""
    
    init() {
    
    }
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        catID   <- map["cat_id"]
        catName <- map["cat_name"]
        goodsNum    <- map["goods_num"]
    }
}
