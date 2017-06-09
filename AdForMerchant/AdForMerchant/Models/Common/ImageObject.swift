//
//  ImageObject.swift
//  FPTrade
//
//  Created by Kuma on 9/7/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

struct ImageObject: Mappable {
    
    // MARK: Properties
    
    var imageId: Int = 0
    var imageURL: String = ""
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        imageId       <- map["productId"]
        imageURL     <- map["name"]
    }
}
