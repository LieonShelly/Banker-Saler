//
//  CampaignPlaceDetailViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/10/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class CampaignPlaceDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    internal var status: CampaignStatus = .notBegin
    internal var campInfo: PlaceCampaignInfo = PlaceCampaignInfo()
    
    var campId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "现场活动详情"
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "NavIconMore"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doMoreAction))
        navigationItem.rightBarButtonItem = rightBarItem
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        tableView.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        //        }
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
        if segue.identifier == "AddNewPlace@Campaign", let desVC = segue.destination as? CampaignAddNewPlaceViewController {
            
            desVC.modifyType = .edit
            desVC.campInfo = campInfo
            desVC.status = status
        } else if segue.identifier == "ProductAddAttribute@Product", let desVC = segue.destination as? ProductAddAttributeViewController {
            
            desVC.canEdit = false
            desVC.type = .campaignNote
            desVC.dataArray = campInfo.notes.map { return ($0.name, $0.content)}
        } else if segue.identifier == "ProductDescInput@Product", let desVC = segue.destination as? DetailInputViewController {
            
            if let indexPath = sender as? IndexPath {
                switch (indexPath.section, indexPath.row) {
                case (2, _):
                    desVC.navTitle = "输入活动名称"
                    desVC.txt = campInfo.title
                    desVC.canEdit = false
                case (3, _):
                    desVC.navTitle = "输入活动描述"
                    desVC.txt = campInfo.detail
                    desVC.canEdit = false
                case (5, 2):
                    desVC.navTitle = "输入活动地址"
                    desVC.txt = campInfo.addressDetail
                    desVC.canEdit = false
                default:
                    break
                }
            } else {
            let campId = campInfo.id
            desVC.navTitle = "中止活动申请"
            desVC.placeholder = "请输入中止申请的原因"
            desVC.emptyContentAlert = "请输入中止申请的原因"
            desVC.confirmBlock = { reason in
                self.requestStopPlaceCampaign(campId)
            }
            }
        } else if segue.identifier == "CampaignParticipator@Campaign", let desVC = segue.destination as? CampaignParticipatorViewController, let indexPath = sender as? IndexPath {
            desVC.type = (indexPath.row == 0) ? .appointment : .appeared
            desVC.campId = campInfo.id
        } else if segue.identifier == "CommonWebViewScene@AccountSession", let destVC = segue.destination as? CommonWebViewController {
            destVC.htmlContent = sender as? String
            destVC.naviTitle = "预览"
        }
    }
}

