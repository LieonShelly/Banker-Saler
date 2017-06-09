//
//  CampaignHomeViewController.swift
//  FPTrade
//
//  Created by Kuma on 10/27/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper
import pop
import SDWebImage
import MBProgressHUD
import HMSegmentedControl

class CampaignTableData {
    var saleDataArray: [CampaignInfo] = []
    var placeDataArray: [PlaceCampaignInfo] = []
    var currentPage: Int = 0
    var totalPage: Int = 0
    var totalItems: String = "0"
}

class CampaignHomeViewController: BaseViewController {
    
    let saleTableScrollView: UIScrollView! = UIScrollView()
    var saleTableViews: [UITableView] = []
    
    let placeTableScrollView: UIScrollView! = UIScrollView()
    var placeTableViews: [UITableView] = []
    
    @IBOutlet  weak var topSegmentCtrl: UISegmentedControl!
    @IBOutlet  weak var segmentView: UIView!
    
    var saleCountOfAllStatus: (String, String, String, String) = ("", "", "", "")
    var placeCountOfAllStatus: (String, String, String, String) = ("", "", "", "")
    
    var saleTableData1: CampaignTableData = CampaignTableData()
    var saleTableData2: CampaignTableData = CampaignTableData()
    var saleTableData3: CampaignTableData = CampaignTableData()
    var saleTableData4: CampaignTableData = CampaignTableData()
    var saleTableData5: CampaignTableData = CampaignTableData()
    var saleTableData6: CampaignTableData = CampaignTableData()
    
    var placeTableData1: CampaignTableData = CampaignTableData()
    var placeTableData2: CampaignTableData = CampaignTableData()
    var placeTableData3: CampaignTableData = CampaignTableData()
    var placeTableData4: CampaignTableData = CampaignTableData()
    var placeTableData5: CampaignTableData = CampaignTableData()
    var placeTableData6: CampaignTableData = CampaignTableData()
    
    var campType: CampaignType = .sale
    
    var willRefreshDataWhenAppear: Bool = false
    
