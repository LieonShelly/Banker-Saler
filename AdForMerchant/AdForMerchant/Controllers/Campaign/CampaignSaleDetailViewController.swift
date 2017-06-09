//
//  CampaignSaleDetailViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 4/13/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class CampaignSaleDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    internal var status: CampaignStatus! = .notBegin
    internal var campInfo: CampaignInfo! = CampaignInfo()
    
    var campId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "促销活动详情"
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "NavIconMore"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doMoreAction))
        navigationItem.rightBarButtonItem = rightBarItem
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        tableView.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestCampaignInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewSale@Campaign", let desVC = segue.destination as? CampaignAddNewSaleViewController {
            desVC.modifyType = .edit
            desVC.campInfo = campInfo
            desVC.status = status
        } else if segue.identifier == "ProductAddAttribute@Product", let desVC = segue.destination as? ProductAddAttributeViewController {
            
            desVC.canEdit = false
            
            guard let indexPath = sender as? IndexPath else {
                return
            }
            
            switch (indexPath.section, indexPath.row) {
            case (3, 1) :
                desVC.type = .coupon
                desVC.dataArray = campInfo.couponRule.map { return ($0.totalAmount, $0.discountAmount)}
            case (5, 0) :
                desVC.type = .campaignNote
                desVC.dataArray = campInfo.notes.map { return ($0.name, $0.content)}
            default:
                break
            }
        } else if segue.identifier == "CampaignAddRelatedProducts@Campaign", let desVC = segue.destination as? CampaignAddRelatedProductsViewController {

            desVC.canEdit = false
            desVC.productsSelected = campInfo.goodsIds.map({return Int($0) ?? 0})
            desVC.completeBlock = { productIds in
                self.campInfo.goodsIds = productIds.components(separatedBy: ",")
            }
        } else if segue.identifier == "ProductDescInput@Product", let desVC = segue.destination as? DetailInputViewController {
            
            if let inputValue = sender as? Int, let inputType = DetailInputType(rawValue: inputValue) {
                desVC.canEdit = false
                switch inputType {
                case .title:
                    desVC.navTitle = "输入活动名称"
                    desVC.txt = campInfo.title
                case .description:
                    desVC.navTitle = "输入活动描述"
                    desVC.txt = campInfo.detail
                default:
                    break
                }
            } else {
                let campId = campInfo.id
                desVC.navTitle = "中止活动申请"
                desVC.placeholder = "请输入中止申请的原因"
                desVC.emptyContentAlert = "请输入中止申请的原因"
                desVC.confirmBlock = { reason in
                    self.requestStopCampaign(campId, reason: reason)
                }
            }
        } else if segue.identifier == "CampaignStopApplyList@Campaign", let desVC = segue.destination as? CampaignStopApplyListViewController {
            
            desVC.applyInfoArray = campInfo.applyList
        } else if segue.identifier == "CommonWebViewScene@AccountSession", let destVC = segue.destination as? CommonWebViewController {
            
            destVC.htmlContent = sender as? String
            destVC.naviTitle = "预览"
        }
    }
}

