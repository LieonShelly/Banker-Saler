//
//  OrderLogisticsTracksViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 8/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderLogisticsTracksViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var tableViewHeader: UIView?
    
    var orderId: Int?
    
    fileprivate var trackInfoArray: [LogisticsTracksInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "物流信息"
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = UIColor.commonBgColor()
        
        tableView.register(UINib(nibName: "OrderLogisticsTracksTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderLogisticsTracksTableViewCell")

        guard orderId != nil else {
            return
        }
        
        requestTrackInfoList()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
        
    func refreshTableViewHeader(_ company: String, number: String) {
        if tableViewHeader == nil {
            tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 70))
            let descLbl = UILabel(frame: CGRect(x: 15, y: 15, width: screenWidth, height: 20))
            descLbl.tag = 10000 + 1
            descLbl.textAlignment = NSTextAlignment.left
            descLbl.font = UIFont.systemFont(ofSize: 15)
            descLbl.text = "物流公司: " + company
            descLbl.textColor = UIColor.commonTxtColor()
            tableViewHeader?.addSubview(descLbl)
            
            let descLbl2 = UILabel(frame: CGRect(x: 15, y: 35, width: screenWidth, height: 20))
        
            descLbl.tag = 10000 + 2
            descLbl2.textAlignment = NSTextAlignment.left
            descLbl2.font = UIFont.systemFont(ofSize: 15)
            descLbl2.text = "物流单号: " + number
            descLbl2.textColor = UIColor.commonTxtColor()
            tableViewHeader?.addSubview(descLbl2)
            guard let tableView = tableViewHeader else {return}
            view.addSubview(tableView)
        } else {
            guard let descLbl = tableViewHeader?.viewWithTag(10000 + 1) as? UILabel else {return}
            descLbl.text = "物流公司: " + company
            guard let descLbl2 = tableViewHeader?.viewWithTag(10000 + 2) as? UILabel else {return}
            descLbl2.text = "物流单号: " + number
        }
    }
    
    // MARK: - Http request
    
    func requestTrackInfoList() {
        Utility.showMBProgressHUDWithTxt()
        guard let orderId = orderId else {return}
        let parameters: [String: AnyObject] = [
            "order_id": orderId as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.logisticsTracks(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (request, response, object, error, _) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
                guard var result = object as? [String: AnyObject] else {return}
                if let array = result["tracks"] as? [AnyObject] {
                    for item in array {
                        guard let model = (item as? [String : AnyObject]) else {return}
                        guard let info = LogisticsTracksInfo(JSON: model) else {return}
                        self.trackInfoArray.append(info)
                    }
                }
                guard let logisticsCompany = result["logistics_company"] as? String else {return}
                guard let logisticsNo = result["logistics_no"] as? String else {return}
                
                self.refreshTableViewHeader(logisticsCompany, number: logisticsNo)
                
                self.tableView.reloadData()
            } else {
            }
            
        })
        
    }
    
    // MARK: - Button Action
    
}

extension OrderLogisticsTracksViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderLogisticsTracksTableViewCell") as? OrderLogisticsTracksTableViewCell else {return UITableViewCell()}
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
        guard let _cell = cell as? OrderLogisticsTracksTableViewCell else {return}
        let info = trackInfoArray[indexPath.row]
        _cell.config(info.acceptTime, content: info.acceptStation)
        if indexPath.row == 0 {
            _cell.willShowHighlight = true
        } else {
            _cell.willShowHighlight = false
        }
    }
}

extension OrderLogisticsTracksViewController: UITableViewDelegate {
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLbl = UILabel(frame: CGRect(x: 12, y: 7, width: 200, height: 15))
        titleLbl.text = "物流跟踪"
        titleLbl.font = UIFont.systemFont(ofSize: 14.0)
        titleLbl.textColor = UIColor.commonGrayTxtColor()
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
        titleBg.addSubview(titleLbl)
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let info = trackInfoArray[indexPath.row]
        
        let size = (info.acceptStation as NSString).boundingRect(with: CGSize(width: screenWidth - 48 - 8, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil)
        return max(77, 20 + ceil(size.height) + 37.0)
    }
    
}
