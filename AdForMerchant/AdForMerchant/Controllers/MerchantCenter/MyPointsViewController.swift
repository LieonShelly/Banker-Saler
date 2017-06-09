//
//  MyPointsViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/23/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MyPointsViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var pointsDescLabel: UILabel!
    @IBOutlet fileprivate weak var pointsLbl: UILabel!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var dataArrayGroups: [[PointBalanceDetail]] = []
    
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    fileprivate var startTime: String?
    fileprivate var endTime: String?
    fileprivate var timeSectionSelected: TimeSectionPart?
    
    fileprivate var isFilterType: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "我的积分"
        
        // Do any additional setup after loading the view.
        
        let rightBarItem = UIBarButtonItem(title: "筛选", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showTimeSectionSelectViewController))
        navigationItem.rightBarButtonItem = rightBarItem
        
        for table in [tableView] {
            
            table?.separatorColor  = table?.backgroundColor
            table?.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            table?.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        }
        
        let attrTxt = NSAttributedString(string: "帮助", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: screenWidth - 60, y: 138, width: 60, height: 32)
        btn.setAttributedTitle(attrTxt, for: UIControlState())
        btn.addTarget(self, action: #selector(self.showHelpPage), for: .touchUpInside)
        view.addSubview(btn)
        
        refreshPoints()
        refreshWhenNoData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPointsAfterCharge), name: NSNotification.Name(rawValue: "RefreshPointsAfterChargeNotification"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.mj_header.beginRefreshing()
        if !isFilterType {
            kApp.requestUserInfoWithCompleteBlock({ () in
                self.refreshPoints()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TimeSectionSelect@MerchantCenter" {
            guard let vc = segue.destination as? TimeSectionSelectViewController else {return}
            vc.startTime = startTime
            vc.endTime = endTime
            vc.navTitle = "积分明细筛选"
            if let timePart = timeSectionSelected {
                vc.timeSectionSelected = timePart
            }
            vc.completeBlock = {timePart, startTime, endTime in
                self.isFilterType = true
                self.timeSectionSelected = timePart
                if timePart == .undefined {
                    self.startTime = startTime
                    self.endTime = endTime
                }
                self.tableView.mj_header.beginRefreshing()
            }
        }
    }
    
    // MARK: - Action
    
    func showHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else {return}
        helpWebVC.requestURL = WebviewHelpDetailTag.pointRechargeNav.detailUrl
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func refreshPointsAfterCharge() {
        isFilterType = false
        timeSectionSelected = nil
        tableView.mj_header.beginRefreshing()
    }
    
    func refreshPoints(_ pointString: String? = nil) {
        if isFilterType {
            pointsDescLabel.text = "筛选积分合计"
            if let pnt = pointString {
                let pointNumber = Float(pnt) ?? 0.0
                pointsLbl.text = Utility.micrometerNumberFormatter(NSNumber(value: pointNumber))          
            }
        } else {
            pointsDescLabel.text = "当前积分"
            if let point = UserManager.sharedInstance.userInfo?.point {
                let pointNumber = Float(point) ?? 0.0
                pointsLbl.text = Utility.micrometerNumberFormatter(NSNumber(value: pointNumber))
            } else {
                pointsLbl.text = "0"
            }
        }
    }
    
    @IBAction func chargeAction(_ sender: UIButton) {
        guard let verificationStatus = UserManager.sharedInstance.userInfo?.status else {
            return
        }
        
        if verificationStatus != .verified {
            Utility.showAlert(self, message: "未绑定银行卡，请先认证")
            return
        }
        
        AOLinkedStoryboardSegue.performWithIdentifier("ChargePoints@MerchantCenter", source: self, sender: nil)
    }
    
    func showTimeSectionSelectViewController() {
        AOLinkedStoryboardSegue.performWithIdentifier("TimeSectionSelect@MerchantCenter", source: self, sender: nil)
    }
    
    // MARK: - Methods
    
    func refreshWhenNoData() {
        if dataArrayGroups.isEmpty {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    // MARK: - Http Request
    
    func requestListWithReload() {
        
        requestProductsList(1)
    }
    
    func requestListWithAppend() {
        if currentPage >= totalPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            requestProductsList(currentPage + 1)
        }
    }
    
    func requestProductsList(_ page: Int) {
        var params: [String: AnyObject] = ["page": page as AnyObject]
        if let timePart = timeSectionSelected {
            if timePart == .undefined {
                params["start"] = startTime as AnyObject?
                params["end"] = endTime as AnyObject?
            } else {
                params["range"] = timePart.rawValue as AnyObject?
            }
        }
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.pointList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                if page == 1 {
                    self.dataArrayGroups.removeAll()
                }
                
                guard let tempArray = result["items"] as? [AnyObject] else {return}
                let tempItems = tempArray.flatMap({PointBalanceDetail(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})

                var groups: [[PointBalanceDetail]] = []
                var group: [PointBalanceDetail] = []
                
                for item in tempItems {
                    if group.isEmpty || (group.last?.createdShort == item.createdShort) {
                        group.append(item)
                    } else {
                        groups.append(group)
                        group.removeAll()
                        group.append(item)
                    }
                }
                
                if !group.isEmpty {
                    groups.append(group)
                }
                
                if let lastGroup = self.dataArrayGroups.last {
                    if lastGroup.last?.createdShort == groups.first?.first?.createdShort {
                        self.dataArrayGroups[self.dataArrayGroups.count - 1] = lastGroup + groups.removeFirst()
                    }
                }
                self.dataArrayGroups += groups
                if let summary = result["summary"] as? [String: String], let point = summary["total"] {
//                    let formatMoney = Utility.currencyNumberFormatter(NSNumber(float: walletMoney))
//                    self.pointsLbl.text = point
                    self.refreshPoints(point)
                }
                
                self.currentPage = page
                self.totalPage = Int((result["total_page"] as? String) ?? "0") ?? 0
                
                self.tableView.reloadData()
                
            }
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
        }
    }
}

extension MyPointsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeOutgoingTableViewCell", for: indexPath) as? IncomeOutgoingTableViewCell else {return IncomeOutgoingTableViewCell()}
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        guard let pCell = cell as? IncomeOutgoingTableViewCell else {
            return
        }
        
        let info = dataArrayGroups[indexPath.section][indexPath.row]
        pCell.configPoint(info.title, time: info.created, point: info.point)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArrayGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArrayGroups[section].count
    }
    
}

extension MyPointsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let first = dataArrayGroups[section].first {
        
            let titleLbl = UILabel(frame: CGRect(x: 12, y: 7, width: 200, height: 15))
            titleLbl.text = first.createdShort + "积分明细"
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor.commonGrayTxtColor()
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
            titleBg.addSubview(titleLbl)
            return titleBg
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        AOLinkedStoryboardSegue.performWithIdentifier("IncomeOutgoingDetail@MerchantCenter", source: self, sender: indexPath)
    }
}
