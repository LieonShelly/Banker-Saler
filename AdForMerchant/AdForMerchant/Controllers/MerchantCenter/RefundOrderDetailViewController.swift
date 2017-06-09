//
//  RefundOrderDetailViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 5/6/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class RefundOrderDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var orderId: Int!
    var refundId: Int!
    
    fileprivate var orderDetail: RefundOrderInfo?
    fileprivate var orderInfoGenerated: String = ""

    var isInProgress: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "退款详情"
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "NavIconMore"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doMoreAction))
        navigationItem.rightBarButtonItem = rightBarItem
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = UIColor.white
        
        tableView.register(UINib(nibName: "OrderSimpleHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderSimpleHeaderTableViewCell")
        tableView.register(UINib(nibName: "OrderSimpleFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderSimpleFooterTableViewCell")
        tableView.register(UINib(nibName: "OrderProductDescTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderProductDescTableViewCell")
        tableView.register(UINib(nibName: "OrderAddressDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderAddressDetailTableViewCell")
        tableView.register(UINib(nibName: "OrderDescTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderDescTableViewCell")
        tableView.register(UINib(nibName: "RefundImgageTableViewCell", bundle: nil), forCellReuseIdentifier: "RefundImgageTableViewCell")
        
        requestOrderDetail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Http request
    func requestOrderDetail() {
        let parameters: [String: Any] = [
            "refund_id": refundId
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderRefundDetail(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
                guard let model = object as? [String: AnyObject] else {return}
                self.orderDetail = RefundOrderInfo(JSON: model)
                //self.generateOrderInfo()
                self.tableView.reloadData()
            }
        }
    }
    
    func requestOrderDelete() {
        
        let parameters: [String: Any] = [
            "refund_id": refundId
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderRefundDelete(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let msg = message else {return}
                Utility.showAlert(self, message: msg.isEmpty ? "退款记录删除成功": msg, dismissCompletion: {
                    _ = self.navigationController?.popViewController(animated: true)
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
    
    func requestOrderRefund(_ willAgree: Bool) {
        
        let parameters: [String: AnyObject] = [
            "refund_id": refundId as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        let requset = willAgree ? AFMRequest.orderRefundAgree(parameters, aesKey, aesIV) : AFMRequest.orderRefundReject(parameters, aesKey, aesIV)
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(requset, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()

                if willAgree {
                    Utility.showMBProgressHUDToastWithTxt(message?.isEmpty ?? false ? "订单同意退款成功": message ?? "")
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    Utility.showMBProgressHUDToastWithTxt(message?.isEmpty ?? false ? "订单拒绝退款成功": message ?? "")
                    _ = self.navigationController?.popViewController(animated: true)
                }
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    // MARK: - Button Action
    
    func doMoreAction() {
        let modalViewController = NavPopoverViewController()
        modalViewController.offsetY = 69
        
        if isInProgress {
            modalViewController.itemInfos = [("PopoverIconOK", "同意退款"), ("PopoverIconRefuse", "拒绝退款")]
        } else {
            modalViewController.itemInfos = [("PopoverIconDelete", "删除")]
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
        
        switch (isInProgress, index) {
        case (true, 0)://同意退款
            Utility.showConfirmAlert(self, message: "确定已收到买家退货， 以免财货两空。现在同意该笔退款？", confirmCompletion: {
                self.requestOrderRefund(true)

            })
        case (true, 1): //拒绝退款
            Utility.showConfirmAlert(self, message: "是否拒绝客户的本次退款?", confirmCompletion: {
                self.requestOrderRefund(false)
            })
        case (false, 0): //删除订单
            Utility.showConfirmAlert(self, message: "是否确认删除本条退款处理信息?", confirmCompletion: {
                self.requestOrderDelete()
            })
        default:
            break
        }
    }
}

extension RefundOrderDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let orderDetail = self.orderDetail else {return 0}
        return orderDetail.images.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDescTableViewCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefundImgageTableViewCell", for: indexPath)
            return cell
        }
    }
}

extension RefundOrderDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            cell.selectionStyle = .none
            guard let _cell = cell as? OrderDescTableViewCell else {return}
            guard let orderDetail = orderDetail else {return}
            let refundAmount = "￥\(orderDetail.refundAmount)\n"
            let normalAttributes = [NSForegroundColorAttributeName: UIColor.commonGrayTxtColor(), NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]
            let blueAttributes = [NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]
            
            let attrTxt = NSMutableAttributedString(string: "退款金额：", attributes: normalAttributes)
            let refundAttrTxt = NSAttributedString(string: refundAmount, attributes: blueAttributes)
            attrTxt.append(refundAttrTxt)
            let reason = orderDetail.remark == "" ? "退款原因：\(orderDetail.reason)" : "退款原因：\(orderDetail.reason),\(orderDetail.remark)"
            
            let otherTxt = ([OrderRefundStatus.agreed, OrderRefundStatus.rejected].contains(orderDetail.refundStatus)) ?
                ("订单金额：￥\(orderDetail.actualPrice)\n" +
                    "退款申请日期：\(orderDetail.applyTime)\n" +
                    "退款处理日期：\(orderDetail.dealTime)\n" +
                    "处理状态：\(orderDetail.refundStatus.desc)\n" +
                    reason)
                :
                ("订单金额：￥\(orderDetail.actualPrice)\n" +
                    "退款申请日期：\(orderDetail.applyTime)\n" +
                    "处理状态：\(orderDetail.refundStatus.desc)\n" +
                    reason)
            
            let otherAttrTxt = NSAttributedString(string: otherTxt, attributes: normalAttributes)
            attrTxt.append(otherAttrTxt)
            _cell.txtLabel.attributedText = attrTxt
        } else {
            cell.selectionStyle = .none
            guard let _cell = cell as? RefundImgageTableViewCell else {return}
            _cell.imageUrlArray = self.orderDetail?.images ?? [String]()
            _cell.clickImageBlock = {  index in 
                    print(index)
                var images = [SKPhotoProtocol]()
                for item in self.orderDetail?.images ?? [String]() {
                    let photo = SKPhotoImage.photoWithImageURL(item)
                    images.append(photo)
                    
                }
                let browser = SKPhotoBrowser(photos: images)                
                browser.initializePageIndex(index)
                
                self.present(browser, animated: true, completion: nil)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 35 : 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        if indexPath.section == 0 {
                let reason = orderDetail?.remark == "" ? "退款原因：\(String(describing: orderDetail?.reason))" : "退款原因：\(String(describing: orderDetail?.reason)),\(String(describing: orderDetail?.remark))"
                let height = String.getLabHeigh(reason, font: UIFont.systemFont(ofSize: 14), width: screenWidth-24)
            guard let orderDetail = orderDetail else {return 0}
            return ([OrderRefundStatus.agreed, OrderRefundStatus.rejected].contains(orderDetail.refundStatus)) ? 115 + height : 95 + height
        } else {
            return 110
        }

    }
}

//extension RefundOrderDetailViewController: DetailPhotoViewDelegate {
//    func photoBrowser(_ skPhotoBroswer: SKPhotoBrowser?) {
//        guard let broswer = skPhotoBroswer else { return }
//        present(broswer, animated: true)
//    }
//}
