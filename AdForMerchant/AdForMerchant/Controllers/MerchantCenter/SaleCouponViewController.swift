//
//  SaleCouponViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 4/6/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class SaleCouponTableViewCell: UITableViewCell {
    
    @IBOutlet internal var contentLabel: UILabel!
    @IBOutlet internal var moneyLabel: UILabel!
    
    @IBOutlet internal var userImageView: UIImageView!
    @IBOutlet internal var userNameLabel: UILabel!
    @IBOutlet internal var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        rightTxtLabel.hidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(_ info: SaleCouponInfo) {
        contentLabel.text = info.title
        if let price = Float(info.price) {
            moneyLabel.text = Utility.currencyNumberFormatter(NSNumber(value: price as Float))
        }
        userImageView.image = UIImage(named: "OrderIconUserGray")
        userNameLabel.text = info.name
        timeLabel.text = info.usedTime
    }
}

class SaleCouponViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    fileprivate var dataArray: [SaleCouponInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "消费券记录"
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = tableView.backgroundColor
        
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        tableView.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        
        tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Transition
    
    func animationControllerForPresentedController(_ presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShopProductMovePresentingAnimator()
    }
    
    func animationControllerForDismissedController(_ dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShopProductMoveDismissingAnimator()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Button Action
    
    // MARK: - Methods
    
    func nodataBgView() -> UIView {// type: 0 系统，1 个人
        let bgView = UIView(frame: tableView.bounds)
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        descLbl.text = "暂时还没有消费券记录"
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
        
    }
    
    // MARK: - Http request
    
    func requestListWithAppend() {
        requestListData(.append)
    }
    
    func requestListWithReload() {
        requestListData(.reload)
    }
    
    func requestListData(_ refreshType: DataRefreshType) {
        var parameters: [String: Any] = [:]
        parameters["page"] = (refreshType == .append) ? (currentPage + 1) : 1
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showNetworkActivityIndicator()
        RequestManager.request(AFMRequest.couponList(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else {return}
                guard let page = result["current_page"] as? String else {return}
                guard let currentPage = Int(page) else {return}
                self.currentPage = currentPage
                if refreshType == .reload {
                    self.dataArray.removeAll()
                }
                if let couponList = result["items"] as? [Any] {
                    for coupon in couponList {
                        if let obj = coupon as? [String: Any], let info = Mapper<SaleCouponInfo>().map(JSON: obj) {
                            self.dataArray.append(info)
                        }
                    }
                }
                
                if self.dataArray.isEmpty == true {
                    self.tableView.backgroundView = self.nodataBgView()
                } else {
                    self.tableView.backgroundView = nil
                }
                
                self.tableView.reloadData()
                
            }
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            Utility.hideNetworkActivityIndicator()
        }
    }
    
}

extension SaleCouponViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dataArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SaleCouponTableViewCell", for: indexPath) as? SaleCouponTableViewCell else {return UITableViewCell()}
            
            let info = dataArray[indexPath.row]
            
            cell.config(info)
            
            return cell
        }
    }
}

extension SaleCouponViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        let _cell = cell as! ShopProductCategorySelectionCell
//        let cateInfo = dataArray[indexPath.row]
//        
//        _cell.isCategorySelected = (Int(cateInfo.catId) == selectedCategoryId)
//        
//        _cell.config(cateInfo.catName, count: "\(cateInfo.goodsNumb)")
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        let cateInfo = dataArray[indexPath.row]
//        selectedCategoryId = Int(cateInfo.catId) ?? 0
//        tableView.reloadData()
        
    }
}
