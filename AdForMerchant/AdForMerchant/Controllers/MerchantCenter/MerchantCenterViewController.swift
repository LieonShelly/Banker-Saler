//
//  MerchantCenterViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 1/29/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MerchantCenterViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    @IBOutlet fileprivate weak var avatarImgView: UIImageView!
    @IBOutlet fileprivate weak var merchantNameLabel: UILabel!
    @IBOutlet fileprivate weak var merchantVerificationLabel: UILabel!
    
    var payPasswd: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImgView.layer.borderWidth = 2.0
        avatarImgView.layer.borderColor = UIColor.white.cgColor
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = self.tableView.backgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTopWhenSignOut), name: Notification.Name(rawValue: userSignOutNotification), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
        kApp.requestUserInfoWithCompleteBlock({ () in
            self.tableView.reloadData()
            self.refreshHeaderView()
        })
        refreshHeaderView()
        refreshVerificationAlert()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextFieldTextDidChange, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderList@MerchantCenter" {
            guard let status = sender as? Int else {return}
            guard let desVC = segue.destination as? OrderListViewController else {return}
            guard let orderStatus = OrderStatus(rawValue: status) else {return}
            desVC.orderStatus = orderStatus
        } else if segue.identifier == "ProductDescInput@Product" {
            guard let desVC = segue.destination as? DetailInputViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            
            switch (indexPath.section, indexPath.row) {
            case (3, _):
                desVC.navTitle = "输入商品名称"
            case (4, _):
                desVC.navTitle = "输入商品描述"
            default:
                break
            }
                
        }
    }

    // MARK: - Button Action
    
    @IBAction func modifyMerchantInfoAction(_ btn: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("MyShop@MerchantCenter", source: self, sender: nil)
    }
    
    func scrollTopWhenSignOut() {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: screenWidth, height: 1), animated: false)
    }
    
    // MARK: - Http request
    
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

    // MARK: - Methods
    
    func refreshHeaderView() {
        if let logo = UserManager.sharedInstance.userInfo?.storeInfo?.logo {
            avatarImgView.sd_setImage(with: URL(string: logo), placeholderImage: UIImage(named: "ic_defaultavatar"))
        }
        if let name = UserManager.sharedInstance.userInfo?.storeInfo?.name {
            merchantNameLabel.text = name
        } else {
            merchantNameLabel.text = ""
        }
        
        if let status = UserManager.sharedInstance.userInfo?.status {
            switch status {
            case .unverified:
                merchantVerificationLabel.text = "  未认证  "
            case .waitingForReview:
                merchantVerificationLabel.text = "  未认证  "
            case .verified:
                merchantVerificationLabel.text = "  已认证  "
            case .verifyFailed:
                merchantVerificationLabel.text = "  未认证  "
            }
        } else {
            merchantVerificationLabel.text = "  未认证  "
        }
    }
    
    func refreshVerificationAlert() {
        guard let status = UserManager.sharedInstance.userInfo?.status else {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            return
        }
        if status == .verified {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        } else {
            
            let alertViewBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
            alertViewBg.backgroundColor = UIColor.colorWithHex("#FFFBCE")
            alertViewBg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showVerificationPage)))
            let alertImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            alertImgView.contentMode = .center
            alertImgView.image = UIImage(named: "MerchantCenterIconAlert")
            alertViewBg.addSubview(alertImgView)
            let alertLbl = UILabel(frame: CGRect(x: 40, y: 0, width: screenWidth - 40 - 10, height: 44))
            alertLbl.font = UIFont.systemFont(ofSize: 11.0)
            alertLbl.textColor = UIColor.commonTxtColor()
            alertLbl.numberOfLines = 0
            if status == .unverified {
                alertLbl.text = "您目前尚未认证。暂时无法发布商品、活动和广告，请先完成认证>>"
            } else if status == .waitingForReview {
                alertLbl.text = "您的认证信息已提交，请等待客服审核，查看详情>>"
            } else if status == .verifyFailed {
                alertLbl.text = "认证失败,请重新提交认证>>"
            }
            alertViewBg.addSubview(alertLbl)
            tableView.tableHeaderView = alertViewBg
        }
        
    }
    
    func showQRScanPage() {
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ScanQR@Main") as? QRViewController else {return}
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
        
    }
    
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func signOut() {
        UserManager.sharedInstance.signedIn = false
        UserManager.sharedInstance.userInfo = nil
        tabBarController?.selectedIndex = 0
        kApp.needLogin()
    }
    
    func showVerificationPage() {
        let status = UserManager.sharedInstance.userInfo?.status ?? .unverified
        // 未认证 不需要输入支付密码
        if status == .unverified {
            if let merchantCenter = UIStoryboard(name: "MerchantCenter", bundle: nil).instantiateViewController(withIdentifier: "MerchantCenterVerification") as? MerchantCenterVerificationViewController {
                let nav: UINavigationController = UINavigationController.init(rootViewController: merchantCenter)
                self.present(nav, animated: true, completion: {
                })
            }
        } else {
        showPayCodeView()
        }
    }
    
    // Mark: - Pay Code View
    
    func showPayCodeView() {
        guard let vc = UIStoryboard(name: "VerifyPayPass", bundle: nil).instantiateInitialViewController() as? VerifypasswordViewController else {return}
        vc.modalPresentationStyle = .custom

        vc.type = .verify
        vc.resultHandle = { (result, data) in
            switch result {
            case .passed:
                self.dim(.out, coverNavigationBar: true)
                vc.dismiss(animated: true, completion: nil)
                guard let verificationVC = AOLinkedStoryboardSegue.sceneNamed("VerificationStatus@MerchantCenter") as? VerificationStatusViewController else {return}
                verificationVC.payPassword = vc.passTextField.text ?? ""
                self.navigationController?.pushViewController(verificationVC, animated: true)
            case .failed:
                print("失败")
            case .canceled:
                self.dim(.out, coverNavigationBar: true)
                vc.dismiss(animated: true, completion: nil)
            }
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension MerchantCenterViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 5
        case 3:
            return 2
        case 4:
            return 1
        case 5:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCenterPointId", for: indexPath)
            return cell
        case (1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCenterOrderId", for: indexPath)
            return cell
            
        case (5, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCenterLogoutCell", for: indexPath)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .default, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
}

extension MerchantCenterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        if indexPath.section >= 2 && indexPath.section <= 4 {
            cell.textLabel?.textColor = UIColor.colorWithHex("#393939")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let _cell = cell as? MerchantCenterPointTableViewCell else {return}
            if let _ = _cell.walletClickBlock {
            } else {
                _cell.walletClickBlock = {
                    AOLinkedStoryboardSegue.performWithIdentifier("MyWallet@MerchantCenter", source: self, sender: nil)
                }
                _cell.pointsClickBlock = {
                    AOLinkedStoryboardSegue.performWithIdentifier("MyPoints@MerchantCenter", source: self, sender: nil)
                }
            }
            guard let money = UserManager.sharedInstance.userInfo?.money else {return}
            guard let walletMoney = Float(money) else {return}
            _cell.walletText = Utility.currencyNumberFormatter(NSNumber(value: walletMoney))

            let point = UserManager.sharedInstance.userInfo?.point ?? "0"
            guard let pointFloat = Float(point) else {return}
            _cell.pointsText = Utility.micrometerNumberFormatter(NSNumber(value: pointFloat))
        case (1, 0):
            
            guard let _cell = cell as? MerchantCenterOrderTableViewCell else {return}
            if let _ = _cell.partClickBlock1 {
            } else {
                _cell.partClickBlock1 = {
                    AOLinkedStoryboardSegue.performWithIdentifier("OrderList@MerchantCenter", source: self, sender: OrderStatus.waitForPay.rawValue)
                }
                _cell.partClickBlock2 = {
                    AOLinkedStoryboardSegue.performWithIdentifier("OrderList@MerchantCenter", source: self, sender: OrderStatus.waitForDelivery.rawValue)
                }
                _cell.partClickBlock3 = {
                    AOLinkedStoryboardSegue.performWithIdentifier("RefundOrderList@MerchantCenter", source: self, sender: nil)
                }
            }
            let waitingForPayNumb = (UserManager.sharedInstance.userInfo?.topayNumb) ?? 0
            let paidNumb = (UserManager.sharedInstance.userInfo?.paiedNumb) ?? 0
            let refundNumb = (UserManager.sharedInstance.userInfo?.refundNumb) ?? 0
            
            _cell.waitForPayNumb = waitingForPayNumb
            _cell.paidNumb = paidNumb
            _cell.finishedNumb = refundNumb
            
        case (2, 0):
            cell.imageView?.image = UIImage(named: "TableIconVerification")
            cell.textLabel?.text = "我的认证"
        case (2, 1):
            cell.imageView?.image = UIImage(named: "TableIconOrder")
            cell.textLabel?.text = "我的订单"
        case (2, 2):
            cell.imageView?.image = UIImage(named: "TableIconSaleSetting")
            cell.textLabel?.text = "扫码支付设置"
        case (2, 3):
            cell.imageView?.image = UIImage(named: "TableIconReceiveOrder")
            cell.textLabel?.text = "我的收单"
        case (2, 4):
            cell.imageView?.image = UIImage(named: "TableIconRecord")
            cell.textLabel?.text = "消费券记录"
        case (3, 0):
            cell.imageView?.image = UIImage(named: "TableIconCollect")
            cell.textLabel?.text = "我要收单"
        case (3, 1):
            cell.imageView?.image = UIImage(named: "TableIconScanCode")
            cell.textLabel?.text = "扫码"
        case (4, 0):
            cell.imageView?.image = UIImage(named: "TableIconSetup")
            cell.textLabel?.text = "设置"
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        case 1:
            return 75
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (2, 0):
            showVerificationPage()
        case (2, 1):
            AOLinkedStoryboardSegue.performWithIdentifier("MyOrders@MerchantCenter", source: self, sender: nil)
        case (2, 2):
            if !kApp.pleaseAttestationAction(showAlert: true, type: .perferentialPaySetting) {
                return
            }
            AOLinkedStoryboardSegue.performWithIdentifier("PrefrentialPay@MerchantCenter", source: self, sender: nil)
        case (2, 3):
            AOLinkedStoryboardSegue.performWithIdentifier("MyCollect@MerchantCenter", source: self, sender: nil)
        case (2, 4):
            AOLinkedStoryboardSegue.performWithIdentifier("SaleCoupon@MerchantCenter", source: self, sender: nil)
        case (3, 0):
            if !kApp.pleaseAttestationAction(showAlert: true, type: .wantCollect) {
                return
            }
            AOLinkedStoryboardSegue.performWithIdentifier("WantCollect@MerchantCenter", source: self, sender:
                nil)
        case (3, 1):
            showQRScanPage()
        case (4, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("Settings@CenterSettings", source: self, sender: nil)
        case (5, 0):
            Utility.showConfirmAlert(self, message: "是否确认退出登录？", confirmCompletion: {
                self.signOut()
            })
            
        default:
            break
        }
    }
}
