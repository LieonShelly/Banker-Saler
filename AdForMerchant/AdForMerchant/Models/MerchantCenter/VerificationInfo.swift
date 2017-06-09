//
//  VerificationInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 4/27/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 
 "certity": {
 "license": "http:\/\/xxxx.com\/license\/a.png",
 "qualification": [
 "http:\/\/xxxx.com\/license\/a.png",
 "http:\/\/xxxx.com\/license\/a.png"
 ],
 "company_name": "王先生",
 "legel_person": "",
 "id_number": "513901198804232345",
 "reg_address": "上海南京路 丰德国际C座",
 "reg_code": "123456789-0987",
 "card_list": [
 {
 "card_id": 1,
 "bank_name": "绵阳商业银行",
 "card_no": "6225-9818123-10813",
 "username": "李农",
 "mobile": "18011411234"
 }
 ]
 }
 */

struct VerificationInfo: Mappable {
    
    var license: [String] = []
    var credentialImgs: [String] = []
    var companyName: String = ""
    var legelPerson: String = ""
    var idNumber: String = ""
    var regAddress: String = ""
    var regCode: String = ""
    var verifyCode: String = ""
    var omittedAddress: String = ""
    var cardList: [BankAccountInfo] = []
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        license     <- map["license"]
        credentialImgs     <- map["qualification"]
        companyName     <- map["company_name"]
        legelPerson     <- map["legel_person"]
        idNumber     <- map["id_number"]
        regAddress     <- map["reg_address"]
        regCode     <- map["reg_code"]
        cardList     <- map["card_list"]
        verifyCode <- map["verify_code"]
    }
}

class ImageCodeParam: Model {
    var mobile: String = ""
    var type: CaptchaType = .merchantVerify
    
    override func mapping(map: Map) {
        mobile <- map["mobile"]
        type <- map["type"]
    }
}

class CheckImageCodeParam: ImageCodeParam {
    var imgCode: String = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        imgCode <- map["img_code"]
    }
}
