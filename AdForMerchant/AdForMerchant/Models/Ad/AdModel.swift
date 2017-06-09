//
//  AdModel.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/24.
//  Copyright © 2016年 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

class AdModel: Mappable {
    var adID: String = ""
    var title: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var type: String = ""
    var joinNum: String = ""
    var costPoint: String = ""
    var thumb: String = ""
    var shareUrl = ""
    
    init () {
    
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        adID    <- map["ad_id"]
        title   <- map["title"]
        startTime   <- map["start_time"]
        endTime <- map["end_time"]
        type    <- map["type"]
        joinNum <- map["join_num"]
        costPoint   <- map["cost_point"]
        thumb   <- map["thumb"]
        shareUrl   <- map["share_url"]
    }
}
