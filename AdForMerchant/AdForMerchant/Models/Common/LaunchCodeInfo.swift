//
//  LaunchCodeInfo.swift
//  FPTrade
//
//  Created by Kuma on 9/28/15.
//  Copyright © 2015 Windward. All rights reserved.
//  swiftlint:disable force_unwrapping
//  swiftlint:disable force_cast

import UIKit
import ObjectMapper

class LaunchCodeInfo: Mappable, NSCoding {
    
    // MARK: Properties
    
    var userId: Int = 0
    var code: String = ""
    
    struct PropertyKey {
        static let infoIdKey = "id"
        static let infoCodeKey = "code"
    }
    
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: PropertyKey.infoIdKey)
        aCoder.encode(code, forKey: PropertyKey.infoCodeKey)
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let userId = aDecoder.decodeInteger(forKey: PropertyKey.infoIdKey)
        let code = aDecoder.decodeObject(forKey: PropertyKey.infoCodeKey) as! String 
        self.init(userId: userId, code: code)
    }
    
    init(userId: Int, code: String) {
        self.userId = userId
        self.code = code
    }
    
    required init(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userId       <- map["productId"]
        code     <- map["name"]
        
    }
    // MARK: Archiving Paths
    static var UserLaunchCodeInfoNeedRefresh = false {
        didSet {
            if UserLaunchCodeInfoNeedRefresh {
                UserLaunchCodeInfoNeedRefresh = false
                if let data = UserDefaults.standard.object(forKey: "LaunchCodeInfo") as? Data {
                    let allConfigBankInfo = NSKeyedUnarchiver.unarchiveObject(with: data)
                    UserLaunchCodeInfo = ((allConfigBankInfo ?? []) as? [LaunchCodeInfo])  ?? [LaunchCodeInfo]()
                }
            }
        }
    }
    
    static var UserLaunchCodeInfo: [LaunchCodeInfo] = {
        if let data = UserDefaults.standard.object(forKey: "LaunchCodeInfo") as? Data {
            var allConfigBankInfo = NSKeyedUnarchiver.unarchiveObject(with: data)
            return allConfigBankInfo as! [LaunchCodeInfo]
        }
        return []
        }()
}
