//
//  ShopProductCategoryInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 3/18/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct ShopProductCategoryInfo: Mappable {
    var catId: String = ""
    var catName: String = ""
    var goodsNumb: Int = 0
    var type: GoodsType = .normal
    var isTop: Bool = false
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        catId  <- map["cat_id"]
        catName    <- map["cat_name"]
        goodsNumb <- (map["goods_num"], IntStringTransform())
        isTop <- (map["is_top"], BoolStringTransform())
        type <- map["type"]
    }
}
