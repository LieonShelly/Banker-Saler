//
//  BankAccountInfo.swift
//  FPTrade
//
//  Created by Kuma on 9/16/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

struct BankAccountInfo: Mappable {
    
    // MARK: Properties
    
    var id: String = ""
//    var bankInfoId: Int = 0
    //    var bankInfo: BankInfo?
    var cardNumber: String = ""
    var bankName: String = ""
    var holderName: String = ""
    var mobile: String = ""
//    var isDefault: Bool = false
    
    init(map: Map) {
        
    }
    
    init() {}
    
    mutating func mapping(map: Map) {
        
        id       <- map["card_id"]
        
        bankName          <- map["bank_name"]
        cardNumber          <- map["card_no"]
        
        holderName     <- map["username"]
        mobile     <- map["mobile"]
        
    }

}
