//
//  Transforms.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class IntStringTransform: TransformType {
    public func transformFromJSON(_ value: Any?) -> Int? {
        if let time = value as? String {
            return Int(time)
        }
        return nil
    }
    
    func transformToJSON(_ value: Int?) -> String? {
        if let date = value {
            return String(date)
        }
        return nil
    }
}

class BoolStringTransform: TransformType {
    public func transformFromJSON(_ value: Any?) -> Bool? {
        if let time = value as? String {
            if time == "1" {
                return true
            } else {
                return false
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: Bool?) -> String? {
        if let date = value {
            if date == true {
                return "1"
            } else {
                return "0"
            }
        }
        return nil
    }
}

class DateStringTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        if let time = value as? String {
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            format.locale = Locale(identifier: "zh")
            return format.date(from: time)
        }
        return nil
    }
    
    public func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.dateToString()
        }
        return nil
    }
    
}
