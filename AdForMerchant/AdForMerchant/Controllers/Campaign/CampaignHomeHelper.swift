//
//  CampaignHomeHelper.swift
//  AdForMerchant
//
//  Created by lieon on 2016/12/29.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper
import pop
import SDWebImage
import MBProgressHUD
import HMSegmentedControl

extension CampaignHomeViewController {
    
    func setupPageTitleView() {
        segmentView.addSubview(titleView)
        titleView.titleTapAction = {  [unowned self] selectedIndex in
            self.isForbiden = true
            self.refreshWhenNoData()
            self.segmentedControlChangedValue(index: selectedIndex)
        }
    }
    
    func changeTopSegmentValue(seg: UISegmentedControl, status: Int) {
        if seg.selectedSegmentIndex == 0 {
            campType = .sale
            saleTableScrollView.isHidden = false
            placeTableScrollView.isHidden = true
        } else {
            campType = .place
            saleTableScrollView.isHidden = true
            placeTableScrollView.isHidden = false
        }
        segmentedControlChangedValue(index:  status)
    }
    
    func topSegmentValueChanged(_ seg: UISegmentedControl) {
        if seg.selectedSegmentIndex == 0 {
            campType = .sale
            saleTableScrollView.isHidden = false
            placeTableScrollView.isHidden = true
            saleTableScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            titleView.setTitle(progress: 1.0, sourceIndex: titleView.currentIndex, targetIndex: 0)
            saleTableViews[0].mj_header.beginRefreshing()
        } else {
            campType = .place
            saleTableScrollView.isHidden = true
            placeTableScrollView.isHidden = false
            placeTableScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            titleView.setTitle(progress: 1.0, sourceIndex: titleView.currentIndex, targetIndex: 0)
            placeTableViews[0].mj_header.beginRefreshing()
        }
    }
    
    func refreshSegmentTitles(status: CampaignStatus, topSegmentCtrlIndex: Int, tottalItems: String) {
        let desc = "您当前" + status.desc + "的活动数量为" + tottalItems
        DispatchQueue.main.async(execute: { () -> Void in
            self.sumLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.5) {
                self.sumLabel.text = desc
                self.sumLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        })
    }
    
