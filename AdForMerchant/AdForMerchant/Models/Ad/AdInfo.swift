//
//  CampaignDescription.swift
//  FPTrade
//
//  Created by Kuma on 9/9/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit

struct AdInfo {
    // MARK: Properties
    
    var type: AdType = .picture
    
    var productId: Int = 0
    var productName: String = ""
    
    var imgUrl: String = ""
    var flagBadge: String = ""
    
    var point: Int = 0
    var originalPrice: Float = 0.0
    
    //    var rating: Float = 0.0
    //    var deliveryFee: Float = 0.0
    
    var participantCount: Int = 0
    
    var startTime: Date?
    var endTime: Date?
    
    var userId: Int = 0
//    var userInfo: UserInfo?
    
    init() {
    }
    
    init(dict: [String: AnyObject]) {
        if let productId = dict["productId"] as? String {
            self.productId = Int(productId) ?? 0
        }
        if let productName = dict["name"] as? String {
            self.productName = productName
        }
        if let imgUrl = dict["imgUrl"] as? String {
            self.imgUrl = imgUrl
        }
        if let flagBadge = dict["flagBadge"] as? String {
            self.flagBadge = flagBadge
        }
        if let point = dict["point"] as? String {
            self.point = Int(point) ?? 0
        }
        if let originalPrice = dict["originalPrice"] as? String {
            self.originalPrice = Float(originalPrice) ?? 0
        }
        
        //        if let rating = dict["rating"] as? String {
        //            self.rating = Float(rating) ?? 0
        //        }
        //        if let deliveryFee = dict["deliveryFee"] as? String {
        //            self.deliveryFee = Float(deliveryFee) ?? 0
        //        }
        
        if let participantCount = dict["participantCount"] as? String {
            self.participantCount = Int(participantCount) ?? 0
        }
        if let sTime = dict["startTime"] as? String {
            self.startTime = Date(timeIntervalSince1970: Double(Int(sTime) ?? 0))
        }
        if let eTime = dict["endTime"] as? String {
            self.endTime = Date(timeIntervalSince1970: Double(Int(eTime) ?? 0))
        }
        if let userId = dict["user_id"] as? String {
            self.userId = Int(userId) ?? 0
        }
//        if let userInfo = dict["user"] as? [String: String] {
//            self.userInfo = UserInfo(JSON: userInfo)
//        }
    }
    
}
