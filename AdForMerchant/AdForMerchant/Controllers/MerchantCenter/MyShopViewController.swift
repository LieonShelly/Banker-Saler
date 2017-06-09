//
//  MyShopViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class MyShopViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var storeInfo: StoreInfo! = StoreInfo()
    var payPasswd: String = ""
    var addressCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的店铺"
        
        if let storeInfo = UserManager.sharedInstance.userInfo?.storeInfo {
            self.storeInfo = storeInfo
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestStoreInfo()
        requestAddressList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShopCreate@MerchantCenter" {
            guard let desVC = segue.destination as? ShopCreateViewController else {return}
            desVC.storeInfo = storeInfo
        }
    }
    
    // MARK: - Http request
    
    func requestStoreInfo() {
        kApp.requestUserInfoWithCompleteBlock({
            if let storeInfo = UserManager.sharedInstance.userInfo?.storeInfo {
                self.storeInfo = storeInfo
            }
            self.tableView.reloadData()
        })
    }
    
    func showPayCodeView() {
        let payCodeVC = PayCodeVerificationViewController()
        payCodeVC.modalPresentationStyle = .custom
        payCodeVC.confirmBlock = {payPassword in
            self.payPasswd = payPassword
            self.requestCheckPayCode()
        }
        present(payCodeVC, animated: true, completion: nil)
    }
    
    // MARK: - Http request
    
    func requestCheckPayCode() {
        
        let parameters: [String: Any] = [
            "pay_password": payPasswd
            ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantCheckPaypassword(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                
                AOLinkedStoryboardSegue.performWithIdentifier("MyShopAssistantViewController@MerchantCenter", source: self, sender: nil)
                
            } else {
                
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestAddressList() {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.storeAddressList(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else {return}
                if let addressList = result["address_list"] as? [[String: Any]] {
                    self.addressCount = addressList.count
                    Utility.hideMBProgressHUD()
                    self.tableView.reloadData()
                }
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }

}

extension MyShopViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShopHeaderTableViewCell", for: indexPath)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .value1, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
}

extension MyShopViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        if indexPath.section >= 1 && indexPath.section <= 5 {
            cell.textLabel?.textColor = UIColor.colorWithHex("#393939")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            
            guard let _cell = cell as? MyShopHeaderTableViewCell else {return}
            _cell.shopBgImgView.sd_setImage(with: URL(string: storeInfo.cover))
            _cell.shopAvatarImgView.sd_setImage(with: URL(string: storeInfo.logo), placeholderImage: UIImage(named: "PlaceHolderHeadportrait"))

            if storeInfo.name.isEmpty {
                _cell.shopNameLbl.text = "店铺名称设置"
            } else {
                _cell.shopNameLbl.text = storeInfo.name
            }
            _cell.shopRatingLbl.text = "评分：" + storeInfo.score
            
        case (1, 0):
            cell.imageView?.image = UIImage(named: "MyShopIconCategory")
            cell.textLabel?.text = "店铺分类"
        case (2, 0):
            cell.imageView?.image = UIImage(named: "btn_Item_management")
            cell.textLabel?.text = "货号管理"
        case (3, 0):
            cell.imageView?.image = UIImage(named: "btn_commodity_setting")
            cell.textLabel?.text = "商品设置"
        case (4, 0):
            cell.imageView?.image = UIImage(named: "btn_my_shop_assistant")
            cell.textLabel?.text = "我的店员"
        case (5, 0):
            cell.imageView?.image = UIImage(named: "MyShopIconAddress")
            cell.detailTextLabel?.text = "\(addressCount)"
            cell.detailTextLabel?.textColor = UIColor.colorWithHex("#393939")
            cell.textLabel?.text = "店铺地址"
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 130
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
           
            AOLinkedStoryboardSegue.performWithIdentifier("ShopCreate@MerchantCenter", source: self, sender: nil)
        case (1, 0):
            if !kApp.pleaseAttestationAction(showAlert: true, type: .shopsCategory) {
                return
            }
            AOLinkedStoryboardSegue.performWithIdentifier("ShopCategoryManage@MerchantCenter", source: self, sender: nil)
        case(2, 0):
            if !kApp.pleaseAttestationAction(showAlert: true, type: .itemManageCategory) {
                return
            }
            AOLinkedStoryboardSegue.performWithIdentifier("ItemManageViewController@MerchantCenter", source: self, sender: nil)
        case (3, 0):
            let destVC = GoodsSetViewController()
            navigationController?.pushViewController(destVC, animated: true)
        case (4, 0):
            
            let statsu = UserManager.sharedInstance.userInfo?.status ?? .unverified
            // 未认证：没有设置支付密码
            if statsu == .unverified {
                if !kApp.pleaseAttestationAction(showAlert: true, type: .myShopAssistanManage) {
                    return
                }
            }
            guard let vc = UIStoryboard(name: "VerifyPayPass", bundle: nil).instantiateInitialViewController() as? VerifypasswordViewController else {return}
            vc.type = .verify
            vc.modalPresentationStyle = .custom

            vc.resultHandle = { (result, data) in
                switch result {
                case .passed:
                    self.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    AOLinkedStoryboardSegue.performWithIdentifier("MyShopAssistantViewController@MerchantCenter", source: self, sender: nil)
                case .failed: break
                case .canceled:
                    self.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                }
            }
            self.dim(.in, coverNavigationBar: true)
            self.present(vc, animated: true, completion: nil)

        case (5, 0):
            if !kApp.pleaseAttestationAction(showAlert: true, type: .shopAdressManage) {
                return
            }
            AOLinkedStoryboardSegue.performWithIdentifier("ShopAddressManage@MerchantCenter", source: self, sender: nil)
                   default: break
        }
    }
}
