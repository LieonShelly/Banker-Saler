//
//  GoodsCategoryModel.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/11.
//  Copyright © 2016年 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct GoodsCategoryModel: Mappable {
    var catId: String = ""
    var catName: String = ""
    var childCatsStruct: [ChildCats]! = [ChildCats]()
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        catId  <- map["cat_id"]
        catName    <- map["cat_name"]
        childCatsStruct  <- map["child_cats"]
    }
}

struct ChildCats: Mappable {
    var catId: String = ""
    var catName: String = ""
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        catId  <- map["cat_id"]
        catName    <- map["cat_name"]
    }
}
