//
//  AdHomeViewController.swift
//  FPTrade
//
//  Created by Kuma on 10/27/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//
// swiftlint:disable type_body_length

import UIKit

import pop
import SDWebImage
import MBProgressHUD
import HMSegmentedControl
import SnapKit
import MJRefresh

//segment数据结构体
struct ADSegmentStruct {
    var status1: Int = 0
    var status2: Int = 0
    var status3: Int = 0
}

//tableView数据源类
class AdTableData {
    var dataArray: [AdModel] = []
    var currentPage: Int = 0
    var totalPage: Int = 0
    var totalItems: String = "0"
}

class AdHomeViewController: BaseViewController {
    @IBOutlet fileprivate weak var segmentView: UIView!
    let tableScrollView: UIScrollView! = UIScrollView()
    var adTableViews = [UITableView]()
    var segmentStruct: SegmentStruct = SegmentStruct()
    var ongoingData: AdTableData = AdTableData()
    var endedData: AdTableData = AdTableData()
    var auditData: AdTableData = AdTableData()
    var exceptionData: AdTableData = AdTableData()
    var draftData: AdTableData = AdTableData()
    var adInfo: AdModel = AdModel()
    
    fileprivate var willRefreshDataWhenAppear: Bool = false
    fileprivate  lazy var sumLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.textAlignment = .center
        tagLabel.font = UIFont.systemFont(ofSize: 12)
        tagLabel.textColor = UIColor.colorWithHex("0x9498a9")
        tagLabel.backgroundColor = UIColor.colorWithHex("0xfffbce")
        tagLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        return tagLabel
    }()
    fileprivate lazy var refreshCoverView: UIView = {
        let refreshCoverView = UIView()
        refreshCoverView.backgroundColor = UIColor.commonBgColor()
        return refreshCoverView
    }()
    lazy var titleView: PageTitleView = { [unowned self] in
        let x: CGFloat = 0
        let y: CGFloat = 0
        let height: CGFloat = self.segmentView.height
        let width: CGFloat = UIScreen.width
        let titleView = PageTitleView(frame: CGRect(x: x, y: y, width: width, height: height), titles: ["进行中", "已结束", "审核中", "异常", "草稿"])
        titleView.backgroundColor = UIColor.white
        return titleView
        }()
    var startOffsetX: CGFloat = 0.0
    var  isForbiden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "NaviIconQRCode"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showQRScanPage))
        navigationItem.leftBarButtonItem = leftBarItem
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
//        createSegmentControl()
        createTableScrollView()
        
        adTableViews[0].mj_header.beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeDataSourceWhenSignOut), name: NSNotification.Name(rawValue: userSignOutNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dataSourceNeedRefreshAfterAppear), name: NSNotification.Name(rawValue: dataSourceNeedRefreshWhenAdChangedNotification), object: nil)
        addSumLabel()
        setupPageTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if willRefreshDataWhenAppear {
            willRefreshDataWhenAppear = false
            adTableViews[titleView.currentIndex].mj_header.beginRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdAddNew@Ad" {
            guard let desVC = segue.destination as? AdAddNewViewController else {return}
            if let type = sender as? Int {
                guard let adType = AdType(rawValue: type) else {return}
                desVC.adType = adType
            } else if let indexPath = sender as? IndexPath {
                let tableData = judgeCurrentDataArray()
                let ad = tableData.dataArray[indexPath.section]
                guard let type = Int(ad.type) else {return}
                guard let adType = AdType(rawValue: type) else {return}
                desVC.adType = adType
                desVC.adID = ad.adID
                desVC.modifyType = .edit
                if titleView.currentIndex == 4 {
                    desVC.isEditDraftAd = true
                } 
            }
        } else if segue.identifier == "AdDetail@Ad" {
            guard let desVC = segue.destination as? AdDetailViewController else {return}
            let tableData = judgeCurrentDataArray()
            if let indexPath = sender as? IndexPath {
                let aID = tableData.dataArray[indexPath.section].adID
                desVC.adID = aID
            }
        } else if segue.identifier == "CommonWebViewScene@AccountSession" {
            guard let destVC = segue.destination as? CommonWebViewController else {return}
            destVC.htmlContent = sender as? String
            destVC.naviTitle = "广告详情"
            destVC.isFixedTitle = true
        }
    }
    
    @IBAction func addNewAdAction(_ sender: UIButton) {
        
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("AddNewObject@Main") as? AddNewObjectViewController else {return}
        guard let senderView = sender.superview else {return}
        modalViewController.dismissBtnCenter = senderView.convert(sender.center, to: nil)
        modalViewController.objectInfos = [("发布网页广告", nil, "BtnPublishIconPart0303"), ("发布视频广告", nil, "BtnPublishIconPart0302"), ("发布图片广告", nil, "BtnPublishIconPart0301")]
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
        
        modalViewController.selectItemCompletionBlock = { index in
            switch index {
            case 0:
                AOLinkedStoryboardSegue.performWithIdentifier("AdAddNew@Ad", source: self, sender: AdType.webpage.rawValue as AnyObject?)
            case 1:
                AOLinkedStoryboardSegue.performWithIdentifier("AdAddNew@Ad", source: self, sender: AdType.movie.rawValue as AnyObject?)
            case 2:
                AOLinkedStoryboardSegue.performWithIdentifier("AdAddNew@Ad", source: self, sender: AdType.picture.rawValue as AnyObject?)
            default:
                break
            }
            
        }
    }
    
}