extension CampaignSaleDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            if campInfo.applyList.isEmpty {
                return 3
            } else {
                return 4
            }
        case 6:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _), (3, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath) as? DefaultTxtTableViewCell else { return UITableViewCell() }
            if indexPath.section == 0 {
                cell.rightTxtLabel.textColor = UIColor.commonBlueColor()
            } else {
                cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
            }
            return cell
        case (1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        case (2, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            return cell
        case (4, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        case (6, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        default:
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath) as? DefaultTxtTableViewCell else { return UITableViewCell() }
            cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
    }
}

extension CampaignSaleDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 35
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 4:
            return 80
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            if section == 1 {
                let attrTxt = NSAttributedString(string: "需要帮助？", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: screenWidth - 100, y: 0, width: 100, height: 35)
                btn.setAttributedTitle(attrTxt, for: UIControlState())
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                titleBg.addSubview(btn)
                return titleBg
            }
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            guard let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动状态"
            _cell.rightTxtLabel.text = status.desc
        case (1, _):
           guard let _cell = cell as? RightImageTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动封面"
            if !campInfo.cover.isEmpty {
                _cell.rightImageView.sd_setImage(with: URL(string: campInfo.cover), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
            }
        case (2, _):
           guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动名称"
            _cell.rightTxtField.placeholder = "请输入简洁有特色的活动名称"
            _cell.rightTxtField.text = campInfo.title
            _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            cell.accessoryType = .disclosureIndicator
        case (3, 0):
            cell.accessoryType = .none
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动类型"
            _cell.rightTxtLabel.text = "满减"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        case (3, 1):
            cell.accessoryType = .disclosureIndicator
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "满减规则"
            let count = campInfo.couponRule.count
            _cell.rightTxtLabel.text = "\(count)"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        case (3, 2):
            cell.accessoryType = .disclosureIndicator
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "选择商品"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            if campInfo.eventGoodsNumb == 0 {
                _cell.rightTxtLabel.text = "0"
                cell.accessoryType = .none
            } else {
                let count = campInfo.eventGoodsNumb
                _cell.rightTxtLabel.text = "\(count)"
                cell.accessoryType = .disclosureIndicator
            }
        case (3, 3):
            cell.accessoryType = .disclosureIndicator
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "申请中止履历"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(campInfo.applyList.count)"
            if campInfo.applyList.isEmpty {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        case (4, _):
            
         guard   let _cell = cell as? NormalDescTableViewCell else { return }
            _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
            if campInfo.detail.isEmpty {
                _cell.txtLabel.text = "请输入活动描述"
            } else {
                _cell.txtLabel.text = campInfo.detail
            }
        case (5, 0):
         guard   let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动须知"
            _cell.rightTxtLabel.text = "\(campInfo.notes.count)"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            if campInfo.notes.isEmpty {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        case (6, 0):
         guard   let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动开始时间"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.startTime
        case (6, 1):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动结束时间"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.endTime
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case(0, 0):
            if status == .exception {
                let destVC = StatusDetailViewController()
                destVC.title = "活动状态"
                let param = StatusDetailParameter()
                param.relationID = campInfo.id
                param.type = .campaign
                destVC.param = param
                navigationController?.pushViewController(destVC, animated: true)
            }
        case (2, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: DetailInputType.title.rawValue as AnyObject?)
        case (3, 1):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath as AnyObject?)
        case (3, 2):
            if campInfo.goodsIds.isEmpty == false {
                AOLinkedStoryboardSegue.performWithIdentifier("CampaignAddRelatedProducts@Campaign", source: self, sender: nil)
            }
        case (3, 3):
            if campInfo.applyList.isEmpty == false {
                AOLinkedStoryboardSegue.performWithIdentifier("CampaignStopApplyList@Campaign", source: self, sender: nil)
            }
        case (4, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: DetailInputType.description.rawValue as AnyObject?)
        case (5, 0):
            if campInfo.notes.isEmpty == false {
                AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath as AnyObject?)            }
        default:
            break
        }
    }
}

extension CampaignSaleDetailViewController {
    fileprivate func copy(item: CampaignInfo) {
         guard let destVC = UIStoryboard(name: "Campaign", bundle: nil).instantiateViewController(withIdentifier: "AddNewSale") as? CampaignAddNewSaleViewController else { return  }
        destVC.modifyType = .copy
        destVC.copyCampInfoID = item.id
        navigationController?.pushViewController(destVC, animated: true)
    }
    
   fileprivate func deleteItem() {
        Utility.showConfirmAlert(self, title: "温馨提示", message: "是否删除该活动？", confirmCompletion: {
            self.requestDeleteCampaign()
        })
    }
    
   fileprivate func stopNotBeginItem() {
        Utility.showConfirmAlert(self, title: "温馨提示", message: "活动中止后用户无法看到该活动的相关信息，是否确认中止该活动？", confirmCompletion: {
                            self.requestStopCampaign(self.campInfo.id)
                        })
    }
    
