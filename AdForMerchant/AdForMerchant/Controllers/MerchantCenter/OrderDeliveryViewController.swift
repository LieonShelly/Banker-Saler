//
//  OrderDeliveryViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderDeliveryViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomBtn: UIButton!
    
    var selectedCompany: DeliveryCompany?

    var orderDetail: OrderDetail!
    
    fileprivate var deliveryInfo: (companyName: String, numb: String) = ("", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "发货"
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = UIColor.commonBgColor()
        
        tableView.register(UINib(nibName: "OrderProductDescTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderProductDescTableViewCell")
        tableView.register(UINib(nibName: "OrderAddressDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderAddressDetailTableViewCell")
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "OrderDeliveryTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderDeliveryTableViewCell")
        
        bottomBtn.addTarget(self, action: #selector(OrderDeliveryViewController.commitDeliveryInfoAction), for: .touchUpInside)
        requestOrderDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderDeliveryCompany@MerchantCenter" {
            guard let desVC = segue.destination as? OrderDeliveryCompanyViewController else {return}
            desVC.selectedCompany = selectedCompany
            desVC.completeBlock = {company in
                self.selectedCompany = company
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    // MARK: - Keyboard Notification
    
    func keyboardWillShow(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.view.layoutIfNeeded()
        }) 
    }
    
    func keyboardWillHide(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.layoutIfNeeded()
        }) 
    }

    // MARK: - Button Action
    
    func commitDeliveryInfoAction() {
        view.endEditing(true)
        
        guard let company = selectedCompany else {
            Utility.showAlert(self, message: "请输入物流信息")
            return
        }
        
        if company.shorthand == "NoCompany" {
        
        } else if company.shorthand == "OtherCompany" && company.name.isEmpty {
            Utility.showAlert(self, message: "请输入物流公司")
            return
        } else if deliveryInfo.numb.isEmpty {
            Utility.showAlert(self, message: "请输入运单编号")
            return
        }
        
        requestOrderDelivery()

    }
    
    // MARK: - Http request
    func requestOrderDetail() {
        let parameters: [String: AnyObject] = [
            "order_id": orderDetail.id as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderDetail(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
                guard let model = object as? [String: AnyObject] else {return}
                self.orderDetail = OrderDetail(JSON: model)
                self.tableView.reloadData()
            }
        }
    }
    
    func requestOrderDelivery() {
        
        guard let company = selectedCompany else {
            return
        }
        
        var parameters: [String: AnyObject] = [
            "order_id": orderDetail.id as AnyObject
        ]
        if company.shorthand == "NoCompany" {
            parameters["logistics_company"] = "无物流" as AnyObject?
        } else if company.shorthand == "OtherCompany" {
            parameters["logistics_company"] = company.name as AnyObject?
            parameters["logistics_no"] = deliveryInfo.numb as AnyObject?
        } else {
            parameters["logistics_com"] = company.shorthand as AnyObject?
            parameters["logistics_no"] = deliveryInfo.numb as AnyObject?
        }
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.orderPaiedShip(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                AOLinkedStoryboardSegue.performWithIdentifier("OrderDeliverySucceed@MerchantCenter", source: self, sender: nil)
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

extension OrderDeliveryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 + orderDetail.orderGoods.count
        case 1:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, orderDetail.orderGoods.count):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderAddressDetailTableViewCell", for: indexPath)
            return cell
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductDescTableViewCell", for: indexPath)
            guard let _cell = cell as? OrderProductDescTableViewCell else {return UITableViewCell()}
            _cell.bgView.backgroundColor = UIColor.white
            
            let productInfo = orderDetail.orderGoods[indexPath.row]
            _cell.config(productInfo.thumb, title: productInfo.title, price: productInfo.price, count: productInfo.num, properList: productInfo.properList)
            return cell
        
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            return cell
        case (1, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDeliveryTableViewCell", for: indexPath)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .default, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
}

extension OrderDeliveryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
            
        case (0, orderDetail.orderGoods.count):
            guard let _cell = cell as? OrderAddressDetailTableViewCell else {return}
            _cell.txtView.text = "\(orderDetail.username), \(orderDetail.mobile), \(orderDetail.address), \(orderDetail.postcode)(邮编), \(orderDetail.name)(收)"
        case (1, 0):
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.accessoryType = .disclosureIndicator
            _cell.leftTxtLabel.text = "物流公司"
            _cell.rightTxtLabel.text = selectedCompany?.name
            
        case (1, 1):
            guard let _cell = cell as? OrderDeliveryTableViewCell else {return}
            _cell.leftTxtLabel.text = "物流单号"
            _cell.centerTxtField.keyboardType = .numberPad
            _cell.centerTxtField.placeholder = "请填写物流单号"
            _cell.centerTxtField.text = deliveryInfo.numb
            _cell.endEditingBlock = { textField in
                self.deliveryInfo.numb = textField.text ?? ""
            }
            
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else if section == 1 {
            return 10
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, orderDetail.orderGoods.count):
            let addressTxt = "\(orderDetail.username), \(orderDetail.mobile), \(orderDetail.address), \(orderDetail.postcode)(邮编), \(orderDetail.name)(收)"
            
            let size = (addressTxt as NSString).boundingRect(with: CGSize(width: screenWidth - 38 - 10 - 8 - 10, height: CGFloat.leastNormalMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil)
            return max(50, ceil(size.height) + 33.0)
        case (0, _):
            return 86
        case (1, _):
            return 46
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
            
        case (1, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("OrderDeliveryCompany@MerchantCenter", source: self, sender: indexPath)
            
        default:
            break
        }
    }
    
}