extension AdHomeViewController {
    
    func nodataBgView(_ segmentIndex: Int) -> UIView {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableScrollView.bounds.height))
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        switch segmentIndex {
        case 0:
            descLbl.text = "暂时没有进行中的广告，请点“+”发布"
        case 1:
            descLbl.text = "暂时没有已结束的广告"
        case 2:
            descLbl.text = "暂时没有审核中的广告"
        case 3:
            descLbl.text = "没有异常的广告"
        case 4:
            descLbl.text = "没有草稿的广告"
        default:
            break
        }
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
        
    }
    
    func requestListWithReload() {
        requestData(.reload, params: nil)
    }
    
    func requestDoubleClickListWithReload() {
        let index = titleView.currentIndex
        let table = self.adTableViews[index]
        table.mj_header.beginRefreshing()
    }
    
    func requestListWithAppend() {
        requestData(.append, params: nil)
    }
    
    func requestData(_ refreshType: DataRefreshType, params: [String: Any]?) {
        //如果是审核 0-待审核 1-进行中 2-已结束 3-异常
        var parameters = [String: Any]()
        
        var status: Int = 0
        switch titleView.currentIndex {
        case 0: // 进行中
            status = 1
        case 1: // 已结束
            status = 2
        case 2: // 审核
            status = 0
        case 3: // 异常
            status = 3
        case 4:
            status = 4 //
        default:
            break
        }

        parameters = params ?? ["status": status, "page": "1"]
        //分页判断
        let data = judgeCurrentDataArray()
        if refreshType == .reload {
            data.currentPage = 1
            parameters["page"] = data.currentPage
        } else {
            if data.currentPage < data.totalPage {
                data.currentPage += 1
                parameters["page"] = data.currentPage
            } else {
                self.adTableViews[titleView.currentIndex].mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
        }
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.adIndex(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if let object = object {
                guard let result = object as? [String: AnyObject] else {return}
                switch self.titleView.currentIndex {
                case 0:
                    self.setFetchData(self.ongoingData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.ongoingData.dataArray.isEmpty {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                    } else {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前进行的广告数量为:\(self.ongoingData.totalItems)", tableView:self.adTableViews[self.titleView.currentIndex] )
                case 1:
                    self.setFetchData(self.endedData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.endedData.dataArray.isEmpty {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                    } else {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前已结束的广告数量为:\(self.endedData.totalItems)", tableView:self.adTableViews[self.titleView.currentIndex] )
                case 2:
                    self.setFetchData(self.auditData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.auditData.dataArray.isEmpty {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                    } else {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前审核中的广告数量为:\(self.auditData.totalItems)", tableView:self.adTableViews[self.titleView.currentIndex] )
                case 3:
                    self.setFetchData(self.exceptionData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.exceptionData.dataArray.isEmpty {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                    } else {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前异常的广告数量为:\(self.exceptionData.totalItems)", tableView:self.adTableViews[self.titleView.currentIndex] )
                case 4:
                    self.setFetchData(self.draftData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.draftData.dataArray.isEmpty {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                    } else {
                        self.adTableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前草稿的数量为:\(self.draftData.totalItems)", tableView:self.adTableViews[self.titleView.currentIndex] )
                default: break
                }
                self.adTableViews[self.titleView.currentIndex].reloadData()
                self.adTableViews[self.titleView.currentIndex].mj_header.endRefreshing()
                self.adTableViews[self.titleView.currentIndex].mj_footer.endRefreshing()
            } else {
                self.adTableViews[self.titleView.currentIndex].mj_header.endRefreshing()
                self.adTableViews[self.titleView.currentIndex].mj_footer.endRefreshing()
            }
        }
    }
    
    func setFetchData(_ data: AdTableData, page: Int, result: [String: AnyObject], refreshType: DataRefreshType) {
        guard let tempArray = result["items"] as? [AnyObject] else {return}
        if refreshType == .reload {
            data.dataArray.removeAll(keepingCapacity: false)
        }
        data.dataArray += tempArray.flatMap({AdModel(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
        data.totalPage = Int((result["total_page"] as? String) ?? "0") ?? 0
        data.totalItems = (result["total_items"] as? String) ?? "0"
    }
    
}

extension AdHomeViewController {
    
    func showQRScanPage() {
        
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ScanQR@Main") as? QRViewController else {return}
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
    }
    
    func stopAd(_ indexPath: IndexPath) {
        
        let proID = judgeCurrentDataArray().dataArray[indexPath.section].adID
        let params = ["ad_id": proID]
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
                self.requestListWithReload()
            })
            
        })
    }
    
    func deleteAd(_ indexPath: IndexPath) {
        
        let proID = judgeCurrentDataArray().dataArray[indexPath.section].adID
        let params = ["ad_id": proID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        let alertController = UIAlertController(title: "提示", message: "是否确认删除该广告", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (alert) in
            Utility.showMBProgressHUDWithTxt()
            RequestManager.request(AFMRequest.adDel(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) in
                Utility.hideMBProgressHUD()
                if object == nil {
                    if let msg = msg {
                        Utility.showAlert(self, message: msg)
                    }
                    return
                }
                self.requestListWithReload()
            })
        })
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func editAd(_ indexPath: IndexPath) {
        AOLinkedStoryboardSegue.performWithIdentifier("AdAddNew@Ad", source: self, sender: indexPath as AnyObject?)
    }
    
    func removeDataSourceWhenSignOut() {
        willRefreshDataWhenAppear = true
        
        for tableData in [ongoingData, endedData, auditData] {
            tableData.dataArray.removeAll()
            tableData.currentPage = 0
            tableData.totalPage = 0
        }
        
        for table in self.adTableViews {
            table.reloadData()
        }
    }
    
    func dataSourceNeedRefreshAfterAppear(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Int] {
            guard  let status = AdStatus(rawValue: userInfo["AdStatus"]!) else {return}
            switch status {
            case .inProgress:
                segmentedControlChangedValue(index: 0)
            case .closed:
                segmentedControlChangedValue(index: 1)
            case .waitingForReview:
                segmentedControlChangedValue(index: 2)
            case .exception:
                segmentedControlChangedValue(index: 3)
            case .draft:
                segmentedControlChangedValue(index: 4)
            }
            
        } else {
            
        }
        
        willRefreshDataWhenAppear = true
    }
    
    func segmentedControlChangedValue(index: Int) {
        titleView.setTitle(progress: 1, sourceIndex: titleView.currentIndex, targetIndex: index)
        tableScrollView.scrollRectToVisible(adTableViews[index].frame, animated: true)
        //判断当前选择项数据源是否有数据
        switch index {
        case 0: judgeDataArray(self.ongoingData)
        case 1: judgeDataArray(self.endedData)
        case 2: judgeDataArray(self.auditData)
        case 3: judgeDataArray(self.exceptionData)
        case 4: judgeDataArray(self.draftData)
        default: break
        }
        
    }
    
    func seePreview(_ indexPath: IndexPath) {
        let adID = judgeCurrentDataArray().dataArray[indexPath.section].adID
        
        let params = ["ad_id": adID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.adPreview(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if object == nil {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            } else {
                guard let result = object as? [String: AnyObject] else {return}
                guard let html = result["html"] as? String else {return}
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html)
            }
        }
    }
    
    func shareItem(_ indexPath: IndexPath) {
        let info = judgeCurrentDataArray().dataArray[indexPath.section]
        
        let shareVC = ShareViewController()
        shareVC.shareTitle = info.title
        shareVC.shareDetailLink = info.shareUrl
        shareVC.shareItems = [.wechatFriends, .wechatCircle, .qqFriends, .copyLink]
        shareVC.transitioningDelegate = shareVC
        shareVC.modalPresentationStyle = .custom
        navigationController?.present(shareVC, animated: true, completion: nil)
    }
    
    func judgeCurrentDataArray() -> AdTableData {
        //判断当前选择项数据源是否有数据
        switch titleView.currentIndex {
        case 0: return self.ongoingData
        case 1: return self.endedData
        case 2: return self.auditData
        case 3: return self.exceptionData
        case 4: return self.draftData
        default: return self.ongoingData
        }
    }
    
    func judgeDataArray(_ data: AdTableData) {
        requestListWithReload()
        //        if data.dataArray.isEmpty {
        //            self.adTableViews[indexSelect - 1].mj_header.beginRefreshing()
        //            requestListWithReload()
        //        }
    }
    
    func createTableScrollView() {
        //set tableScrollView
        self.tableScrollView.delegate = self
        self.tableScrollView.bounces = false
        self.tableScrollView.isPagingEnabled = true
        self.tableScrollView.showsHorizontalScrollIndicator = false
        self.tableScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableScrollView)
        self.tableScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(40)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
        
        self.adTableViews.removeAll()
        var next_table: UITableView?
        
        for index in 0 ..< 5 {
            let table = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
            table.delegate = self
            table.dataSource = self
            table.backgroundColor = UIColor.commonBgColor()
            table.separatorColor = table.backgroundColor
            table.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: "AdTableViewCell")
              table.register(UINib(nibName: "5SAdTableViewCell", bundle: nil), forCellReuseIdentifier: "5SAdTableViewCell")
            table.register(UINib(nibName: "DoMoreFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "DoMoreFooterTableViewCell")
            table.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            table.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
            self.tableScrollView.addSubview(table)
            self.adTableViews.append(table)
            table.snp.makeConstraints({ (make) -> Void in
                if let last = next_table {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalTo(self.tableScrollView.snp.leading)
                }
                make.top.equalTo(self.tableScrollView.snp.top)
                make.bottom.equalTo(self.tableScrollView.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(self.tableScrollView.snp.height)
                if index == 4 {
                    make.trailing.equalTo(self.tableScrollView.snp.trailing)
                }
            })
            table.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            next_table = table
        }
    }
    
}

extension AdHomeViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("******scrollViewWillBeginDragging*****")
        if scrollView.contentOffset.y != 0 {
            return
        }
        isForbiden = false
        startOffsetX = scrollView.contentOffset.x
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("******scrollViewDidScroll*****")
        if scrollView.contentOffset.y != 0 {
            return
        }
        if isForbiden {
            return
        }
        let currentOffsetX = scrollView.contentOffset.x
        var targetIndex: Int = 0
        var sourceIndex: Int = 0
        var progress: CGFloat = 0.0
        let titleCount: Int = 6
        let scrollViewWidth = scrollView.frame.width
        if currentOffsetX > startOffsetX {
            progress = currentOffsetX / scrollViewWidth - floor(currentOffsetX / scrollViewWidth)
            sourceIndex = Int(currentOffsetX / scrollViewWidth)
            targetIndex = sourceIndex + 1
            
            if targetIndex >= titleCount {
                targetIndex = titleCount - 1
            }
            if currentOffsetX - startOffsetX == scrollViewWidth {
                progress = 1
                targetIndex = sourceIndex
            }
        } else {
            progress = 1 - currentOffsetX/scrollViewWidth  + floor(currentOffsetX / scrollViewWidth)
            targetIndex = Int(currentOffsetX / scrollViewWidth)
            sourceIndex = targetIndex + 1
            if sourceIndex >= titleCount {
                sourceIndex = titleCount - 1
            }
        }
        titleView.setTitle(progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
        displayTag(index: targetIndex)
    }
    
    fileprivate func displayTag(index: Int) {
        switch index {
        case 0:
            showSumLabelNoAnimation(text: "您当前进行中的广告数量为:\(self.ongoingData.totalItems)")
        case 1:
            showSumLabelNoAnimation(text: "您当前已结束的广告数量为:\(self.endedData.totalItems)")
        case 2:
            showSumLabelNoAnimation(text: "您当前审核中的广告数量为:\(self.auditData.totalItems)")
        case 3:
            showSumLabelNoAnimation(text: "您当前异常的广告数量为:\(self.exceptionData.totalItems)")
        case 4:
            showSumLabelNoAnimation(text: "您当前草稿的数量为:\(self.exceptionData.totalItems)")
        default:
            break
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("******scrollViewDidEndScrollingAnimation*****")
        let contentOffsetX = scrollView.contentOffset.x
        let index = Int(contentOffsetX/UIScreen.main.bounds.width)
           displayTag(index: index)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("******scrollViewDidEndDecelerating*****")
        if scrollView == tableScrollView {
            let contentOffsetX = scrollView.contentOffset.x
            let index = Int(contentOffsetX/UIScreen.main.bounds.width)
            //判断当前选择项数据源是否有数据
            switch index {
            case 0: judgeDataArray(self.ongoingData)
            showSumLabelNoAnimation(text: "您当前进行中的广告数量为:\(self.ongoingData.totalItems)")
            case 1: judgeDataArray(self.endedData)
            showSumLabelNoAnimation(text: "您当前已结束的广告数量为:\(self.endedData.totalItems)")
            case 2: judgeDataArray(self.auditData)
            showSumLabelNoAnimation(text: "您当前审核中的广告数量为:\(self.auditData.totalItems)")
            case 3: judgeDataArray(self.auditData)
            showSumLabelNoAnimation(text: "您当前异常的广告数量为:\(self.exceptionData.totalItems)")
            case 4: judgeDataArray(self.draftData)
            showSumLabelNoAnimation(text: "您当前草稿的数量为:\(self.draftData.totalItems)")
            default: break
            }
        }
    }
}

extension AdHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if iphone5 {
                guard let cell = Bundle.main.loadNibNamed("AdTableViewCell", owner: self, options: nil)?.last as? AdTableViewCell else {return UITableViewCell()}
                return cell
            } else {
                guard let cell = Bundle.main.loadNibNamed("AdTableViewCell", owner: self, options: nil)?.first as? AdTableViewCell else {return UITableViewCell()}
                return cell    
            }
      
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoMoreFooterTableViewCell", for: indexPath) as? DoMoreFooterTableViewCell else {return UITableViewCell()}
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            guard let pCell = cell as? AdTableViewCell else {
                return
            }
            if tableView.isEqual(adTableViews[0]) {
                if self.ongoingData.dataArray.count > indexPath.section {
                    self.adInfo = self.ongoingData.dataArray[indexPath.section]
                }
            }
            if tableView.isEqual(adTableViews[1]) {
                if self.endedData.dataArray.count > indexPath.section {
                    self.adInfo = self.endedData.dataArray[indexPath.section]
                }
            }
            if tableView.isEqual(adTableViews[2]) {
                if self.auditData.dataArray.count > indexPath.section {
                    self.adInfo = self.auditData.dataArray[indexPath.section]
                }
            }
            if tableView.isEqual(adTableViews[3]) {
                if self.exceptionData.dataArray.count > indexPath.section {
                    self.adInfo = self.exceptionData.dataArray[indexPath.section]
                }
            }
            if tableView.isEqual(adTableViews[4]) {
                if self.draftData.dataArray.count > indexPath.section {
                    self.adInfo = self.draftData.dataArray[indexPath.section]
                }
            }
            pCell.config(self.adInfo)
            
        } else {
            guard let pCell = cell as? DoMoreFooterTableViewCell else {
                return
            }
            switch tableView {
            case self.adTableViews[0]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "中止"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock3 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.seePreview(index)
                }
                
                pCell.buttonBlock2 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.stopAd(index)
                }
                pCell.buttonBlock1 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.shareItem(index)
                }
            case self.adTableViews[1]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = "预览"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock2 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.seePreview(index)
                }
                pCell.buttonBlock1 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.deleteAd(index)
                }
            case self.adTableViews[2]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = nil
                pCell.buttonTitle1 = "预览"
                pCell.buttonBlock1 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.seePreview(index)
                }
            case self.adTableViews[3]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "编辑"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock3 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.editAd(index)
                }
                pCell.buttonBlock1 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.deleteAd(index)
                }
            case self.adTableViews[4]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = "编辑"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock2 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.editAd(index)
                }
                pCell.buttonBlock1 = { fCell in
                    guard let index = tableView.indexPath(for: fCell) else {return}
                    self.deleteAd(index)
                }
            default:
                break
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case self.adTableViews[0]:
            return ongoingData.dataArray.count
        case self.adTableViews[1]:
            return endedData.dataArray.count
        case self.adTableViews[2]:
            return auditData.dataArray.count
        case self.adTableViews[3]:
            return exceptionData.dataArray.count
        case self.adTableViews[4]:
            return draftData.dataArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension AdHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 75.0
        } else {
            return 45.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AOLinkedStoryboardSegue.performWithIdentifier("AdDetail@Ad", source: self, sender: indexPath as AnyObject?)
    }
}

