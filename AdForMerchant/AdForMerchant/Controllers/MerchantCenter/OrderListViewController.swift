//
//  OrderListViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//
//  swiftlint:disable force_unwrapping

import UIKit

class OrderListViewController: BaseViewController {
    
    var errorBlock: ((_ error: String) -> Void)?
    var successBlock: (() -> Void)?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    internal var orderStatus: OrderStatus!
    
    fileprivate var dataArray: [OrderDetail] = []
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let orderStatus = orderStatus else {return}
        switch orderStatus {
        case .waitForPay:
            navigationItem.title = "待付款的订单"
        case .waitForDelivery:
            navigationItem.title = "待发货的订单"
        case .delivered:
            navigationItem.title = "已发货的订单"
        case .refund:
            navigationItem.title = "退款的订单"
        case .failed:
            navigationItem.title = "关闭的订单"
        case .success:
            navigationItem.title = "完成的订单"
        }
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = UIColor.white
        
        tableView.register(UINib(nibName: "OrderSimpleHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderSimpleHeaderTableViewCell")
        tableView.register(UINib(nibName: "OrderFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderFooterTableViewCell")
        tableView.register(UINib(nibName: "OrderProductDescTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderProductDescTableViewCell")
        
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        tableView.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTableview), name: Notification.Name(rawValue: sendSuccessfulNotification), object: nil)
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderDetail@MerchantCenter" {
            guard let desVC = segue.destination as? OrderDetailViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            desVC.orderStatus = orderStatus
            desVC.orderDetail = dataArray[indexPath.section]
        } else if segue.identifier == "OrderDelivery@MerchantCenter" {
            guard let indexPath = sender as? IndexPath else {return}
            guard let desVC = segue.destination as? OrderDeliveryViewController else {return}
            desVC.orderDetail = dataArray[indexPath.section]
        } else if segue.identifier == "OrderLogisticsTracks@MerchantCenter" {
            guard let indexPath = sender as? IndexPath else {return}
            guard let desVC = segue.destination as? OrderLogisticsTracksViewController else {return}
            desVC.orderId = dataArray[indexPath.section].id
        }
    }
    
    // MARK: - Action
    func updateTableview() {
        self.tableView.mj_header.beginRefreshing()
    }
    
    func nodataBgView() -> UIView {
        let bgView = UIView(frame: tableView.bounds)
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        guard let orderStatus = orderStatus else {return UIView()}
        switch orderStatus {
        case .waitForPay:
            descLbl.text = "暂时没有等待买家付款的订单"
        case .waitForDelivery:
            descLbl.text = "暂时没有等待发货的订单"
        case .delivered:
            descLbl.text = "暂时没有已发货的订单"
        case .refund:
            descLbl.text = "暂时没有退款的订单"
        case .failed:
            descLbl.text = "暂时没有关闭的订单"
        case .success:
            descLbl.text = "暂时没有成功的订单"
        }
        
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
        
    }
    
    func modifyOrderPrice(_ indexPath: IndexPath) {
        let orderDetail = dataArray[indexPath.section]
        guard let alertContrller = UIStoryboard(name: "Alert", bundle: nil).instantiateInitialViewController() as? AlertViewController else {return}
        alertContrller.modalPresentationStyle = .custom
        
        alertContrller.confirmBlock = { price in
            self.requestModifyOrderPrice(Float(price) ?? 0, orderId: orderDetail.id)
        }
        alertContrller.cancelBlock = {
            alertContrller.dismiss(animated: true, completion: nil)
            self.dim(.out, coverNavigationBar: true)
        }
        
        errorBlock = { error in
            alertContrller.errorLabel.isHidden = false
            alertContrller.errorLabel.text = error
            return
        }
        successBlock = {
            alertContrller.dismiss(animated: true, completion: nil)
            self.dim(.out, coverNavigationBar: true)
        }
        
        self.dim(.in, coverNavigationBar: true)
        present(alertContrller, animated: true, completion: nil)
    }
    
    func alertTextFieldChange(textFiled: UITextField) {
        let tfString = textFiled.text ?? ""
        let stringCount = tfString.characters.count
        let nsTfString = tfString as NSString
        if tfString.contains(".") {
            if nsTfString.substring(from: stringCount-1) == "." {
            } else {
                let strlocation = nsTfString.range(of: ".")
                let decimalCount = nsTfString.substring(from: strlocation.location).characters.count
                if decimalCount >= 3 {
                    textFiled.text = nsTfString.substring(to: strlocation.location+3)
                }
            }
        }
    }
    
    // MARK: - Http Request
    
    func requestListWithReload() {
        
        requestProductsList(1)
    }
    
    func requestListWithAppend() {
        if currentPage >= totalPage {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            requestProductsList(currentPage + 1)
        }
    }
    
    func requestProductsList(_ page: Int) {
        
        let parameters: [String: AnyObject] = ["page": page as AnyObject]
        var request: AFMRequest!
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        guard let orderStatus = orderStatus else { return }
        switch orderStatus {
        case .waitForPay:
            request = AFMRequest.orderTopayList(parameters, aesKey, aesIV)
        case .waitForDelivery:
            request = AFMRequest.orderPaiedList(parameters, aesKey, aesIV)
        case .delivered:
            request = AFMRequest.orderShippedList(parameters, aesKey, aesIV)
        case .refund:
            break
        case .failed:
            request = AFMRequest.orderClosedList(parameters, aesKey, aesIV)
        case .success:
            request = AFMRequest.orderDoneList(parameters, aesKey, aesIV)
        }
        
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                guard let tempArray = result["items"] as? [AnyObject] else {return}
                self.dataArray = tempArray.flatMap({OrderDetail(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                self.currentPage = page
                self.totalPage = Int((result["total_page"] as? String) ?? "0") ?? 0
                
                if self.dataArray.isEmpty {
                    self.tableView.backgroundView = self.nodataBgView()
                } else {
                    self.tableView.backgroundView = nil
                }
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            } else {
                
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }
        }
    }
    
    func requestOrderClose(_ indexPath: IndexPath) {
        
        let orderDetail = dataArray[indexPath.section]
        
        let parameters: [String: AnyObject] = [
            "order_id": orderDetail.id as AnyObject
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderClose(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.showMBProgressHUDToastWithTxt(message!.isEmpty ? "关闭订单成功": message!)
                self.tableView.mj_header.beginRefreshing()
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }

    func requestModifyOrderPrice(_ price: Float, orderId: Int) {
        let price2 = String(format: "%.2f", price)
        let cgfloatPrice = price2.toFloat()
        
        let parameters: [String: AnyObject] = [
            "order_id": orderId as AnyObject,
            "total_price": cgfloatPrice as AnyObject
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderTopayChangePrice(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                self.dim(.out, coverNavigationBar: true)
                guard let block = self.successBlock else { return }
                block()
                Utility.showMBProgressHUDToastWithTxt(message!.isEmpty ? "修改订单成功": message!)
                self.tableView.mj_header.beginRefreshing()
            } else {
                if let msg = message {
                    guard let block = self.errorBlock else { return }
                    block(msg)
                    Utility.hideMBProgressHUD()
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestOrderDeliveryDeadlineExtend(_ indexPath: IndexPath) {
        
        let orderDetail = dataArray[indexPath.section]
        
        let parameters: [String: AnyObject] = [
            "order_id": orderDetail.id as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderShippedExtend(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.showMBProgressHUDToastWithTxt(message!.isEmpty ? "订单延迟收货成功": message!)
                self.tableView.mj_header.beginRefreshing()
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestOrderDelete(_ indexPath: IndexPath) {
        
        let orderDetail = dataArray[indexPath.section]
        
        let parameters: [String: AnyObject] = [
            "order_id": orderDetail.id as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderDelete(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.showMBProgressHUDToastWithTxt(message!.isEmpty ? "订单删除成功": message!)
                self.tableView.mj_header.beginRefreshing()
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

extension OrderListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let orderInfo = dataArray[section]
        
        switch section {
        default:
            return 1 + orderInfo.orderGoods.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let orderInfo = dataArray[indexPath.section]
        switch (indexPath.section, indexPath.row) {
        case (_, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSimpleHeaderTableViewCell", for: indexPath)
            return cell
        case (_, orderInfo.orderGoods.count + 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderFooterTableViewCell", for: indexPath)
            return cell
        case (_, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductDescTableViewCell", for: indexPath)
            return cell
        }
    }
}

extension OrderListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        
        let orderInfo = dataArray[indexPath.section]
        switch (indexPath.section, indexPath.row) {
        case (_, 0):
            guard let _cell = cell as? OrderSimpleHeaderTableViewCell else {return}
            var str = orderInfo.created.timeFormat()
            str.append("  \(orderInfo.orderNumb)")
            _cell.config("", user: orderInfo.username, otherInfo: str)
        case (_, orderInfo.orderGoods.count + 1):
            guard let _cell = cell as? OrderFooterTableViewCell else {return}
            
            let price = orderInfo.totalPrice
            
            _cell.config(productCount: Int(orderInfo.goodsCount) ?? 0, price: price, pointPrice: orderInfo.pointPrice, actualPrice: orderInfo.actualPrice, discount: orderInfo.totalDiscount, revisedPrice: orderInfo.revisedPrice)
            guard let orderStatus = self.orderStatus else {return}
            switch orderStatus {
            case .waitForPay:
                _cell.buttonTitle1 = "关闭交易"
                _cell.buttonTitle2 = "修改价格"
                _cell.buttonBlock1 = {fCell in
                    Utility.showConfirmAlert(self, message: "确认要关闭交易吗？", confirmCompletion: {
                        guard let index = self.tableView.indexPath(for: fCell) else {return}
                        self.requestOrderClose(index)
                    })
                }
                _cell.buttonBlock2 = {fCell in
                        guard let index = self.tableView.indexPath(for: fCell) else {return}
                        self.modifyOrderPrice(index)
                }
            case .waitForDelivery:
                _cell.buttonTitle1 = "去发货"
                _cell.buttonBlock1 = {fCell in
                    guard let index = self.tableView.indexPath(for: fCell) else {return}
                    AOLinkedStoryboardSegue.performWithIdentifier("OrderDelivery@MerchantCenter", source: self, sender: index)
                
                }
            case .delivered:
                _cell.buttonTitle1 = "查看物流"
                _cell.buttonTitle2 = "延迟收货"
                _cell.buttonEnable2 = orderInfo.canDeferConfirmDelivery
                _cell.buttonBlock1 = {fCell in
                    guard let index = self.tableView.indexPath(for: fCell) else {return}
                    AOLinkedStoryboardSegue.performWithIdentifier("OrderLogisticsTracks@MerchantCenter", source: self, sender: index)
                }
                if orderInfo.canDeferConfirmDelivery {
                    _cell.buttonBlock2 = {fCell in
                        Utility.showConfirmAlert(self, message: "确认要延迟收货吗？", confirmCompletion: {
                            guard let index = self.tableView.indexPath(for: fCell) else {return}
                            self.requestOrderDeliveryDeadlineExtend(index)
                        })
                    }
                } else {
                    _cell.buttonBlock2 = {fCell in
                    }
                }

                if let rStatus = orderInfo.refundStatus, rStatus == .waitingForProcess {
                    _cell.refundInfo = rStatus.desc
                } else {
                    _cell.refundInfo = ""
                }
                
            case .failed:
                _cell.buttonTitle1 = "删除订单"
                _cell.buttonBlock1 = {fCell in
                    Utility.showConfirmAlert(self, message: "确认要删除订单吗？", confirmCompletion: {
                        guard let index = self.tableView.indexPath(for: fCell) else {return}
                        self.requestOrderDelete(index)
                    })
                }
                if let rStatus = orderInfo.refundStatus, rStatus != .noInfo {
                    _cell.refundInfo = rStatus.desc
                } else {
                    _cell.refundInfo = ""
                }
            case .success:
                _cell.buttonTitle1 = "删除订单"
                _cell.buttonBlock1 = {fCell in
                    Utility.showConfirmAlert(self, message: "确认要删除订单吗？", confirmCompletion: {
                        guard let index = self.tableView.indexPath(for: fCell) else {return}
                        self.requestOrderDelete(index)
                    })
                }
                if let rStatus = orderInfo.refundStatus, rStatus == .agreed {
                    let attrTxt = NSMutableAttributedString(string: "已退款 ", attributes: [NSForegroundColorAttributeName: UIColor.commonBlueColor()])
                    let refundPriceAttrTxt = NSAttributedString(string: "退款金额:", attributes: [NSForegroundColorAttributeName: UIColor.commonTxtColor()])
                    let refundPriceAttrTxt2 = NSAttributedString(string: "￥\(orderInfo.refundAmount)", attributes: [NSForegroundColorAttributeName: UIColor.commonBlueColor()])
                    attrTxt.append(refundPriceAttrTxt)
                    attrTxt.append(refundPriceAttrTxt2)
                    _cell.refundInfoAttributedString = attrTxt
                } else {
                    _cell.refundInfoAttributedString = nil
                }
            default:
                break
            
            }
        case (_, _):
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            guard let _cell = cell as? OrderProductDescTableViewCell else {return}
            let orderGoodsIndex = indexPath.row - 1
            let productInfo = orderInfo.orderGoods[orderGoodsIndex]
            _cell.config(productInfo.thumb, title: productInfo.title, price: productInfo.price, count: productInfo.num, properList: productInfo.properList)
            
//        default:
//            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let orderInfo = dataArray[indexPath.section]
        
        switch indexPath.row {
        case 0:
            return 36
        case (orderInfo.orderGoods.count + 1):
            return ((Double(orderInfo.revisedPrice) ?? 0.0) == 0) || (Double(orderInfo.revisedPrice) ?? 0.0) == ((Double(orderInfo.totalPrice) ?? 0.0)) ? 98 : 118
        default:
            return 86
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        default:
            AOLinkedStoryboardSegue.performWithIdentifier("OrderDetail@MerchantCenter", source: self, sender: indexPath)

            break
        }
    }
}
