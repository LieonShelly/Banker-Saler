//
//  NotificationViewController.swift
//  FPTrade
//
//  Created by Ryuukou on 15/9/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//
// swiftlint:disable legacy_constant

import UIKit

import pop
import SDWebImage
import MBProgressHUD
import HMSegmentedControl
import SnapKit
import MJRefresh

//segment数据结构体
struct NTSegmentStruct {
    var status1: Int = 0
    var status2: Int = 0
}

//tableView数据源类
class NTTableData {
    var sysDataArray: [NotificationModel] = []
    var myDataArray: [MyNotificationModel] = []
    var currentPage: Int = 0
    var totalPage: Int = 0
}

class NotificationViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var segmentView: UIView!
    let ntTableScrollView: UIScrollView! = UIScrollView()
    var indexSelect: Int = 0
    var segmentCtrl: HMSegmentedControl?
    var ntTableViews = [UITableView]()
    var segmentStruct: SegmentStruct = SegmentStruct()
    var myNTData: NTTableData = NTTableData()
    var sysNTData: NTTableData = NTTableData()
    
    var unSysReadNotice = ""
    var unMyReadNotice = ""
    
    fileprivate var willRefreshDataWhenAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "消息中心"
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        // create segment control
        createSegmentControl()
        createTableScrollView()
        
        self.ntTableViews[0].mj_header.beginRefreshing()
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeDataSourceWhenSignOut), name: NSNotification.Name(rawValue: userSignOutNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshNotification), name: NSNotification.Name(rawValue: refreshMessageCenterItemNotification), object: nil)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if indexSelect == 0 {
            ntTableViews[0].reloadData()
        } else {
            ntTableViews[1].reloadData()
        }
        if willRefreshDataWhenAppear {
            willRefreshDataWhenAppear = false
            requestListWithReload()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommonWebViewScene@AccountSession" {
            guard let destVC = segue.destination as? CommonWebViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            if indexSelect == 0 {
                let info = self.myNTData.myDataArray[indexPath.section]
                destVC.extra = info.extra
                destVC.notice = info.content
                destVC.buttonTxt = info.buttonTxt
                destVC.time = info.created
                destVC.headTitle = info.title
                destVC.tokenEnable = true
            } else {
                let info = self.sysNTData.sysDataArray[indexPath.section]
                info.isReaded = .isRead
                destVC.extra = info.extra
                destVC.notice = info.content
                destVC.buttonTxt = info.buttonTxt
                destVC.time = info.created
                destVC.headTitle = info.title
                destVC.tokenEnable = true
            }
        }
    }
}

