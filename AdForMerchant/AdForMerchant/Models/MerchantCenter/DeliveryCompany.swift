//
//  DeliveryCompany.swift
//  AdForMerchant
//
//  Created by Kuma on 5/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct DeliveryCompany: Mappable {
    
//    "com": "ems",
//    "name": "EMS"
//    
    var shorthand: String = ""
    var name: String = ""
    
    init(map: Map) {
        
    }
    
    init(shorthand: String, name: String) {
        self.shorthand = shorthand
        self.name = name
    }
    
    mutating func mapping(map: Map) {
        
        shorthand     <- map["com"]
        name     <- map["name"]
        
    }
}
