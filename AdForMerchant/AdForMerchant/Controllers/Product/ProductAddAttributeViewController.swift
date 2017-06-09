//
//  ProductAddAtributeViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/29/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ProductAddAttributeViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet fileprivate var bottomBtnBottomConstr: NSLayoutConstraint!
    
    internal var selectCompletionBlock: ((String) -> Void)?
    
    var dataArray: [(String, String)] = []
    var maxNumber: Int?
    var maxNumberAlert: String = "添加数量超过最大限制"
    
    var type: AttributeType = .productParameter
    var completeBlock: (([(String, String)]) -> Void)?
    
    var canEdit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = UIColor.commonBgColor()
        
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "CommonBackButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.confirmAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
        switch type {
        case .productParameter:
            navigationItem.title = canEdit ? "添加商品参数" : "商品参数"
            tableView.register(UINib(nibName: "ObjectAttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "ObjectAttributeTableViewCell")
        case .productProperty:
            navigationItem.title = canEdit ? "添加商品规格" : "商品规格"
            tableView.register(UINib(nibName: "ObjectAttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "ObjectAttributeTableViewCell")
        case .buyNote:
            navigationItem.title = canEdit ? "添加购买须知" : "购买须知"
            tableView.register(UINib(nibName: "BuyNoteAttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "BuyNoteAttributeTableViewCell")
        case .campaignNote:
            navigationItem.title = canEdit ? "添加活动须知" : "活动须知"
            tableView.register(UINib(nibName: "BuyNoteAttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "BuyNoteAttributeTableViewCell")
        case .coupon:
            navigationItem.title = canEdit ? "设置满减规则" : "满减规则"
            tableView.register(UINib(nibName: "CouponRuleTableViewCell", bundle: nil), forCellReuseIdentifier: "CouponRuleTableViewCell")
        }
        
        if canEdit {
            let rightBarItem = UIBarButtonItem(image: UIImage(named: "CommonButtonAdd"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.addNewAttributeAction))
            navigationItem.rightBarButtonItem = rightBarItem
        }
        
        refreshTableViewBg()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.refreshTableViewBg()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bottomBtnBottomConstr.constant = -49
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CampaignAddNewCouponRule@Campaign", let desVC = segue.destination as? CampaignAddNewCouponRuleViewController {
            
            desVC.completeBlock = { totalAmount, couponAmount in
                self.dataArray += [(totalAmount, couponAmount)]
            }
        } else if segue.identifier == "ProductAddNewAttribute@Product", let addNewVC = segue.destination as? ProductAddNewAttributeViewController {
            
            addNewVC.type = type
            addNewVC.completeBlock = {(name, value) in
                self.dataArray += [(name, value)]
                self.tableView.reloadData()
            }
        } else if segue.identifier == "ProductAddNewBuyNote@Product", let addBuyVC = segue.destination as? ProductAddNewBuyNoteViewController {
          
            switch type {
            case .buyNote:
                addBuyVC.navTitle = "添加购买须知"
                addBuyVC.nameCharacterMaxLimit = 5
                addBuyVC.contentCharacterMaxLimit = 50
            case .campaignNote:
                addBuyVC.navTitle = "添加活动须知"
                addBuyVC.nameCharacterMaxLimit = 5
                addBuyVC.contentCharacterMaxLimit = 50
            default:
                break
            }
            addBuyVC.completeBlock = {(name, value) in
                self.dataArray += [(name, value)]
                self.tableView.reloadData()
            }
        }
    }
    
    func addNewAttributeAction() {
        if let max = maxNumber, dataArray.count >= max {
            Utility.showAlert(self, message: maxNumberAlert)
            return
        }
        switch type {
        case .productParameter:
            AOLinkedStoryboardSegue.performWithIdentifier("ProductAddNewAttribute@Product", source: self, sender: nil)
        case .productProperty:
            AOLinkedStoryboardSegue.performWithIdentifier("ProductAddNewAttribute@Product", source: self, sender: nil)
        case .buyNote, .campaignNote:
            AOLinkedStoryboardSegue.performWithIdentifier("ProductAddNewBuyNote@Product", source: self, sender: nil)
        case .coupon:
            AOLinkedStoryboardSegue.performWithIdentifier("CampaignAddNewCouponRule@Campaign", source: self, sender: nil)
        }
    }
    
    @IBAction func confirmAction() {
        if let block = completeBlock {
            block(dataArray)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func refreshTableViewBg() {
        if dataArray.isEmpty {
            tableView.backgroundView = nodataBgView()
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func nodataBgView() -> UIView {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableView.bounds.height))
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        switch type {
        case .productParameter:
            descLbl.text = canEdit ? "当前暂无参数，请点击右上角按钮添加" : "当前暂无参数"
        case .productProperty:
            descLbl.text = canEdit ? "当前暂无规格，请点击右上角按钮添加" : "当前暂无规格"
        case .buyNote:
            descLbl.text = canEdit ? "当前暂无须知，请点击右上角按钮添加" : "当前暂无须知"
        case .campaignNote:
            descLbl.text = canEdit ? "当前暂无须知，请点击右上角按钮添加" : "当前暂无须知"
        case .coupon:
            descLbl.text = canEdit ? "当前暂无规则，请点击右上角按钮添加" : "当前暂无规则"
        }
        
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
        
    }

}

extension ProductAddAttributeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch type {
        case .productParameter, .productProperty:
            guard   let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectAttributeTableViewCell", for: indexPath) as? ObjectAttributeTableViewCell else { return  UITableViewCell() }
            cell.nameField.isUserInteractionEnabled = false
            cell.contentField.isUserInteractionEnabled = false
            return cell
        case .buyNote, .campaignNote:
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "BuyNoteAttributeTableViewCell", for: indexPath) as? BuyNoteAttributeTableViewCell else { return  UITableViewCell() }
            cell.nameField.isUserInteractionEnabled = false
            cell.contentTxtView.isUserInteractionEnabled = false
            return cell
        case .coupon:
          guard  let cell = tableView.dequeueReusableCell(withIdentifier: "CouponRuleTableViewCell", for: indexPath) as?CouponRuleTableViewCell else { return  UITableViewCell() }
            return cell
            
        }
        
    }
}

extension ProductAddAttributeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch type {
        case .productParameter, .productProperty:
            return 90
        case .buyNote:
            return 112
        case .campaignNote:
            let info = dataArray[indexPath.section]
            let str: String = info.1
            let size = (str as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
            return max(112, 42 + ceil(size.height) + 9 + 20)
        case .coupon:
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        let info = dataArray[indexPath.section]
        
        switch type {
        case .productParameter:
          guard  let _cell = cell as? ObjectAttributeTableViewCell else { return  }
            _cell.config(info.0, content: info.1)
            if canEdit {
                _cell.deleteBlock = {cCell -> Void in
                    if let indexPath = self.tableView.indexPath(for: cCell) {
                        Utility.showConfirmAlert(self, message: "是否确认删除该参数？", confirmCompletion: {
                            self.dataArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        case .productProperty:
            guard let _cell = cell as? ObjectAttributeTableViewCell else { return  }
            _cell.config(info.0, content: info.1)
            _cell.type = .productProperty
            if canEdit {
                _cell.deleteBlock = {cCell -> Void in
                    if let indexPath = self.tableView.indexPath(for: cCell) {
                        Utility.showConfirmAlert(self, message: "是否确认删除该规格？", confirmCompletion: {
                            self.dataArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        case .buyNote, .campaignNote:
            guard let _cell = cell as? BuyNoteAttributeTableViewCell  else { return  }
            _cell.config(info.0, content: info.1)
            if canEdit {
                _cell.deleteBlock = {cCell -> Void in
                    if let indexPath = self.tableView.indexPath(for: cCell) {
                        Utility.showConfirmAlert(self, message: "是否确认删除该须知？", confirmCompletion: {
                            self.dataArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        case .coupon:
          guard  let _cell = cell as? CouponRuleTableViewCell  else { return  }
            _cell.config(info.0, discount: info.1)
            if canEdit {
                _cell.deleteBlock = { cCell in
                    if let indexPath = self.tableView.indexPath(for: cCell) {
                        Utility.showConfirmAlert(self, message: "是否确认删除该规则？", confirmCompletion: {
                            self.dataArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
