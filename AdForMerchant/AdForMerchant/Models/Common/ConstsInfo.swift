//
//  ConstsInfo.swift
//  FPTrade
//
//  Created by Apple on 15/9/22.
//  Copyright © 2015年 Windward. All rights reserved.
// swiftlint:disable force_cast

import UIKit
import ObjectMapper

class ConstsInfo: Mappable, NSCoding {
    var division: String = ""
    var title: String = ""
    var label: String = ""
    var value: Int = 0
    
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(division, forKey: "division")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(label, forKey: "label")
        aCoder.encode(value, forKey: "value")
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let cdivision = aDecoder.decodeObject(forKey: "division") as! String
        let ctitle = aDecoder.decodeObject(forKey: "title") as! String
        let clabel = aDecoder.decodeObject(forKey: "label") as!  String
        let cvalue = aDecoder.decodeInteger(forKey: "value")
        self.init(cdivision: cdivision, ctitle: ctitle, clabel:clabel, cvalue:cvalue)
    }
    
    init(cdivision: String, ctitle: String, clabel: String, cvalue: Int) {
        
        self.division = cdivision
        self.title = ctitle
        self.label = clabel
        self.value = cvalue
        
    }
    
    required init(map: Map) {
        
    }
    
    func mapping(map: Map) {
        division       <- map["productId"]
        title     <- map["name"]
        label     <- map["celsius"]
        value     <- map["celsius"]
        
    }
}
