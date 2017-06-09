//
//  CommonWebViewController.swift
//  FPTrade
//
//  Created by Apple on 15/10/12.
//  Copyright © 2015年 Windward. All rights reserved.
//

import UIKit
import WebKit
import ObjectMapper

class CommonWebViewController: BaseViewController {
    fileprivate lazy var webView: WKWebView = {
        let wb = WKWebView()
        return wb
    }()
    
    var payPasswd: String = ""
    var requestURL: String = ""
    var naviTitle: String = ""
    var tokenEnable: Bool = false
    var htmlContent: String?
    var extra: ExtraModel?
    var tempURL = ""
    var isFixedTitle: Bool = false
    var mutableURLRequest: URLRequest?
    var notice = ""
    var buttonTxt = ""
    var headTitle = ""
    var time = ""
    var productDetailModel: ProductDetailModel?
    
    fileprivate lazy var progressView: UIProgressView = {
        let pro = UIProgressView()
        pro.tintColor = UIColor.commonBlueColor()
        pro.trackTintColor = UIColor.white
        return pro
    }()
    
    fileprivate var additionalInfo: (notificationType: MyNotificationType, itemId: Int, itemType: DetailContentType, buttonTxt: String)?
    
    var willShowHelpPage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        view.addSubview(webView)
        view.insertSubview(progressView, aboveSubview: webView)
        webView.navigationDelegate = self
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
        }
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(webView.snp.top).offset(1)
            make.right.equalTo(0)
            make.height.equalTo(2)
            make.left.equalTo(0)
        }
        backBtnSet()
        var urlComponents = URLComponents()
        if let htmlContent = htmlContent {
            _ = webView.loadHTMLString(htmlContent, baseURL: nil)
        } else {
            if requestURL.hasPrefix("http://") {
                tempURL = requestURL
                guard let url = URL(string: tempURL) else {return}
                mutableURLRequest = URLRequest(url: url )
            } else if requestURL.hasPrefix("https://") {
                tempURL = requestURL
                guard let url = URL(string: tempURL) else {return}
                mutableURLRequest = URLRequest(url: url )
            } else {
                urlComponents.scheme = "mshmerchant"
                urlComponents.host = extra?.action.rawValue
                guard let model = extra else { return }
                let item = URLQueryItem(name: "type", value: (model.extra?.contentType).map { $0.rawValue })
                let item2 = URLQueryItem(name: "id", value: model.extra?.contentID)
                urlComponents.queryItems = [item, item2]
                guard let url = urlComponents.url else {return}
                mutableURLRequest = URLRequest(url: url)
            }
             guard let request = mutableURLRequest else { return  }
            _ =  webView.load(request)
            
        }
        if tokenEnable {
            mutableURLRequest?.httpMethod = "POST"
            if let _ = AFMRequest.OAuthToken {
                mutableURLRequest?.setValue(AFMRequest.OAuthToken ?? "", forHTTPHeaderField: "APP_TOKEN")
            }
            
            if let info = Bundle.main.infoDictionary {
                let version = (info["CFBundleShortVersionString"] as? String) ?? "Unknown"
                mutableURLRequest?.setValue(version, forHTTPHeaderField: "APP_VERSION")
            }
            
            mutableURLRequest?.setValue("1", forHTTPHeaderField: "DEVICE_MODEL")
            mutableURLRequest?.setValue(UIDevice.current.identifierForVendor?.uuidString, forHTTPHeaderField: "DEVICE_UUID")
            let strSysVersion = UIDevice.current.systemVersion
            mutableURLRequest?.setValue(strSysVersion, forHTTPHeaderField: "DEVICE_VERSION")
            
            guard let request = mutableURLRequest else { return  }
            _ =  webView.load(request)
        }
        if willShowHelpPage {
            let rightBarItem = UIBarButtonItem(title: "帮助", style: .plain, target: self, action: #selector(self.showHelpPage))
            navigationItem.rightBarButtonItem = rightBarItem
        }
        
        if let _ = additionalInfo {
            let rightBarItem = UIBarButtonItem(title: "详情", style: .plain, target: self, action: #selector(self.showAdditionalDetail))
            navigationItem.rightBarButtonItem = rightBarItem
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CommonWebViewController {
    func requestCheckPayCode() {
        
        let parameters: [String: AnyObject] = [
            "pay_password": payPasswd as AnyObject
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantCheckPaypassword(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                AOLinkedStoryboardSegue.performWithIdentifier("VerificationStatus@MerchantCenter", source: self, sender: nil)
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
        
    }
    
    func showHelpPage() {
    }
    
    func showAdditionalDetail() {
        guard let info = additionalInfo else { return  }
        switch info.notificationType {
        case .product:
            if info.itemType == .goods {
                if info.buttonTxt == "编辑商品" {
                    showEditGoodsDetails(productID: String(info.itemId))
                } else {
                    showNormalGoodDetails(productID: String(info.itemId))
                }
            } else if info.itemType == .serviceGoods {
                showServiceGoodDetails(productID: String(info.itemId))
            } else if info.itemType == .addStockNum {
                addStockNum(productID: String(info.itemId))
            } else if info.itemType == .deferService {
                deferService(productID: String(info.itemId))
            }            
        case .campaign:
            if info.itemType == .saleCampaign {
                showSaleCampaign(productID: info.itemId)
            } else {
               showPlaceCampaign(productID: info.itemId)
            }
        case .ad:
            showAdDetails(productID: String(info.itemId))
        case .merchantCenter:
            if info.itemType == .coupon {
                showVerificationPage()
            } else if info.itemType == .order {
                showOrderDetails(productID: info.itemId)
            } else if info.itemType == .goodsRefund {
               showNormalGoodRefundDetails(productID: info.itemId)
            } else if additionalInfo?.itemType == .staff {
                showStaffDetails(productID: String(info.itemId))
            }
        case .system:
            showCenterDetail()
        case .undefined:
            break
        }
    }
    
    func setleftBarButton(vcc: UIViewController) {        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "CommonBaseBackButton"), for: .normal)
        backButton.sizeToFit()
        backButton.x = 20
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        backButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        vcc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func back() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func showVerificationPage() {
        guard let status = UserManager.sharedInstance.userInfo?.status else {
            return
        }
        switch status {
        case .unverified:
            if let merchantCenter = UIStoryboard(name: "MerchantCenter", bundle: nil).instantiateViewController(withIdentifier: "MerchantCenterVerification") as? MerchantCenterVerificationViewController {
                let nav: UINavigationController = UINavigationController.init(rootViewController: merchantCenter)
                self.navigationController?.present(nav, animated: true, completion: nil)
            }
        default:
            showPayCodeView()
        }
    }
    
    func showPayCodeView() {
        let payCodeVC = PayCodeVerificationViewController()
        payCodeVC.modalPresentationStyle = .custom
        payCodeVC.confirmBlock = { payPassword in
            self.payPasswd = payPassword
            self.requestCheckPayCode()
            
        }
        present(payCodeVC, animated: true, completion: nil)
    }
}

extension CommonWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: true)
        if let _ = htmlContent {
            if !isFixedTitle {
                webView.evaluateJavaScript("document.title", completionHandler: { (value, error) in
                    if let title = value as? String {
                        self.navigationItem.title = title
                    }
                })
            }
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let _ = htmlContent {
            if !isFixedTitle {
                webView.evaluateJavaScript("document.title", completionHandler: { (value, error) in
                    if let title = value as? String {
                        self.navigationItem.title = title
                    }
                })
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.url?.host ?? "")
        if navigationAction.request.url?.scheme == "http" {
            decisionHandler(.allow)
        }
        if let url = navigationAction.request.url, url.scheme == "mshmerchant", let _ = url.host?.removingPercentEncoding, let action = self.extra?.action, let extra = self.extra?.extra {
            if action == .showDetail {
                
                let contentType = extra.contentType
                let contentId = extra.contentID
                switch contentType {
                case .goods:
                    if self.buttonTxt == "编辑商品"{
                            additionalInfo = (.product, Int(contentId) ?? 0, .goods, "编辑商品")
                    } else {
                            additionalInfo = (.product, Int(contentId) ?? 0, .goods, "")
                    }
                case .advertise:
                    additionalInfo = (.ad, Int(contentId) ?? 0, .advertise, "")
                case .placeCampaign:
                    additionalInfo = (.campaign, Int(contentId) ?? 0, .placeCampaign, "")
                case .saleCampaign:
                    additionalInfo = (.campaign, Int(contentId) ?? 0, .saleCampaign, "")
                case .order:
                    additionalInfo = (.merchantCenter, Int(contentId) ?? 0, .order, "")
                case .serviceGoods:
                    additionalInfo = (.product, Int(contentId) ?? 0, .serviceGoods, "")
                case .coupon:
                    additionalInfo = (.merchantCenter, Int(contentId) ?? 0, .coupon, "")
                case .goodsRefund:
                    additionalInfo = (.merchantCenter, Int(contentId) ?? 0, .goodsRefund, "")
                case .staff:
                    additionalInfo = (.merchantCenter, Int(contentId) ?? 0, .staff, "")
                case .addStockNum:
                    additionalInfo = (.product, Int(contentId) ?? 0, .addStockNum, "")
                case .deferService:
                    additionalInfo = (.product, Int(contentId) ?? 0, .deferService, "")
                case .system:
                    additionalInfo = (.system, Int(contentId) ?? 0, .system, "")
                default:
                    break
                }
                if additionalInfo != nil {
                    showAdditionalDetail()
                    decisionHandler(.allow)
                }
                decisionHandler(.cancel)
            } else if action == .gotoPage {
                decisionHandler(.allow)

            } else {
                decisionHandler(.allow)
            }
        } else {
            if let url = navigationAction.request.url,
                url.scheme == "mshuser",
                let data = url.host?.data(using: .utf8),
                let dic = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonDict = dic as? [String : Any],               
                let info = Mapper<ExtraModel>().map(JSON: jsonDict) {
                if info.action == .openUrl || info.action == .playVideo {
                    guard let requestUrl = info.extra?.url else {return}
                    let vc = CommonWebViewController()
                    vc.requestURL = requestUrl
                    self.navigationController?.pushViewController(vc, animated: true)
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                    return
                }
                
            }
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.setProgress(0.0, animated: true)
//        let  alter = UIAlertController(title: "页面加载失败", message: "可以返回重试下哦", preferredStyle: .alert)
//        alter.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
//        present(alter, animated: true, completion: nil)
       
    }
}

extension CommonWebViewController {
    fileprivate func backBtnSet() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "CommonBaseBackButton"), style: .plain, target: self, action: #selector(self.backBtnClick))
    }
    
   @objc func backBtnClick() {
        
        if webView.canGoBack {
            webView.goBack()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        if keyPath == "title" {
            self.title = webView.title != "" ? webView.title : navigationItem.title
        }
    }
}

extension CommonWebViewController {
    // 显示普通商品详情
    func showNormalGoodDetails(productID: String) {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("ProductDetail@Product") as? ProductNDetailViewController else {  return }
        setleftBarButton(vcc: vc)
        vc.productID = productID
        vc.productType = .normal
        navigationController?.pushViewController(vc, animated: false)
    }
    // 显示服务商品详情
    func showServiceGoodDetails(productID: String) {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("ProductDetail@Product") as? ProductNDetailViewController else {  return }
        setleftBarButton(vcc: vc)
        vc.productID = productID
        vc.productType = .service
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // 补充库存
    func addStockNum(productID: String) {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        let param: [String: Any] = ["goods_id": productID]
        RequestManager.request(AFMRequest.goodsDetail(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                let productModel = ProductDetailModel(JSON: result) ?? ProductDetailModel()
                guard  let vc = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
                self.setleftBarButton(vcc: vc)
                vc.modifyType = .edit
                vc.productID = productID
                vc.productType = productModel.type == "1" ? .normal : .service
                vc.isNoticeSource = true
                vc.isAddStockNum = true
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    // 延期服务
    func deferService(productID: String) {
        guard  let vc = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        setleftBarButton(vcc: vc)
        vc.modifyType = .edit
        vc.productID = productID
        vc.productType = .service
        vc.isAddStockNum = true
        vc.isNoticeSource = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // 促销活动详情
    func showSaleCampaign(productID: Int) {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("CampaignSaleDetail@Campaign") as? CampaignSaleDetailViewController else {  return }
        setleftBarButton(vcc: vc)
        vc.campId = productID
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // 现场活动详情
    func showPlaceCampaign(productID: Int) {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("CampaignPlaceDetail@Campaign") as? CampaignPlaceDetailViewController  else {  return }
        setleftBarButton(vcc: vc)
        vc.campId = productID
        self.navigationController?.pushViewController(vc, animated: false)
    }
    // 广告详情
    func showAdDetails(productID: String) {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("AdDetail@Ad") as? AdDetailViewController else {  return }
        setleftBarButton(vcc: vc)
        vc.adID = productID
        self.navigationController?.pushViewController(vc, animated: false)
    }
    // 订单详情
    func showOrderDetails(productID: Int) {
        guard  let vc = AOLinkedStoryboardSegue.sceneNamed("OrderDetail@MerchantCenter") as? OrderDetailViewController else {  return }
        setleftBarButton(vcc: vc)
        vc.orderId = productID
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //普通商品退款订单详情
    func showNormalGoodRefundDetails(productID: Int) {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("RefundOrderDetail@MerchantCenter") as? RefundOrderDetailViewController else {  return }
        setleftBarButton(vcc: vc)
        vc.refundId = productID
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //店员详情
    func showStaffDetails(productID: String) {
        let vc = EditShopAssistantViewController()
        vc.staffID = productID
        setleftBarButton(vcc: vc)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // 编辑商品
    func showEditGoodsDetails(productID: String) {
        guard  let vc = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        self.setleftBarButton(vcc: vc)
        vc.modifyType = .edit
        vc.productID = productID
        vc.isNoticeSource = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // 系统消息
    func showCenterDetail() {
        let vc = NoticeDetailViewController()
        self.setleftBarButton(vcc: vc)
        vc.notice = notice
        vc.time = time
        vc.headTitle = headTitle
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
