//
//  CampaignDescription.swift
//  FPTrade
//
//  Created by Kuma on 9/9/15.
//  Copyright (c) 2015 Windward. All rights reserved.
// swiftlint:disable operator_whitespace
// swiftlint:disable force_unwrapping

import UIKit
import ObjectMapper

// 状态：0-待审核 1-未开始 2-进行中 3-已结束 4-异常

public enum CampaignStatus: String {
    case inReview = "0"
    case notBegin = "1"
    case inProgress = "2"
    case over = "3"
    case exception = "4"
    case draft = "5"
    
    var desc: String {
        switch self {
        case .inReview:
            return "审核中"
        case .notBegin:
            return "未开始"
        case .inProgress:
            return "进行中"
        case .over:
            return "已结束"
        case .exception:
            return "异常"
        case .draft:
            return "草稿"
        }
    }
}

enum CampaignSaleType: Int {
    case coupon, sale = 1, price = 2
}

//下架申请状态 0-从未申请 1-申请中 2-拒绝 3-已同意
enum CampaignStopApplyStatus: String {
    case never = "0", inProgress = "1", rejected = "2", approved = "3"
}

struct CampaignInfo: Mappable, Equatable {
    var id: Int = 0
    var category: String = ""
    var type: CampaignSaleType = .coupon
    var title: String = ""
    var cover: String = ""
    var detail: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var appointmentEndTime: String = ""
    var couponRule: [CouponRule] = []
    var notes: [CampaignNote] = []
    var applyListNumb: Int = 0
    var applyList: [CampaignStopApplyInfo] = []
    var goodsIds: [String] = []
    var maxNumb: Int = 0
    var point: Int = 0
    var addressId: String = ""
    var isApproved: ApproveStatus = .waitingForReview
    var stopApplyStatus: CampaignStopApplyStatus = .never
    var status: CampaignStatus = .notBegin
    var eventGoodsNumb: Int = 0
    var eventGoodsConfigID: [String] = [String]()
    var eventGoonsConfigNum: Int = 0
    var shareUrl: String = ""
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
        
        startTime           <- map["start_time"]
        endTime             <- map["end_time"]
        appointmentEndTime  <- map["appointment_end_time"]
        
        couponRule          <- map["rule.reach_then_minus"]
        notes               <- map["notes"]
        
        applyListNumb <- (map["apply_list_num"], IntStringTransform())
        applyList          <- map["apply_list"]
        
        goodsIds            <- map["event_goods_id"]
        
        maxNumb <- (map["max_num"], IntStringTransform())
        point <- (map["point"], IntStringTransform())

        addressId               <- map["add_id"]
        approveStatus   <- (map["is_approved"], IntStringTransform())
        stopApplyStatus <- map["apply_status"]
        
        status <- map["status"]
        shareUrl   <- map["share_url"]
        eventGoodsConfigID <- map["goods_config_id"]
        eventGoonsConfigNum <- (map["goods_config_num"], IntStringTransform())
        eventGoodsNumb <- (map["goods_num"], IntStringTransform())
    }
    
    var canBeDraft: Bool {
        return !self.cover.isEmpty ||
        !self.title.isEmpty ||
        !self.detail.isEmpty ||
        !self.notes.isEmpty ||
        !self.startTime.isEmpty ||
        !self.endTime.isEmpty ||
        !self.couponRule.isEmpty ||
        !self.eventGoodsConfigID.isEmpty
    }
    
    static func ==(lhs: CampaignInfo, rhs: CampaignInfo) -> Bool {
        return  lhs.id == rhs.id &&
            lhs.category == rhs.category &&
            lhs.type == rhs.type &&
            lhs.status == rhs.status &&
            lhs.startTime == rhs.startTime &&
            lhs.endTime == rhs.endTime &&
            lhs.cover == rhs.cover &&
            lhs.appointmentEndTime == rhs.appointmentEndTime &&
            lhs.couponRule == rhs.couponRule &&
            lhs.notes == rhs.notes &&
            lhs.applyList == rhs.applyList &&
            lhs.applyListNumb == rhs.applyListNumb &&
            lhs.goodsIds == rhs.goodsIds &&
            lhs.maxNumb == rhs.maxNumb &&
            lhs.detail == rhs.detail &&
            lhs.point == rhs.point &&
            lhs.addressId == rhs.addressId &&
            lhs.isApproved == rhs.isApproved &&
            lhs.stopApplyStatus == rhs.stopApplyStatus &&
            lhs.shareUrl == rhs.shareUrl &&
            lhs.eventGoodsConfigID == rhs.eventGoodsConfigID &&
            lhs.eventGoonsConfigNum == rhs.eventGoonsConfigNum &&
            lhs.eventGoodsNumb == rhs.eventGoodsNumb
    }
}
