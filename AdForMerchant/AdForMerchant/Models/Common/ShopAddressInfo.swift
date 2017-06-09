//
//  AddressInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 3/16/16.
//  Copyright © 2016 Windward. All rights reserved.
// swiftlint:disable operator_whitespace

import Foundation
import ObjectMapper

struct ShopAddressInfo: Mappable, Equatable {
    
    // MARK: Properties
    
    var id: Int = 0
    var shopName: String = ""
    var contact: String = ""
    var phone: String = ""
    var address: String = ""
    
    init() {
        
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- (map["add_id"], IntStringTransform())
        shopName            <- map["name"]
        contact             <- map["contact"]
        phone               <- map["tel"]
        address             <- map["address"]
    }
    
    public static func ==(lhs: ShopAddressInfo, rhs: ShopAddressInfo) -> Bool {
        return lhs.id == rhs.id &&
            lhs.shopName == rhs.shopName &&
            lhs.contact == rhs.contact &&
            lhs.phone == rhs.phone &&
            lhs.address == rhs.address

    }
}
