//
//  PrivilegeCreateInfo.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/18.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

struct PrivilegeCreateInfo: Mappable {
//    "order_id": "1",
//    "code": "二维码"
    var orderId = ""
    var code = ""
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        orderId      <- map["order_id"]
        code        <- map["code"]
    }
}
