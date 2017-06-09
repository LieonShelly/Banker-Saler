//
//  PrivilegeRuleInfo.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/18.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

struct PrivilegeRuleInfo: Mappable {

    var privilegeId = ""
    var privilegeName = ""
    var type = ""
    var discount = ""
    var fullSum = ""
    var minusSum = ""
    var topPrivilege = ""
    var updateTime = ""
    var rule = ""
    var created = ""
    var id = ""
    var ruleHeight: CGFloat = 0
    var isExpand = false
    
    var isSeleted = false
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        privilegeId       <- map["id"]
        privilegeName     <- map["privilege_name"]
        type              <- map["type"]
        discount          <- map["discount"]
        fullSum           <- map["full_sum"]
        minusSum          <- map["minus_sum"]
        topPrivilege      <- map["top_privilege"]
        updateTime        <- map["update_time"]
        rule              <- map["rule"]
        created           <- map["created"]
        id                <- map["id"]
    }
}

struct PrivilegeRuleInfoList: Mappable {
    var ruleList = [PrivilegeRuleInfo]()
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        ruleList       <- map["rule_list"]
    }
}
