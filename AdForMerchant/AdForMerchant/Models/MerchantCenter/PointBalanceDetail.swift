//
//  PointBalanceDetail.swift
//  AdForMerchant
//
//  Created by Kuma on 7/8/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 "id": "1",
 "type": "2",
 "type_name": "积分消耗",//类型 1-积分充值 2-积分消耗
 "cat": "1",
 "cat_name": "广告消耗",
 "point": "10",
 "title": "现场活动名称",
 "created_short": "2015-07-01",
 "created": "2015-07-01 18:00:00"
 */

struct PointBalanceDetail: Mappable {
    var id: Int = 0
    var type: PointBalanceType = .charge
    var typeName: String = ""
    var category: String = ""
    var categoryName: String = ""
    var point: String = ""
    var title: String = ""
    var createdShort: String = ""
    var created: String = ""
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id  <- (map["id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        type <- (map["type"], TransformOf<PointBalanceType, String>(fromJSON: { PointBalanceType(rawValue: Int($0 ?? "") ?? 0) }, toJSON: { $0.map { String(describing: $0) } }))
        typeName     <- map["type_name"]
        category     <- map["cat"]
        categoryName     <- map["cat_name"]
        point     <- map["point"]
        title     <- map["title"]
        createdShort     <- map["created_short"]
        created     <- map["created"]
        
    }
}
