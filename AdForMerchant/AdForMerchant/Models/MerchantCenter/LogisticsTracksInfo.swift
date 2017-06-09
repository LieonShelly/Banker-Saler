//
//  LogisticsTracksInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 8/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct LogisticsTracksInfo: Mappable {
    
    var acceptTime: String = ""
    var acceptStation: String = ""
    
    init(map: Map) {
        
    }
    
    init(acceptTime: String, acceptStation: String) {
        self.acceptTime = acceptTime
        self.acceptStation = acceptStation
    }
    
    mutating func mapping(map: Map) {
        acceptTime      <- map["accept_time"]
        acceptStation   <- map["accept_station"]
    }
}
