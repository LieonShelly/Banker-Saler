//
//  AppDelegate.swift
//  AdForMerchant
//
//  Created by Kuma on 1/27/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage
import MonkeyKing
import CHPushSocket
import Fabric
import Crashlytics
import Whisper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var lastRequestTime: Date?
    var timeoutTimer: Timer?
    fileprivate lazy var timer: Timer = {
        let timer = Timer()
        return timer
    }()
    fileprivate lazy var noticeTimer: Timer = {
        let noticeTimer = Timer()
        return noticeTimer
    }()
    var time = 1800
    fileprivate var additionalInfo: (notificationType: MyNotificationType, itemId: Int, itemType: Int)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.initialRequest), name: NSNotification.Name.UIWindowDidBecomeKey, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.relogin(_:)), name: NSNotification.Name(rawValue: "NEED_RELOGIN_NOTI"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.requestUserInfo), name: NSNotification.Name(rawValue: refreshMerchantInfoNotification), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.initialRequest), name: Notification.Name(rawValue: startAppNotification), object: nil)
        
        if let options = launchOptions, let notification = options[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] {
            NotificationAndMessageController.handle(notification: notification)
        }
        SDImageCache.shared().config.shouldDecompressImages = false
        SDWebImageDownloader.shared().shouldDecompressImages = false
        CHPushService.registerRemoteNotification()
          setupPush()
        return true
    }
    
    func setupUI() {
        window?.backgroundColor = UIColor.commonBlueColor()
        UINavigationBar.appearance().backIndicatorImage = R.image.commonBaseBackButton()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = R.image.commonBaseBackButton()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().tintAdjustmentMode = .normal
        UINavigationBar.appearance().barTintColor = UIColor.commonBlueColor()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().setBackgroundImage(R.image.commonBlueBg(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if sourceApplication == nil {
            return true
        }
        
        if MonkeyKing.handleOpenURL(url) {
            return true
        }
        return false
        
    }

    // MARK: - Action
    
    func showAdditionalDetail() {
        
       guard let tabVC = window?.rootViewController as? UITabBarController else { return }
        guard let nvc = tabVC.selectedViewController as? UINavigationController else { return }
         guard let info = additionalInfo else { return  }
        switch info.notificationType {
        case .product:
             guard let vc = AOLinkedStoryboardSegue.sceneNamed("ProductDetail@Product") as? ProductNDetailViewController else { return  }
            vc.productID = String(info.itemId)
            vc.productType = ProductType(rawValue: info.itemType) ?? .normal
            nvc.pushViewController(vc, animated: true)
        case .campaign:
            if info.itemType == 1 {
               guard let vc = AOLinkedStoryboardSegue.sceneNamed("CampaignSaleDetail@Campaign") as? CampaignSaleDetailViewController else { return }
                vc.campId = info.itemId
                nvc.pushViewController(vc, animated: true)
            } else {
              guard  let vc = AOLinkedStoryboardSegue.sceneNamed("CampaignPlaceDetail@Campaign") as? CampaignPlaceDetailViewController else { return }
                vc.campId = info.itemId
                nvc.pushViewController(vc, animated: true)
            }
        case .ad:
            let vc = AOLinkedStoryboardSegue.sceneNamed("AdDetail@Ad")
            nvc.pushViewController(vc, animated: true)
        case .merchantCenter:
            if info.itemType == 1 {
                showVerificationPage()
            } else if info.itemType == 2 {
              guard  let vc = AOLinkedStoryboardSegue.sceneNamed("OrderDetail@MerchantCenter") as? OrderDetailViewController else { return }
                vc.orderId = info.itemId
                nvc.pushViewController(vc, animated: true)
            } else if info.itemType == 3 {
               guard let vc = AOLinkedStoryboardSegue.sceneNamed("OrderDetail@MerchantCenter") as? OrderDetailViewController else { return }
                vc.orderId = info.itemId
                nvc.pushViewController(vc, animated: true)
            }
        case .system:
            let vc = NoticeDetailViewController()
            nvc.pushViewController(vc, animated: true)
        case .undefined:
            break
        }
    }
    
    func showVerificationPage() {
        guard let status = UserManager.sharedInstance.userInfo?.status else {
            return
        }
        
       guard let tabVC = window?.rootViewController as? UITabBarController else { return }
       guard let nvc = tabVC.selectedViewController as? UINavigationController else { return }
        switch status {
        case .unverified:
            if let merchantCenter = UIStoryboard(name: "MerchantCenter", bundle: nil).instantiateViewController(withIdentifier: "MerchantCenterVerification") as? MerchantCenterVerificationViewController {
                let nav: UINavigationController = UINavigationController.init(rootViewController: merchantCenter)
                nvc.present(nav, animated: true, completion: {
                })
            }
        default:
            showPayCodeView()
        }
    }
    
    func showPayCodeView() {
      guard  let tabVC = window?.rootViewController as? UITabBarController else { return }
       guard let nvc = tabVC.selectedViewController as? UINavigationController else { return }
        
        let payCodeVC = PayCodeVerificationViewController()
        payCodeVC.modalPresentationStyle = .custom
        payCodeVC.confirmBlock = {payPassword in
            self.requestCheckPayCode(payPassword)

        }
        nvc.present(payCodeVC, animated: true, completion: nil)
    }
    
    func requestCheckPayCode(_ payPassword: String) {
       guard let tabVC = window?.rootViewController as? UITabBarController else { return }
       guard let nvc = tabVC.selectedViewController as? UINavigationController else { return }
        
        let parameters: [String: AnyObject] = [
            "pay_password": payPassword as AnyObject]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantCheckPaypassword(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                
                let vc = AOLinkedStoryboardSegue.sceneNamed("VerificationStatus@MerchantCenter")
                nvc.pushViewController(vc, animated: true)
            } else {
                
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
        
    }

    // MARK: - Methods
    
    func initialRequest() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIWindowDidBecomeKey, object: nil)
        juedgeCurrentVersionWithOldVersion()
    }
    
    func juedgeCurrentVersionWithOldVersion() {
        let userDef = UserDefaults.standard
        guard let oldVersion =  userDef.object(forKey: oldVersionKey) as? String == nil ? "0.0" : userDef.object(forKey: oldVersionKey) as? String else {return}
        guard let data = Bundle.main.infoDictionary else {return}
        guard let currentVersion = data[cFBundleShortVersionString] as? String else {return}
        if oldVersion == currentVersion {
            needLogin()
            requestPublicKey()
        } else {
            let flowLout = UICollectionViewFlowLayout()
            flowLout.itemSize = UIScreen.main.bounds.size
            flowLout.minimumLineSpacing = 0
            flowLout.minimumInteritemSpacing = 0
            flowLout.scrollDirection = .horizontal
            let guideVC = GuideCollectionViewController(collectionViewLayout: flowLout)
            self.window?.rootViewController = guideVC
            userDef.set(currentVersion, forKey: oldVersionKey)
        }
    }
    
    func needLogin() {
        timeOver()
        NotificationCenter.default.post(name: Notification.Name(rawValue: userSignOutNotification), object: nil)
        
        UserManager.sharedInstance.signedIn = false
        UserManager.sharedInstance.userInfo = nil
        
        let userDef = UserDefaults.standard
        userDef.setValue(nil, forKey: kToken)
        userDef.synchronize()
        AFMRequest.OAuthToken = nil
        
        if let vc = window?.rootViewController?.presentedViewController {
            if vc.isKind(of: SignInHomeViewController.self) {
                return
            }
        }
        
        if let tabVC = window?.rootViewController as? UITabBarController {
                if let _ = tabVC.selectedViewController?.presentedViewController {
                tabVC.selectedViewController?.dismiss(animated: false, completion: nil)
            }
            guard  let nvc = tabVC.selectedViewController as? UINavigationController else { return  }
            if nvc.isKind(of: UINavigationController.self) {
                tabVC.selectedIndex = 0
                nvc.popToRootViewController(animated: false)
            } else {
                tabVC.selectedIndex = 0
            }
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
        guard let vc = UIStoryboard(name: "AccountSession", bundle: nil).instantiateInitialViewController() else { return }
        self.window?.rootViewController?.present(vc, animated: false, completion: { () -> Void in
            
        })
    }
    
    func relogin(_ notification: Notification) {
        timer.invalidate()
        requestPublicKey()
        if !UserManager.sharedInstance.signedIn {
            
            if let msg = notification.userInfo?["message"] as? String {
               guard let tabVC = window?.rootViewController as? UITabBarController else { return }
                if let presentedVC = tabVC.selectedViewController?.presentedViewController {
                    Utility.showAlert(presentedVC, message: msg)
                } else {
                    guard let selectedVC = tabVC.selectedViewController else {  return }
                    Utility.showAlert(selectedVC, message: msg)
                }
                
            }
            return
        }
        
        UserManager.sharedInstance.signedIn = false
        UserManager.sharedInstance.userInfo = nil
        
        let userDef = UserDefaults.standard
        userDef.set(nil, forKey: kToken)
        AFMRequest.OAuthToken = nil
        let msg = notification.userInfo?["message"] as? String
        
        let alertVC = UIAlertController(title: "提示", message: msg ?? "账号在别处登录", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "重新登录", style: UIAlertActionStyle.default) { (action) -> Void in
            self.needLogin()
        }
        alertVC.addAction(alertAction)
        let currentVC = returnCurrentVC()
        if currentVC.isKind(of: VerifypasswordViewController.self) {
            (currentVC as? VerifypasswordViewController)?.cancelAction(UIButton())
        }
        perform(#selector(self.showAlertActoin(alert:)), with: alertVC, afterDelay: 1)
    }
    
    @objc fileprivate func showAlertActoin(alert: UIAlertController) {
        returnCurrentVC().present(alert, animated: true, completion: nil)
    }
    
    // MARK: - http request
    
    func requestUserInfo() {
        requestUserInfoWithCompleteBlock()
    }

    func requestPublicKey() {
        RequestManager.request(AFMRequest.sshPublicKey(["auth": ""])) { (request, response, object, error, _) in
            if (object) != nil {
                guard  let result = object as? [String: AnyObject] else {  return }
                if let key = result["public_key"] as? String {
                    AFMRequest.PublicKey = Utility.getTextByTrim(key)
                }
            }
        }
    }
    
    func requestUserInfoWithCompleteBlock(_ completeBlock: ((Void) -> Void)? = nil, failedBlock: (() -> Void)? = nil) {
        if let _ = (UserDefaults.standard.object(forKey: kToken) as? String) {
            
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
            
            RequestManager.request(AFMRequest.merchantInfo(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (request, response, object, error, _) -> Void in
                if (object) != nil {
                    guard let result = object as? [String: Any]  else {  return }
                    UserManager.sharedInstance.signedIn = true
                    let userInfo = Mapper<MerchantInfo>().map(JSON: result)
                    UserManager.sharedInstance.userInfo = userInfo
                    completeBlock?()
                } else {
                    failedBlock?()
                }
            })
        }
    }
    
    func test() {
        if let _ = DES3Util.aes128Decrypt("SoweULfnYcJJCWc57NQH3g==", key: "1234567890123456", andIv: "1234567890123456") {
        }
    }
}

extension AppDelegate {
    
    func starNoticeTiemr() {
        self.noticeTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(self.requestUnreadNoticeNum), userInfo: nil, repeats: true)
        RunLoop.current.add(self.noticeTimer, forMode: RunLoopMode.commonModes)
    }
    
    func noticeTimerOver() {
        noticeTimer.fireDate = Date.distantFuture
        noticeTimer.invalidate()
    }
    
    func starTimer() {
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.timeUpdate), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
    }
    func timeUpdate() {
        time -= 1
        if time == 0 {
            timer.fireDate = Date.distantFuture
            timeOfLogOut()
        }
    }
    
    func timeOver() {
        timer.fireDate = Date.distantFuture
        timer.invalidate()
        noticeTimerOver()
    }
    
    func timeOfLogOut() {
        self.timer.invalidate()
        UserManager.sharedInstance.signedIn = false
        UserManager.sharedInstance.userInfo = nil
        
        let userDef = UserDefaults.standard
        userDef.setValue(nil, forKey: kToken)
        userDef.synchronize()
        AFMRequest.OAuthToken = nil
        
        let alertVC = UIAlertController(title: "提示", message: "长时间无响应，请重新登录", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "重新登录", style: UIAlertActionStyle.default) { (action) -> Void in
            self.needLogin()
        }
        alertVC.addAction(alertAction)
        self.returnCurrentVC().present(alertVC, animated: true, completion: nil)
    }
}

