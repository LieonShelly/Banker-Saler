//
//  PrivilegeInfo.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/18.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

struct PrivilegeInfoList: Mappable {
    var totalPage = ""
    var totlaItems = ""
    var currentPage = ""
    var perpage = ""
    var items = [PrivilegeInfo]()
    init () {
        
    }
    init(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        totalPage     <- map["total_page"]
        totlaItems     <- map["totla_items"]
        currentPage     <- map["current_page"]
        perpage     <- map["perpage"]
        items     <- map["items"]
    }
    
}
/*
 actual = "980.00";
 name = "";
 "order_id" = 1;
 "order_no" = 20161019133605342430;
 "staff_name" = "\U8d85\U7ea7\U7ecf\U7eaa\U4eba";
 total = "1000.00";
 type = 1;
 "update_time" = "";
 */
struct PrivilegeInfo: Mappable {
    var name = ""
    var orderNo = ""
    var total = ""
    var actual = ""
    var updateTime = ""
    var orderID = ""
    var staffName = ""
    var storeNmae = ""
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        orderID  <- map["oder_id"]
        name     <- map["name"]
        orderNo  <- map["order_no"]
        total    <- map["total"]
        actual   <- map["actual"]
        updateTime  <- map["update_time"]
        staffName  <- map["staff_name"]
        storeNmae <- map["store_name"]
    }
}
