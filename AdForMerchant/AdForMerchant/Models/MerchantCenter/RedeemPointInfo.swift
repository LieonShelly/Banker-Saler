//
//  RedeemPointInfo.swift
//  AdForMerchant
//
//  Created by 糖otk on 2017/5/11.
//  Copyright © 2017年 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct RedeemPointInfo: Mappable {
    var cardNoTail = ""
    var money = ""
    var point = ""
    var bankName = ""
    var tips = ""
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        cardNoTail  <- map["card_no_tail"]
        money    <- map["money"]
        point <- map["point"]
        bankName <- map["bank_name"]
        tips <- map["tips"]
    }
}
