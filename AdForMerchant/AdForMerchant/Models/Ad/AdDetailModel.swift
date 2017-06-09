//
//  AdDetailModel.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/24.
//  Copyright © 2016年 Windward. All rights reserved.
// swiftlint:disable operator_whitespace
// swiftlint:disable force_unwrapping

import Foundation
import ObjectMapper

class AdDetailModel: Mappable, Equatable {
    var adID: String = ""
    var title: String = ""
    var detail: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var type: String = ""
    var shareUrl: String = ""
    var videoAdUrl: String = ""
    var webAdUrl: String = ""
    var imgAdUrl: [String] = [String]()
    var cover: String = ""
    var thumb: String = ""
    var point: String = ""
    var pointLimitPerday: String = ""
    var viewNum: String = ""
    var joinNum: String = ""
    var costPoint: String = ""
    var isApproved: ApproveStatus = .waitingForReview
    var status: AdStatus = .waitingForReview //0-待审核 1-进行中 2-已结束
    var question: String = ""
    var answer: AnswerTab = AnswerTab()
    private var approveStatus: Int = 0 {
        didSet {
            self.isApproved = ApproveStatus(rawValue: approveStatus)!
        }
    }
    init() {

    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        adID    <- map["ad_id"]
        title   <- map["title"]
        detail  <- map["detail"]
        startTime  <- map["start_time"]
        endTime <- map["end_time"]
        type    <- map["type"]
        shareUrl  <- map["share_url"]
        videoAdUrl  <- map["video_ad_url"]
        webAdUrl    <- map["web_ad_url"]
        imgAdUrl    <- map["img_ad_url"]
        cover   <- map["cover"]
        thumb   <- map["thumb"]
        point   <- map["point"]
        pointLimitPerday    <- map["point_limit_perday"]
        viewNum <- map["view_num"]
        joinNum <- map["join_num"]
        costPoint   <- map["cost_point"]
        approveStatus  <- (map["is_approved"], IntStringTransform())
       status <- (map["status"], TransformOf<AdStatus, String>(fromJSON: { AdStatus(rawValue: Int($0 ?? "") ?? 0) }, toJSON: { $0.map { String(describing: $0) } }))
        question    <- map["question"]
        answer  <- map["answer"]
    }
    
    var canBeDraft: Bool {
        return !self.adID.isEmpty ||
        !self.title.isEmpty ||
        !self.detail.isEmpty ||
        !self.startTime.isEmpty ||
        !self.endTime.isEmpty ||
        !self.type.isEmpty ||
        !self.shareUrl.isEmpty ||
        !self.videoAdUrl.isEmpty ||
        !self.webAdUrl.isEmpty ||
        !self.imgAdUrl.isEmpty ||
        !self.thumb.isEmpty ||
        !self.pointLimitPerday.isEmpty ||
        !self.viewNum.isEmpty ||
        !self.joinNum.isEmpty ||
        !self.costPoint.isEmpty ||
         !self.question.isEmpty
    }
    
    static func ==(lhs: AdDetailModel, rhs: AdDetailModel) -> Bool {
        return  lhs.adID == rhs.adID &&
            lhs.title == rhs.title &&
            lhs.detail == rhs.detail &&
            lhs.startTime == rhs.startTime &&
            lhs.endTime == rhs.endTime &&
            lhs.type == rhs.type &&
            lhs.shareUrl == rhs.shareUrl &&
            lhs.videoAdUrl == rhs.videoAdUrl &&
            lhs.webAdUrl == rhs.webAdUrl &&
            lhs.imgAdUrl == rhs.imgAdUrl &&
            lhs.pointLimitPerday == rhs.pointLimitPerday &&
            lhs.point == rhs.point &&
            lhs.viewNum == rhs.viewNum &&
            lhs.joinNum == rhs.joinNum &&
            lhs.costPoint == rhs.costPoint &&
            lhs.isApproved == rhs.isApproved &&
            lhs.status == rhs.status &&
            lhs.question == rhs.question &&
            lhs.answer == rhs.answer
    }
}

class AnswerTab: Mappable, Equatable {
    var answerA: AnswerModel = AnswerModel()
    var answerB: AnswerModel = AnswerModel()
    var answerC: AnswerModel = AnswerModel()
    var answerD: AnswerModel = AnswerModel()
    
    init () {
    
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        answerA <- map["a"]
        answerB <- map["b"]
        answerC <- map["c"]
        answerD <- map["d"]
    }
    
   static func ==(lhs: AnswerTab, rhs: AnswerTab) -> Bool {
    return lhs.answerA == rhs.answerA &&
        lhs.answerB == rhs.answerB &&
        lhs.answerC == rhs.answerC &&
        lhs.answerD == rhs.answerD
    }
}

class AnswerModel: Mappable, Equatable {
    var text: String = ""
    var isCorrect: String = "0"
    
    init() {
    
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        text    <- map["text"]
        isCorrect  <- map["is_correct"]
    }
    
    static func ==(lhs: AnswerModel, rhs: AnswerModel) -> Bool {
        return lhs.text == rhs.text &&
            lhs.isCorrect == rhs.isCorrect
    }
}
