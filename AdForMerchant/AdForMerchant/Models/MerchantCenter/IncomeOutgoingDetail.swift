//
//  IncomeOutgoingDetail.swift
//  AdForMerchant
//
//  Created by Kuma on 4/19/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 
 "id": "1",
 "cat_name": "订单",
 "amount": "10",
 "title": "201607221111",
 "created_short": "2015-07-01",
 "created": "2015-07-01 18:00:00"
 
 */

struct IncomeDetail: Mappable {
    
    var id: Int = 0
    var categoryName: String = ""
    var amount: String = ""
    var title: String = ""
    var createdShort: String = ""
    var created: String = ""
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id  <- (map["id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        categoryName     <- map["cat_name"]
        amount     <- map["amount"]
        title     <- map["title"]
        createdShort     <- map["created_short"]
        created     <- map["created"]
        
    }
}

/*
 "id": "1",
 "type": "2",//类型 1-收入 2-支出
 "cat": "1",
 "cat_name": "提现",
 "status": "0",状态 0-待处理 1-处理中 2-处理完结 9-异常
 "amount": "100.00",
 "trade_time": "2015-07-01 18:00"
 "trade_no": "eccbc87e4b5ce2fe28308fd9f2a7baf3",
 "remark"
 */

struct IncomeOutgoingDetail: Mappable {
    var id: Int = 0
    var type: IncomeOutgoingType = .in
    var category: String = ""
    var categoryName: String = ""
    var status: IncomeOutgoingStatus = .waitingForProcess
    var amount: String = ""
    var tradeTime: String = ""
    var tradeNo: String = ""
    var remark: String = ""

    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id  <- (map["id"], TransformOf<Int, String>(fromJSON: { Int($0 ?? "0") }, toJSON: { $0.map { String($0) }}))
        type <- (map["type"], TransformOf<IncomeOutgoingType, String>(fromJSON: { IncomeOutgoingType(rawValue: Int($0 ?? "") ?? 0) }, toJSON: { $0.map { String(describing: $0) } }))
        category     <- map["cat"]
        categoryName     <- map["cat_name"]
        status <- (map["status"], TransformOf<IncomeOutgoingStatus, String>(fromJSON: { IncomeOutgoingStatus(rawValue: Int($0 ?? "") ?? 0) }, toJSON: { $0.map { String(describing: $0) } }))
        amount     <- map["amount"]
        tradeTime     <- map["trade_time"]
        tradeNo     <- map["trade_no"]
        remark     <- map["remark"]
        
    }
}
