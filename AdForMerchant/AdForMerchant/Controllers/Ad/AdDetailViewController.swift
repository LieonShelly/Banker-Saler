//
//  AdDetailViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/19/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class AdDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    var adID: String! = ""
    
    var adDetailModel: AdDetailModel! = AdDetailModel()
    var willSeePreview: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "广告详情"
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "NavIconMore"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doMoreAction))
        navigationItem.rightBarButtonItem = rightBarItem

        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = tableView.backgroundColor
        
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        tableView.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        Utility.showMBProgressHUDWithTxt()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdAddNew@Ad" {
            guard let desVC = segue.destination as? AdAddNewViewController else {return}
            guard let type = (sender as? Int) else {return}
            switch type {
            case 1:
                desVC.adType = AdType.picture
            case 2:
                desVC.adType = AdType.movie
            case 3:
                desVC.adType = AdType.webpage
            default:
                break
            }
            desVC.adDetailModel = self.adDetailModel
            desVC.modifyType = ObjectModifyType.edit
        } else if segue.identifier == "ProductDescInput@Product" {
            guard let desVC = segue.destination as? DetailInputViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            
            switch (indexPath.section, indexPath.row) {
            case (2, _):
                desVC.navTitle = "广告标题"
                desVC.txt = adDetailModel.title
                desVC.canEdit = false
                
            case (3, _):
                desVC.navTitle = "广告描述"
                desVC.txt = adDetailModel.detail
                desVC.canEdit = false
            default:
                break
            }
        } else if segue.identifier == "CommonWebViewScene@AccountSession" {
            guard let destVC = segue.destination as? CommonWebViewController else {return}
            guard let text = sender as? String else {
                return
            }
            if willSeePreview {
                destVC.naviTitle = "预览"
                destVC.htmlContent = text
            } else {
                destVC.requestURL = text
                switch adDetailModel.type {
                case "2":
                    destVC.naviTitle = "广告视频"
                case "3":
                    destVC.naviTitle = "广告网页"
                default:break
                }
            }
        } else if segue.identifier == "AdQuestionDetail@Ad" {
            guard let desVC = segue.destination as? AdQuestionDetailViewController else {return}
            desVC.adDetailModel = adDetailModel
        }
    }
}