extension CampaignPlaceDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 2
        case 5:
            return 3
        case 6:
            return 1
        case 7:
            return 4
        case 8:
            if status == .notBegin || status == .inReview {
                return 1
            } else {
                return 2
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        case (1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        case (2, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            return cell
        case (3, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
            return cell
        case (4, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        case (5, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        case (6, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        case (8, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        }
        
    }
}

extension CampaignPlaceDetailViewController: UITableViewDelegate {
    
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
        case 3:
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
        case (0, 0):
           guard let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动状态"
            _cell.rightTxtLabel.textColor = UIColor.commonBlueColor()
           if campInfo.isApproved == .approved {
                _cell.rightTxtLabel.text = status.desc
           } else {
                _cell.rightTxtLabel.text = campInfo.isApproved.desc
            }
            
        case (0, 1):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "已消耗积分"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(campInfo.costPoint)"
        case (1, _):
          guard  let _cell = cell as? RightImageTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动封面"
            if !campInfo.cover.isEmpty {
                _cell.rightImageView.sd_setImage(with: URL(string: campInfo.cover), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
            }
        case (2, _):
            
           guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动名称"
            _cell.rightTxtField.placeholder = "请输入简洁有特色的活动名称"
            _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtField.text = campInfo.title
            _cell.accessoryType = .disclosureIndicator
        case (3, _):
            cell.accessoryType = .disclosureIndicator
         guard   let _cell = cell as? NormalDescTableViewCell else { return }
            _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
            if campInfo.detail.isEmpty {
                _cell.txtLabel.text = "请输入活动描述"
            } else {
                _cell.txtLabel.text = campInfo.detail
            }
        case (4, 0):
            
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动人数上限"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(campInfo.maxNumb)人"
        case (4, 1):
            
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "单个赠予积分"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(campInfo.point)"
            
        case (5, 0):
            
           guard let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "联系人"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.addressContact
        case (5, 1):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "联系电话"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.addressTel
        case (5, 2):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动地址"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.addressDetail
            cell.accessoryType = .disclosureIndicator
        case (6, 0):
         guard   let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动须知"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(campInfo.notes.count)"
            if campInfo.notes.isEmpty {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        case (7, 0):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "报名开始时间"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.appointmentStartTime
        case (7, 1):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "报名结束时间"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.appointmentEndTime
        case (7, 2):
         guard   let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "开始时间"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.startTime
        case (7, 3):
         guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "结束时间"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = campInfo.endTime
        case (8, 0):
         guard   let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "已报名人数"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(campInfo.appointmentNumb)"
            cell.accessoryType = .none
            if campInfo.appointmentNumb == 0 {
                cell.accessoryType = .none
            } else {
            }
        case (8, 1):
         guard   let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "已参与人数"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(campInfo.joinNumb)"
            if campInfo.joinNumb == 0 {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
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
        case (2, _):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (3, _):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (5, 2):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (6, 0):            
            if campInfo.notes.isEmpty == false {
                AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath as AnyObject?)
            }
        case (8, 1):
            if campInfo.joinNumb == 0 {
                break
            }
            AOLinkedStoryboardSegue.performWithIdentifier("CampaignParticipator@Campaign", source: self, sender: indexPath as AnyObject?)
        default:
            break
        }
    }
}

extension CampaignPlaceDetailViewController {
    fileprivate func copy(item: PlaceCampaignInfo) {
            guard let destVC = UIStoryboard(name: "Campaign", bundle: nil).instantiateViewController(withIdentifier: "AddNewPlace") as? CampaignAddNewPlaceViewController else { return  }
            destVC.modifyType = .copy
            destVC.campInfo = item
            destVC.status = status
        navigationController?.pushViewController(destVC, animated: true)
    }
    
   fileprivate func deleteItem() {
        let ac = UIAlertController(title: "提示", message: "是否删除该活动？", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "确认", style: .default, handler: {action in
            self.requestDeleteCampaign()
        }))
    }
    
   fileprivate func stopItem() {
        Utility.showConfirmAlert(self, message: "活动中止之后，用户将不能报名参加该活动，是否确认继续？", confirmCompletion: {
            let campId = self.campInfo.id
            self.requestStopPlaceCampaign(campId)
        })
    }
    
    fileprivate func showEditViewController() {
        AOLinkedStoryboardSegue.performWithIdentifier("AddNewPlace@Campaign", source: self, sender: nil)
    }
    
   fileprivate func seePreview() {
        
        let parameters: [String: Any] = [
            "event_id": campInfo.id
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.placeEventPreview(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil, let result = object as? [String: AnyObject],
                let html = result["html"] as? String {
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html)
            } else {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
    
  fileprivate  func shareItem() {
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
        if campInfo.isApproved == .approved {// 审核通过的状态: 进行中，未开始，已结束
            switch campInfo.status {
            case .inProgress:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_btn_preview", "预览"),
                                                  ("product_btn_share", "分享")]
            case .notBegin:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_btn_preview", "预览"),
                                                  ("product_btn_suspension", "分享"),
                                                  ("product_btn_share", "中止")]
            case .over:
                modalViewController.itemInfos = [ ("product_btn_copy", "复制"),
                                                  ("product_btn_preview", "预览"),
                                                  ("product_btn_delete", "删除")]
            default:
                break
            }
        } else {
            switch campInfo.isApproved {
            case .waitingForReview:
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
            default:
                break
            }
            
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
            return
        }
        if campInfo.isApproved == .approved {// 审核通过的状态: 进行中，未开始，已结束
            switch campInfo.status {
            case .inProgress:
                switch index {
                case 1:
                    seePreview()
                case 2:
                     shareItem()
                default:
                    break
                }
            case .notBegin:
                switch index {
                case 1:
                    seePreview()
                case 2:
                    shareItem()
                case 3:
                    stopItem()
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
            default: break
            }
            
        } else {
            switch campInfo.isApproved {
            case .waitingForReview:
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
            default:
                break
            }
            
        }
        
    }
}

extension CampaignPlaceDetailViewController {
    func requestCampaignInfo() {
        
        let parameters: [String: Any] = [
            "event_id": campId ?? campInfo.id
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.placeEventDetail(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil, let result = object as? [String: AnyObject] {
                Utility.hideMBProgressHUD()
                if let campInfo = Mapper<PlaceCampaignInfo>().map(JSON: result) {
                    self.campInfo = campInfo
                    self.status = campInfo.status
                    self.tableView.reloadData()
                }
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
        RequestManager.request(AFMRequest.placeEventDel(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.place.rawValue, "CampaignStatus": self.campInfo.status.rawValue])
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
    
    func requestStopPlaceCampaign(_ campaignId: Int) {
        
        let parameters: [String: Any] = [
            "event_id": campaignId
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.placeEventClose(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
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
