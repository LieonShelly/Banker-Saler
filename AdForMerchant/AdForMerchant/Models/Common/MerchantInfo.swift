//
//  UserInfo.swift
//  FPTrade
//
//  Created by Kuma on 9/7/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

// 0-未审核 1-审核中 2-审核失败 3-审核成功
public enum LicenseVerifyStatus: String {
    case unverified = "0"
    case waitingForReview = "1"
    case verifyFailed = "2"
    case verified = "3"
}

struct MerchantInfo: Mappable {
    
    // MARK: Properties
    
    var id: Int = 0
    var name: String = ""
    var status: LicenseVerifyStatus = .unverified
    
    var tips: String = ""
    var logo: String = ""
    var license: String = ""
    var contact: String = ""
    var tel: String = ""
    
    var verificationInfo: VerificationInfo?
    
    var haveAddedStore: Bool = false
    var storeInfo: StoreInfo?
    
    var lastLogin: String = ""
    var settedPayPassward: String = ""
//    var addedStore: Int = 0
    var money: String = ""
    var point: String = ""
    var topayNumb: Int = 0
    var paiedNumb: Int = 0
    var doneNumb: Int = 0
    var refundNumb: Int = 0
    var storeAddressNumb: Int = 0
    
    var isBlocked: Bool = false
    var remark = ""
    
    init() {
    
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        id <- (map["merchant_id"], IntStringTransform())
        name                <- map["name"]
//        status              <- map["status"]
        status <- map["status"]

        tips                <- map["tips"]
        logo                <- map["logo"]
        license             <- map["license"]
        contact             <- map["contact"]
        tel                 <- map["tel"]
        
        verificationInfo <- map["certify"]
        
        haveAddedStore           <- (map["added_store"], BoolStringTransform())
        storeInfo           <- map["store"]
        
        lastLogin           <- map["last_login"]
        settedPayPassward   <- map["setted_pay_passwrd"]
        
        money               <- map["money"]
        point               <- map["point"]
        topayNumb           <- (map["topay_num"], IntStringTransform())
        paiedNumb           <- (map["paied_num"], IntStringTransform())
        doneNumb            <- (map["done_num"], IntStringTransform())
        refundNumb          <- (map["refund_num"], IntStringTransform())
        
        storeAddressNumb    <- map["store_address_num"]
        
        isBlocked   <- (map["is_blocked"], BoolStringTransform())
        remark <- (map["remark"])
    }
    
}