    func showQRScanPage() {
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ScanQR@Main") as? QRViewController else {  return }
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
        })
    }
    
    func refreshDataBgView(_ type: Int, status: Int) {// type: 0 系统，1 个人
        switch (type, status) {
        case (0, 0):
            if self.saleTableData1.saleDataArray.isEmpty == false {
                self.saleTableViews[0].backgroundView = nil
            } else {
                self.saleTableViews[0].backgroundView = noDataBg("您当前还没有进行中的促销活动，请点“+”发布")
            }
        case (0, 1):
            if self.saleTableData2.saleDataArray.isEmpty == false {
                self.saleTableViews[1].backgroundView = nil
            } else {
                self.saleTableViews[1].backgroundView = noDataBg("您当前还没有未开始的促销活动，请点“+”发布")
            }
        case (0, 2):
            if self.saleTableData3.saleDataArray.isEmpty == false {
                self.saleTableViews[2].backgroundView = nil
            } else {
                self.saleTableViews[2].backgroundView = noDataBg("没有已结束的促销活动")
            }
        case (0, 3):
            if self.saleTableData4.saleDataArray.isEmpty == false {
                self.saleTableViews[3].backgroundView = nil
            } else {
                self.saleTableViews[3].backgroundView = noDataBg("没有审核中的促销活动")
            }
        case (0, 4):
            if self.saleTableData5.saleDataArray.isEmpty == false {
                self.saleTableViews[4].backgroundView = nil
            } else {
                self.saleTableViews[4].backgroundView = noDataBg("没有异常的促销活动")
            }
        case (0, 5):
            if self.saleTableData6.saleDataArray.isEmpty == false {
                self.saleTableViews[5].backgroundView = nil
            } else {
                self.saleTableViews[5].backgroundView = noDataBg("没有草稿的促销活动")
            }
        case (1, 0):
            if self.placeTableData1.placeDataArray.isEmpty == false {
                self.placeTableViews[0].backgroundView = nil
            } else {
                self.placeTableViews[0].backgroundView = noDataBg("您当前还没有进行中的现场活动，请点“+”发布")
            }
        case (1, 1):
            if self.placeTableData2.placeDataArray.isEmpty == false {
                self.placeTableViews[1].backgroundView = nil
            } else {
                self.placeTableViews[1].backgroundView = noDataBg("您当前还没有未开始的现场活动，请点“+”发布")
            }
        case (1, 2):
            if self.placeTableData3.placeDataArray.isEmpty == false {
                self.placeTableViews[2].backgroundView = nil
            } else {
                self.placeTableViews[2].backgroundView = noDataBg("没有已结束的现场活动")
            }
        case (1, 3):
            if self.placeTableData4.placeDataArray.isEmpty == false {
                self.placeTableViews[3].backgroundView = nil
            } else {
                self.placeTableViews[3].backgroundView = noDataBg("没有审核中的现场活动")
            }
        case (1, 4):
            if self.placeTableData5.placeDataArray.isEmpty == false {
                self.placeTableViews[4].backgroundView = nil
            } else {
                self.placeTableViews[4].backgroundView = noDataBg("没有异常的现场活动")
            }
        case (1, 5):
            if self.placeTableData6.placeDataArray.isEmpty == false {
                self.placeTableViews[5].backgroundView = nil
            } else {
                self.placeTableViews[5].backgroundView = noDataBg("没有草稿的现场活动")
            }
        default:
            break
        }
    }
    
    func noDataBg(_ text: String) -> UIView {
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: saleTableScrollView.bounds.height))
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        descLbl.text = text
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        return bgView
    }
    
    func reloadTableView() {
        
        if topSegmentCtrl.selectedSegmentIndex == 0 {
//            saleTableData1.saleDataArray[seletedIndex.section].isSuspend = true
            //            print(self.seletedIndex.row)
            saleTableViews[0].mj_header.beginRefreshing()
        }
        
    }
    
    func removeDataSourceWhenSignOut() {
        willRefreshDataWhenAppear = true
        
        for tableData in [saleTableData1, saleTableData2, saleTableData3, saleTableData4, placeTableData1, placeTableData2, placeTableData3, placeTableData4] {
            tableData.saleDataArray.removeAll()
            tableData.placeDataArray.removeAll()
            tableData.currentPage = 0
            tableData.totalPage = 0
        }
        
        for table in (saleTableViews + placeTableViews) {
            table.reloadData()
        }
    }
    
    func dataSourceNeedRefreshAfterAppear(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let type = userInfo["CampaignType"] as? Int else { return }
        guard let status = userInfo["CampaignStatus"] as? String else { return }
        
        let campaignStatus = CampaignStatus(rawValue: status)
        topSegmentCtrl.selectedSegmentIndex = type
        
        if topSegmentCtrl.selectedSegmentIndex == 0 {
            campType = .sale
            saleTableScrollView.isHidden = false
            placeTableScrollView.isHidden = true
        } else {
            campType = .place
            saleTableScrollView.isHidden = true
            placeTableScrollView.isHidden = false
        }
        guard  let s = campaignStatus else { return }
        
        switch s {
        case .inProgress:
            segmentedControlChangedValue(index: 0)
        case .notBegin:
            segmentedControlChangedValue(index: 1)
        case .over:
            segmentedControlChangedValue(index: 2)
        case .inReview:
            segmentedControlChangedValue(index: 3)
        case .exception:
            segmentedControlChangedValue(index: 4)
        case .draft:
            segmentedControlChangedValue(index: 5)
        }
        requestListWithReload()
    }
    
    func showSaleEditViewController(_ indexPath: IndexPath) {
        AOLinkedStoryboardSegue.performWithIdentifier("AddNewSale@Campaign", source: self, sender: indexPath as AnyObject?)
    }
    
    func showPlaceEditViewController(_ indexPath: IndexPath) {
        AOLinkedStoryboardSegue.performWithIdentifier("AddNewPlace@Campaign", source: self, sender: indexPath as AnyObject?)
    }
    
    func campaignDelete(_ indexPath: IndexPath) {
        Utility.showConfirmAlert(self, message: "是否删除该活动？", confirmCompletion: {
            let statusIndex: Int = self.titleView.currentIndex
            var campId = 0
            let type = self.topSegmentCtrl.selectedSegmentIndex
            self.doActionWithTypeAndStatus(type, status: statusIndex) { (table, tableData) in
                if !tableData.saleDataArray.isEmpty {
                    campId = tableData.saleDataArray[indexPath.section].id
                } else {
                    campId = tableData.placeDataArray[indexPath.section].id
                }
            }
            self.requestDeleteCampaign(campId)
        })
    }
    
    func campaignStop(_ indexPath: IndexPath) {

        let statusIndex: Int = titleView.currentIndex
        self.seletedIndex = indexPath
        let type = self.topSegmentCtrl.selectedSegmentIndex
        if type == 0 { // 促销活动
            if statusIndex == 1 || statusIndex == 3 {//未开始
                
                var campId = 0
                self.doActionWithTypeAndStatus(type, status: statusIndex) { (table, tableData) in
                    if !tableData.saleDataArray.isEmpty {
                        campId = tableData.saleDataArray[indexPath.section].id
                    } else {
                        campId = tableData.placeDataArray[indexPath.section].id
                    }
                }
                
                Utility.showConfirmAlert(self, title: "温馨提示", message: "活动中止后用户无法看到该活动的相关信息，是否确认中止该活动？", confirmCompletion: {
                    self.requestStopCampaign(campId)
                })
            } else {
                Utility.showConfirmAlert(
                    self,
                    title: "温馨提示",
                    message: "中止操作需要提交申请，是否继续中止该活动？",
                    confirmCompletion: {
                        AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
                })
            }
        } else {
            
            var campId = 0
            self.doActionWithTypeAndStatus(type, status: statusIndex) { (table, tableData) in
                if !tableData.saleDataArray.isEmpty {
                    campId = tableData.saleDataArray[indexPath.section].id
                } else {
                    campId = tableData.placeDataArray[indexPath.section].id
                }
            }
            
            Utility.showConfirmAlert(self, message: "活动中止之后，用户将不能报名参加该活动，是否确认继续？", confirmCompletion: {
                self.requestStopPlaceCampaign(campId)
            })
        }
    }
    
    func segmentedControlChangedValue(index: Int) {
        titleView.setTitle(progress: 1, sourceIndex: titleView.currentIndex, targetIndex: index)
        if topSegmentCtrl.selectedSegmentIndex == 0 {
            saleTableScrollView.scrollRectToVisible(saleTableViews[index].frame, animated: true)
        } else {
            placeTableScrollView.scrollRectToVisible(placeTableViews[index].frame, animated: true)
        }
//        refreshWhenNoData()
    }
    
    func refreshWhenNoData() {
        requestListWithReload()
        let type = topSegmentCtrl.selectedSegmentIndex
        let index: Int = titleView.currentIndex
        doActionWithTypeAndStatus(type, status: index) { (table, tableData) in
            self.disPlayCount(index: index, count: tableData.totalItems)
        }
        
    }
    
  func disPlayCount(index: Int, count: String) {
        switch index {
        case 0: // 进行中
            let desc = "您当前进行中的活动数量为\(count)"
            sumLabel.text = desc
            break
        case 1: // 未开始
            let desc = "您当前未开始的活动数量为\(count)"
            sumLabel.text = desc
            break
        case 2: // 已结束
            let desc = "您当前已结束的活动数量为\(count)"
            sumLabel.text = desc
            break
        case 3: // 审核中
            let desc = "您当前审核中的活动数量为\(count)"
            sumLabel.text = desc
            break
        case 4: // 异常
            let desc = "您当前异常的活动数量为\(count)"
            sumLabel.text = desc
        case 5: // 草稿
            let desc = "您当前草稿的数量为\(count)"
            sumLabel.text = desc
            break
        default:
            break
        }
    }
    
    func doActionWithTypeAndStatus(_ type: Int, status: Int, action:((_ table: UITableView, _ tableData: CampaignTableData) -> Void)) {
        
        switch (type, status) {
        case (0, 0):
            action(self.saleTableViews[0], self.saleTableData1)
        case (0, 1):
            action(self.saleTableViews[1], self.saleTableData2)
        case (0, 2):
            action(self.saleTableViews[2], self.saleTableData3)
        case (0, 3):
            action(self.saleTableViews[3], self.saleTableData4)
        case (0, 4):
            action(self.saleTableViews[4], self.saleTableData5)
        case (0, 5):
            action(self.saleTableViews[5], self.saleTableData6)
        case (1, 0):
            action(self.placeTableViews[0], self.placeTableData1)
        case (1, 1):
            action(self.placeTableViews[1], self.placeTableData2)
        case (1, 2):
            action(self.placeTableViews[2], self.placeTableData3)
        case (1, 3):
            action(self.placeTableViews[3], self.placeTableData4)
        case (1, 4):
            action(self.placeTableViews[4], self.placeTableData5)
        case (1, 5):
            action(self.placeTableViews[5], self.placeTableData6)
        default: break
        }
        
    }
    
    func seePreview(_ indexPath: IndexPath) {
        let statusIndex: Int = titleView.currentIndex
        let type = self.topSegmentCtrl.selectedSegmentIndex
        self.doActionWithTypeAndStatus(type, status: statusIndex) { (table, tableData) in
            if !tableData.saleDataArray.isEmpty {
                let campId = "\(tableData.saleDataArray[indexPath.section].id)"
                
                let parameters: [String: Any] = [
                    "event_id": campId
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
            } else {
                let campId = "\(tableData.placeDataArray[indexPath.section].id)"
                
                let parameters: [String: AnyObject] = [
                    "event_id": campId as AnyObject
                ]
                let aesKey = AFMRequest.randomStringWithLength16()
                let aesIV = AFMRequest.randomStringWithLength16()
                
                Utility.showMBProgressHUDWithTxt()
                RequestManager.request(AFMRequest.placeEventPreview(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
                    Utility.hideMBProgressHUD()
                    if (object) != nil {
                        guard  let result = object as? [String: AnyObject], let html = result["html"] as? String else { return }
                        AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html as AnyObject?)
                    } else {
                        if let msg = msg {
                            Utility.showAlert(self, message: msg)
                        }
                    }
                }
            }
        }
        
    }
    
    func shareItem(_ indexPath: IndexPath) {
        let statusIndex: Int = titleView.currentIndex
        var title = ""
        var URL = ""
        
        let type = self.topSegmentCtrl.selectedSegmentIndex
        self.doActionWithTypeAndStatus(type, status: statusIndex) { (table, tableData) in
            if !tableData.saleDataArray.isEmpty {
                let camp = tableData.saleDataArray[indexPath.section]
                title = camp.title
                URL = camp.shareUrl
            } else {
                let camp = tableData.placeDataArray[indexPath.section]
                title = camp.title
                URL = camp.shareUrl
            }
        }
        
        let shareVC = ShareViewController()
        shareVC.shareTitle = title
        shareVC.shareDetailLink = URL
        shareVC.shareItems = [.wechatFriends, .wechatCircle, .qqFriends, .copyLink]
        shareVC.transitioningDelegate = shareVC
        shareVC.modalPresentationStyle = .custom
        navigationController?.present(shareVC, animated: true, completion: nil)
    }
}