extension AdHomeViewController {
    fileprivate func addSumLabel() {
        view.insertSubview(refreshCoverView, aboveSubview: adTableViews[0])
        refreshCoverView.snp.makeConstraints({make in
            make.height.equalTo(30)
            make.left.equalTo(0)
            make.top.equalTo(segmentView.frame.maxY)
            make.right.equalTo(0)
        })
        refreshCoverView.addSubview(sumLabel)
        sumLabel.snp.makeConstraints({make in
            make.height.equalTo(30)
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.right.equalTo(0)
        })
        
    }
    
    func showSumLabel(text: String, tableView: UITableView) {
        DispatchQueue.main.async {
            self.sumLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.5) {
                self.sumLabel.text = text
                let select = tableView
                select.setContentOffset(CGPoint(x: 0, y: -30), animated: false)
                self.sumLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func showSumLabelNoAnimation(text: String) {
        sumLabel.text = text
    }
    
   fileprivate func setupPageTitleView() {
        segmentView.addSubview(titleView)
        titleView.titleTapAction = {  [unowned self] selectedIndex in
            self.displayTag(index: selectedIndex)
            self.isForbiden = true
            self.tableScrollView.scrollRectToVisible(self.adTableViews[selectedIndex].frame, animated: true)
            self.requestListWithReload()
        }
    }
}