extension NotificationViewController {
    func createTableScrollView() {
        //set tableScrollView
        self.ntTableScrollView.delegate = self
        self.ntTableScrollView.bounces = false
        self.ntTableScrollView.isPagingEnabled = true
        self.ntTableScrollView.showsHorizontalScrollIndicator = false
        self.ntTableScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(ntTableScrollView)
        self.ntTableScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(40)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
        
        self.ntTableViews.removeAll()
        var next_table: UITableView?
        
        for index in 0 ..< 2 {
            let table = UITableView(frame: CGRect.zero, style: .grouped)
            table.delegate = self
            table.dataSource = self
            table.backgroundColor = UIColor.commonBgColor()
            table.separatorColor = UIColor.colorWithHex("#E5E5E5")
            table.rowHeight = UITableViewAutomaticDimension
            table.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
            table.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            table.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
            self.ntTableScrollView.addSubview(table)
            self.ntTableViews.append(table)
            table.snp.makeConstraints({ (make) -> Void in
                if let last = next_table {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalTo(self.ntTableScrollView.snp.leading)
                }
                make.top.equalTo(self.ntTableScrollView.snp.top)
                make.bottom.equalTo(self.ntTableScrollView.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(self.ntTableScrollView.snp.height)
                if index == 1 {
                    make.trailing.equalTo(self.ntTableScrollView.snp.trailing)
                }
            })
            next_table = table
        }
    }
    
    func createSegmentControl() {
        
        guard let segmentCtrl = HMSegmentedControl(sectionTitles: ["我的消息(0)", "系统公告(0)"]) else {return}
        self.segmentCtrl = segmentCtrl
        guard let titleTextAttributes = NSDictionary(objects: [UIColor.colorWithHex("#636F7B"), UIFont.systemFont(ofSize: 15)], forKeys: [NSForegroundColorAttributeName as NSCopying, NSFontAttributeName as NSCopying]) as? [AnyHashable: Any] else {return}
        segmentCtrl.backgroundColor = UIColor.clear
        segmentCtrl.titleTextAttributes = titleTextAttributes
        guard let selectedTitleTextAttributes = NSDictionary(object: UIColor.colorWithHex("#3198f9"), forKey: NSForegroundColorAttributeName as NSCopying) as? [String: AnyObject] else {return}
        segmentCtrl.selectedTitleTextAttributes = selectedTitleTextAttributes
        segmentCtrl.selectionIndicatorColor = UIColor.colorWithHex("#3198f9")
        segmentCtrl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.down
        segmentCtrl.selectionIndicatorHeight = 2.0
        segmentCtrl.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 40)
        segmentCtrl.addTarget(self, action: #selector(self.segmentedControlChangedValue(_:)), for: UIControlEvents.valueChanged)
        segmentView.addSubview(segmentCtrl)
        self.indexSelect = (segmentCtrl.selectedSegmentIndex)
    }
    
    func nodataBgView(_ segmentIndex: Int) -> UIView {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: ntTableScrollView.bounds.height))
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        switch segmentIndex {
        case 0:
            descLbl.text = "您暂时没收到任何消息"
        case 1:
            descLbl.text = "您暂时没收到系统公告"
        default:
            break
        }
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
        
    }
    
    func readNotice(noticeID: Int) {
        let params: [String: Any] = ["notice_id": noticeID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.readNotice(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            guard let segmentCtrl = self.segmentCtrl else {return}
            let seletedIndex = UInt(segmentCtrl.selectedSegmentIndex)
            if self.indexSelect == 0 {
                guard let unMyReadNotice = Int(self.unMyReadNotice) else {return}
                self.unMyReadNotice = "\(unMyReadNotice-1)"
                segmentCtrl.sectionTitles[0] = "我的消息(" + "\(self.unMyReadNotice)"+")"
                self.ntTableViews[0].reloadData()
            } else {
                guard let unSysReadNotice = Int(self.unSysReadNotice) else {return}
                self.unSysReadNotice = "\(unSysReadNotice-1)"
                segmentCtrl.sectionTitles[1] = "系统消息(" + "\(self.unSysReadNotice)"+")"
                self.ntTableViews[1].reloadData()
            }
            segmentCtrl.setSelectedSegmentIndex(seletedIndex, animated: true)
            
        }
        
    }
    
    func requestListWithReload() {
        requestData(.reload, params: nil)
    }
    
    func requestDoubleClickListWithReload() {
        guard let index = segmentCtrl?.selectedSegmentIndex else {return}
        let table = self.ntTableViews[index]
        table.mj_header.beginRefreshing()
    }
    
    func requestListWithAppend() {
        requestData(.append, params: nil)
    }
    
    func requestData(_ refreshType: DataRefreshType, params: [String: AnyObject]?) {
        let tab = self.indexSelect == 0 ? 1 : 2
        var parameters = params ?? (["page": "1" as AnyObject,
                                     "tab": tab as AnyObject
            ] as [String: AnyObject])
        //分页判断
        let data = judgeCurrentDataArray()
        if refreshType == .reload {
            data.currentPage = 1
            parameters["page"] = data.currentPage as AnyObject?
        } else {
            if data.currentPage < data.totalPage {
                data.currentPage += 1
                parameters["page"] = data.currentPage as AnyObject?
            } else {
                self.ntTableViews[indexSelect].mj_footer.endRefreshingWithNoMoreData()
                return
            }
        }
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        let request =  AFMRequest.noticeMyNotice(parameters, aesKey, aesIV)
        
        let index = self.indexSelect
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if let object = object {
                guard let result = object as? [String: AnyObject] else {return}
                print(result)
                switch index {
                case 0:
                    self.setFetchData(self.myNTData, pageIndex: index, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.myNTData.myDataArray.isEmpty == true {
                        self.ntTableViews[index].backgroundView = self.nodataBgView(index)
                    } else {
                        self.ntTableViews[index].backgroundView = nil
                    }
                case 1:
                    self.setFetchData(self.sysNTData, pageIndex: index, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.sysNTData.sysDataArray.isEmpty == true {
                        self.ntTableViews[index].backgroundView = self.nodataBgView(index)
                    } else {
                        self.ntTableViews[index].backgroundView = nil
                    }
                default: break
                }
                DispatchQueue.main.async {
                    guard let segmentCtrl = self.segmentCtrl else {return}
                    guard let summary = result["summary"] else {return}
                    guard let unReadNotice = summary["unread_notice"] as? String else {return}
                    guard let unReadSysNotice = summary["unread_sys_notice"] as? String else {return}
                    segmentCtrl.sectionTitles[0] = "我的消息(\(unReadNotice))"
                    segmentCtrl.sectionTitles[1] = "系统公告(\(unReadSysNotice))"
                    self.unMyReadNotice = unReadNotice
                    self.unSysReadNotice = unReadSysNotice
                    segmentCtrl.setSelectedSegmentIndex(UInt((segmentCtrl.selectedSegmentIndex)), animated: true)
                }
                self.ntTableViews[index].reloadData()
            }
            self.ntTableViews[index].mj_header.endRefreshing()
            self.ntTableViews[index].mj_footer.endRefreshing()
        }
    }
    
    func setFetchData(_ data: NTTableData, pageIndex: Int, page: Int, result: [String: AnyObject], refreshType: DataRefreshType) {
        guard let tempArray = result["items"] as? [AnyObject] else {return}
        if refreshType == .reload {
            data.myDataArray.removeAll(keepingCapacity: false)
            data.sysDataArray.removeAll(keepingCapacity: false)
        }
        if pageIndex == 0 {
            data.myDataArray += tempArray.flatMap({MyNotificationModel(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
        } else {
            data.sysDataArray += tempArray.flatMap({NotificationModel(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
        }
        data.totalPage = Int((result["total_page"] as? String) ?? "0") ?? 0
    }
    
    func segmentedControlChangedValue(_ segCtr: HMSegmentedControl) {
        self.ntTableScrollView.scrollRectToVisible(ntTableViews[segCtr.selectedSegmentIndex].frame, animated: true)
        guard let segmentCtrl = self.segmentCtrl else {return}
        indexSelect = (segmentCtrl.selectedSegmentIndex)
        //判断当前选择项数据源是否有数据
        judgeDataArray(indexSelect)
    }
    
    func removeDataSourceWhenSignOut() {
        willRefreshDataWhenAppear = true
        
        for tableData in [myNTData, sysNTData] {
            tableData.myDataArray.removeAll()
            tableData.sysDataArray.removeAll()
            tableData.currentPage = 0
            tableData.totalPage = 0
        }
        
        for table in ntTableViews {
            table.reloadData()
        }
    }
    
    func judgeCurrentDataArray() -> NTTableData {
        switch indexSelect {
        case 0: return self.myNTData
        case 1: return self.sysNTData
        default: return self.myNTData
        }
    }
    
    func judgeDataArray(_ pageIndex: Int) {
        if pageIndex == 0 {
            if myNTData.myDataArray.isEmpty {
                ntTableViews[indexSelect].mj_header.beginRefreshing()
                requestListWithReload()
            }
        } else {
            if sysNTData.sysDataArray.isEmpty {
                ntTableViews[indexSelect].mj_header.beginRefreshing()
                requestListWithReload()
            }
        }
    }
}
extension NotificationViewController: UIScrollViewDelegate {
    //ScrollView切换tableview刷新事件
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == ntTableScrollView {
            guard let segmentCtrl = self.segmentCtrl else {return}
            let contentOffsetX = scrollView.contentOffset.x
            let index = Int(contentOffsetX/UIScreen.main.bounds.width)
            segmentCtrl.setSelectedSegmentIndex(UInt(index), animated: true)
            indexSelect = (segmentCtrl.selectedSegmentIndex)
            //判断当前选择项数据源是否有数据
            judgeDataArray(indexSelect)
        }
    }

}

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        guard let nCell = cell as? NotificationTableViewCell else {
            return
        }
        
        if tableView == self.ntTableViews[0] {
            nCell.config(myNTData.myDataArray[indexPath.section])
        } else {
            nCell.config(sysNTData.sysDataArray[indexPath.section])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.ntTableViews[0] {
            return myNTData.myDataArray.count
        } else {
            return sysNTData.sysDataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func showCenterDetail(noticeString: String) {
        let vc = NoticeDetailViewController()
        vc.notice = noticeString
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.ntTableViews[0] {
            
            let model = myNTData.myDataArray[indexPath.section]
            guard let noticeID = Int(model.noticeID) else {return}
            if  model.buttonTxt == "" && model.isReaded == .unRead {
                readNotice(noticeID: noticeID)
                model.isReaded = .isRead
                return
            }
            if  model.buttonTxt == "" && model.isReaded == .isRead {
                return
            }
            if model.extra?.action == .gotoPage && model.isReaded == .isRead {
                self.showCenterDetail(noticeString: model.content )
                return
            }
            if model.extra?.action == .gotoPage && model.isReaded == .unRead {
                kApp.requestUnreadNoticeNum()
                model.isReaded = .isRead
                readNotice(noticeID: noticeID)
                showCenterDetail(noticeString: model.content )
                return
            }
            if  model.extra?.action == .showDetail && model.isReaded == .unRead {
                kApp.requestUnreadNoticeNum()
                readNotice(noticeID: noticeID)
                model.isReaded = .isRead
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: indexPath as AnyObject?)
                return
            }
            if  model.extra?.action == .showDetail && model.isReaded == .isRead {
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: indexPath as AnyObject?)
                return
            }
        } else {
            let model = sysNTData.sysDataArray[indexPath.section]
            guard let noticeID = Int(model.noticeID) else {return}
            if  model.extra?.action == .noActionType && model.isReaded == .unRead {
                kApp.requestUnreadNoticeNum()
                model.isReaded = .isRead
                readNotice(noticeID: noticeID)
                return
            }
            if  model.extra?.action == .noActionType && model.isReaded == .isRead {
                return
            }
            if  model.extra?.action != .noActionType && model.isReaded == .unRead {
                kApp.requestUnreadNoticeNum()
                model.isReaded = .isRead
                readNotice(noticeID: noticeID)
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: indexPath as AnyObject?)
                return
            }
            if  model.extra?.action != .noActionType && model.isReaded ==  .isRead {                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: indexPath as AnyObject?)
                return
            }
            
        }
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var detailTxt = ""
        var buttonText = ""
        if tableView == ntTableViews[0] {
            detailTxt = myNTData.myDataArray[indexPath.section].content
            buttonText = myNTData.myDataArray[indexPath.section].buttonTxt
            let height = detailTxt == "" ? 0 : self.getLabelHeight(string: detailTxt)
            if buttonText == "查看详情" || buttonText == "编辑商品" || buttonText == "补充库存"{
                if height == 0 {
                    return 85
                }
                return 41+height+1+10+18+17
            } else {
                return 41+height+10
            }
        } else {
            detailTxt = sysNTData.sysDataArray[indexPath.section].content
            buttonText = sysNTData.sysDataArray[indexPath.section].buttonTxt
            let height = detailTxt == "" ? 0 : self.getLabelHeight(string: detailTxt)
            if buttonText == "查看详情" || buttonText == "编辑商品" || buttonText == "补充库存"{
                if height == 0 {
                    return 85
                }
                return 41+height+1+18+10+17
            } else {
                return 41+height+10
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}

extension NotificationViewController {
    func getLabelHeight(string: String) -> CGFloat {
           return (string as NSString).boundingRect(with: CGSize(width: screenWidth - 10 - 10, height: 2000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15.0)], context: nil).size.height
    }
}

extension NotificationViewController {
    func refreshNotification() {
        requestDoubleClickListWithReload()
    }
}
