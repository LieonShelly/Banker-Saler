//
//  PlaceCampaignInfo.swift
//  AdForMerchant
//
//  Created by Kuma on 3/16/16.
//  Copyright © 2016 Windward. All rights reserved.
//  swiftlint:disable operator_whitespace
// swiftlint:disable force_unwrapping

import Foundation
import ObjectMapper

//结束类型
enum PlaceCampaignClosedType: String {
    //无
    case noInfo = "0",
    //正常结束
    normallyClosed = "1",
    //冻结结束
    frozenClosed = "2",
    //首次审核结束
    auditClosed = "3",
    //进行中审核结束
    ongoingClosed = "4"
}

struct PlaceCampaignInfo: Mappable, Equatable {
    
    // MARK: Properties
    
    var id: Int = 0
    var title: String = ""
    var detail: String = ""
    
    var startTime: String = ""
    var endTime: String = ""
    var appointmentStartTime: String = ""
    var appointmentEndTime: String = ""
    
    var category: String = ""
    var type: CampaignSaleType = .coupon
    var cover: String = ""
    var thumb: String = ""
    var canCallEventPublish: Bool = false
    
    var couponRule: [(String, String)] = []
    var notes: [CampaignNote] = []
    
    var eventGoodsNumb: String = ""
    var eventGoodsIds: [String] = []
    
    var maxNumb: Int = 0
    var appointmentNumb: Int = 0
    var joinNumb: Int = 0
    var point: Int = 0
    var costPoint: Int = 0
    
    var status: CampaignStatus = .notBegin
    
//    var addressId: String = ""
    var addressContact: String = ""
    var addressTel: String = ""
    var addressDetail: String = ""
    
    var shareUrl: String = ""
    
    var closedType: PlaceCampaignClosedType = .noInfo
    var isSuspend = false
    var isApproved: ApproveStatus = .waitingForReview
    private var approveStatus: Int = 0 {
        didSet {
            self.isApproved = ApproveStatus(rawValue: approveStatus)!
        }
    }
    init() {
        
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- (map["event_id"], IntStringTransform())
        category            <- map["cat"]
        
        type                <- map["type"]
        title               <- map["title"]
        cover               <- map["cover"]
        detail              <- map["detail"]
        
        canCallEventPublish <- (map["can_call_event_publish"], BoolStringTransform())
        
        startTime           <- map["start_time"]
        endTime             <- map["end_time"]
        appointmentStartTime  <- map["appointment_start_time"]
        appointmentEndTime  <- map["appointment_end_time"]
        
//        couponRule          <- map["rule"]
        notes               <- map["notes"]
        eventGoodsNumb      <- map["event_goods_num"]
        eventGoodsIds       <- map["event_goods_id"]
        
        maxNumb <- (map["max_num"], IntStringTransform())
        appointmentNumb <- (map["appointment_num"], IntStringTransform())
        joinNumb <- (map["join_num"], IntStringTransform())
        point <- (map["point"], IntStringTransform())
        costPoint <- (map["cost_point"], IntStringTransform())
        
        status <- map["status"]

        addressContact      <- map["contact"]
        addressTel          <- map["tel"]
        addressDetail       <- map["address"]
        
        shareUrl   <- map["share_url"]
        
        closedType <- map["close_type"]
        approveStatus <- (map["is_approved"], IntStringTransform())
    }
    
    var canBeDraft: Bool {
        return !self.cover.isEmpty ||
            !self.title.isEmpty ||
            !self.detail.isEmpty ||
            !self.notes.isEmpty ||
            !self.couponRule.isEmpty ||
            self.maxNumb != 0 ||
            self.point != 0 ||
        !self.addressTel.isEmpty ||
        !self.addressContact.isEmpty ||
        !self.startTime.isEmpty ||
        !self.endTime.isEmpty ||
        !self.appointmentEndTime.isEmpty ||
        !self.appointmentStartTime.isEmpty
    }
    
    static func ==(lhs: PlaceCampaignInfo, rhs: PlaceCampaignInfo) -> Bool {
        var couponRuleIsEqual: Bool = false
        for i in 0 ..< lhs.couponRule.count {
           let  ldic = lhs.couponRule[i]
            let rdic = rhs.couponRule[i]
            if ldic.0 != rdic.0 && ldic.1 != rdic.1 {
                couponRuleIsEqual = false
            } else {
                couponRuleIsEqual = true
            }
        }
        if lhs.couponRule.isEmpty {
            couponRuleIsEqual = true
        }
        return  lhs.id == rhs.id
        &&  lhs.title == rhs.title
        &&  lhs.detail == rhs.detail
        &&  lhs.startTime == rhs.startTime
        &&  lhs.endTime == rhs.endTime
        &&  lhs.appointmentStartTime == rhs.appointmentStartTime
        &&  lhs.appointmentEndTime == rhs.appointmentEndTime
        &&  lhs.cover == rhs.cover
        &&  lhs.thumb == rhs.thumb
        &&  lhs.canCallEventPublish == rhs.canCallEventPublish
        &&  couponRuleIsEqual
        &&  lhs.notes == rhs.notes
        &&  lhs.eventGoodsNumb == rhs.eventGoodsNumb
        &&  lhs.eventGoodsIds == rhs.eventGoodsIds
        &&  lhs.maxNumb == rhs.maxNumb
        &&  lhs.appointmentNumb == rhs.appointmentNumb
        &&  lhs.joinNumb == rhs.joinNumb
        &&  lhs.point == rhs.point
        &&  lhs.costPoint == rhs.costPoint
        &&  lhs.status == rhs.status
        &&  lhs.addressContact == rhs.addressContact
        &&  lhs.shareUrl == rhs.shareUrl
        &&  lhs.closedType == rhs.closedType
        &&  lhs.isSuspend == rhs.isSuspend
    }

}
