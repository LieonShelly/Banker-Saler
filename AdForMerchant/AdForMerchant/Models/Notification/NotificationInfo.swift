//
//  NotificationInfo.swift
//  FPTrade
//
//  Created by Koh Ryu on 21/9/15.
//  Copyright © 2015年 Windward. All rights reserved.
//

import Foundation
import ObjectMapper

public enum NotificationType: Int {
    case system = 1
    case message = 2
}

public enum NotificationExtraDataType: Int {//1:评论问题 2:赞问题 3:赞评论
    case undefined = 0
    case answerQuestion = 1
    case favorQuestion = 2
    case upvoteAnswer = 3
}

class NotificationExtraData {
    
    var type: NotificationExtraDataType = .undefined
//    var questionInfo: QuestionInfo = QuestionInfo()
//    var answerInfo: AnswerInfo = AnswerInfo()
    
    init() {
        self.type = .undefined
//        self.answerInfo = AnswerInfo()
//        self.questionInfo = QuestionInfo()
    }
    
    init(dic: [String : AnyObject]) {
        if let str = dic["type"] as? String, let tType = Int(str) {
            self.type = NotificationExtraDataType(rawValue: tType) ?? .undefined
        }
    }

}

struct NotificationInfo: Mappable {
    var id: Int = 0
    var type: NotificationType = NotificationType.system
    var content: String = ""
    var createTime: Date?
    var hasRead: Bool = false
    var extraData: NotificationExtraData = NotificationExtraData()
    
    init() {
        self.id = 0
        self.type = .system
        self.content = "【活动】悦诗风吟2周年纪念活动即将开始~"
        self.createTime = Date()
        self.hasRead = false
    }
    
    init(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        id          <- map["productId"]
        type        <- map["name"]
        content     <- map["productId"]
        createTime  <- map["name"]
        hasRead     <- map["productId"]
    }
    
    static func test() -> NotificationInfo {
        let notice = NotificationInfo()
        return notice
    }
}
