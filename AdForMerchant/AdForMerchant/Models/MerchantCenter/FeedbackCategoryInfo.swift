//
//  FeedbackCategoryInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 7/19/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct FeedbackCategoryInfo: Mappable {
    var catId: String = ""
    var catName: String = ""
    var subCats: [FeedbackCategoryInfo] = []
    init?(map: Map) {
        
    }
    init () {
        
    }
    mutating func mapping(map: Map) {
        catId <- map["cat_id"]
        catName <- map["cat_name"]
        subCats <- map["sub_cats"]
    }
}