    var isSuspend = false
    var seletedIndex = IndexPath()
    fileprivate lazy var refreshCoverView: UIView = {
        let refreshCoverView = UIView()
        refreshCoverView.backgroundColor = UIColor.commonBgColor()
        return refreshCoverView
    }()
    lazy var sumLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.textAlignment = .center
        tagLabel.font = UIFont.systemFont(ofSize: 12)
        tagLabel.textColor = UIColor.colorWithHex("0x9498a9")
        tagLabel.backgroundColor = UIColor.colorWithHex("0xfffbce")
        tagLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        return tagLabel
    }()
    
    lazy var titleView: PageTitleView = { [unowned self] in
        let x: CGFloat = 0
        let y: CGFloat = 0
        let height: CGFloat = self.segmentView.height
        let width: CGFloat = UIScreen.width
        let titleView = PageTitleView(frame: CGRect(x: x, y: y, width: width, height: height), titles: ["进行中", "未开始", "已结束", "审核中", "异常", "草稿"])
        titleView.backgroundColor = UIColor.white
        return titleView
        }()
    var startOffsetX: CGFloat = 0.0
    var  isForbiden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "NaviIconQRCode"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showQRScanPage))
        navigationItem.leftBarButtonItem = leftBarItem
        
        topSegmentCtrl.layer.masksToBounds = true
        topSegmentCtrl.layer.cornerRadius = 14
        topSegmentCtrl.layer.borderColor = UIColor.white.cgColor
        topSegmentCtrl.layer.borderWidth = 1.0
        topSegmentCtrl.addTarget(self, action: #selector(self.topSegmentValueChanged(_:)), for: .valueChanged)
        setupPageTitleView()
        saleTableScrollView.delegate = self
        saleTableScrollView.bounces = false
        saleTableScrollView.isPagingEnabled = true
        saleTableScrollView.showsHorizontalScrollIndicator = false
        saleTableScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(saleTableScrollView)
        saleTableScrollView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(40)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
        saleTableViews.removeAll()
        
        var next_table: UITableView?
        
        for index in 0 ..< 6 {
            let table = UITableView()
            table.delegate = self
            table.dataSource = self
            table.backgroundColor = UIColor.commonBgColor()
            table.separatorColor = UIColor.clear
            table.register(UINib(nibName: "CampaignTableViewCell", bundle: nil), forCellReuseIdentifier: "CampaignTableViewCell")
            table.register(UINib(nibName: "DoMoreFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "DoMoreFooterTableViewCell")
            // 刷新最新数据
            table.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            // 刷新更多数据
            table.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
            saleTableScrollView.addSubview(table)
            self.saleTableViews.append(table)
            
            // 促销活动的
            table.snp.makeConstraints({ (make) -> Void in
                if let last = next_table {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalTo(saleTableScrollView.snp.leading)
                }
                make.top.equalTo(saleTableScrollView.snp.top)
                make.bottom.equalTo(saleTableScrollView.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(saleTableScrollView.snp.height)
                if index == 5 {
                    make.trailing.equalTo(saleTableScrollView.snp.trailing)
                }
            })
            table.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            next_table = table
        }
        
        placeTableScrollView.delegate = self
        placeTableScrollView.bounces = false
        placeTableScrollView.isPagingEnabled = true
        placeTableScrollView.showsHorizontalScrollIndicator = false
        placeTableScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(placeTableScrollView)
        placeTableScrollView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(40)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
        placeTableViews.removeAll()
        placeTableScrollView.isHidden = true
        
        next_table = nil
        /// 现场活动
        for index in 0 ..< 6 {
            let table = UITableView()
            table.delegate = self
            table.dataSource = self
            table.backgroundColor = UIColor.commonBgColor()
            table.separatorColor = UIColor.clear
            table.register(UINib(nibName: "CampaignTableViewCell", bundle: nil), forCellReuseIdentifier: "CampaignTableViewCell")
            table.register(UINib(nibName: "DoMoreFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "DoMoreFooterTableViewCell")
            // 刷新最新数据
            table.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            // 刷新更多数据
            table.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
            placeTableScrollView.addSubview(table)
            placeTableViews.append(table)
            table.snp.makeConstraints({ (make) -> Void in
                if let last = next_table {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalTo(placeTableScrollView.snp.leading)
                }
                make.top.equalTo(placeTableScrollView.snp.top)
                make.bottom.equalTo(placeTableScrollView.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(placeTableScrollView.snp.height)
                if index == 5 {
                    make.trailing.equalTo(placeTableScrollView.snp.trailing)
                }
            })
            table.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            
            next_table = table
        }
        
        willRefreshDataWhenAppear = false
        saleTableViews[0].mj_header.beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeDataSourceWhenSignOut), name: NSNotification.Name(rawValue: userSignOutNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dataSourceNeedRefreshAfterAppear), name: NSNotification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableView), name: NSNotification.Name(rawValue: refreshTableViewWhenSuspendNotification), object: nil)
        addSumLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if willRefreshDataWhenAppear {
            willRefreshDataWhenAppear = false
            
            topSegmentCtrl.selectedSegmentIndex = 0
            topSegmentValueChanged(topSegmentCtrl)
            segmentedControlChangedValue(index: 0)
            
            //            saleTableViews[0].mj_header.beginRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "AddNewPlace@Campaign", let desVC = segue.destination as? CampaignAddNewPlaceViewController {
            desVC.modifyType = .addNew
            if let indexPath = sender as? IndexPath {
                desVC.modifyType = .edit
                switch titleView.currentIndex {
                case 0:
                    desVC.status = .inProgress
                    desVC.campInfo = placeTableData1.placeDataArray[indexPath.section]
                case 1:
                    desVC.status = .notBegin
                    desVC.campInfo = placeTableData2.placeDataArray[indexPath.section]
                case 2:
                    desVC.status = .over
                    desVC.campInfo = placeTableData3.placeDataArray[indexPath.section]
                case 3:
                    desVC.status = .inReview
                    desVC.campInfo = placeTableData4.placeDataArray[indexPath.section]
                case 4:
                    desVC.status = .exception
                    desVC.campInfo = placeTableData5.placeDataArray[indexPath.section]
                case 5:
                    desVC.status = .draft
                    desVC.campInfo = placeTableData6.placeDataArray[indexPath.section]
                default:
                    break
                }
            }
            
        } else if segue.identifier == "ProductDescInput@Product", let desVC = segue.destination as? DetailInputViewController, let indexPath = sender as? IndexPath {
            var campId = 0
            let index: Int = titleView.currentIndex
            let type = topSegmentCtrl.selectedSegmentIndex
            self.doActionWithTypeAndStatus(type, status: index) { (table, tableData) in
                if !tableData.saleDataArray.isEmpty {
                    campId = tableData.saleDataArray[indexPath.section].id
                } else {
                    campId = tableData.placeDataArray[indexPath.section].id
                }
            }
            
            desVC.navTitle = "中止活动申请"
            desVC.placeholder = "请输入中止活动的原因"
            desVC.emptyContentAlert = "请输入中止活动的原因"
            desVC.confirmBlock = { reason in
                self.requestStopCampaign(campId, reason: reason)
            }
            
        } else if segue.identifier == "AddNewSale@Campaign", let desVC = segue.destination as? CampaignAddNewSaleViewController {
            if let indexPath = sender as? IndexPath {
                desVC.modifyType = .edit
                switch titleView.currentIndex {
                case 0:
                    desVC.status = .inProgress
                    desVC.campInfo = saleTableData1.saleDataArray[indexPath.section]
                case 1:
                    desVC.status = .notBegin
                    desVC.campInfo = saleTableData2.saleDataArray[indexPath.section]
                case 2:
                    desVC.status = .over
                    desVC.campInfo = saleTableData3.saleDataArray[indexPath.section]
                case 3:
                    desVC.status = .inReview
                    desVC.campInfo = saleTableData4.saleDataArray[indexPath.section]
                case 4:
                    desVC.status = .exception
                    desVC.campInfo = saleTableData5.saleDataArray[indexPath.section]
                case 5:
                    desVC.status = .draft
                    desVC.campInfo = saleTableData6.saleDataArray[indexPath.section]
                default:
                    break
                }
            }
            
        } else if segue.identifier == "CampaignPlaceDetail@Campaign", let desVC = segue.destination as? CampaignPlaceDetailViewController, let indexPath = sender as? IndexPath {
            
            //                desVC.modifyType = ObjectModifyType(rawValue: typeValue)!
            switch titleView.currentIndex {
            case 0:
                desVC.status = .inProgress
                desVC.campInfo = placeTableData1.placeDataArray[indexPath.section]
            case 1:
                desVC.status = .notBegin
                desVC.campInfo = placeTableData2.placeDataArray[indexPath.section]
            case 2:
                desVC.status = .over
                desVC.campInfo = placeTableData3.placeDataArray[indexPath.section]
            case 3:
                desVC.status = .inReview
                desVC.campInfo = placeTableData4.placeDataArray[indexPath.section]
            case 4:
                desVC.status = .exception
                desVC.campInfo = placeTableData5.placeDataArray[indexPath.section]
            case 5:
                desVC.status = .draft
                desVC.campInfo = placeTableData6.placeDataArray[indexPath.section]
            default:
                break
            }
        } else if segue.identifier == "CampaignSaleDetail@Campaign" {
            if let indexPath = sender as? IndexPath, let desVC = segue.destination as? CampaignSaleDetailViewController {
                switch titleView.currentIndex {
                case 0:
                    desVC.status = .inProgress
                    desVC.campInfo = saleTableData1.saleDataArray[indexPath.section]
                case 1:
                    desVC.status = .notBegin
                    desVC.campInfo = saleTableData2.saleDataArray[indexPath.section]
                case 2:
                    desVC.status = .over
                    desVC.campInfo = saleTableData3.saleDataArray[indexPath.section]
                case 3:
                    desVC.status = .inReview
                    desVC.campInfo = saleTableData4.saleDataArray[indexPath.section]
                case 4:
                    desVC.status = .exception
                    desVC.campInfo = saleTableData5.saleDataArray[indexPath.section]
                case 5:
                    desVC.status = .draft
                    desVC.campInfo = saleTableData6.saleDataArray[indexPath.section]
                default:
                    break
                }
            }
        } else if segue.identifier == "CommonWebViewScene@AccountSession", let destVC = segue.destination as? CommonWebViewController {
            
            destVC.naviTitle = "预览"
            destVC.htmlContent = sender as? String
        }
    }
    
    @IBAction func addNewCampaignAction(_ sender: UIButton) {
        guard  let modalViewController = AOLinkedStoryboardSegue.sceneNamed("AddNewObject@Main") as?AddNewObjectViewController, let superView = sender.superview else {  return }
        modalViewController.dismissBtnCenter = superView.convert(sender.center, to: nil)
        modalViewController.objectInfos = [("发布促销活动", "促销活动是指，商家发起的以打折、满减等形式为主的线上商品折扣活动；", "BtnPublishIconPart0201"), ("发布现场活动", "现场活动是指，商家发起的通过平台报名、线下参与的店铺活动，例如试吃、节日趴、座谈会等等；", "BtnPublishIconPart0202")]
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
        })
        
        modalViewController.selectItemCompletionBlock = { index in
            switch index {
            case 0:
                AOLinkedStoryboardSegue.performWithIdentifier("AddNewSale@Campaign", source: self, sender: nil)
            case 1:
                AOLinkedStoryboardSegue.performWithIdentifier("AddNewPlace@Campaign", source: self, sender: nil)
            default:
                break
            }
            
        }
    }
}