extension AdDetailViewController {
    func requestData() {
        let params = ["ad_id": adID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.adDetail(params as [String : AnyObject], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if object == nil {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            } else {
                guard let result = object as? [String: AnyObject] else {return}
                self.adDetailModel = AdDetailModel(JSON: result)
                print("***************:\(self.adDetailModel.isApproved))")
                self.tableView.reloadData()
            }
        }
    }
    
    func seePreview() {
        let params = ["ad_id": adID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.adPreview(params as [String : AnyObject], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if object == nil {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            } else {
                self.willSeePreview = true
                guard let result = object as? [String: AnyObject] else {return}
                guard let html = result["html"] as? String else {return}
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html)
            }
        }
    }
    
    func shareItem() {
        //        let info = judgeCurrentDataArray().dataArray[indexPath.section]
        
        let shareVC = ShareViewController()
        shareVC.shareTitle = adDetailModel.title
        shareVC.shareDetailLink = adDetailModel.shareUrl
        shareVC.shareItems = [.wechatFriends, .wechatCircle, .qqFriends, .copyLink]
        shareVC.transitioningDelegate = shareVC
        shareVC.modalPresentationStyle = .custom
        navigationController?.present(shareVC, animated: true, completion: nil)
    }
    
    func doMoreAction() {
        let modalViewController = NavPopoverViewController()
        modalViewController.offsetY = 69
            switch adDetailModel.status {
            case .inProgress:
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览"),
                                                 ("product_btn_suspension", "中止"),
                                                    ("product_btn_share", "分享")]
            case .closed:
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览"),
                                                 ("product_btn_delete", "删除")]
            case .waitingForReview:
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览")]
            case .exception:
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览"),
                                                 ("product_head_btn_edit", "编辑"),
                                                 ("product_btn_delete", "删除")]
            case .draft:
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_head_btn_edit", "编辑"),
                                                 ("product_btn_delete", "删除")]
        }
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        modalViewController.selectItemCompletionBlock = {(index: Int) -> Void in
            self.modalAction(index)
        }
        self.navigationController?.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
    }
    
    func modalAction(_ index: Int) {
        if index == 0 {
            copy(adID: adDetailModel.adID)
            return
        }
        switch adDetailModel.status {
        case .inProgress:
            switch index {
            case 1:
                seePreview()
            case 2:
                stopAd()
            case 3:
                shareItem()
            default:
                break
            }
        case .closed:
            switch index {
            case 1:
                seePreview()
            case 2:
                deleteAd()
            default:
                break
            }
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
                editAd()
            case 3:
                deleteAd()
            default:
                break
            }
        case .draft:
            switch index {
            case 1:
                editAd()
            case 2:
                deleteAd()
            default:
                break
            }
        }
    }
    
    func copy(adID: String) {
     guard let destVC = UIStoryboard(name: "Ad", bundle: nil).instantiateViewController(withIdentifier: "AdAddNew") as? AdAddNewViewController, let typevalue = Int(adDetailModel.type), let type = AdType(rawValue: typevalue) else { return  }
        destVC.adType = type
        destVC.adDetailModel = self.adDetailModel
        destVC.modifyType = .copy
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func editAd() {
        AOLinkedStoryboardSegue.performWithIdentifier("AdAddNew@Ad", source: self, sender: Int(adDetailModel.type) as AnyObject?)
    }
    
    func deleteAd() {
        
        let  params = ["ad_id": adDetailModel.adID]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        let alertController = UIAlertController(title: "提示", message: "是否确认删除该广告", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (alert) in
            Utility.showMBProgressHUDWithTxt()
            RequestManager.request(AFMRequest.adDel(params as [String : AnyObject], aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) in
                Utility.hideMBProgressHUD()
                if object == nil {
                    if let msg = msg {
                        Utility.showAlert(self, message: msg)
                    }
                    return
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenAdChangedNotification), object: nil)
                _ = self.navigationController?.popViewController(animated: true)
            })
        })
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func stopAd() {
        let params: [String: Any] = ["ad_id": adDetailModel.adID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showConfirmAlert(self, message: "中止后该广告不能被用户看到，是否确认继续？", confirmCompletion: {
            Utility.showMBProgressHUDWithTxt()
            RequestManager.request(AFMRequest.adClose(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) in
                Utility.hideMBProgressHUD()
                if object == nil {
                    if let msg = msg {
                        Utility.showAlert(self, message: msg)
                    }
                    return
                }
            })
            
        })
    }
}

extension AdDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
        
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
            return 1
        case 5:
            return 2
        case 6:
            return 1
        case 7:
            return 2
        case 8:
            return 2
        case 9:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
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
        case (5, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        case (7, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            return cell
        }
        
    }
}

