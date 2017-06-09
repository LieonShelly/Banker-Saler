//
//  Common.swift
//  AdForMerchant
//
//  Created by Kuma on 1/28/16.
//  Copyright © 2016 Windward. All rights reserved.
// swiftlint:disable variable_name

import Foundation

typealias CellDoMoreBlock = (UITableViewCell) -> Void

let kApp = UIApplication.shared.delegate as? AppDelegate ??  AppDelegate()

public let sessionInactiveInterval: TimeInterval = 1800

public let screenWidth = UIScreen.main.bounds.width
public let screenHeight = UIScreen.main.bounds.height

let iphone6P = (screenHeight == 736)
let iphone6 = (screenHeight == 667)
let iphone5 = (screenHeight == 568)

let userSignOutNotification = "userSignOutNotification"
let refreshMerchantInfoNotification = "RefreshMerchantInfoNotification"
let removeProductFilterConditionsNotification = "removeProductFilterConditionsNotification"
let dataSourceNeedRefreshWhenNewObjectAddedNotification = "DataSourceNeedRefreshWhenNewObjectAddedNotification"
let dataSourceNeedRefreshWhenNewProductAddedNotification = "dataSourceNeedRefreshWhenNewProductAddedNotification"
let dataSourceNeedRefreshWhenNewCampaignAddedNotification = "dataSourceNeedRefreshWhenNewCampaignAddedNotification"
let dataSourceNeedRefreshWhenAdChangedNotification = "DataSourceNeedRefreshWhenAdChangedNotification"
let refreshTableViewWhenSuspendNotification = "refreshTableViewWhenSuspendNotification"
let dataSourceWhenRuleInfoFullThreeNotification = "DataSourceWhenRuleInfoFullThreeNotification"
let sendSuccessfulNotification = "sendSuccessfulNotification"
let refreshMessageCenterItemNotification = "refreshMessageCenterItemNotification"
let startAppNotification = "startAppNotification"

let kToken              = "token"
let kstaffId            = "staff_id"
let kSessionAccount     = "sessionAccount"

let oldVersionKey = "oldVersionKey"
let cFBundleShortVersionString = "CFBundleShortVersionString"

//微信
let kWeixinAppID       = "wx1e626583058cf466"
let kWeixinAppSecret   = "235a818fe463fdd3121428ff81df5933"
let kWeixinRedirectURI = "https://www.winagent.com.cn/sns_login/callback/wechat"

//QQ
let kQQAppId           = "1104802249"
let kQQRedirectURI     = "https://www.winagent.com.cn/sns_login/callback/qq"

//PUSH
let kPushId: UInt32 = 2200214104
let kPushKey = "IUS8AD38B86P"

let secondsOfOneDay              = 24 * 60 * 60
let secondsOfOneWeek             = 7 * 24 * 60 * 60
let secondsOfOneMonth            = 30 * 24 * 60 * 60
let secondsOfOneYear             = 365 * 24 * 60 * 60

let itemCountPerPage = 40

public enum PrivileteType: Int {
    case notChoose
    case usePrivilete
    case notPrivilete
}

public enum ObjectModifyType: Int {
    case addNew
    case edit
    case copy
}

public enum ProductType: Int {
    case normal = 1
    case service = 2
}

public enum CampaignType: Int {
    case sale
    case place
}

public enum AttributeType: Int {
    case productParameter
    case productProperty
    case buyNote
    case campaignNote
    case coupon
}

//scan_type	int	true	方式 1-扫描 2-输入

public enum QRCodeType: Int {
    case scan = 1
    case input = 2
}

//1-图片广告 2-视频广告 3-网页广告
public enum AdType: Int {
    case picture = 1
    case movie = 2
    case webpage = 3
}

//0-待审核 1-出售中 2-无库存 3-下架 4-异常
public enum ProductSaleStatus: Int {
    case waitingForReview = 0
    case readyForSale = 1
    case noStock = 2
    case offShelf = 3
    case exception = 4
    case draft = 5
}

public enum ApproveStatus: Int {
    case waitingForReview = 0 // 待审核
    case approved = 1 // 已审核
    case exception = 2 //异常
    case draft = 3 // 草稿
    
    var desc: String {
        switch self {
        case .waitingForReview:
            return "待审核"
        case .approved:
            return "已审核"
        case .exception:
            return "异常"
        case .draft:
            return "草稿"
        }
    }
}

public enum ProductCellType: Int {
    case undefined
    case status
    case cover
    case name
    case summary
    case goodsCategory
    case shopCategory
    case merchantInfo
    case detail
    case goodsImgs
    case price
    case marketPrice
    case point
    case stock
    case rules
    case delivery
    case params
    case property
    case startTime
    case closeTime
    case goodsConfigID
}

public enum CampaignParticipatorListType: Int {
    case appointment
    case appeared
}

//0-全部 1-近三天 2-近一周 3-近一月 4-近三月 5-近一年
public enum TimeSectionPart: Int {
    case undefined = -1
    case all = 0
    case lastThreeDays = 1
    case lastWeek = 2
    case lastMonth = 3
    case lastThreeMonths = 4
    case lastYear = 5
}

//0-未设置封面 1-系统封面 2-自定义封面",
public enum StoreCoverType: Int {
    case undefined = 0
    case system = 1
    case custom = 2
}

//类型 1-积分充值 2-积分消耗
public enum PointBalanceType: Int {
    case charge = 1
    case use = 2
}

public enum IncomeOutgoingType: Int {
    case `in` = 1
    case out = 2
}

