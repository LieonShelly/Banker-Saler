//
//  ProductSelectAddressViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/29/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ShopAddressSelectTableViewCell: UITableViewCell {
    
    @IBOutlet internal var txtLabel: UILabel!
    @IBOutlet internal var selectionButton: UIButton!
    
    @IBOutlet internal var buttonLeading: NSLayoutConstraint!
    
    internal var willShowSelectButton: Bool = true {
        didSet {
            if willShowSelectButton {
                selectionButton.isHidden = false
                buttonLeading.constant = 8
            } else {
                selectionButton.isHidden = true
                buttonLeading.constant = -26
            }
        }
    }

    internal var isAddressSelected: Bool = false {
        didSet {
            if isAddressSelected {
                selectionButton.isSelected = true
            } else {
                selectionButton.isSelected = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionButton.isUserInteractionEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func config(_ info: ShopAddressInfo) {
        
        let strPart1 = "\(info.shopName)， "
        let strPart2 = "\(info.contact)， \(info.phone)"
        let strPart3 = "，\(info.address)"
        
        let attTxt1 = NSMutableAttributedString(string:strPart1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#0D0D0D")])
        
        let attTxt2 = NSMutableAttributedString(string:strPart2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0), NSForegroundColorAttributeName: UIColor.commonBlueColor()])
        
        let attTxt3 = NSMutableAttributedString(string:strPart3, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0), NSForegroundColorAttributeName: UIColor.colorWithHex("#0D0D0D")])
        
        attTxt1.append(attTxt2)
        attTxt1.append(attTxt3)
        txtLabel.attributedText = attTxt1
    }
    
}

class ProductSelectAddressViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    @IBOutlet fileprivate var bottomBtnBottomConstr: NSLayoutConstraint!
    internal var selectCompletionBlock: ((String) -> Void)?
    internal var selectCompletionArrayBlock: (([ShopAddressInfo]) -> Void)?
    internal var dataArray: [ShopAddressInfo] = []
    var selectedAddressId: Int = 0
    var canEdit: Bool = true
    var isMoreSelect = false
    var selectedCategoryIds: Set<Int> = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "添加商户信息"
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        if canEdit {
            let rightBarItem = UIBarButtonItem(image: UIImage(named: "CommonButtonAdd"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.addNewAddressAction))
            navigationItem.rightBarButtonItem = rightBarItem
        }
        
        confirmButton.setTitle("确定", for: UIControlState())
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if canEdit {
            requestAddressList()
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        if !canEdit {
            bottomBtnBottomConstr.constant = -49
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNewAddressAction() {
        AOLinkedStoryboardSegue.performWithIdentifier("ProductAddNewAddress@Product", source: self, sender: nil)

    }
    
    @IBAction func confirmAction() {
        if isMoreSelect {
//            if selectedCategoryIndex.count == 0 {
//                Utility.showAlert(self, message: "请至少选择一条商户信息")
//                return
//            }
            if let block = selectCompletionArrayBlock {
                var array = [ShopAddressInfo]()
                for store in self.dataArray {
                    if selectedCategoryIds.contains(store.id) {
                        array.append(store)
                    }
                }
                block(array)
            }
        } else {
            if let block = selectCompletionBlock {
                if self.selectedAddressId != 0 {
                    block("\(self.selectedAddressId)")
                }
            }
        }
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - Http request
    
    func requestAddressList() {
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.storeAddressList(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else { return  }
                if let addressList = result["address_list"] as? [[String: Any]] {
                    self.dataArray.removeAll()
                    for address in addressList {
                       guard let address = Mapper<ShopAddressInfo>().map(JSON: address) else { return  }
                        self.dataArray.append(address)
                    }
                    
                    self.tableView.reloadData()
                    
                    Utility.hideMBProgressHUD()
                } else {
                    Utility.hideMBProgressHUD()
                }
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }
    
}

extension ProductSelectAddressViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopAddressSelectTableViewCell", for: indexPath) as?ShopAddressSelectTableViewCell else { return  UITableViewCell() }
        cell.selectionStyle = .none
        let info = dataArray[indexPath.row]
        cell.config(info)
        if isMoreSelect {
            cell.isAddressSelected = false
            if selectedCategoryIds.contains(info.id) {
                cell.isAddressSelected = true
            }
        } else {
            cell.isAddressSelected = (info.id == selectedAddressId)
        }
        cell.willShowSelectButton = canEdit
        return cell
        
    }
}

extension ProductSelectAddressViewController: UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if canEdit {
            return UITableViewAutomaticDimension
        } else {
            let info = dataArray[indexPath.row]
            
            let storeInfo = "\(info.shopName)， " + "\(info.contact)， \(info.phone)" + "，\(info.address)"
            
            let size = (storeInfo as NSString).boundingRect(with: CGSize(width: screenWidth - 12 - 12, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)], context: nil)
            return max(50, ceil(size.height) + 21.0)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isMoreSelect {
            let store = dataArray[indexPath.row]
            if selectedCategoryIds.contains(store.id) {
                selectedCategoryIds.remove(store.id)
            } else {
                selectedCategoryIds.insert(store.id)
            }
        } else {
            let info = dataArray[indexPath.row]
            selectedAddressId = info.id
        }
        tableView.reloadData()
    }
}