extension AppDelegate {
    func returnCurrentVC() -> UIViewController {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {return UIViewController()}
        if rootVC.isKind(of: UITabBarController.self) {
             guard let tabVC = rootVC as? UITabBarController else { return  UIViewController() }
            let vc = (tabVC).selectedViewController as? UINavigationController
            guard let showVC = vc?.visibleViewController else { return UIViewController()}
            return showVC
        } else {
            return (UIApplication.shared.keyWindow?.rootViewController) ?? UIViewController()
        }
    }
    
    func requestUnreadNoticeNum() {
        if UserManager.sharedInstance.signedIn == false {
            return
        }

        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.unreadNum(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            if object != nil {
               guard  let result = object as? [String: AnyObject] else {return}
                    let num = result["unread_num"] as? String
                  guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {return}
                guard let tabVC = rootVC as? UITabBarController else { return  }
                if rootVC.isKind(of: UITabBarController.self) {
                    if num != "0" {
                        tabVC.tabBar.showBadgeOnItemIndex(index: 3)
                    } else {
                        tabVC.tabBar.hideBadgeOnItemIndex(index: 3)
                    }
                }
            }
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("用户同意推送")
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        Common.AppConfig.applePushToken = deviceTokenString
        // update apns
        CHWebSocket.shared.updateAPNsToken(deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError:\(error)")
    }
    
    /// 从后台点击了通知进入程序
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if application.applicationState == .background, let json =  userInfo as? [String: Any] {
             NotificationAndMessageController.handle(notification: json)
        }
    }
    
}

extension AppDelegate {
    fileprivate func setupPush(applePushToken: String? = nil) {
        CHService.setupSocket(appKey: Common.AppConfig.appKey, appSecret: Common.AppConfig.appSecret, deviceToken: Common.AppConfig.deviceUUIDString ?? "", applePushToken: applePushToken)
        CHWebSocket.shared.connect()
        CHWebSocket.shared.didLoginCallBack = { registerID in
            Common.AppConfig.registrationID = registerID
            // update apns
            CHWebSocket.shared.updateAPNsToken(Common.AppConfig.applePushToken ?? "")
        }
        CHWebSocket.shared.didReceiveMessageCompletionHandler = { _, message in
            if  let msg = message as? [String: Any], let noti = msg["notification"] as? [String: Any] {
                if UIApplication.shared.applicationState == .active {
                     NotificationAndMessageController.display(notification: noti)
                }
            }
            guard let msg = message as? [String: Any], let json = msg["message"] as?  [String: Any] else { return }
            NotificationAndMessageController.handle(message: json)
        }
    }
    