extension CampaignHomeViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            return
        }
        isForbiden = false
        startOffsetX = scrollView.contentOffset.x
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        displayTag()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshWhenNoData()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        displayTag()
    }
    private func displayTag() {
        let type = topSegmentCtrl.selectedSegmentIndex
        let index: Int = titleView.currentIndex
        doActionWithTypeAndStatus(type, status: index) { (table, tableData) in
            self.disPlayCount(index: index, count: tableData.totalItems)
        }
    }
 }

extension CampaignHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CampaignTableViewCell", for: indexPath) as? CampaignTableViewCell else { return UITableViewCell()}
            cell.type = campType
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoMoreFooterTableViewCell", for: indexPath)  as?DoMoreFooterTableViewCell else { return UITableViewCell()}
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            guard let pCell = cell as? CampaignTableViewCell else {
                return
            }
            switch tableView {
            case saleTableViews[0]:
                let dataArray = saleTableData1.saleDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.config(cInfo)
            case saleTableViews[1]:
                let dataArray = saleTableData2.saleDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.config(cInfo)
            case saleTableViews[2]:
                let dataArray = saleTableData3.saleDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.config(cInfo)
            case saleTableViews[3]:
                let dataArray = saleTableData4.saleDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.config(cInfo)
            case saleTableViews[4]:
                let dataArray = saleTableData5.saleDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.config(cInfo)
            case saleTableViews[5]:
                let dataArray = saleTableData6.saleDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.config(cInfo)
            case placeTableViews[0]:
                let dataArray = placeTableData1.placeDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.status = .inProgress
                pCell.config(cInfo)
            case placeTableViews[1]:
                let dataArray = placeTableData2.placeDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.status = .notBegin
                pCell.config(cInfo)
            case placeTableViews[2]:
                let dataArray = placeTableData3.placeDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.status = .over
                pCell.config(cInfo)
            case placeTableViews[3]:
                let dataArray = placeTableData4.placeDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.status = .inReview
                pCell.config(cInfo)
            case placeTableViews[4]:
                let dataArray = placeTableData5.placeDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.status = .exception
                pCell.config(cInfo)
            case placeTableViews[5]:
                let dataArray = placeTableData6.placeDataArray
                let cInfo = dataArray[indexPath.section]
                pCell.status = .draft
                pCell.config(cInfo)
            default:
                break
            }
        } else {
            guard let pCell = cell as? DoMoreFooterTableViewCell else {
                return
            }
            switch tableView {
            case self.saleTableViews[0]:
                let dataArray = saleTableData1.saleDataArray
                let cInfo = dataArray[indexPath.section]
                
                if cInfo.stopApplyStatus == .inProgress {
                    pCell.buttonTitle5 = nil
                    pCell.buttonTitle4 = nil
                    pCell.buttonTitle3 = "预览"
                    pCell.buttonTitle2 = "中止"
                    pCell.buttonTitle1 = "分享"
                    pCell.buttonBlock3 = {fCell in
                        guard   let index = tableView.indexPath(for: fCell) else { return }
                        self.seePreview(index)
                    }
                   
                    pCell.buttonBlock2 = {fCell in
                        guard let index = tableView.indexPath(for: fCell) else { return }
                        self.campaignStop(index)
                    }
                    pCell.buttonBlock1 = {fCell in
                        guard   let index = tableView.indexPath(for: fCell) else { return }
                        self.shareItem(index)
                    }

                    pCell.rightButton1.setTitleColor(UIColor.lightGray, for: UIControlState())
                    pCell.rightButton1.layer.borderUIColor = UIColor.lightGray
                } else {
                    pCell.buttonTitle5 = nil
                    pCell.buttonTitle4 = nil
                    pCell.buttonTitle3 = "预览"
                    pCell.buttonTitle2 = "中止"
                    pCell.buttonTitle1 = "分享"
                    
                    pCell.rightButton1.setTitleColor(UIColor.colorWithHex("116FE9"), for: UIControlState())
                    pCell.rightButton1.layer.borderUIColor = UIColor.colorWithHex("116FE9")
                    
                    pCell.buttonBlock3 = {fCell in
                        guard let index = tableView.indexPath(for: fCell) else { return }
                        self.seePreview(index)
                    }
                    pCell.buttonBlock2 = {fCell in
                        guard let index = tableView.indexPath(for: fCell) else { return }
                        self.campaignStop(index)
                    }
                    pCell.buttonBlock1 = {fCell in
                        guard let index = tableView.indexPath(for: fCell) else { return }
                        self.shareItem(index)
                    }
                }
            case self.placeTableViews[0]: // 进行中
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = "预览"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock2 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.shareItem(index)
                }
            case self.saleTableViews[1]: // 未开始
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "中止"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock3 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.campaignStop(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.shareItem(index)
                }
                
            case self.placeTableViews[1]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "分享"
                pCell.buttonTitle1 = "中止"
                pCell.buttonBlock3 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.shareItem(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.campaignStop(index)
                }
            case self.saleTableViews[2], self.placeTableViews[2]: // 已结束
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = "预览"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock2 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.campaignDelete(index)
                }
            case self.saleTableViews[3]: // 审核中
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = nil
                pCell.buttonTitle1 = "预览"
                
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
            case self.placeTableViews[3]: // 审核中
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = nil
                pCell.buttonTitle1 = "预览"
                pCell.buttonBlock1 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
            case self.placeTableViews[4], self.saleTableViews[4]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "编辑"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock3 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    if tableView == self.placeTableViews[4] {
                        self.showPlaceEditViewController(index)
                    }
                    if tableView == self.saleTableViews[4] {
                        self.showSaleEditViewController(index)
                    }
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.campaignDelete(index)
                }
            case self.placeTableViews[5], self.saleTableViews[5]:
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = "编辑"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock2 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    if tableView == self.placeTableViews[5] {
                        self.showPlaceEditViewController(index)
                    }
                    if tableView == self.saleTableViews[5] {
                        self.showSaleEditViewController(index)
                    }
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.campaignDelete(index)
                }
            default:
                break
                
            }
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case saleTableViews[0]:
            return saleTableData1.saleDataArray.count
        case saleTableViews[1]:
            return saleTableData2.saleDataArray.count
        case saleTableViews[2]:
            return saleTableData3.saleDataArray.count
        case saleTableViews[3]:
            return saleTableData4.saleDataArray.count
        case saleTableViews[4]:
            return saleTableData5.saleDataArray.count
        case saleTableViews[5]:
            return saleTableData6.saleDataArray.count
        case placeTableViews[0]:
            return placeTableData1.placeDataArray.count
        case placeTableViews[1]:
            return placeTableData2.placeDataArray.count
        case placeTableViews[2]:
            return placeTableData3.placeDataArray.count
        case placeTableViews[3]:
            return placeTableData4.placeDataArray.count
        case placeTableViews[4]:
            return placeTableData5.placeDataArray.count
        case placeTableViews[5]:
            return placeTableData6.placeDataArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension CampaignHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 4.0
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 130.0
        } else {
            return 45.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if campType == .sale {
            AOLinkedStoryboardSegue.performWithIdentifier("CampaignSaleDetail@Campaign", source: self, sender: indexPath as AnyObject?)
        } else {
            AOLinkedStoryboardSegue.performWithIdentifier("CampaignPlaceDetail@Campaign", source: self, sender: indexPath as AnyObject?)
            
        }
    }
}

extension CampaignHomeViewController {
    fileprivate func addSumLabel() {
        view.insertSubview(refreshCoverView, aboveSubview: saleTableViews[0])
        refreshCoverView.addSubview(sumLabel)
        refreshCoverView.snp.makeConstraints({make in
            make.height.equalTo(30)
            make.left.equalTo(0)
            make.top.equalTo(segmentView.frame.maxY)
            make.right.equalTo(0)
        })
        
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
}
