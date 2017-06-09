//
//  Staff.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper
 class Model: Mappable {
    
    init() {
        
    }
    
    // MARK: Mappable
    
    required internal init?(map: Map) {
        
    }
    
     func mapping(map: Map) {
        
    }
    
}

// MARK: - Model Debug String
extension Model: CustomDebugStringConvertible {
    
    internal var debugDescription: String {
        var str = "\n"
        let properties = Mirror(reflecting: self).children
        for c in properties {
            if let name = c.label {
                str += name + ": \(c.value)\n"
            }
        }
        return str
    }
}

class Staff: Model {
    var staffID: String?
    var name: String?
    var mobile: String?
    var limits: StaffLimitsType = .waiter
    var avatar: String?
    var awardNum: Int?
    var created: String?
    var status: InvitedStatusType = .rejected
    
    override func mapping(map: Map) {
        staffID <- map["staff_id"]
        name <- map["name"]
        mobile <- map["mobile"]
        limits <- map["limits"]
        avatar <- map["avatar"]
        awardNum <- (map["award_num"], IntStringTransform())
        created <- map["created"]
        status <- map["status"]
    }
}
 enum StaffLimitsType: String {
    case waiter = "1"
    case casher = "2"
    var  title: String? {
        get {
            switch self {
            case .waiter:
                return "服务员"
            case .casher:
                return "收银员"
            }
        }
        set {
            
        }
    }
    var backgroudColor: UIColor {
        switch self {
        case .waiter:
            return UIColor.colorWithHex("f8b551")
        case .casher:
            return UIColor.colorWithHex("65cac2")
        }
    }
    
}

public enum InvitedStatusType: String {
    case inviting = "0"
    case invited = "1"
    case rejected = "2"
    var title: NSAttributedString {
        switch self {
        case .inviting:
            return "等待处理".attributedString(UIColor.red, fontSize: 13)
        case .invited:
            return "已邀请".attributedString(UIColor.colorWithHex("141414"), fontSize: 13)
        case .rejected:
            return "已拒绝".attributedString(UIColor.lightGray, fontSize: 13)
        }
    }
    
}