    fileprivate func handleResponse(userInfo: [AnyHashable: Any]) {
        if let contentTypeStr = userInfo["type"] as? String, let contentType = Int(contentTypeStr) {
            guard let contentId = userInfo["notice_id"] as? String else { return }
            guard let tabVC = window?.rootViewController as? UITabBarController else { return }
            guard let nvc = tabVC.selectedViewController as? UINavigationController else { return }
            
            if let vc = window?.rootViewController?.presentedViewController {
                if vc.isKind(of: SignInHomeViewController.self) {
                    return
                }
            }
            
            if let _ = tabVC.selectedViewController?.presentedViewController {
                return
            }
            guard let aps = userInfo["aps"] as? [String : String] else { return }
            
            Utility.showConfirmAlert(nvc, title: "通知", cancelButtonTitle: "取消", confirmButtonTitle: "查看", message: aps["alert"]!, confirmCompletion: {
                self.showAdditionalDetail()
            })
            
            // JSON Data : "{\"action\":\"showDetail\",\"extra\":{\"content_type\":4,\"content_id\":\"274\"}}"
            /*
             2	商品
             3	店铺
             4	广告
             5	现场活动
             6	促销活动
             8	订单
             9	服务商品
             10 认证, 认证成功 content_id = 1,认证失败 content_id = 0
             */
            
            switch contentType {
            case 2:
                additionalInfo = (.product, Int(contentId) ?? 0, Int(0))
            case 4:
                additionalInfo = (.ad, Int(contentId) ?? 0, Int(0))
            case 5:
                additionalInfo = (.campaign, Int(contentId) ?? 0, Int(0))
            case 6:
                additionalInfo = (.campaign, Int(contentId) ?? 0, Int(1))
            case 8:
                additionalInfo = (.merchantCenter, Int(contentId) ?? 0, 2)
            case 9:
                additionalInfo = (.product, Int(contentId) ?? 0, Int(1))
            case 10:
                additionalInfo = (.merchantCenter, Int(contentId) ?? 0, 1)
            default:
                break
            }
            
            if additionalInfo != nil {
                showAdditionalDetail()
            }
        }
    }
    
}

extension AppDelegate {
    
