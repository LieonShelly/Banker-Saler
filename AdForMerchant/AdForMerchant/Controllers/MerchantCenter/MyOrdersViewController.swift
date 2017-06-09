//
//  MyOrdersViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MyOrdersViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var tableSectionOneTitles = ["待付款的订单", "待发货的订单", "已发货的订单"]
    fileprivate var tableSectionOneImages = ["MyOrderTableIconObligation", "MyOrderTableIconToBeShipped", "MyOrderTableIconShipped"]
    fileprivate var tableSectionTwoTitles = ["退款的订单", "完成的订单", "关闭的订单"]
    fileprivate var tableSectionTwoImages = ["MyOrderTableIconRefund", "MyOrderTableIconSuccess", "MyOrderTableIconOver"]
    
    fileprivate var orderCategoryCount: (waitForPay: String, waitForDelivery: String, delivered: String, refund: String, finished: String, closed: String) = ("", "", "", "", "", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "我的订单"
        
        let rightBarItem = UIBarButtonItem(title: "帮助", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showHelpPage))
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestOrderSummary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderList@MerchantCenter" {
            guard let indexPath = sender as? IndexPath else {return}
            guard let desVC = segue.destination as? OrderListViewController else {return}
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                desVC.orderStatus = .waitForPay
            case (0, 1):
                desVC.orderStatus = .waitForDelivery
            case (0, 2):
                desVC.orderStatus = .delivered
            case (1, 0):
                desVC.orderStatus = .refund
            case (1, 1):
                desVC.orderStatus = .success
            case (1, 2):
                desVC.orderStatus = .failed
            default:
                break
            }
        }
    }
    
    // MARK: - Private
    
    func showHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else {return}
        helpWebVC.requestURL = WebviewHelpDetailTag.merchantOrderNav.detailUrl
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    // MARK: - Http request
    
    func requestOrderSummary() {
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.orderSummary(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                guard let summary = object as? [String: String] else {return}
                self.orderCategoryCount.waitForPay = summary["topay_num"] ?? ""
                self.orderCategoryCount.waitForDelivery = summary["paied_num"] ?? ""
                self.orderCategoryCount.delivered = summary["shipped_num"] ?? ""
                self.orderCategoryCount.refund = summary["refund_num"] ?? ""
                self.orderCategoryCount.finished = summary["done_num"] ?? ""
                self.orderCategoryCount.closed = summary["closed_num"] ?? ""
                self.tableView.reloadData()
                
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }

}

extension MyOrdersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
//        case (0, _):
//            let cell = tableView.dequeueReusableCellWithIdentifier("OrderCountTableViewCell", forIndexPath: indexPath)
//            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCountTableViewCell", for: indexPath)
            return cell
        }
    }
}

extension MyOrdersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _cell = cell as? OrderCountTableViewCell else {return}
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            _cell.imgView.image = UIImage(named: tableSectionOneImages[indexPath.row])
            _cell.titleLbl.text = tableSectionOneTitles[indexPath.row]
            _cell.countLbl.isHidden = false
            if indexPath.row == 0 {
                _cell.countLbl.text = orderCategoryCount.waitForPay
            } else if indexPath.row == 1 {
                _cell.countLbl.text = orderCategoryCount.waitForDelivery
            } else if indexPath.row == 2 {
                _cell.countLbl.text = orderCategoryCount.delivered
            }
        case (1, _):
            _cell.imgView.image = UIImage(named: tableSectionTwoImages[indexPath.row])
            _cell.titleLbl.text = tableSectionTwoTitles[indexPath.row]
            _cell.countLbl.isHidden = false
            if indexPath.row == 0 {
                _cell.countLbl.text = orderCategoryCount.refund
            } else if indexPath.row == 1 {
                _cell.countLbl.text = orderCategoryCount.finished
            } else if indexPath.row == 2 {
                _cell.countLbl.text = orderCategoryCount.closed
            }
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("RefundOrderList@MerchantCenter", source: self, sender: indexPath)
        default:
            AOLinkedStoryboardSegue.performWithIdentifier("OrderList@MerchantCenter", source: self, sender: indexPath)
            break
        }
    }
}
