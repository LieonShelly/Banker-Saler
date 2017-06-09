//
//  CampaignStopApplyInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 7/6/16.
//  Copyright © 2016 Windward. All rights reserved.
// swiftlint:disable operator_whitespace

import Foundation
import ObjectMapper

struct CampaignStopApplyInfo: Mappable, Equatable {
    
    // MARK: Properties
    
    /*
     
     "id": 1,
     "apply_date": "2016-06-20",
     "status": 2,
     "status_name": "拒绝中止",
     "reason": "没钱了，不想玩",
     "comment": "不想玩，没门"
 */
    
    var id: Int = 0
    var applyDate: String = ""
    var status: CampaignStopApplyStatus = .never
    var statusName: String = ""
    var reason: String = ""
    var comment: String = ""
    
    init() {
        
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- (map["event_id"], IntStringTransform())
        applyDate <- map["apply_date"]
        
        status <- map["status"]
        
        statusName <- map["status_name"]
        reason <- map["reason"]
        comment <- map["comment"]
    }
    
    static func ==(lhs: CampaignStopApplyInfo, rhs: CampaignStopApplyInfo) -> Bool {
        return lhs.id == rhs.id &&
            lhs.applyDate == rhs.applyDate &&
            lhs.status == rhs.status &&
            lhs.statusName == rhs.statusName &&
            lhs.reason == rhs.reason &&
            lhs.comment == rhs.comment
    }
}