    func showVerifyPasswordVC(currentVC: UIViewController, status: LicenseVerifyStatus) {
        guard let vc = UIStoryboard(name: "VerifyPayPass", bundle: nil).instantiateInitialViewController() as? VerifypasswordViewController else {return}
        vc.type = .verify
        vc.modalPresentationStyle = .custom
        vc.resultHandle = { (result, data) in
            switch result {
            case .passed:
                currentVC.dim(.out, coverNavigationBar: true)
                vc.dismiss(animated: true, completion: nil)
                guard let verificationVC = AOLinkedStoryboardSegue.sceneNamed("VerificationStatus@MerchantCenter") as? VerificationStatusViewController else {return}
                verificationVC.payPassword = vc.passTextField.text ?? ""
                currentVC.navigationController?.pushViewController(verificationVC, animated: true)
            case .failed:
                print("失败")
            case .canceled:
                currentVC.dim(.out, coverNavigationBar: true)
                vc.dismiss(animated: true, completion: nil)
            }
        }
        currentVC.dim(.in, coverNavigationBar: true)
        currentVC.present(vc, animated: true, completion: nil)
    }
    
    // 请认证
    func pleaseAttestationAction(showAlert: Bool, type: AttestationAlertTitle) -> Bool {
        let status = UserManager.sharedInstance.userInfo?.status ?? .unverified
        
        if status == .verified {return true}
        if showAlert {
            let vc = returnCurrentVC()
            Utility.showConfirmAlert(vc, title: "提示", cancelButtonTitle: "暂不认证", confirmButtonTitle: "马上认证", message: type.rawValue) { _ in
                
                let merchantCenter = UIStoryboard(name: "MerchantCenter", bundle: nil).instantiateViewController(withIdentifier: "MerchantCenterVerification") as? MerchantCenterVerificationViewController ?? MerchantCenterVerificationViewController()
                // 认证失败 认证中
                if status == .verifyFailed || status == .waitingForReview {
                    self.showVerifyPasswordVC(currentVC: vc, status: status)
                } else {
                    // 未认证
                    let nav: UINavigationController = UINavigationController.init(rootViewController: merchantCenter)
                    vc.present(nav, animated: true, completion: nil)
                }                
            }
        }
        return false
    }
}

extension UIWindow {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        kApp.time = 1800
        let superView = super.hitTest(point, with: event)
        return superView
    }
}
