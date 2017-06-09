//
//  RefundOrderListViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import HMSegmentedControl

class RefundOrderListViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableView2: UITableView!
    
    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet fileprivate weak var segmentView: UIView!
    @IBOutlet fileprivate weak var leadingConstr: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableViewWidthConstr: NSLayoutConstraint!
    
    fileprivate var itemsCount: (String, String) = ("", "")

    var segIndex: NSInteger = 0
    var segmentCtrl: HMSegmentedControl?
    
//    internal var titleStr: String!
    
    fileprivate var dataArray: [RefundOrderInfo] = []
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    fileprivate var dataArray2: [RefundOrderInfo] = []
    fileprivate var currentPage2: Int = 0
    fileprivate var totalPage2: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "退款的订单"
        
        let panGes = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGestrueAction(_:)))
        view.addGestureRecognizer(panGes)
        for table in [tableView, tableView2] {
            table?.backgroundColor = UIColor.commonBgColor()
//            table.separatorColor = UIColor.clearColor()
            table?.separatorColor = UIColor.white
            
            table?.register(UINib(nibName: "OrderSimpleHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderSimpleHeaderTableViewCell")
            table?.register(UINib(nibName: "OrderFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderFooterTableViewCell")
            table?.register(UINib(nibName: "OrderProductDescTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderProductDescTableViewCell")
            
            table?.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            table?.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        }
        
        createSegmentControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.mj_header.beginRefreshing()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableViewWidthConstr.constant = self.view.frame.size.width
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RefundOrderDetail@MerchantCenter" {
            guard let desVC = segue.destination as? RefundOrderDetailViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            if segIndex == 0 {
                let orderDetail = dataArray[indexPath.section]
                desVC.orderId = orderDetail.orderId
                desVC.refundId = orderDetail.id
                desVC.isInProgress = true
            } else {
                let orderDetail = dataArray2[indexPath.section]
                desVC.orderId = orderDetail.orderId
                desVC.refundId = orderDetail.id
                desVC.isInProgress = false
            }
            
        }
    }
    
    // MARK: - Initial Views
    
    func createSegmentControl() {
        guard let segmentCtrl = HMSegmentedControl(sectionTitles: ["申请中()", "已处理()"]) else {return}
        self.segmentCtrl = segmentCtrl
        segmentCtrl.backgroundColor = UIColor.clear
        segmentCtrl.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.colorWithHex("#636F7B"), NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
        segmentCtrl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.colorWithHex("#3198f9")]
        segmentCtrl.selectionIndicatorColor = UIColor.colorWithHex("#3198f9")
        segmentCtrl.selectionIndicatorLocation = .down
        segmentCtrl.selectionIndicatorHeight = 2.0
        segmentCtrl.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 40)
        segmentCtrl.addTarget(self, action: #selector(self.segmentedControlChangedValue(_:)), for: UIControlEvents.valueChanged)
        segmentView.addSubview(segmentCtrl)
    }
    
    func panGestrueAction(_ pan: UIPanGestureRecognizer) {
        let horizontalOffset = pan.translation(in: pan.view).x
        let velocity = pan.velocity(in: pan.view).x
        let width = self.view.frame.size.width
        guard let seletedIndex = self.segmentCtrl?.selectedSegmentIndex else {return}
        switch pan.state {
        case UIGestureRecognizerState.began:
            pan.setTranslation(CGPoint.zero, in: pan.view)
        case UIGestureRecognizerState.changed:
            self.leadingConstr.constant = -CGFloat(self.segIndex) * width + horizontalOffset
            self.view.layoutIfNeeded()
        case UIGestureRecognizerState.ended:
            if fabs(horizontalOffset) > width * 0.5 || fabs(velocity) > 1000.0 {
                if horizontalOffset > 0 {
                    self.moveToPageIndex(seletedIndex - 1)
                } else {
                    self.moveToPageIndex(seletedIndex + 1)
                }
            } else {
                self.moveToPageIndex(seletedIndex)
            }
            pan.setTranslation(CGPoint.zero, in: pan.view)
        case UIGestureRecognizerState.cancelled:
            pan.setTranslation(CGPoint.zero, in: pan.view)
        default:
            break
        }
    }

    func nodataBgView(_ segmentIndex: Int) -> UIView {// type: 0 系统，1 个人
        let bgView = UIView(frame: tableView.bounds)
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        switch segmentIndex {
        case 0:
            descLbl.text = "暂时没有退款申请中的订单"
        case 1:
            descLbl.text = "暂时没有退款已处理的订单"
        default:
            break
        }
        
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
        
    }
    
    // MARK: Methods
    
    func segmentedControlChangedValue(_ segCtr: HMSegmentedControl) {
        moveToPageIndex(segCtr.selectedSegmentIndex)
        //        requestData(.Reload)
        refreshWhenNoData()
    }
    
    //判断当前选择数据源是否有数据-没有数据则请求
    func refreshWhenNoData() {
        
        guard let index: Int = (segmentCtrl?.selectedSegmentIndex) else {return}
        
        if index == 0 && dataArray.isEmpty {
            tableView.mj_header.beginRefreshing()
        } else if index == 1 && dataArray2.isEmpty {
            tableView2.mj_header.beginRefreshing()
        }
        
    }
    
    func moveToPageIndex(_ pageIndex: NSInteger) {
        let width: CGFloat = self.view.frame.size.width
        
        if pageIndex != self.segIndex {
            if pageIndex > 3 || pageIndex < 0 {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.leadingConstr.constant = -CGFloat(self.segIndex) * width
                    self.view.layoutIfNeeded()
                })
                return
            }
            
            if self.segmentCtrl?.selectedSegmentIndex != pageIndex {
                self.segmentCtrl?.setSelectedSegmentIndex(UInt(pageIndex), animated: true)
            }
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.leadingConstr.constant = -CGFloat(pageIndex) * width
                self.view.layoutIfNeeded()
                self.segIndex = pageIndex
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.leadingConstr.constant = -CGFloat(self.segIndex) * width
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func refreshSegmentTitles() {

        DispatchQueue.main.async(execute: { () -> Void in
            self.segmentCtrl?.sectionTitles[0] = "申请中(\(self.itemsCount.0))"
            self.segmentCtrl?.sectionTitles[1] = "已处理(\(self.itemsCount.1))"
            self.segmentCtrl?.setSelectedSegmentIndex(UInt((self.segmentCtrl?.selectedSegmentIndex) ?? 0), animated: false)
        })
    }
    
    // MARK: - Http Request
    
    func requestListWithReload() {
        
        requestProductsList(1)
    }
    
    func requestListWithAppend() {
        if segIndex == 0 {
            if currentPage >= totalPage {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                requestProductsList(currentPage + 1)
            }
        } else {
            if currentPage2 >= totalPage2 {
                self.tableView2.mj_footer.endRefreshingWithNoMoreData()
            } else {
                requestProductsList(currentPage2 + 1)
            }
        }
    }
    
    func requestProductsList(_ page: Int) {
        let segmentIndex = segIndex
        let parameters: [String: AnyObject] = ["page": page as AnyObject]
        var request: AFMRequest!
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        switch segIndex {
        case 0:
            request = AFMRequest.orderRefundingList(parameters, aesKey, aesIV)
        case 1:
            request = AFMRequest.orderDealedList(parameters, aesKey, aesIV)
        default:
            break
        }
        
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                guard let tempArray = result["items"] as? [AnyObject] else {return}
                
                if let count1 = result["summary"]!["refunding_num"] as? String,
                    let count2 = result["summary"]!["dealed_num"] as? String {
                    self.itemsCount = (count1, count2)
                    self.refreshSegmentTitles()
                }
                
                if segmentIndex == 0 {
                    self.dataArray = tempArray.flatMap({RefundOrderInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                    self.currentPage = page
                    guard let page = result["total_page"] as? String else {return}
                    guard let totalpage = Int(page) else {return}
                    self.totalPage = totalpage
                    
                    if self.dataArray.isEmpty {
                        self.tableView.backgroundView = self.nodataBgView(0)
                    } else {
                        self.tableView.backgroundView = nil
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.mj_footer.endRefreshing()
                } else {
                    self.dataArray2 = tempArray.flatMap({RefundOrderInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                    self.currentPage2 = page
                    guard let page = result["total_page"] as? String else {return}
                    guard let totalpage = Int(page) else {return}
                    self.totalPage2 = totalpage
                    
                    if self.dataArray2.isEmpty {
                        self.tableView2.backgroundView = self.nodataBgView(1)
                    } else {
                        self.tableView2.backgroundView = nil
                    }
                    
                    self.tableView2.reloadData()
                    self.tableView2.mj_header.endRefreshing()
                    self.tableView2.mj_footer.endRefreshing()
                }
            } else {
                if segmentIndex == 0 {
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.mj_footer.endRefreshing()
                } else {
                    
                    self.tableView2.mj_header.endRefreshing()
                    self.tableView2.mj_footer.endRefreshing()
                }
            }
        }
    }
    
    func requestOrderDelete(_ indexPath: IndexPath) {
        
        let refundOrder = dataArray2[indexPath.section]
        
        let parameters: [String: Any] = [
            "refund_id": refundOrder.id
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderRefundDelete(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.showMBProgressHUDToastWithTxt(message?.isEmpty ?? true ? "退款记录删除成功": message ?? "")
                self.requestListWithReload()
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestOrderRefund(_ willAgree: Bool, indexPath: IndexPath) {
        
        let refundOrder = dataArray[indexPath.section]
        
        let parameters: [String: AnyObject] = [
            "refund_id": refundOrder.id as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        let requset = willAgree ? AFMRequest.orderRefundAgree(parameters, aesKey, aesIV) : AFMRequest.orderRefundReject(parameters, aesKey, aesIV)
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(requset, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                if willAgree {
                    Utility.showMBProgressHUDToastWithTxt(message?.isEmpty ?? false ? "订单同意退款成功": message ?? "")
                } else {
                    Utility.showMBProgressHUDToastWithTxt(message?.isEmpty ?? false ? "订单拒绝退款成功": message ?? "")
                }
                self.requestListWithReload()
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

extension RefundOrderListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return dataArray.count
        } else {
            return dataArray2.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let orderInfo = (tableView == self.tableView) ? dataArray[section] : dataArray2[section]
        switch section {
        default:
            return 1 + orderInfo.orderGoods.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderInfo = (tableView == self.tableView) ? dataArray[indexPath.section] : dataArray2[indexPath.section]
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

extension RefundOrderListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        let orderInfo = (tableView == self.tableView) ? dataArray[indexPath.section] : dataArray2[indexPath.section]

        switch (indexPath.section, indexPath.row) {
        case (_, 0):
            guard let _cell = cell as? OrderSimpleHeaderTableViewCell else {return}
            var str = orderInfo.created.timeFormat()
            str.append("  \(orderInfo.orderNumb)")
            _cell.config("", user: orderInfo.username, otherInfo: str)
        case (_, orderInfo.orderGoods.count + 1):
            guard let _cell = cell as? OrderFooterTableViewCell else {return}
            if tableView == self.tableView {
                let price = orderInfo.totalPrice
                _cell.config(productCount: Int(orderInfo.goodsCount) ?? 0, price: price, pointPrice: orderInfo.pointPrice, actualPrice: orderInfo.actualPrice, discount: orderInfo.totalDiscount, revisedPrice: orderInfo.revisedPrice)
                
                let attrTxt = NSMutableAttributedString(string: "退款金额:", attributes: [NSForegroundColorAttributeName: UIColor.commonTxtColor()])
                let refundPriceAttrTxt = NSAttributedString(string: "￥\(orderInfo.refundAmount)", attributes: [NSForegroundColorAttributeName: UIColor.commonBlueColor()])
                attrTxt.append(refundPriceAttrTxt)
                
                if let _ = _cell.buttonBlock1 {} else {
                    _cell.buttonTitle1 = "拒绝退款"
                    _cell.buttonTitle2 = "同意退款"
                    _cell.buttonBlock1 = {fCell in
                        Utility.showConfirmAlert(self, message: "是否拒绝客户的本次退款？", confirmCompletion: {
                            guard let index = self.tableView.indexPath(for: fCell) else {return}
                            self.requestOrderRefund(false, indexPath: index)
                        })
                    }
                    _cell.buttonBlock2 = {fCell in
                        Utility.showConfirmAlert(self, message: "确定已收到买家退货， 以免财货两空。现在同意该笔退款？", confirmCompletion: {
                            guard let index = self.tableView.indexPath(for: fCell) else {return}
                            self.requestOrderRefund(true, indexPath: index)
                        })
                    }
                }
                if orderInfo.refundStatus != .noInfo {
                    _cell.refundInfoAttributedString = attrTxt
                } else {
                    _cell.refundInfoAttributedString = nil
                }
            } else {
                let price = orderInfo.totalPrice
                _cell.config(productCount: Int(orderInfo.goodsCount) ?? 0, price: price, pointPrice: orderInfo.pointPrice, actualPrice: orderInfo.actualPrice, discount: orderInfo.totalDiscount, revisedPrice: orderInfo.revisedPrice)
                
                let attrTxt = NSMutableAttributedString(string: orderInfo.refundStatus.desc, attributes: [NSForegroundColorAttributeName: UIColor.commonBlueColor()])
                let attrTxtPart1 = NSAttributedString(string: " 退款金额:", attributes: [NSForegroundColorAttributeName: UIColor.commonTxtColor()])
                attrTxt.append(attrTxtPart1)
                let refundPriceAttrTxt = NSAttributedString(string: orderInfo.refundAmount, attributes: [NSForegroundColorAttributeName: UIColor.commonBlueColor()])
                attrTxt.append(refundPriceAttrTxt)
                
                if let _ = _cell.buttonBlock1 {} else {
                    _cell.buttonTitle1 = "删除订单"
                    _cell.buttonBlock1 = {fCell in
                        Utility.showConfirmAlert(self, message: "是否确认删除本条退款处理信息？", confirmCompletion: {
                            guard let index = self.tableView2.indexPath(for: fCell) else {return}
                            self.requestOrderDelete(index)
                        })
                    }
                }
                if orderInfo.refundStatus != .noInfo {
                    _cell.refundInfoAttributedString = attrTxt
                } else {
                    _cell.refundInfoAttributedString = nil
                }
            }
            
        case (_, _):
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            guard let _cell = cell as? OrderProductDescTableViewCell else {return}
            let orderGoodsIndex = indexPath.row - 1
            let productInfo = orderInfo.orderGoods[orderGoodsIndex]
            _cell.config(productInfo.thumb, title: productInfo.title, price: productInfo.price, count: productInfo.num, properList: productInfo.properList )
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let orderInfo = (tableView == self.tableView) ? dataArray[indexPath.section] : dataArray2[indexPath.section]

        switch indexPath.row {
        case 0:
            return 36
        case (orderInfo.orderGoods.count + 1):
             return ((Double(orderInfo.revisedPrice) ?? 0.0) == 0) || ((Double(orderInfo.revisedPrice) ?? 0.0) == ((Double(orderInfo.totalPrice) ?? 0.0))) ? 98 : 118
        default:
            return 86
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        default:
            AOLinkedStoryboardSegue.performWithIdentifier("RefundOrderDetail@MerchantCenter", source: self, sender: indexPath)
            break
        }
    }
}