extension AdDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            if section == 1 {
                return 35
            }
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
        let bg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 10))
        return bg
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
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.rightTxtLabel.textColor = UIColor.commonBlueColor()
            _cell.leftTxtLabel.text = "广告状态"
            switch self.adDetailModel.status {
            case .inProgress:
                _cell.rightTxtLabel.text = "进行中"
            case .closed:
                _cell.rightTxtLabel.text = "已结束"
            case .waitingForReview:
                _cell.rightTxtLabel.text = "审核中"
            case .exception:
                _cell.rightTxtLabel.text = "异常"
            case .draft:
                _cell.rightTxtLabel.text = "草稿"
            }
        case (0, 1):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.leftTxtLabel.text = "已消耗积分"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.rightTxtLabel.text = "\(adDetailModel.costPoint)"
        case (1, _):
            guard let _cell = cell as? RightImageTableViewCell else {return}
            _cell.leftTxtLabel.text = "广告封面"
            if adDetailModel.cover.isEmpty == false {
                _cell.rightImageView.sd_setImage(with: URL(string: adDetailModel.cover))
            } else {
                _cell.rightImageView.sd_setImage(with: URL(string: ""))
            }
        case (2, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            _cell.leftTxtLabel.text = "广告标题"
            _cell.accessoryType = .disclosureIndicator
            if adDetailModel.title.isEmpty == false {
                _cell.rightTxtField.text = self.adDetailModel.title
            } else {
                _cell.rightTxtField.placeholder = "暂无商品名称"
            }
        case (3, _):
            guard let _cell = cell as? NormalDescTableViewCell else {return}
            _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
            _cell.accessoryType = .disclosureIndicator
            if adDetailModel.detail.isEmpty == false {
                _cell.txtLabel?.text = adDetailModel.detail
            } else {
                _cell.txtLabel?.text = "暂无广告描述"
            }
        case (4, 0):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.accessoryType = .disclosureIndicator
            switch adDetailModel.type {
            case "1":
                _cell.leftTxtLabel.text = "广告图片"
            case "2":
                _cell.leftTxtLabel.text = "广告视频"
            case "3":
                _cell.leftTxtLabel.text = "广告网页"
            default:break
            }
            _cell.rightTxtLabel.text = ""
        case (5, 0):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.accessoryType = .none
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.leftTxtLabel.text = "开始时间"
            if adDetailModel.startTime.isEmpty == false {
                _cell.rightTxtLabel.text = adDetailModel.startTime
            } else {
                _cell.rightTxtLabel.text = "暂无"
            }
        case (5, 1):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.accessoryType = .none
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.leftTxtLabel.text = "结束时间"
            if adDetailModel.startTime.isEmpty == false {
                _cell.rightTxtLabel.text = adDetailModel.endTime
            } else {
                _cell.rightTxtLabel.text = "暂无"
            }
        case (6, 0):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.accessoryType = .disclosureIndicator
            _cell.leftTxtLabel.text = "用户参与形式"
            _cell.rightTxtLabel.text = "问答"
        case (7, 0):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.accessoryType = .none
            _cell.leftTxtLabel.text = "回答正确奖励积分"
            if adDetailModel.point.isEmpty == false {
                _cell.rightTxtLabel.text = "\(adDetailModel.point)个"
            } else {
                _cell.rightTxtLabel.text = "暂无"
            }
        case (7, 1):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.accessoryType = .none
            _cell.leftTxtLabel.text = "每日积分使用上限"
            if adDetailModel.pointLimitPerday.isEmpty == false {
                _cell.rightTxtLabel.text = "\(adDetailModel.pointLimitPerday)个"
            } else {
                _cell.rightTxtLabel.text = "暂无"
            }
        case (8, 0):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
             _cell.leftTxtLabel.text = "总浏览量"
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.accessoryType = .none
            if adDetailModel.viewNum.isEmpty == false {
                _cell.rightTxtLabel.text = adDetailModel.viewNum
            } else {
                _cell.rightTxtLabel.text = "暂无"
            }
        case (8, 1):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.accessoryType = .none
            _cell.leftTxtLabel.text = "总扣除积分"
            if adDetailModel.costPoint.isEmpty == false {
                _cell.rightTxtLabel.text = adDetailModel.costPoint
            } else {
                _cell.rightTxtLabel.text = "暂无"
            }
        case (9, 0):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.rightTxtLabel.textColor = UIColor.gray
            _cell.accessoryType = .none
            _cell.leftTxtLabel.text = "参与次数"
            if adDetailModel.joinNum.isEmpty == false {
                _cell.rightTxtLabel.text = adDetailModel.joinNum
            } else {
                _cell.rightTxtLabel.text = "暂无"
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if adDetailModel.status == .exception {
                let destVC = StatusDetailViewController()
                destVC.title = "广告状态"
                let param = StatusDetailParameter()
                param.relationID = Int(adDetailModel.adID)
                param.type = .advertisement
                destVC.param = param
                navigationController?.pushViewController(destVC, animated: true)
            }
        case (2, _):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (3, _):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (4, _):
            switch adDetailModel.type {
            case "1":
                let detailVC = PhotoDetailViewController(nibName: "PhotoDetailViewController", bundle: nil)
                var urlImgArr = [String]()
                guard let url = adDetailModel?.imgAdUrl else {return}
                for item in url {
                    urlImgArr.append(item)
                }
                detailVC.photosUrlArray = urlImgArr
                navigationController?.pushViewController(detailVC, animated: true)
            case "2":
                willSeePreview = false
                let requestUrl = adDetailModel.videoAdUrl
                if requestUrl.isEmpty == false {
                    AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: requestUrl as AnyObject?)
                }
            case "3":
                willSeePreview = false
                let requestUrl = adDetailModel.webAdUrl
                if requestUrl.isEmpty == false {
                    AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: requestUrl as AnyObject?)
                }
            default:break
            }
        case (6, 0):
            
            AOLinkedStoryboardSegue.performWithIdentifier("AdQuestionDetail@Ad", source: self, sender: nil)
            
        default:
            break
        }
    }
}
