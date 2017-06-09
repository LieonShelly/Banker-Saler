//
//  StoreInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 3/17/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

struct StoreCover: Mappable {
    
    // MARK: Properties
    
    var isDefault: Bool = false
    var URL: String = ""
    
    init() {
        
    }
    
    init(map: Map) {
        
    }
    
    /*
     store_logo	string	false	店铺logo
     store_cover	string	false	店铺封面
     store_name	string	false	店铺名称
     store_detail	string	false	店铺详细
     store_charger	string	false	负责人
     store_tel
     */
    
    mutating func mapping(map: Map) {
        isDefault <- (map["is_default"], BoolStringTransform())
        URL       <- map["url"]
        
    }
}

struct StoreInfo: Mappable {
    
    // MARK: Properties
    
    var id: String = ""
    var name: String = ""
    var logo: String = ""
    var cover: String = ""
    var coverType: StoreCoverType = .undefined
    var detail: String = ""
    var charger: String = ""
    var phone: String = ""
    var score: String = ""
    
    init() {
        
    }
    
    init(map: Map) {
        
    }
    
    /*
     store_logo	string	false	店铺logo
     store_cover	string	false	店铺封面
     store_name	string	false	店铺名称
     store_detail	string	false	店铺详细
     store_charger	string	false	负责人
     store_tel
     */
    
    mutating func mapping(map: Map) {
        id                  <- map["store_id"]
        name                <- map["store_name"]
        logo                <- map["store_logo"]
        cover               <- map["store_cover"]
        coverType <- (map["type"], TransformOf<StoreCoverType, String>(fromJSON: { StoreCoverType(rawValue: Int($0 ?? "0") ?? 0) }, toJSON: { $0.map { String(describing: $0) } }))
        detail              <- map["store_detail"]
        charger             <- map["store_charger"]
        phone               <- map["store_tel"]
        score               <- map["score"]
        
    }
}
