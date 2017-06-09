//
//  ProductRelatedCampaignViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 6/17/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductRelatedCampaignViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
        
    fileprivate var saleDataArray: [CampaignInfo] = []
    
    internal var productId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "参与活动"
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = tableView.backgroundColor
        tableView.register(UINib(nibName: "CampaignTableViewCell", bundle: nil), forCellReuseIdentifier: "CampaignTableViewCell")
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListData")
        
        requestListData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Private
    
    // MARK: - Http request
    
    func requestListData() {
        var parameters: [String: AnyObject] = [:]
        var request: AFMRequest!
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        parameters["goods_id"] = productId as AnyObject?
        
        request = AFMRequest.goodsEvents(parameters, aesKey, aesIV)
        
        Utility.showNetworkActivityIndicator()
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else { return }
                
                self.saleDataArray.removeAll()
                
                if let campaignList = result["events"] as? [Any] {
                    for campaign in campaignList {
                        if let obj = campaign as? [String: Any], let camp = Mapper<CampaignInfo>().map(JSON: obj) {
                            self.saleDataArray.append(camp)
                        }
                    }
                }
                
            }
            
            self.endTableViewRefresh()
            Utility.hideNetworkActivityIndicator()
        }
    }
    
    func endTableViewRefresh() {
        tableView.reloadData()
        tableView.mj_header.endRefreshing()
    }
}

extension ProductRelatedCampaignViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CampaignTableViewCell", for: indexPath) as? CampaignTableViewCell else { return UITableViewCell()}
        cell.type = .sale
        cell.willShowCountLabel = false
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        guard let pCell = cell as? CampaignTableViewCell else {
            return
        }
        let cInfo = saleDataArray[indexPath.section]
        pCell.config(cInfo)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return saleDataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}

extension ProductRelatedCampaignViewController: UITableViewDelegate {
    
    //    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return UITableViewAutomaticDimension
    //    }
    
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
    
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
