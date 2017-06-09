//
//  CouponRule.swift
//  AdForMerchant
//
//  Created by Kuma on 3/19/16.
//  Copyright © 2016 Windward. All rights reserved.
//  swiftlint:disable operator_whitespace

import Foundation
import ObjectMapper

struct CouponRule: Mappable, Equatable {
    
    // MARK: Properties
    
    var totalAmount: String = ""
    var discountAmount: String = ""
    
    init() {
        
    }
    
    init(totalAmount: String, discountAmount: String) {
        self.totalAmount = totalAmount
        self.discountAmount = discountAmount
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        totalAmount                <- map["cond_amount"]
        discountAmount             <- map["minus_amount"]
        
    }
    
    static func ==(lhs: CouponRule, rhs: CouponRule) -> Bool {
        return lhs.totalAmount == rhs.totalAmount && lhs.discountAmount == rhs.discountAmount
    }
}