// "status": "0",状态 0-待处理 1-处理中 2-处理完结 9-异常
public enum IncomeOutgoingStatus: Int {
    case waitingForProcess = 0
    case inProgress = 1
    case success = 2
    case error = 9
    
    var desc: String {
        switch self {
        case .waitingForProcess:
            return "待处理"
        case .inProgress:
            return "处理中"
        case .success:
            return "处理完结"
        case .error:
            return "异常"
        }
    }
}

//退款状态 0-无退款信息 1-退款申请中 2-已同意 3-已拒绝

public enum OrderRefundStatus: Int {
    case noInfo = 0
    case waitingForProcess = 1
    case agreed = 2
    case rejected = 3
    
    var desc: String {
        switch self {
        case .noInfo:
            return "无退款信息"
        case .waitingForProcess:
            return "退款申请中"
        case .agreed:
            return "已同意"
        case .rejected:
            return "已拒绝"
        }
    }
}

//订单状态 1-待付款 2-已付款/待发货 3-已发货 4-已完成/已收货 9-已关闭
public enum OrderStatus: Int {
    case waitForPay = 1
    case waitForDelivery = 2
    case delivered = 3
    case success = 4
    case refund = 5
    case failed = 9
    
    var desc: String {
        switch self {
        case .waitForPay:
            return "待付款"
        case .waitForDelivery:
            return "待发货"
        case .delivered:
            return "已发货"
        case .refund:
            return "退款"
        case .success:
            return "已完成"
        case .failed:
            return "已关闭"
        }
    }
}

//var status: String = ""//0-待审核 1-进行中 2-已结束 3-异常
// 	广告状态 0-待审核 1-进行中 2-已结束 3-异常(审核失败)
public enum AdStatus: Int {
    case waitingForReview = 0
    case inProgress = 1
    case closed = 2
    case exception = 3
    case draft = 4
}

public enum PaymentType: Int {
    case undefined = -1
    case bankCard = 0
    case alipay = 1
    case wechat = 2
    
    var desc: String {
        switch self {
        case .undefined:
            return "未选择"
        case .bankCard:
            return "银行卡支付"
        case .alipay:
            return "支付宝"
        case .wechat:
            return "微信支付"
        }
    }
}

//type	1-商品 2-活动 3-广告 4-商户中心
public enum MyNotificationType: Int {
    case undefined = 0
    case product = 1
    case campaign = 2
    case ad = 3
    case merchantCenter = 4
    case system = 5
}

public enum DataRefreshType {
    case reload         //清空原有数据，重新载入
    case append         //向原数据追加新数据
}

public enum DetailInputType: Int {
    case undefined
    case title
    case description
    
}

public enum BankAccountListStyle {
    case manage
    case select
}

public enum ShopCategoryManageType {
    case add
    case edit
}

public enum ShopProductManageType {
    case normal
    case move
}

public enum SelectType {
    case single      //单选
    case more       //多选
}

public enum GoodsType: String {
    case normal = "1"
    case service = "2"
    var backgroudColor: UIColor {
        switch self {
        case .normal:
            return UIColor.colorWithHex("eb6158")
        case .service:
            return UIColor.colorWithHex("3eb98b")
        }
    }
    
    var title: String {
        switch self {
        case .normal:
            return "普通商品"
        case .service:
            return "生活服务"
        }
   }
    var nikiname: String {
        switch self {
        case .normal:
            return "普通商品"
        case .service:
            return "服务商品"
        }
    }
}

public enum MessageType: String {
    // 未读
    case unRead = "0"
    // 已读
    case isRead = "1"
}

// 用户登录 类型（店员／老板）
public enum LoginType {
    case clerk
    case boss
}

// 消息中心action类型
public enum ActionType: String {
    case showDetail = "showDetail"
    case gotoPage = "gotoPage"
    case noActionType = ""
    case openUrl = "openUrl"
    case playVideo = "playVideo"
}

/// 验证码状态：1-注册 2-忘记密码 3-重置支付密码 4-商户认证
enum CaptchaType: String {
    case register = "1"
    case forgetPassword = "2"
    case resetPassword = "3"
    case merchantVerify = "4"
}

struct Common {
    struct AppConfig {
        static let appKey: String = (Bundle.main.object(forInfoDictionaryKey: "PUSH_APP_KEY") as? String) ?? ""
        static let appSecret: String = (Bundle.main.object(forInfoDictionaryKey: "PUSH_APP_SECRET") as? String) ?? ""
        static var registrationID: String?
        static var deviceUUIDString: String? = UIDevice.current.identifierForVendor?.uuidString
        static var applePushToken: String?
        static var isEncrpt: Bool {
            if let encrptStr = Bundle.main.infoDictionary?["ENCRYPT"] as? String, let encrpt = Bool(encrptStr) {
                return encrpt
            } else {
                return true
            }
        }
    }
}

/// 使用xx功能需先进行商家实名认证
public enum AttestationAlertTitle: String {
    
    /// 扫码支付设置
    case perferentialPaySetting = "使用扫码支付设置功能需先进行商家实名认证"
    /// 我要收单
    case wantCollect = "使用我要收单功能需先进行商家实名认证"
    /// 店铺分类
    case shopsCategory = "使用店铺分类功能需先进行商家实名认证"
    /// 货号管理
    case itemManageCategory = "使用货号管理功能需先进行商家实名认证"
    /// 我的店员
    case myShopAssistanManage = "使用我的店员功能需先进行商家实名认证"
    /// 店铺地址管理
    case shopAdressManage = "使用店铺地址管理功能需先进行商家实名认证"
    /// 发布公能
    case publish = "使用发布功能需先进行商家实名认证"
}
