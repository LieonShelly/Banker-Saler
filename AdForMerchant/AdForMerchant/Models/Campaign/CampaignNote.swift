//
//  CampaignNote.swift
//  AdForMerchant
//
//  Created by Kuma on 4/13/16.
//  Copyright © 2016 Windward. All rights reserved.
// swiftlint:disable operator_whitespace

import Foundation
import ObjectMapper

struct CampaignNote: Mappable, Equatable {
    
    // MARK: Properties
    
    var name: String = ""
    var content: String = ""
    
    init() {
        
    }
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name                <- map["name"]
        content             <- map["content"]
        
    }
    
    static func ==(lhs: CampaignNote, rhs: CampaignNote) -> Bool {
        return lhs.name == rhs.name && lhs.content == rhs.content
    }
}