extension CampaignHomeViewController {
    func requestListWithAppend() {
        requestListData(.append)
    }
    
    func requestListWithReload() {
        requestListData(.reload)
    }
    
    func requestDoubleClickListWithReload() {
        let typeAndStatus = (topSegmentCtrl.selectedSegmentIndex, titleView.currentIndex)
        doActionWithTypeAndStatus(typeAndStatus.0, status: typeAndStatus.1) { (table, tableData) in
            table.mj_header.beginRefreshing()
        }
    }
    
    func requestListData(_ refreshType: DataRefreshType) {
        var parameters: [String: AnyObject] = [:]
        var request: AFMRequest!
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        func judgeDataLoadCompletely(_ tableData: CampaignTableData, tableview: UITableView) -> Bool {
            tableData.currentPage = (refreshType == .append) ? tableData.currentPage : 0
            if tableData.currentPage >= tableData.totalPage && tableData.currentPage != 0 {
                tableview.mj_footer.endRefreshingWithNoMoreData()
                return true
            }
            return false
        }
        
        let typeAndStatus = (topSegmentCtrl.selectedSegmentIndex, titleView.currentIndex)
        switch typeAndStatus {
        case (0, 0):
            parameters["status"] = CampaignStatus.inProgress.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (saleTableData1.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.eventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(saleTableData1, tableview: saleTableViews[0]) {
                return
            }
        case (0, 1):
            parameters["status"] = CampaignStatus.notBegin.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (saleTableData2.currentPage + 1) : 1 ) as AnyObject?
            request = AFMRequest.eventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(saleTableData2, tableview: saleTableViews[1]) {
                return
            }
        case (0, 2):
            parameters["status"] = CampaignStatus.over.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (saleTableData3.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.eventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(saleTableData3, tableview: saleTableViews[2]) {
                return
            }
        case (0, 3):
            parameters["status"] = CampaignStatus.inReview.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (saleTableData4.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.eventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(saleTableData4, tableview: saleTableViews[3]) {
                return
            }
        case (0, 4):
            parameters["status"] = CampaignStatus.exception.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (saleTableData5.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.eventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(saleTableData5, tableview: saleTableViews[4]) {
                return
            }
        case (0, 5):
            parameters["status"] = CampaignStatus.draft.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (saleTableData5.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.eventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(saleTableData6, tableview: saleTableViews[5]) {
                return
            }
        case (1, 0):
            parameters["cat"] = 2 as AnyObject?
            parameters["status"] = CampaignStatus.inProgress.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (placeTableData1.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.placeEventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(placeTableData1, tableview: placeTableViews[0]) {
                return
            }
        case (1, 1):
            parameters["cat"] = 2 as AnyObject?
            parameters["status"] = CampaignStatus.notBegin.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (placeTableData2.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.placeEventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(placeTableData2, tableview: placeTableViews[1]) {
                return
            }
        case (1, 2):
            parameters["cat"] = 2 as AnyObject?
            parameters["status"] = CampaignStatus.over.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (placeTableData3.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.placeEventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(placeTableData3, tableview: placeTableViews[2]) {
                return
            }
        case (1, 3):
            parameters["cat"] = 2 as AnyObject?
            parameters["status"] = CampaignStatus.inReview.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (placeTableData4.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.placeEventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(placeTableData4, tableview: placeTableViews[3]) {
                return
            }
        case (1, 4):
            parameters["cat"] = 2 as AnyObject?
            parameters["status"] = CampaignStatus.exception.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (placeTableData5.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.placeEventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(placeTableData5, tableview: placeTableViews[4]) {
                return
            }
        case (1, 5):
            parameters["cat"] = 2 as AnyObject?
            parameters["status"] = CampaignStatus.draft.rawValue as AnyObject?
            parameters["page"] = ((refreshType == .append) ? (placeTableData6.currentPage + 1) : 1) as AnyObject?
            request = AFMRequest.placeEventIndex(parameters, aesKey, aesIV)
            if judgeDataLoadCompletely(placeTableData6, tableview: placeTableViews[5]) {
                return
            }
        default:
            return
        }
        Utility.showNetworkActivityIndicator()
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            //            if (object) != nil {
            if let result = object as? [String: AnyObject] {
                
                guard let currentPage = result["current_page"] as? String, let totalPage = result["total_page"] as? String, let totalItems = result["total_items"] as? String, let status = parameters["status"] as? String else { return }
                    print(totalItems)
                   let s = CampaignStatus.init(rawValue:status)
                    self.refreshSegmentTitles(status: s ?? .inReview, topSegmentCtrlIndex: self.topSegmentCtrl.selectedSegmentIndex, tottalItems: totalItems)
                
                self.doActionWithTypeAndStatus(typeAndStatus.0, status: typeAndStatus.1) { (table, tableData) in
                    tableData.totalItems = totalItems
                    tableData.currentPage = Int(currentPage) ?? 0
                    tableData.totalPage = Int(totalPage) ?? 0
                    if refreshType == .reload {
                        if typeAndStatus.0 == 0 {
                            tableData.saleDataArray.removeAll()
                        } else {
                            tableData.placeDataArray.removeAll()
                        }
                    }
                    guard let campaignList = result["items"] as? [AnyObject] else { return }
                    for campaign in campaignList {
                        if typeAndStatus.0 == 0 {
                            if let camp = Mapper<CampaignInfo>().map(JSON: (campaign as? [String : Any]) ?? [String: Any]() ) {
                                tableData.saleDataArray.append(camp)
                            }
                        } else {
                            if let camp = Mapper<PlaceCampaignInfo>().map(JSON: (campaign as? [String: Any]) ?? [String: Any]()) {
                                tableData.placeDataArray.append(camp)
                            }
                        }
                    }
                    table.reloadData()
                    self.refreshDataBgView(typeAndStatus.0, status: typeAndStatus.1)
                }
            }
            self.endTableViewRefresh(typeAndStatus)
            Utility.hideNetworkActivityIndicator()
        }
    }
    
    func endTableViewRefresh(_ typeAndStatus: (Int, Int)) {
        doActionWithTypeAndStatus(typeAndStatus.0, status: typeAndStatus.1) { (table, tableData) in
            table.reloadData()
            table.mj_header.endRefreshing()
            table.mj_footer.endRefreshing()
        }
    }
    
    func requestDeleteCampaign(_ campaignId: Int) {
        var request: AFMRequest!
        let parameters: [String: AnyObject] = [
            "event_id": campaignId as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        if topSegmentCtrl.selectedSegmentIndex == 0 {
            request = AFMRequest.eventDel(parameters, aesKey, aesIV)
        } else {
            request = AFMRequest.placeEventDel(parameters, aesKey, aesIV)
        }
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                self.requestListWithReload()
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
        let parameters: [String: AnyObject] = [
            "event_id": campaignId as AnyObject,
            "reason": reason as AnyObject
        ]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.eventApply(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                Utility.showAlert(self, message: "活动中止申请成功，请等待审核", dismissCompletion: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: refreshTableViewWhenSuspendNotification), object: nil, userInfo: nil)
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
        let parameters: [String: AnyObject] = [
            "event_id": campaignId as AnyObject
        ]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.eventClose(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if let msg = msg, !msg.isEmpty {
                 Utility.showAlert(self, message: msg)
                return
            }
            Utility.showAlert(self, message: "结束活动成功", dismissCompletion: {
                self.requestListWithReload()
            })
        }
    }
    
    func requestStopPlaceCampaign(_ campaignId: Int) {
        
        let parameters: [String: Any] = [
            "event_id": campaignId
        ]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
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
