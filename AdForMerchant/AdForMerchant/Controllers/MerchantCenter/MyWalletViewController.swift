//
//  MyWalletViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/23/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class MyWalletViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var walletLbl: UILabel!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
        
    fileprivate var dataArrayGroups: [[IncomeDetail]] = []
    
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    fileprivate var startTime: String?
    fileprivate var endTime: String?
    fileprivate var timeSectionSelected: TimeSectionPart?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "我的收入"
        
        let rightBarItem = UIBarButtonItem(title: "筛选", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showTimeSectionSelectViewController))
        navigationItem.rightBarButtonItem = rightBarItem
        guard let money = UserManager.sharedInstance.userInfo?.money else {return}
        guard let walletMoney = Float(money) else {return}
        let formatMoney = Utility.currencyNumberFormatter(NSNumber(value: walletMoney))
        walletLbl.text = formatMoney
        
        for table in [tableView] {
            table?.separatorColor = table?.backgroundColor
            table?.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            table?.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        }

        refreshWhenNoData()
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
            vc.navTitle = "收入明细筛选"
            if let timePart = timeSectionSelected {
                vc.timeSectionSelected = timePart
            }
            vc.completeBlock = {timePart, startTime, endTime in
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
    
    @IBAction func withdrawAction(_ sender: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("Withdraw@MerchantCenter", source: self, sender: nil)
    }
    
    func showTimeSectionSelectViewController() {
        AOLinkedStoryboardSegue.performWithIdentifier("TimeSectionSelect@MerchantCenter", source: self, sender: nil)
    }
    // MARK: Methods
    
    func refreshWhenNoData() {
        if dataArrayGroups.isEmpty {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    // MARK: - Http Request
    
    func requestListWithReload() {
        
        requestIncomeList(1)
    }
    
    func requestListWithAppend() {
        if currentPage >= totalPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            requestIncomeList(currentPage + 1)
        }
    }
    
    func requestIncomeList(_ page: Int) {
        var params: [String : Any] = ["page": page]
        if let timePart = timeSectionSelected {
            if timePart == .undefined {
                params["start"] = startTime
                params["end"] = endTime
            } else {
                params["range"] = timePart.rawValue
            }
        }
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.moneyList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: Any] {
                if page == 1 {
                    self.dataArrayGroups.removeAll()
                }
                
                guard let tempArray = result["items"] as? [AnyObject] else { return }                
                let tempItems = tempArray.flatMap({IncomeDetail(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                var groups: [[IncomeDetail]] = []
                var group: [IncomeDetail] = []
                
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
                
                if let summary = result["summary"] as? [String: String], let income = summary["total"], let walletMoney = Float(income) {
                    let formatMoney = Utility.currencyNumberFormatter(NSNumber(value: walletMoney))
                    self.walletLbl.text = formatMoney
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

extension MyWalletViewController: UITableViewDataSource {
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
        pCell.config(info.categoryName + info.title, time: info.created, amount: info.amount)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArrayGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArrayGroups[section].count
    }
    
}

extension MyWalletViewController: UITableViewDelegate {
    
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
            titleLbl.text = first.createdShort + "收入明细"
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
