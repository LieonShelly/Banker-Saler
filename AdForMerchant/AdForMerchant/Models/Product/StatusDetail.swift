//
//  StatusDetail.swift
//  AdForMerchant
//
//  Created by lieon on 2017/2/22.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class StatusDetail: Model {
    var remark: String?
    var createTime: String?
    
    override func mapping(map: Map) {
        remark <- map["remark"]
        createTime <- map["created"]
    }
}

class StatusDetailParameter: Model {
    var relationID: Int?
    var type: RelationType?
    
    override func mapping(map: Map) {
        relationID <- (map["relation_id"], IntStringTransform())
        type <- map["type"]
    }
}

enum RelationType: Int {
    case goods = 1
    case campaign = 2
    case advertisement = 3
}
