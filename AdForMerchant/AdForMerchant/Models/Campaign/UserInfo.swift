//
//  UserInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 5/10/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
/*
 "user_id": "1",
 "name": "李狗蛋",
 "mobile": "180****8008",
 "avatar": "http:\/\/v1.qzone.cc\/avatar\/201408\/20\/17\/23\/53f468ff9c337550.jpg%21200x200.jpg",
 "join_time"
 
 */

import ObjectMapper

struct UserInfo: Mappable {
    
    // MARK: Properties
    
    var userId: String = ""
    var name: String = ""
    var mobile: String = ""
    var avatar: String = ""
    var joinTime: String = ""
    
    init() {
        
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        userId              <- map["user_id"]
        name                <- map["name"]
        mobile                <- map["mobile"]
        avatar                <- map["avatar"]
        joinTime              <- map["join_time"]
        
    }
}
