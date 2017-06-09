//
//  Network.swift
//  AdForMerchant
//
//  Created by lieon on 2017/2/15.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class Header: Model {
    var appToken: String = AFMRequest.OAuthToken ?? ""
    var appVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    var appRole: String = "merchant"
    var deviceModel: String = "1"
    var deviceUUID: String = Common.AppConfig.deviceUUIDString ?? ""
    var deviceVersion: String = UIDevice.current.systemVersion
    var registrationID: String = Common.AppConfig.registrationID ?? ""
    var contentType: String = "application/json"
    
    override func mapping(map: Map) {
        contentType <- map["Content-Type"]
        if Common.AppConfig.isEncrpt {
            appToken <- map["APP_TOKEN"]
            appVersion <- map["APP_VERSION"]
            appRole <- map["APP_ROLE"]
            deviceModel <- map["DEVICE_MODEL"]
            deviceUUID <- map["DEVICE_UUID"]
            deviceVersion <- map["DEVICE_VERSION"]
            registrationID <- map["REGISTRATION_ID"]
        } else {
            appToken <- map["APP-TOKEN"]
            appVersion <- map["APP-VERSION"]
            appRole <- map["APP-ROLE"]
            deviceModel <- map["DEVICE-MODEL"]
            deviceUUID <- map["DEVICE-UUID"]
            deviceVersion <- map["DEVICE-VERSION"]
            registrationID <- map["REGISTRATION-ID"]
        }
    }
}

class KeyObject: Model {
    var key: String = ""
    var hash: String = ""
    var ivSalt: String = ""
    
    override func mapping(map: Map) {
        hash <- map["hash"]
        key <- map["key"]
        ivSalt <- map["iv"]
    }
    
}
class PayloadObject: Model {
    var header: Header = Header()
    var post: [String: Any] = [:]
    
    override func mapping(map: Map) {
        header <- map["header"]
        post <- map["post"]
    }
}

class PostData: Model {
    var payloadObject: PayloadObject =  PayloadObject()
    var keyObject: KeyObject = KeyObject()
    var payload: String = ""
    var keys: String = ""
    
    override func mapping(map: Map) {
        payload <- map["payload"]
        keys <- map["keys"]
    }

    convenience init(parameter: [String: Any], aesKey: String, aesIV: String) {
        self.init()
        var param: [String: Any] = parameter
        if !Common.AppConfig.isEncrpt {
            param["no_encrypt"] = "1"
        }
        payloadObject.post = param
        guard let payloadEncodeJson = payloadObject.toJSONString() else { return }
        let encryptPayload = DES3Util.aes128Encrypt(payloadEncodeJson, key: aesKey, andIv: aesIV)
        keyObject.key = aesKey
        keyObject.ivSalt = aesIV
        keyObject.hash = payloadEncodeJson.md5
        guard let keysEncodeJson = keyObject.toJSONString() else { return }
        if let pubkey = AFMRequest.PublicKey, let paylod = encryptPayload, let encWithPubKey = RSA.encryptString(keysEncodeJson, publicKey: pubkey) {
            self.payload = paylod
            self.keys = encWithPubKey
        }
    }
}
