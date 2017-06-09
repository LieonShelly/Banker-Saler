//
//  RequestManager.swift
//  feno
//
//  Created by Kuma on 6/29/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//  swiftlint:disable force_unwrapping
//  swiftlint:disable type_body_length

import UIKit
import Alamofire
import ObjectMapper

let domainURL: String = (Bundle.main.object(forInfoDictionaryKey: "DOMAIN_URL") as? String) ?? ""
let environment: String = (Bundle.main.object(forInfoDictionaryKey: "DOMAIN_ENV") as? String) ?? "stg"

public enum AFMRequest: URLRequestConvertible {
    static let merchantBaseURLString = "http://"+environment+".merchant." + domainURL
    static let ebusinessBaseURLString = "http://"+environment+".ebusiness." + domainURL
    static let marketingBaseURLString = "http://"+environment+".marketing." + domainURL
    static let contentBaseURLString = "http://"+environment+".content." + domainURL
    static let fileBaseURLString = "http://"+environment+".file." + domainURL
    static let homeURLString = "http://www.winagent.com.cn"
    
    static var OAuthToken: String?
    static var PublicKey: String?
    
    static let dateFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        format.locale = Locale(identifier: "en_US_POSIX")
        format.timeZone = TimeZone(abbreviation: "GMT")
        return format
        }()
    
    case feedbackCatList(String, String)
    case feedbackSave([String : Any], String, String)
    case startStartPage(String, String)
    
    case captchaImgCode([String : Any], String, String)
    case captchaCheckImgCode([String : Any], String, String)
    case cardList(String, String)
    case cardBind([String : Any], String, String)
    case cardDel([String : Any], String, String)
    case configDefaultStoreCover(String, String)
    case merchantRegist([String : Any], String, String)
    case merchantLogin([String : Any], String, String)
    case merchantLogout(String, String)
    case merchantUpdatePassword([String : Any], String, String)
    case merchantSetPaypassword([String : Any], String, String)
    case merchantCheckPaypassword([String : Any], String, String)
    case merchantUpdatePayPassword([String : Any], String, String)
    case merchantResetPasswordStepOne([String : Any], String, String)
    case merchantResetPasswordStepTwo([String : Any], String, String)
    case merchantResetPayPasswordStepOne([String : Any], String, String)
    case merchantResetPayPasswordStepTwo([String : Any], String, String)
    case merchantInfo(String, String)
    case merchantUpdate([String : Any], String, String)
    case merchantCertify([String : Any], String, String)
    case merchantCheckIdNumber([String : Any], String, String)
    case noticeMyNotice([String : Any], String, String)
    case noticeSysNotice([String : Any], String, String)
    case readNotice([String : Any], String, String)
    case unreadNum(String, String)
    case moneyList([String : Any], String, String)
    case pointList([String : Any], String, String)
    case pointRechargeByCard([String : Any], String, String)
    case verifyPayPassword([String : Any], String, String)
    case sendSmsCode([String : Any], String, String)
    case getAllPoint(String, String)
    case storeInfo(String, String)
    case storeSave([String : Any], String, String)
    case storeCatList([String : Any], String, String)
    case storeSaveCat([String : Any], String, String)
    case storeDelCat([String : Any], String, String)
    case storeTopCat([String : Any], String, String)
    case storeUntopCat([String : Any], String, String)
    case storeReclassify([String : Any], String, String)
    case storeReclassifyServiceGoods([String : Any], String, String)
    case storeReclassifyGoodsConfig([String : Any], String, String)
    case storeAddressList(String, String)
    case storeSaveAddress([String : Any], String, String)
    case storeDelAddress([String : Any], String, String)
    case walletWithdraw([String : Any], String, String)
    case walletMoneyList([String : Any], String, String)
    case walletMoneyDetail([String : Any], String, String)
    case walletPointRecharge([String : Any], String, String)
    case walletGetAlipayInfo([String : Any], String, String)
    case walletGetWeixinInfo([String : Any], String, String)
    case savePushToken([String : Any], String, String)
    case sshPublicKey([String: Any])
    //--------电商---------
    case couponList([String : Any], String, String)
    //促销活动--商户用
    case eventIndex([String : Any], String, String)
    case eventClose([String : Any], String, String)
    case eventApply([String : Any], String, String)
    case eventDel([String : Any], String, String)
    case eventDetail([String : Any], String, String)
    case eventPreview([String: Any], String, String)
    case eventSave([String : Any], String, String)
    //商品-商户用
    case goodsForEvents([String: Any], String, String)
    case goodsAll([String: Any], String, String)
    case goodsCatList([String: Any], String, String)
    case goodsFilter(String, String)
    case goodsSearch([String: Any], String, String)
    case goodsIndex([String : Any], String, String)
    case goodsEvents([String : Any], String, String)
    case goodsSoldout([String : Any], String, String)
    case goodsPutaway([String : Any], String, String)
    case goodsDel([String : Any], String, String)
    case goodsDetail([String : Any], String, String)
    case goodsPreview([String : Any], String, String)
    case goodsSave([String : Any], String, String)
    case exception([String : Any], String, String)
    case addNum([String : Any], String, String)
    case postpone([String : Any], String, String)
    //物流公司
    case logisticsList(String, String)
    case logisticsTracks([String : Any], String, String)
    //订单-商户用
    case orderSummary(String, String)
    case orderTopayList([String : Any], String, String)
    case orderTopayChangePrice([String : Any], String, String)
    case orderPaiedList([String : Any], String, String)
    case orderPaiedShip([String : Any], String, String)
    case orderShippedList([String : Any], String, String)
    case orderShippedExtend([String : Any], String, String)
    case orderRefundingList([String : Any], String, String)
    case orderDealedList([String : Any], String, String)
    case orderRefundAgree([String : Any], String, String)
    case orderRefundReject([String : Any], String, String)
    case orderRefundDelete([String : Any], String, String)
    case orderDoneList([String : Any], String, String)
    case orderClosedList([String : Any], String, String)
    case orderClose([String : Any], String, String)
    case orderDelete([String : Any], String, String)
    case orderDetail([String : Any], String, String)
    case orderRefundDetail([String : Any], String, String)
    //QR Code
    case qrCodeConfirm([String : Any], String, String)
    case qrCodeScan([String : Any], String, String)
    
    //广告-商户用
    case adIndex([String : Any], String, String)
    case adClose([String : Any], String, String)
    case adDetail([String : Any], String, String)
    case adPreview([String : Any], String, String)
    case adUserlist([String : Any], String, String)
    case adPointCost([String : Any], String, String)
    case adSave([String : Any], String, String)
    case adDel([String : Any], String, String)
    //现场活动-商家用
    case placeEventIndex([String : Any], String, String)
    case placeEventClose([String : Any], String, String)
    case placeEventDel([String : Any], String, String)
    case placeEventDetail([String : Any], String, String)
    case placeEventPreview([String : Any], String, String)
    case placeEventAppointedUserlist([String : Any], String, String)
    case placeEventUserlist([String : Any], String, String)
    case placeEventSave([String : Any], String, String)
    case placeEventScanQrcode([String : Any], String, String)

    // 优惠买单-商家用
    case privilegeList([String : Any], String, String)
    case privilegeAddRule([String : Any], String, String)
    case privilegeRuleList([String : Any], String, String)
    case privilegeDeleteRule([String : Any], String, String)
    case privilegeCreate([String : Any], String, String)
    
    ///商户店员管理
    case addStaff([String: Any], String, String)
    case getStaffList(String, String)
    case deleteStaff([String: Any], String, String)
    case modifyStaff([String: Any], String, String)
    case detailsStaff([String: Any], String, String)
    /// 货号
    case getGoodsList([String: Any], String, String)
    case saveGoods([String: Any], String, String)
    case goodsConfigDetail([String: Any], String, String)
    case deleteGoodsConfig([String: Any], String, String)
    case goodsConfigGetFinalGoods([String: Any], String, String)
    // 上传图片
    case imageUpload
    
    var method: Alamofire.HTTPMethod {
        switch self {
        default:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .feedbackCatList: return "feedback/cat_list"
        case .feedbackSave: return "feedback/save"
        case .startStartPage: return "start/start_page"
        case .captchaImgCode: return "captcha/img_code"
        case .captchaCheckImgCode: return "captcha/check_img_code"
        case .cardList: return "card/list"
        case .cardBind: return "card/bind"
        case .cardDel: return "card/del"
        case .configDefaultStoreCover: return "config/default_store_cover"
        case .merchantRegist: return "merchant/regist"
        case .merchantLogin: return "merchant/login"
        case .merchantLogout: return "merchant/logout"
        case .merchantUpdatePassword: return "merchant/update_password"
        case .merchantSetPaypassword: return "merchant/set_pay_password"
        case .merchantCheckPaypassword: return "merchant/check_pay_password"
        case .merchantUpdatePayPassword: return "merchant/update_pay_password"
        case .merchantResetPasswordStepOne: return "merchant/reset_password_step_one"
        case .merchantResetPasswordStepTwo: return "merchant/reset_password_step_two"
        case .merchantResetPayPasswordStepOne: return "merchant/reset_pay_password_step_one"
        case .merchantResetPayPasswordStepTwo: return "merchant/reset_pay_password_step_two"
        case .merchantInfo: return "merchant/info"
        case .merchantUpdate: return "merchant/update"
        case .merchantCertify: return "merchant/certify"
        case .merchantCheckIdNumber: return "merchant/check_id_number"
        case .noticeMyNotice: return "notice/list"
        case .noticeSysNotice: return "notice/list"
        case .readNotice: return "notice/read_notice"
        case .unreadNum: return "notice/unread_num"
        case .moneyList: return "money/list"
        case .pointList: return "point/list"
        case .pointRechargeByCard: return "point/recharge_by_card"
        case .verifyPayPassword: return "point/verify_pay_password"
        case .sendSmsCode: return "point/send_sms_code"
        case .getAllPoint: return "point/get_merchant_total_point"
        case .storeInfo: return "store/info"
        case .storeSave: return "store/save"
        case .storeCatList: return "store/cat_list"
        case .storeSaveCat: return "store/save_cat"
        case .storeDelCat: return "store/del_cat"
        case .storeTopCat: return "store/top_cat"
        case .storeUntopCat: return "store/untop_cat"
        case .storeReclassify: return "store/reclassify"
        case .storeReclassifyGoodsConfig: return "store/reclassify_goods_config"
        case .storeReclassifyServiceGoods: return "store/reclassify_service_goods"
        case .storeAddressList: return "store/address_list"
        case .storeSaveAddress: return "store/save_address"
        case .storeDelAddress: return "store/del_address"
        case .walletWithdraw: return "wallet/withdraw"
        case .walletMoneyList: return "wallet/money_list"
        case .walletMoneyDetail: return "wallet/money_detail"
        case .walletPointRecharge: return "wallet/point_recharge"
        case .walletGetAlipayInfo: return "wallet/get_alipay_info"
        case .walletGetWeixinInfo: return "wallet/get_weixin_info"
        case .couponList: return "coupon/list"
        case .sshPublicKey: return "ssh/public_key"
        case .savePushToken: return "merchant/save_push_token"
        //促销活动--商户用
        case .eventIndex: return "event/index"
        case .eventClose: return "event/close"
        case .eventApply: return "event/apply"
        case .eventDel: return "event/del"
        case .eventDetail: return "event/detail"
        case .eventPreview: return "event/preview"
        case .eventSave: return "event/save"
        //商品--商户用
        case .goodsAll: return "goods/all"
        case .goodsForEvents: return "goods/event_goods"
        case .goodsSearch: return "goods/search"
        case .goodsFilter: return "goods/filter"
        case .goodsCatList: return "goods/cat_list"
        case .goodsIndex: return "goods/index"
        case .goodsEvents: return "goods/events"
        case .goodsSoldout: return "goods/soldout"
        case .goodsPutaway: return "goods/putaway"
        case .goodsDel: return "goods/del"
        case .goodsDetail: return "goods/detail"
        case .goodsPreview: return "goods/preview"
        case .goodsSave: return "goods/save"
        case .logisticsList: return "logistics/list"
        case .logisticsTracks: return "logistics/tracks"
        case .exception: return "merchant/abnormal/check_abnormal"
        case .addNum: return "goods/add_num"
        case .postpone: return "goods/postpone"
        //订单--商户用
        case .orderSummary: return "order/summary"
        case .orderTopayList: return "order/topay_list"
        case .orderTopayChangePrice: return "order/topay_change_price"
        case .orderPaiedList: return "order/paied_list"
        case .orderPaiedShip: return "order/paied_ship"
        case .orderShippedList: return "order/shipped_list"
        case .orderShippedExtend: return "order/shipped_extend"
        case .orderRefundingList: return "order/refunding_list"
        case .orderDealedList: return "order/dealed_list"
        case .orderRefundAgree: return "order/agree_refund"
        case .orderRefundReject: return "order/reject_refund"
        case .orderRefundDelete: return "order/del_refund"
        case .orderDoneList: return "order/done_list"
        case .orderClosedList: return "order/closed_list"
        case .orderClose: return "order/close"
        case .orderDelete: return "order/del"
        case .orderDetail: return "order/detail"
        case .orderRefundDetail: return "order/refund_detail"
        case .qrCodeConfirm: return "qrcode/confirm"
        case .qrCodeScan: return "qrcode/scan"
        
        //广告-商户用
        case .adIndex: return "ad/index"
        case .adClose: return "ad/close"
        case .adDetail: return "ad/detail"
        case .adPreview: return "ad/preview"
        case .adUserlist: return "ad/userlist"
        case .adPointCost: return "ad/point_cost"
        case .adSave: return "ad/save"
        case .adDel: return "ad/del"
        
        //现场活动-商家用
        case .placeEventIndex: return "event/index"
        case .placeEventClose: return "event/close"
        case .placeEventDel: return "event/del"
        case .placeEventDetail: return "event/detail"
        case .placeEventPreview: return "event/preview"
        case .placeEventUserlist: return "event/userlist"
        case .placeEventAppointedUserlist: return "event/appointed_userlist"
        case .placeEventSave: return "event/save"
        case .placeEventScanQrcode: return "event/scan_qrcode"

        // 优惠买单-商家用
        case .privilegeList: return "privilege/order_list"
        case .privilegeAddRule: return "privilege/add_rule"
        case .privilegeRuleList: return "privilege/rule_list"
        case .privilegeDeleteRule: return "privilege/del_rule"
        case .privilegeCreate: return "privilege/create"

        // 商户店员管理
        case .addStaff: return "staff/add_staff"
        case .getStaffList: return "staff/staff_list"
        case .deleteStaff: return "staff/del_staff"
        case .modifyStaff: return "staff/update_staff"
        case .detailsStaff: return "staff/get_staff_info"
            
        // 货号管理
        case .getGoodsList: return "goods_config/list"
        case .saveGoods: return "goods_config/save"
        case .goodsConfigDetail: return "goods_config/detail"
        case .deleteGoodsConfig: return "goods_config/delete"
        case .goodsConfigGetFinalGoods: return "goods_config/get_finally"
        // 上传图片
        case .imageUpload: return "image/upload"
        }
    }
    
    // MARK: URLRequestConvertible
    
    public func asURLRequest() throws -> URLRequest {
        var URL = Foundation.URL(string: AFMRequest.merchantBaseURLString)!
        
        switch self {
        case .feedbackCatList,
             .feedbackSave,
             .startStartPage:
             URL = Foundation.URL(string: AFMRequest.contentBaseURLString)!
        case .captchaImgCode,
        .captchaCheckImgCode,
        .cardList,
        .cardBind,
        .cardDel,
        .configDefaultStoreCover,
        .merchantRegist,
        .merchantLogin,
        .merchantLogout,
        .merchantUpdatePassword,
        .merchantSetPaypassword,
        .merchantCheckPaypassword,
        .merchantUpdatePayPassword,
        .merchantResetPasswordStepOne,
        .merchantResetPasswordStepTwo,
        .merchantResetPayPasswordStepOne,
        .merchantResetPayPasswordStepTwo,
        .merchantInfo,
        .merchantUpdate,
        .merchantCertify,
        .merchantCheckIdNumber,
        .noticeMyNotice,
        .noticeSysNotice,
        .readNotice,
        .unreadNum,
        .moneyList,
        .pointList,
        .pointRechargeByCard,
        .verifyPayPassword,
        .sendSmsCode,
        .getAllPoint,
        .storeInfo,
        .storeSave,
        .storeCatList,
        .storeSaveCat,
        .storeDelCat,
        .storeTopCat,
        .storeUntopCat,
        .storeReclassify,
        .storeReclassifyGoodsConfig,
        .storeReclassifyServiceGoods,
        .storeAddressList,
        .storeSaveAddress,
        .storeDelAddress,
        .walletWithdraw,
        .walletMoneyList,
        .walletMoneyDetail,
        .walletPointRecharge,
        .walletGetAlipayInfo,
        .walletGetWeixinInfo,
        .sshPublicKey,
        .savePushToken,
        .addStaff,
        .getStaffList,
        .deleteStaff,
        .detailsStaff,
        .modifyStaff:
            
            URL = Foundation.URL(string: AFMRequest.merchantBaseURLString)!
            
        case .adIndex,
        .adClose,
        .adDetail,
        .adPreview,
        .adUserlist,
        .adPointCost,
        .adSave,
        .adDel,
        .placeEventIndex,
        .placeEventClose,
        .placeEventDel,
        .placeEventDetail,
        .placeEventPreview,
        .placeEventUserlist,
        .placeEventAppointedUserlist,
        .placeEventSave,
        .placeEventScanQrcode:
            URL = Foundation.URL(string: AFMRequest.marketingBaseURLString)!
        
        case .imageUpload:
            URL = Foundation.URL(string: AFMRequest.fileBaseURLString)!
            
        default:
            URL = Foundation.URL(string: AFMRequest.ebusinessBaseURLString)!
        }
        
        var mutableURLRequest = URLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue

        switch self {
        case .feedbackCatList(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .feedbackSave(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .startStartPage(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .captchaImgCode(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .captchaCheckImgCode(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .cardList(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .cardBind(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .cardDel(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .configDefaultStoreCover(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantRegist(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantLogin(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            print(" 登陆参数:"+"\(postParms)")
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantLogout(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantUpdatePassword(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantSetPaypassword(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantCheckPaypassword(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantUpdatePayPassword(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantResetPasswordStepOne(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantResetPasswordStepTwo(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantResetPayPasswordStepOne(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantResetPayPasswordStepTwo(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantInfo(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantUpdate(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantCertify(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .merchantCheckIdNumber(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .noticeMyNotice(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .noticeSysNotice(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .readNotice(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .unreadNum(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .moneyList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .pointList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .pointRechargeByCard(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .verifyPayPassword(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .sendSmsCode(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .getAllPoint(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeInfo(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeSave(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeCatList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeSaveCat(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeDelCat(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeTopCat(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeUntopCat(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeReclassify(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeReclassifyGoodsConfig(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeReclassifyServiceGoods(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeAddressList(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeSaveAddress(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .storeDelAddress(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .walletWithdraw(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .walletMoneyList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .walletMoneyDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .walletPointRecharge(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .walletGetAlipayInfo(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .walletGetWeixinInfo(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .sshPublicKey(let parameters):
            return try URLEncoding.default.encode(mutableURLRequest, with: parameters).urlRequest!
        case .savePushToken(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .couponList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        //促销活动--商户用
        case .eventIndex(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .eventClose(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .eventApply(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .eventDel(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .eventDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .eventPreview(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .eventSave(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        //商品--商户用
        case .goodsCatList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsAll(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsForEvents(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsFilter(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsSearch(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsIndex(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsEvents(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsSoldout(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsPutaway(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsDel(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsPreview(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsSave(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .exception(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .addNum(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .postpone(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        //物流公司
        case .logisticsList(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .logisticsTracks(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
            
//        订单-商户用
        case .orderSummary(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderTopayList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderTopayChangePrice(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderPaiedList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderPaiedShip(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderShippedList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderShippedExtend(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderRefundingList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderDealedList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderRefundAgree(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderRefundReject(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderRefundDelete(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderDoneList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderClosedList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderClose(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderDelete(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .orderRefundDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .qrCodeConfirm(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .qrCodeScan(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
       
        case .adIndex(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .adClose(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .adDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .adPreview(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .adUserlist(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .adPointCost(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .adSave(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .adDel(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventIndex(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventClose(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventDel(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventPreview(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventUserlist(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventAppointedUserlist(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventSave(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .placeEventScanQrcode(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!

        // 优惠买单用
        case .privilegeList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .privilegeAddRule(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .privilegeRuleList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .privilegeDeleteRule(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .privilegeCreate(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
         /// 商户店员管理
        case .addStaff(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
          case .getStaffList(let aesKey, let aesIv):
            let postParms = postParameters([:], aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .deleteStaff(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .modifyStaff(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .detailsStaff(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        /// 货号管理
            /// 获取货物列表
        case .getGoodsList(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
            /// 添加/编辑货号
        case .saveGoods(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
            /// 货号详情
        case .goodsConfigDetail(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
            /// 删除货号
        case .deleteGoodsConfig(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        case .goodsConfigGetFinalGoods(let parameters, let aesKey, let aesIv):
            let postParms = postParameters(parameters, aesKey: aesKey, aesIV: aesIv)
            return try URLEncoding.default.encode(mutableURLRequest, with: postParms).urlRequest!
        default:
            return mutableURLRequest
        }
    }
    
    func postParameters(_ parameters: [String : Any], aesKey: String, aesIV: String) -> [String: Any] {
        let postData = PostData(parameter: parameters, aesKey: aesKey, aesIV: aesIV)
        print("param="+"\(postData.payloadObject.post)")
        return postData.toJSON()
       /* var headers: [String: Any] = [:]
        if let token = AFMRequest.OAuthToken {
            headers["APP_TOKEN"] = token
        }
        
        if let info = Bundle.main.infoDictionary, let version = info["CFBundleShortVersionString"] as? String {
            headers["APP_VERSION"] = version
        }
        headers["APP_ROLE"] = "merchant"
        
        headers["DEVICE_MODEL"] = "1"
        headers["DEVICE_UUID"] = Common.AppConfig.deviceUUIDString
        let strSysVersion = UIDevice.current.systemVersion
        headers["DEVICE_VERSION"] = strSysVersion
        headers["REGISTRATION_ID"] = Common.AppConfig.registrationID ?? ""
        headers["Content-Type"] = "application/json"
        let payload = ["header": headers, "post": parameters]
        
//        print("payload:\n\(payload)")
        
        var payloadEncodeJson = ""
        
        do {
            let options = JSONSerialization.WritingOptions()
            let data = try JSONSerialization.data(withJSONObject: payload, options: options)
            payloadEncodeJson = String(data: data, encoding: String.Encoding.utf8)!
        } catch {
            return ([:])
        }
        let encryptPayload = DES3Util.aes128Encrypt(payloadEncodeJson, key: aesKey, andIv: aesIV)
        let keys = ["key": aesKey, "iv": aesIV, "hash": payloadEncodeJson.md5]
        
        var keysEncodeJson = ""
        
        do {
            let options = JSONSerialization.WritingOptions()
            let data = try JSONSerialization.data(withJSONObject: keys, options: options)
            keysEncodeJson = String(data: data, encoding: String.Encoding.utf8)!
        } catch {
            return ([:])
        }
        guard let pubkey = AFMRequest.PublicKey else {
            
            return ([:])
        }
        
        // Demo: encrypt with public key
        if let paylod = encryptPayload, let encWithPubKey = RSA.encryptString(keysEncodeJson, publicKey: pubkey) {
            return (["payload": paylod, "keys": encWithPubKey])
        } else {
            return [:]
        } */
    }
    
    static func randomStringWithLength16() -> String {
        return String(format:"%08X%08X", arc4random(), arc4random())
    }
    
    static func randomStringWithLength32() -> String {
        return String(format:"%08X%08X%08X%08X", arc4random(), arc4random(), arc4random(), arc4random())
    }
}

class RequestManager: NSObject {
    static let sharedManager: SessionManager = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = TimeInterval(10)
        configuration.timeoutIntervalForResource = TimeInterval(60)
        return SessionManager(configuration: configuration)
    }()
    
    class func request(_ URLRequest: URLRequestConvertible, aesKeyAndIv: (key: String, iv: String)? = nil, completionHandler: @escaping (URLRequest, HTTPURLResponse?, Any?, NSError?, String?) -> Void) {
        let aesKey = aesKeyAndIv?.key
        let aesIV = aesKeyAndIv?.iv
//        print("aeskey:\(aesKey ?? "")-----aesIV:\(aesIV ?? "")")
//                print(URLRequest.urlRequest?.url ?? "")
        
        RequestManager.sharedManager.request(URLRequest).responseJSON(options: JSONSerialization.ReadingOptions.allowFragments) { (response) -> Void in
            if let object = response.result.value as? [String: Any] {
                
//                print(object)
//                print("\n\n\naesKey \(aesKey)\naesIV \(aesIV)\n\n")
                
                var responseObject: [String: Any]!
                if let payload = object["payload"] as? String {
                    if let decryptPayload = DES3Util.aes128Decrypt(payload, key: aesKey, andIv: aesIV) {
//                        print(decryptPayload)
                        
                        do {
                            let processedStr = decryptPayload.replacingOccurrences(of: "\0", with: "")
                            let data = processedStr.data(using: .utf8)
                            responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                            if responseObject == nil {
                                responseObject = ["status": "0", "msg": "JSON Error"]
                            }
                        } catch {
//                            print(error)
                            responseObject = ["status": "0", "msg": "JSON Error"]
                        }
                    } else {
                        responseObject = ["status": "0", "msg": "Unknow Error"]
                    }
                } else {
                    responseObject = object
                }
                
                let status = responseObject["status"] as? String
                let msg = (responseObject["msg"] as? String) ?? ""
                
                if status == "1" {
                    let filterResult = self.getObjectsResultFromInitDic(responseObject)
//                    print("data:\(filterResult)")
                    DispatchQueue.main.async {
                        completionHandler(response.request!, response.response, filterResult, nil, msg)
                    }
                } else {
                    NSLog("message: %@", msg)
                    
                    if let needRelogin = responseObject["need_relogin"] as? String, needRelogin == "1" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NEED_RELOGIN_NOTI"), object: nil, userInfo: ["message": msg])
                        let code = (responseObject["code"] as? String) ?? "0"
                        DispatchQueue.main.async {
                            completionHandler(response.request!, nil, nil, NSError(domain: "com.mianshanghang.merchantapp", code: Int(code) ?? 0, userInfo: nil), nil)
                        }
                    } else {
                        let code = (responseObject["code"] as? String) ?? "0"
                        DispatchQueue.main.async {
                            completionHandler(response.request!, nil, nil, NSError(domain: "com.mianshanghang.merchantapp", code: Int(code) ?? 0, userInfo: ["message": msg]), msg)
                        }
                    }
                    return
                }
            } else if let error = response.result.error {
                NSLog("%@", error.localizedDescription)
                
                let errMsg = error.localizedDescription
                let err = NSError(domain: "com.mianshanghang.merchantapp", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    completionHandler(response.request!, nil, nil, err, errMsg )
                }
                
            } else {
                let errMsg = "Unknow Error"
                let error = NSError(domain: response.request!.url?.absoluteString ?? "", code: 9999, userInfo:  ["message": errMsg])
                DispatchQueue.main.async {
                    completionHandler(response.request!, nil, nil, error, errMsg )
                }
            }
            
        }
        
    }
    
    class func uploadImage(_ urlRequest: URLRequestConvertible, params: [String: Any], completionHandler: @escaping (URLRequest, HTTPURLResponse?, Any?, NSError?) -> Void) {
        RequestManager.sharedManager.upload(multipartFormData: { multipartFormData in
            for key in params.keys {
                if !key.hasPrefix("prefix") {
                    if let photoData = params[key] as? Data {
                        multipartFormData.append(photoData, withName: key, fileName: "\(key).jpg", mimeType: "image/jpeg")
                    } else if let photoDataArray = params[key] as? [Data] {
                        for index in 0..<photoDataArray.count {
                            let data = photoDataArray[index]
                            multipartFormData.append(data, withName: "\(key)[]", fileName: "\(key)\(index).jpg", mimeType: "image/jpeg")
                        }
                    }
                } else {
                    guard let content = params[key] as? String, let data = content.data(using: .utf8) else { return }
                    multipartFormData.append(data, withName: key)
                }
            }
        }, with: urlRequest, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(options: .allowFragments) { response in
                    
                    switch response.result {
                    case .success(_):
                        if let responseObject = response.result.value as? [String: Any] {
//                            print("JSON: \(responseObject)")
                            
                            if ((responseObject["status"] as? String) ?? "0") == "1" {
                                let filterResult = self.getObjectsResultFromInitDic(responseObject)
                                DispatchQueue.main.async {
                                    completionHandler(response.request!, response.response, filterResult, nil)
                                }
                            } else {
                                let msg = responseObject["message"] as? String
                                NSLog("message: %@", msg ?? "")
                                DispatchQueue.main.async {
                                    completionHandler(response.request!, nil, nil, NSError(domain: "com.mianshanghang.merchantapp", code: 0, userInfo: ["message": msg ?? ""]))
                                }
                            }
                        }
                    case .failure(let error):
                        NSLog("message: %@", error.localizedDescription)
                        DispatchQueue.main.async {
                            completionHandler(response.request!, nil, nil, error as NSError?)
                        }
                        
                    }
                }
            case .failure( _):
                completionHandler(NSURLRequest() as URLRequest, nil, nil, NSError(domain: "com.mianshanghang.merchantapp", code: 9999, userInfo: nil) )
//                print(encodingError)
            }
        })
        
    }
    
    class func uploadImageWithFilePath(_ urlRequest: URLRequestConvertible, params: [String: Any], completionHandler: @escaping (URLRequest, HTTPURLResponse?, Any?, NSError?) -> Void) {
        RequestManager.sharedManager.upload(multipartFormData: { (multipartFormData) in

            for key in params.keys {
                if !key.hasPrefix("prefix") {
                    if let photoFilePath = params[key] as? URL {
                        multipartFormData.append(photoFilePath, withName: key, fileName: "\(key).jpg", mimeType: "image/jpeg")
                    } else if let photoFilePathArray = params[key] as? [URL] {
                        for i in 0..<photoFilePathArray.count {
                            multipartFormData.append(photoFilePathArray[i], withName: "\(key)[]", fileName: "\(key)\(i).jpg", mimeType: "image/jpeg")
                        }
                    }
                } else {
                    guard let content = params[key] as? String, let data = content.data(using: .utf8) else { return }
                    multipartFormData.append(data, withName: key)
                }
            }
        }, with: urlRequest, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(options: .allowFragments) { response in
                    switch response.result {
                    case .success(_):
                        
                        if let responseObject = response.result.value as? [String: Any] {
//                            print("JSON: \(responseObject)")
                            
                            if (responseObject["status"] as? String) == "1" {
                                let filterResult = self.getObjectsResultFromInitDic(responseObject)
                                DispatchQueue.main.async {
                                    completionHandler(response.request!, response.response, filterResult, nil)
                                }
                            } else {
                                let msg = responseObject["message"] as? String
                                NSLog("message: %@", msg ?? "")
                                DispatchQueue.main.async {
                                    completionHandler(response.request!, nil, nil, NSError(domain: "com.mianshanghang.merchantapp", code: 0, userInfo: ["message": msg ?? ""]))
                                }
                            }
                        }
                        
                    case .failure(let error):
                        NSLog("message: %@", error.localizedDescription)
                        
                        DispatchQueue.main.async {
                            completionHandler(response.request!, nil, nil, error as NSError?)
                        }
                        
                    }
                }
            case .failure(_):
                completionHandler(NSURLRequest() as URLRequest, nil, nil, NSError(domain: "com.mianshanghang.merchantapp", code: 9999, userInfo: nil) )
//                print(encodingError)
            }
        })
    }
    
    class func getObjectsResultFromInitDic(_ initDic: [String: Any]) -> Any? {
        let result = initDic["data"]
        return result
    }
}
