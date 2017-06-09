//
//  OrderDetailViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/24/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderDetailViewController: BaseViewController {
    
    var errorBlock: ((_ error: String) -> Void)?
    var successBlock: (() -> Void)?
    
    @IBOutlet fileprivate weak var bottomBtnBottomConstr: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomBtn: UIButton!
    
    fileprivate var addressTxt: String {
       return "\(orderDetail.username), \(orderDetail.mobile), \(orderDetail.address), \(orderDetail.postcode)(邮编), \(orderDetail.name)(收)"
    }
    fileprivate var orderInfoGenerated: String = ""
    fileprivate var deliveryTxt: String {
        return "物流公司：\(orderDetail.logisticsCompany)\n运单编号：\(orderDetail.logisticsNumb)"
    }
    
    internal var orderStatus: OrderStatus = .waitForPay
    
    var orderDetail: OrderDetail! = OrderDetail()
    
    var orderId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "订单详情"
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "NavIconMore"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doMoreAction))
        navigationItem.rightBarButtonItem = rightBarItem
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = UIColor.commonBgColor()
        
        tableView.register(UINib(nibName: "OrderSimpleHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderSimpleHeaderTableViewCell")
        tableView.register(UINib(nibName: "OrderSimpleFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderSimpleFooterTableViewCell")
        tableView.register(UINib(nibName: "OrderProductDescTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderProductDescTableViewCell")
        tableView.register(UINib(nibName: "OrderAddressDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderAddressDetailTableViewCell")
        tableView.register(UINib(nibName: "OrderDescTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderDescTableViewCell")
        
        bottomBtn.isHidden = true
        
//        bottomBtn.addTarget(self, action: #selector(self.bottomButtonClicked), forControlEvents: .TouchUpInside)
        
        requestOrderDetail()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        switch orderStatus {
        default:
            bottomBtnBottomConstr.constant = -49
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductDescInput@Product" {
            guard let desVC = segue.destination as? DetailInputViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            
            switch (indexPath.section, indexPath.row) {
            case (3, _):
                desVC.navTitle = "输入商品名称"
            case (4, _):
                desVC.navTitle = "输入商品描述"
            default:
                break
            }
            
        } else if segue.identifier == "OrderDelivery@MerchantCenter" {
            
            guard let desVC = segue.destination as? OrderDeliveryViewController else {return}
            desVC.orderDetail = orderDetail
        } else if segue.identifier == "OrderDelivery@MerchantCenter" {
            guard let desVC = segue.destination as? OrderDeliveryViewController else {return}
            desVC.orderDetail = orderDetail
        } else if segue.identifier == "OrderLogisticsTracks@MerchantCenter" {
            guard let desVC = segue.destination as? OrderLogisticsTracksViewController else {return}
            desVC.orderId = orderDetail.id
        }

    }
    
    // MARK: - Private
    
    func generateOrderInfo() {
        switch orderStatus {
        case .waitForPay:
            orderInfoGenerated = "订单编号：\(orderDetail.orderNumb)\n" +
                "创建时间：\(orderDetail.created)"
        case .waitForDelivery:
            orderInfoGenerated = "订单编号：\(orderDetail.orderNumb)\n" +
                "付款交易号：\(orderDetail.payNumb)\n" +
                "创建时间：\(orderDetail.created)\n" +
                "付款时间：\(orderDetail.payTime)"
        case .delivered:
            orderInfoGenerated = "订单编号：\(orderDetail.orderNumb)\n" +
                "付款交易号：\(orderDetail.payNumb)\n" +
                "创建时间：\(orderDetail.created)\n" +
                "付款时间：\(orderDetail.payTime)\n" +
                "发货时间：\(orderDetail.shipTime)\n" +
                "自动确认收货时间：\(orderDetail.arrivalDeadline)\n"
        case .success:
            if orderDetail.refundItems.first?.refundStatus == .agreed {
                guard let first = orderDetail.refundItems.first else {return}
                orderInfoGenerated = "订单编号：\(orderDetail.orderNumb)\n" +
                    "付款交易号：\(orderDetail.payNumb)\n" +
                    "创建时间：\(orderDetail.created)\n" +
                    "付款时间：\(orderDetail.payTime)\n" +
                    "发货时间：\(orderDetail.shipTime)\n" +
                    "完成时间：\(first.dealTime)"
            } else {
                orderInfoGenerated = "订单编号：\(orderDetail.orderNumb)\n" +
                    "付款交易号：\(orderDetail.payNumb)\n" +
                    "创建时间：\(orderDetail.created)\n" +
                    "付款时间：\(orderDetail.payTime)\n" +
                    "发货时间：\(orderDetail.shipTime)\n" +
                    "自动确认收货时间：\(orderDetail.arrivalDeadline)\n" +
                    "成交时间：\(orderDetail.arrivalTime)"
            }
            
        case .failed:
            orderInfoGenerated = "订单编号：\(orderDetail.orderNumb)\n" +
                "创建时间：\(orderDetail.created)\n" +
                "关闭时间：\(orderDetail.closeTime)"
        default:
            orderInfoGenerated = "订单编号：\(orderDetail.orderNumb)\n" +
                "创建时间：\(orderDetail.created)\n" +
                "关闭时间：\(orderDetail.closeTime)\n"
        }
        
    }

    // MARK: - Button Action
    func bottomButtonClicked() {
        AOLinkedStoryboardSegue.performWithIdentifier("OrderDelivery@MerchantCenter", source: self, sender: nil)

    }
    
    func modifyOrderPrice() {
//        let alertContrller = UIAlertController(title: "修改订单总价", message: nil, preferredStyle: .alert)
//        alertContrller.addTextField { (textField) in
//            textField.addTarget(self, action: #selector(self.alertTextFieldChange(textFiled:)), for: .editingChanged)
//        }
//        alertContrller.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
//        alertContrller.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
//            if let textField = alertContrller.textFields?.first {
//                self.requestModifyOrderPrice(Float(textField.text ?? "0") ?? 0, orderId: self.orderDetail.id)
//            }
//        }))
        guard let alertContrller = UIStoryboard(name: "Alert", bundle: nil).instantiateInitialViewController() as? AlertViewController else {return}
        alertContrller.modalPresentationStyle = .custom
        
        alertContrller.confirmBlock = { price in
              self.requestModifyOrderPrice(Float(price) ?? 0, orderId: self.orderDetail.id)
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
    
    func doMoreAction() {
        let modalViewController = NavPopoverViewController()
        modalViewController.offsetY = 69
        
        switch orderStatus {
        case .waitForPay:
            modalViewController.itemInfos = [("PopoverIconMoney", "修改价格"), ("PopoverIconClose", "关闭交易")]
        case .waitForDelivery:
            modalViewController.itemInfos = [("PopoverIconDelivery", "去发货")]
        case .delivered:
            modalViewController.itemInfos = [("PopoverIconDelay", "延迟收货"), ("PopoverIconLogistics", "查看物流")]
        case .success:
            modalViewController.itemInfos = [("PopoverIconDelete", "删除订单")]
        case .failed:
            modalViewController.itemInfos = [("PopoverIconDelete", "删除订单")]
        default:
            break
        }
        
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        modalViewController.selectItemCompletionBlock = {(index: Int) -> Void in
            self.doNavAction(index)
        }
        self.navigationController?.present(modalViewController, animated: true, completion: { () -> Void in
        })
    }
    
    ///  pop Action
    ///
    ///  - parameter index: pop Index
    func doNavAction(_ index: Int) {
        
        switch (orderStatus, index) {
        case (.waitForPay, 0)://修改价格
                self.modifyOrderPrice()
        case (.waitForPay, 1): //关闭交易
            Utility.showConfirmAlert(self, message: "确认要关闭交易吗？", confirmCompletion: {
                self.requestOrderClose()
            })
        case (.waitForDelivery, 0): //去发货
            AOLinkedStoryboardSegue.performWithIdentifier("OrderDelivery@MerchantCenter", source: self, sender: nil)
        case (.delivered, 0): //延迟收货
            Utility.showConfirmAlert(self, message: "确认要延迟收货吗？", confirmCompletion: {
                self.requestOrderDeliveryDeadlineExtend()
            })
        case (.delivered, 1): //查看物流
            AOLinkedStoryboardSegue.performWithIdentifier("OrderLogisticsTracks@MerchantCenter", source: self, sender: nil)
        case (.success, 0), (.failed, 0): //删除订单
            Utility.showConfirmAlert(self, message: "确认要删除订单吗？", confirmCompletion: {
                self.requestOrderDelete()
            })
        default:
            break
        }
    }
    
    // MARK: - Http request
    func requestOrderDetail() {
        let parameters: [String: AnyObject] = [
            "order_id": orderId as AnyObject? ?? orderDetail.id as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderDetail(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            Utility.hideMBProgressHUD()
            if let object = object as? [String: Any] {
                self.orderDetail = Mapper<OrderDetail>().map(JSON: object)
                if let status = self.orderDetail.status {
                    self.orderStatus = status
                }
                self.generateOrderInfo()
                self.tableView.reloadData()
            }
        }
    }
    
    func requestOrderClose() {
        
        let parameters: [String: Any] = [
            "order_id": orderDetail.id
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderClose(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let message = message else {return}
                Utility.showAlert(self, message: message.isEmpty ? "关闭订单成功": message, dismissCompletion: {
                    self.requestOrderDetail()
                })
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
        let parameters: [String: Any] = [
            "order_id": orderId,
            "total_price": price
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderTopayChangePrice(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let msg = message else {return}
                self.dim(.out, coverNavigationBar: true)
                guard let block = self.successBlock else { return }
                block()
                Utility.showAlert(self, message: msg.isEmpty ? "修改订单成功": msg, dismissCompletion: {
                    self.requestOrderDetail()
                })
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
    
    func requestOrderDeliveryDeadlineExtend() {
        
        let parameters: [String: Any] = [
            "order_id": orderDetail.id
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderShippedExtend(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let msg = message else {return}
                Utility.showAlert(self, message: msg.isEmpty ? "订单延迟收货成功": msg, dismissCompletion: {
                    self.requestOrderDetail()
                })
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestOrderDelete() {
        let parameters: [String: Any] = [
            "order_id": orderDetail.id
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderDelete(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let msg = message else {return}
                Utility.showAlert(self, message: msg.isEmpty ? "订单删除成功": msg, dismissCompletion: {
                    self.requestOrderDetail()
                })
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

extension OrderDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch orderStatus {
        case .waitForPay, .waitForDelivery, .failed:
            return 3
        case .delivered:
            if orderDetail.refundItems.isEmpty == false {
                return 5
            } else {
                return 4
            }
        case .success:
            if orderDetail.refundItems.isEmpty == false {
                return 5
            } else {
                return 4
            }
        default:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 + orderDetail.orderGoods.count + 1
        case 4:
            return orderDetail.refundItems.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSimpleHeaderTableViewCell", for: indexPath)
            guard let _cell = cell as? OrderSimpleHeaderTableViewCell else {return UITableViewCell()}
            _cell.config("", user: orderDetail.username, otherInfo: orderDetail.orderNumb)
            _cell.rightTxtLabel.text = orderStatus.desc
            _cell.rightTxtLabel.textColor = UIColor.commonBlueColor()
            return cell
        case (0, orderDetail.orderGoods.count + 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSimpleFooterTableViewCell", for: indexPath)
            guard let _cell = cell as? OrderSimpleFooterTableViewCell else {return UITableViewCell()}
            if orderDetail.refundItems.first?.refundStatus == .agreed {
                _cell.config(productCount: Int(orderDetail.goodsCount) ?? 0, price: orderDetail.totalPrice, pointPrice: orderDetail.pointPrice, actualPrice: orderDetail.actualPrice, discount: orderDetail.totalDiscount, refundAmount: orderDetail.refundAmount, revisedPrice: orderDetail.revisedPrice)
            } else {
                _cell.config(productCount: Int(orderDetail.goodsCount) ?? 0, price: orderDetail.totalPrice, pointPrice: orderDetail.pointPrice, actualPrice: orderDetail.actualPrice, discount: orderDetail.totalDiscount, revisedPrice: orderDetail.revisedPrice)
            }
            return cell
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductDescTableViewCell", for: indexPath)
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            guard let _cell = cell as? OrderProductDescTableViewCell else {return UITableViewCell()}
            
            let orderGoodsIndex = indexPath.row - 1
            let productInfo = orderDetail.orderGoods[orderGoodsIndex]
            _cell.config(productInfo.thumb, title: productInfo.title, price: productInfo.price, count: productInfo.num, properList:productInfo.properList )
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderAddressDetailTableViewCell", for: indexPath)
            guard let _cell = cell as? OrderAddressDetailTableViewCell else {return UITableViewCell()}
            _cell.txtView.text = addressTxt
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDescTableViewCell", for: indexPath)
            
            guard let _cell = cell as? OrderDescTableViewCell else {return UITableViewCell()}
            _cell.txtLabel.text = orderInfoGenerated
            
            return cell
        case (3, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDescTableViewCell", for: indexPath)
            guard let _cell = cell as? OrderDescTableViewCell else {return UITableViewCell()}
            
            _cell.txtLabel.text = deliveryTxt
            
            return cell
        case (4, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDescTableViewCell", for: indexPath)
            
            return cell

        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .default, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
}

extension OrderDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        guard let orderDetail = orderDetail else {return}
        switch (indexPath.section, indexPath.row) {
        case (4, _):
            let refundInfo = orderDetail.refundItems[indexPath.row]
            guard let _cell = cell as? OrderDescTableViewCell else {return}
            let refundAmount = "￥\(refundInfo.refundAmount)\n"
            let normalAttributes = [NSForegroundColorAttributeName: UIColor.commonGrayTxtColor(), NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]
            let blueAttributes = [NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]
            
            let attrTxt = NSMutableAttributedString(string: "退款金额：", attributes: normalAttributes)
            let refundAttrTxt = NSAttributedString(string: refundAmount, attributes: blueAttributes)
            attrTxt.append(refundAttrTxt)
            
            let otherTxt = ([OrderRefundStatus.agreed, OrderRefundStatus.rejected].contains(refundInfo.refundStatus)) ?
                ("订单金额：￥\(refundInfo.totalPrice)\n" +
                    "退款申请日期：\(refundInfo.applyTime)\n" +
                    "退款处理日期：\(refundInfo.dealTime)\n" +
                    "处理状态：\(refundInfo.refundStatus.desc)")
                :
                ("订单金额：￥\(refundInfo.totalPrice)\n" +
                    "退款申请日期：\(refundInfo.applyTime)\n" +
                    "处理状态：\(refundInfo.refundStatus.desc)")
            
            let otherAttrTxt = NSAttributedString(string: otherTxt, attributes: normalAttributes)
            attrTxt.append(otherAttrTxt)
            _cell.txtLabel.attributedText = attrTxt
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else if section == 1 {
            return CGFloat.leastNormalMagnitude
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let titleLbl = UILabel(frame: CGRect(x: 12, y: 7, width: 200, height: 15))
            titleLbl.text = "订单信息"
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor.commonGrayTxtColor()
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
            titleBg.addSubview(titleLbl)
            return titleBg
        } else if section == 3 {
            let titleLbl = UILabel(frame: CGRect(x: 12, y: 7, width: 200, height: 15))
            titleLbl.text = "物流信息"
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor.commonGrayTxtColor()
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
            titleBg.addSubview(titleLbl)
            return titleBg
        } else if section == 4 {
            let titleLbl = UILabel(frame: CGRect(x: 12, y: 7, width: 200, height: 15))
            titleLbl.text = "退款信息"
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor.commonGrayTxtColor()
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
            titleBg.addSubview(titleLbl)
            return titleBg
        }
        
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 36
        case (0, orderDetail.orderGoods.count + 1):
            if orderDetail.refundItems.first?.refundStatus == .agreed {
                return 70
            } else {
                return ((Double(orderDetail.revisedPrice) ?? 0.0) == 0) || ((Double(orderDetail.revisedPrice) ?? 0.0) == ((Double(orderDetail.totalPrice) ?? 0.0))) ? 60 : 70
            }
        case (0, _):
            return 86
        case (1, 0):
            let size = (addressTxt as NSString).boundingRect(with: CGSize(width: screenWidth - 38 - 10 - 8 - 10, height: 1000.0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil)
            return max(50, ceil(size.height) + 33.0)
        case (2, 0):
            let size = (orderInfoGenerated as NSString).boundingRect(with: CGSize(width: screenWidth - 12 * 2, height: 1000.0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil)
            return max(40, ceil(size.height) + 13 * 2)
        case (3, 0):
            let size = (deliveryTxt as NSString).boundingRect(with: CGSize(width: screenWidth - 12 * 2, height: 1000.0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil)
            return max(40, ceil(size.height) + 13 * 2)
        case (4, _):
            let refundInfo = orderDetail.refundItems[indexPath.row]
            if ([OrderRefundStatus.agreed, OrderRefundStatus.rejected].contains(refundInfo.refundStatus)) {
                return 112
            } else {
                return 95
            }
        default:
            return 46
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
