//
//  CHWebSocket.swift
//  CHWebSocketSDK
//
//  Created by lieon on 2016/12/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import SocketRocket

private let info: AppInfo = AppInfo()
fileprivate class AppInfo {
    static var standard: AppInfo {
        return info
    }
    var registerID: String? = {
        let regID = UserDefaults.standard.string(forKey: registerKey)
        return regID
    }()
    var appKey: String = ""
    var appSecret: String = ""
    var deviceToken: String = ""
    var applePushToken: String?
}

fileprivate enum CHMessageType: String {
    case userRegister = "user_register"
    case userDelete = "user_delete"
    case userLogin = "user_login"
    case updateAPNsToken = "update_apple_push_token"
}

fileprivate let registerKey = "chcts_push_service_reg_id"

private let socket = CHWebSocket()
public class CHWebSocket: NSObject {
    static public var shared: CHWebSocket {
        return socket
    }
    public var didOpenCompletionHandler: ((_ webSocket: SRWebSocket) -> Void)?
    public var didCloseCompletionHandler: ((_ webSocket: SRWebSocket, _ code: Int, _ reason: String, _ wasClean: Bool) -> Void)?
    public var didFailCompletionHandler: ((_ webSocket: SRWebSocket, _ error: Error) -> Void)?
    public var didReceiveMessageCompletionHandler: ((_ webSocket: SRWebSocket, _ message: Any) -> Void)?
    public var didReceivePongCompletionHandler: ((_ webSocket: SRWebSocket, _ pongPayload: Data) -> Void)?
    public var didRegisterCallBack: ((_ registerID: String) -> Void)?
    public var didLoginCallBack: ((_ registerID: String) -> Void)?
    fileprivate var websocket: SRWebSocket?
    fileprivate lazy var appInfo: AppInfo = AppInfo.standard
    
    public func setup(appKey: String, appSecret: String, deviceToken: String, applePushToken: String? = nil) {
        appInfo.appKey = appKey
        appInfo.appSecret = appSecret
        appInfo.deviceToken = deviceToken
        appInfo.applePushToken = applePushToken
    }
    
    public func connect() {
        print("******** connect ********")
        var request = URLRequest(url: URL(string: "wss://push.chcts.cc/ws")!)
        let header = ["Content-Type": "application/json",
                      "Authorization": "Basic " + (appInfo.appKey + ":" + appInfo.appSecret).ch_ToBase64()!]
        header.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        websocket?.close()
        websocket?.delegate = nil
        websocket = nil
        
        websocket = SRWebSocket(urlRequest: request)
        websocket?.delegate = self
        websocket?.open()
    }
    
    public func close() {
        print("******** close ********")
        websocket?.close()
    }
    
    public func send(_ data: Any!) {
        print("******** send ********")
        let socketqueue = DispatchQueue(label: "socketqueue")
        socketqueue.async {
            if let state = self.websocket?.readyState, case .OPEN = state {
                self.websocket?.send(data)
            }
        }
    }
    
    public func registerDevice() {
        print("******** register device ********")
        let param: [String: String] = ["device_token": appInfo.deviceToken,
                                       "type": "register",
                                       "platform": "ios"]
        send(param.toJSONString())
        print("***** register param [\(param.toJSONString())]******")
    }
    
    public func removeDevice() {
        print("******** remove device ********")
        guard let registrationID = appInfo.registerID else { return }
        let  param = ["registration_id": registrationID,
                      "type": "delete"]
        send(param.toJSONString())
        print("***** remove param [\(param.toJSONString())]******")
    }
    
    public func loginDevice(registrationID: String) {
        print("******** login device ********")
        var param = ["registration_id": registrationID,
                     "type": "login"]
        send(param.toJSONString())
        print("***** login param [\(param.toJSONString())]******")
    }
    
    public func updateAPNsToken(_ apnsToken: String) {
        print("******** update APNs token ********")
        guard let registrationID = appInfo.registerID else { return }
        let param = ["registration_id": registrationID,
                     "apple_push_token": apnsToken,
                     "type": CHMessageType.updateAPNsToken.rawValue]
        send(param.toJSONString())
        print("***** update APNs token param [\(param.toJSONString())]******")
    }
    
}

extension CHWebSocket: SRWebSocketDelegate {
    public func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("******** did open ********")
        if let regID = appInfo.registerID, !regID.isEmpty {
            loginDevice(registrationID: regID)
        } else {
            registerDevice()
        }
        if let block = didOpenCompletionHandler, let socket = websocket {
            block(socket)
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("******** did close ********")
        connect()
        if let block = didCloseCompletionHandler {
            block(webSocket, code, reason, wasClean)
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        connect()
        print("******** did failed ********")
        if let block = didFailCompletionHandler {
            block(webSocket, error)
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        guard let jsonStr = message as? String else { return }
        print("******** did receive message [ \(jsonStr) ] ********")
        guard let jsonData = jsonStr.data(using: .utf8) else { return }
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else { return  }
        guard let jsonDict = dict else { return }
        var callBackMessage: Any?
        if let dataDict = jsonDict["data"] as? [String: Any] {
            if let typeStr = dataDict["type"] as? String, let messageType = CHMessageType(rawValue: typeStr), let dataJson = dataDict["data"] as? [String: Any], let registerID = dataJson["registration_id"] as? String {
                switch messageType {
                case .userRegister:
                    appInfo.registerID = registerID
                    UserDefaults.standard.set(registerID, forKey: registerKey)
                    loginDevice(registrationID: registerID)
                    didRegisterCallBack?(registerID)
                    return
                case.userDelete:
                    appInfo.registerID = nil
                    return
                case .userLogin:
                    appInfo.registerID = registerID
                    UserDefaults.standard.set(registerID, forKey: registerKey)
                    didLoginCallBack?(registerID)
                    return
                case .updateAPNsToken:
                    return
                }
            }
            if let msg = dataDict["msg"] as? String, !msg.isEmpty {
                callBackMessage = msg
            } else if let data = dataDict["data"] {
                callBackMessage = data
            } else { }
        }
        
        if let block = didReceiveMessageCompletionHandler, let msgg = callBackMessage {
            block(webSocket, msgg)
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        print("******** did receive pong ********")
        if let block = didReceivePongCompletionHandler {
            block(webSocket, pongPayload)
        }
    }
}