   fileprivate func stopInProgressItem() {
            Utility.showConfirmAlert(self, title: "温馨提示", message: "中止操作需要提交申请，是否继续中止该活动？", confirmCompletion: {
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: nil)
            })
    }
   fileprivate func showEditViewController() {
        AOLinkedStoryboardSegue.performWithIdentifier("AddNewSale@Campaign", source: self, sender: nil)
    }
    
   fileprivate func seePreview() {
        
        let parameters: [String: Any] = [
            "event_id": campInfo.id
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventPreview(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
                guard let result = object as? [String: AnyObject], let html = result["html"] as? String else { return }
                
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html as AnyObject?)
            } else {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
    
   fileprivate func shareItem() {
        let shareVC = ShareViewController()
        shareVC.shareTitle = campInfo.title
        shareVC.shareDetailLink = campInfo.shareUrl
        shareVC.shareItems = [.wechatFriends, .wechatCircle, .qqFriends, .copyLink]
        shareVC.transitioningDelegate = shareVC
        shareVC.modalPresentationStyle = .custom
        navigationController?.present(shareVC, animated: true, completion: nil)
    }
    
    func doMoreAction() {
        let modalViewController = NavPopoverViewController()
        modalViewController.offsetY = 69
            guard let sta = status else { return  }
            switch sta {
            case .inProgress, .notBegin:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_btn_preview", "预览"),
                                                  ("product_btn_suspension", "中止"),
                                                    ("product_btn_share", "分享")]
            case .over:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_btn_preview", "预览"),
                                                  ("product_btn_delete", "删除")]
            case .inReview:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_btn_preview", "预览")]
            case .exception:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_btn_preview", "预览"),
                                                  ("product_head_btn_edit", "编辑"),
                                                  ("product_btn_delete", "删除")]
            case .draft:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_head_btn_edit", "编辑"),
                                                  ("product_btn_delete", "删除")]
            }
        
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        modalViewController.selectItemCompletionBlock = {(index: Int) -> Void in
            self.doNavAction(index)
        }
        self.navigationController?.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
    }
    
    func doNavAction(_ index: Int) {
        if index == 0 {
            copy(item: campInfo)
        }
         guard let sta = status else { return  }
            switch sta {
            case .inProgress, .notBegin:
                switch index {
                case 1:
                    seePreview()
                case 2:
                    if sta == .inProgress {
                        stopInProgressItem()
                    }
                    if sta == .notBegin {
                        stopNotBeginItem()
                    }
                case 3:
                    shareItem()
                default:
                    break
                }
            case .over:
                switch index {
                case 1:
                    seePreview()
                case 2:
                    requestDeleteCampaign()
                default:
                    break
                }
            case .inReview:
                switch index {
                case 1:
                    seePreview()
                default:
                    break
                }
            case .exception:
                switch index {
                case 1:
                    seePreview()
                case 2:
                    showEditViewController()
                case 3:
                    requestDeleteCampaign()
                default:
                    break
                }
            case .draft:
                switch index {
                case 1:
                    showEditViewController()
                case 2:
                    requestDeleteCampaign()
                default:
                    break
                }
        
            }
    }

}

extension CampaignSaleDetailViewController {
    func requestCampaignInfo() {
        
        let parameters: [String: Any] = [
            "event_id": campId  ?? campInfo.id
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventDetail(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let result = object as? [String: AnyObject] else { return }
                let campInfo = Mapper<CampaignInfo>().map(JSON: result)
                self.campInfo = campInfo
                self.status = campInfo?.status
                self.tableView.reloadData()
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }
    
    func requestDeleteCampaign() {
        let parameters: [String: Any] = [
            "event_id": campInfo.id
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventDel(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.sale.rawValue, "CampaignStatus": self.campInfo.status.rawValue])
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                if let msg = msg {
                    Utility.hideMBProgressHUD()
                    Utility.showAlert(self, message: msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
        
    }
    
    func requestStopCampaign(_ campaignId: Int, reason: String) {
        
        let parameters: [String: Any] = [
            "event_id": campaignId,
            "reason": reason
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventApply(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                Utility.showAlert(self, message: "中止活动申请成功", dismissCompletion: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                if let msg = error?.userInfo["message"] as? String {
                    Utility.hideMBProgressHUD()
                    Utility.showAlert(self, message: msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestStopCampaign(_ campaignId: Int) {
        
        let parameters: [String: Any] = [
            "event_id": campaignId
        ]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.eventClose(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                Utility.showAlert(self, message: "结束活动成功", dismissCompletion: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                if let msg = error?.userInfo["message"] as? String {
                    Utility.hideMBProgressHUD()
                    Utility.showAlert(self, message: msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
}
