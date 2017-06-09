//
//  BankInfo.swift
//  FPTrade
//
//  Created by Kuma on 9/16/15.
//  Copyright (c) 2015 Windward. All rights reserved.
// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast

import UIKit
import ObjectMapper

class BankInfo: Mappable, NSCoding {
    
    var bankInfoId: Int = 0
    var bankName: String = ""
    var bankLogo: String = ""
    
    struct PropertyKey {
        static let bankInfoIdKey = "id"
        static let bankNameKey = "name"
        static let bankLogoKey = "logo"
    }
    
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(bankInfoId, forKey: PropertyKey.bankInfoIdKey)
        aCoder.encode(bankName, forKey: PropertyKey.bankNameKey)
        aCoder.encode(bankLogo, forKey: PropertyKey.bankLogoKey)
    }
    
    @objc convenience required init?(coder aDecoder: NSCoder) {
        let bankInfoId = aDecoder.decodeInteger(forKey: PropertyKey.bankInfoIdKey)
         let bankName = aDecoder.decodeObject(forKey: PropertyKey.bankNameKey) as! String
         let bankLogo = aDecoder.decodeObject(forKey: PropertyKey.bankLogoKey) as! String
        
        self.init(bankInfoId: bankInfoId, bankName: bankName, bankLogo:bankLogo)
    }
    
    init(bankInfoId: Int, bankName: String, bankLogo: String) {
        
        self.bankInfoId = bankInfoId
        self.bankName = bankName
        self.bankLogo = bankLogo
        
    }
    
    required init(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        bankInfoId       <- map["productId"]
        bankName     <- map["name"]
        bankLogo     <- map["celsius"]
        
    }

    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("bankInfo")
    
    static let ConfigBankInfo: [BankInfo] = {
        var allConfigBankInfo = NSKeyedUnarchiver.unarchiveObject(withFile: BankInfo.ArchiveURL.path) as? [BankInfo]
        return allConfigBankInfo ?? []
    }()
}
