//
//  ProductNDetailViewController.swift
//  AdForMerchant
//
//  Created by YYQ on 16/5/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class ProductNDetailViewController: BaseViewController {
    @IBOutlet  weak var table: UITableView!
    internal var productType: ProductType = .normal {
        didSet {
            if productType == .normal {
                navigationItem.title = "商品详情"
            } else {
                navigationItem.title = "服务详情"
            }
        }
    }
    var productModel: ProductDetailModel?
    var productID: String = ""
    //image Data
    var imageData: Data?
    static weak var instance: ProductAddNewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initialData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.table.reloadData()
        requestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductEdit@Product", let dVC = segue.destination as? ProductAddNewViewController {
            
            dVC.productID = self.productID
            dVC.productType = self.productType
            dVC.modifyType = ObjectModifyType.edit
//            dVC.productModel = self.productModel
        } else if segue.identifier == "ProductRelatedCampaign@Product", let dVC = segue.destination as? ProductRelatedCampaignViewController {
            
            dVC.productId = Int(self.productID)
        } else if segue.identifier == "ProductDescInput@Product", let desVC = segue.destination as? DetailInputViewController, let indexPath = sender as? IndexPath {
            desVC.canEdit = false
            desVC.txt = " "
            switch productType {
            case .normal:
                switch (indexPath.section, indexPath.row) {
                case (3, 0):
                    desVC.navTitle = "输入商品名称"
                    if productModel?.title.isEmpty == false {
                        desVC.txt = productModel?.title
                    } else {
                    }
                case (3, 1):
                    desVC.navTitle = "输入商品概述"
                    if productModel?.summary.isEmpty == false {
                        desVC.txt = productModel?.summary
                    }
                case (5, _):
                    desVC.navTitle = "输入商品描述"
                    if productModel?.detail.isEmpty == false {
                        desVC.txt = productModel?.detail
                    }
                default:
                    break
                }
                
            case .service:
                switch (indexPath.section, indexPath.row) {
                case (2, 0):
                    desVC.navTitle = "输入商品名称"
                    if productModel?.title.isEmpty == false {
                        desVC.txt = productModel?.title
                    }
                case (2, 1):
                    desVC.navTitle = "输入商品概述"
                    if productModel?.summary.isEmpty == false {
                        desVC.txt = productModel?.summary
                    }
                case (5, _):
                    desVC.navTitle = "输入商品描述"
                    if productModel?.detail.isEmpty == false {
                        desVC.txt = productModel?.detail
                    }
                default:
                    break
                }
            }
        } else if segue.identifier == "ProductAddAttribute@Product", let desVC = segue.destination as? ProductAddAttributeViewController {
            desVC.canEdit = false
            switch productType {
            case .normal:
                guard let indexPath = sender as? IndexPath else { return }
                if indexPath.row == 0 {
//                    desVC.type = .ProductParameter
//                    for value in productModel!.paramsStruct {
//                        let strut = (value.paramName, value.paramValue)
//                        desVC.dataArray.append(strut)
//                    }
                } else {
                    desVC.type = .productParameter
                     guard let model = productModel else { return  }
                    for value in model.paramsStruct {
                        let strut = (value.paramName, value.paramValue)
                        desVC.dataArray.append(strut)
                    }
//                    desVC.type = .ProductProperty
//                    for prop in productModel!.properties {
//                        let strut = (prop.propertyName, prop.propertyValue)
//                        desVC.dataArray.append(strut)
//                    }
                }
            case .service:
                desVC.type = .buyNote
                 guard let model = productModel else { return  }
                for value in model.rulesStruct {
                    let strut = (value.name, value.content)
                    desVC.dataArray.append(strut)
                }
            }
        } else if segue.identifier == "ProductSelectAddress@Product", let desVC = segue.destination as? ProductSelectAddressViewController {
          
            desVC.canEdit = false
            if let array = productModel?.storesStruct {
                desVC.dataArray = array
            }
        } else if segue.identifier == "CommonWebViewScene@AccountSession", let destVC = segue.destination as? CommonWebViewController {
            destVC.htmlContent = sender as? String
            destVC.naviTitle = "预览"
        }
    }
}

extension ProductNDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch productType {
        case .normal:
            return 11
        case .service:
            return 12
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (productType, section) {
        case (.normal, 0):
            return 2
        case (.normal, 1):
            return 2
        case (.normal, 3):
            return 2
        case (.normal, 4):
            return 2
        case (.normal, 7):
            return 2
        case (.normal, 9):
            return 2
        case (.normal, 10):
            return 2
        case (.service, 0):
            return 2
        case (.service, 2):
            return 2
        case (.service, 3):
            return 2
        case (.service, 7):
            return 2
        case (.service, 11):
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch productType {
        case .normal:
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case  (0, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (1, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductChoosecodeCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (1, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (2, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (3, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (4, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (4, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (5, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                return cell
            case (6, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (7, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (7, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (8, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (9, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (9, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (10, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
//                cell.accessoryType = .None
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            }
        case .service:
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case  (0, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (1, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (2, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (3, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (3, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (4, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (5, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                return cell
            case (6, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (7, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (7, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (8, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (9, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (10, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (11, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (11, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            }
        }
    }
}

extension ProductNDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch (productType, section) {
        case (.normal, 2):
            return 35
        case (.normal, 8):
            return 35 + 20
        case (.service, 1):
            return 35
        case (.service, 8):
            return 35 + 20
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
         guard let model = productModel else { return nil }
        switch (productType, section) {
        case (.normal, 2), (.service, 1):
            let attrTxt = NSAttributedString(string: "需要帮助？", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: screenWidth - 100, y: 0, width: 100, height: 35)
            btn.setAttributedTitle(attrTxt, for: UIControlState())
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
            titleBg.addSubview(btn)
            return titleBg
        case (.normal, 8), (.service, 8):
            var point = "0"
            if !model.pointPrice.isEmpty {
                point = String(format: "%.0f", (Float(model.pointPrice) ?? 0) * 100)
            }
            
            var percent = "0.00%"
            if !model.pointPrice.isEmpty && !model.price.isEmpty {
                if let price = Float(model.price), price > 0.001 {
                    percent = String(format: "%.2f%%", (Float(model.pointPrice) ?? 0) / price * 100)
                }
            }
            
            let text = "ⓘ 本金额可兑换\(point)积分\n积分占整个商品金额的\(percent)"
            
            let attrTxt = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
            attrTxt.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor()], range: (text as NSString).range(of: "ⓘ"))
            attrTxt.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor()], range: (text as NSString).range(of: point))
            attrTxt.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor()], range: (text as NSString).range(of: percent, options: .backwards))
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 55))
            label.numberOfLines = 0
            label.textAlignment = .right
            label.attributedText = attrTxt
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 55))
            titleBg.addSubview(label)
            return titleBg
        default:
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            return titleBg
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (productType, indexPath.section, indexPath.row) {
        case (.normal, 1, 0):
            return 55
        case (.normal, 5, _):
            return 80
        case (.normal, 6, _):
            return 90
     
        case (.service, 5, _):
            return 80
        case (.service, 6, _):
            return 90
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.layoutMargins = UIEdgeInsets.zero
        switch productType {
        case .normal:
            switch (indexPath.section, indexPath.row) {
            case (0, 0): cellStatus(cell)
            case (0, 1): cellScore(cell)
            case(1, 0):  cellGoodsConfigID(cell)
            case (1, 1): cellActive(cell)
            case (2, _): cellCover(cell)
            case (3, 0): cellName(cell)
            case (3, 1): cellSummary(cell)
            case (4, 0): cellGoodsCategory(cell)
            case (4, 1): cellShopCategory(cell)
            case (5, _): cellDetail(cell)
            case (6, _): cellGoodsImgs(cell)
            case (7, 0): cellPrice(cell)
            case (7, 1): cellMarketPrice(cell)
            case (8, _): cellPoint(cell)
            case (9, 0): cellStock(cell)
            case (9, 1): cellDelivery(cell)
            case (10, 0): cellProperties(cell)
            case (10, 1): cellParams(cell)
            default: break
            }
        case .service:
            switch (indexPath.section, indexPath.row) {
            case (0, 0): cellStatus(cell)
            case (0, 1): cellScore(cell)
            case (1, 0): cellCover(cell)
            case (2, 0): cellName(cell)
            case (2, 1): cellSummary(cell)
            case (3, 0): cellGoodsCategory(cell)
            case (3, 1): cellShopCategory(cell)
            case (4, _): cellBusiness(cell)
            case (5, _): cellDetail(cell)
            case (6, _): cellGoodsImgs(cell)
            case (7, 0): cellPrice(cell)
            case (7, 1): cellMarketPrice(cell)
            case (8, _): cellPoint(cell)
            case (9, _): cellStock(cell)
            case (10, _): cellRules(cell)
            case (11, 0): cellStartTime(cell)
            case (11, 1): cellCloseTime(cell)
            default: break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch productType {
        case .normal:
            switch (indexPath.section, indexPath.row) {
            case(0, 0):
                if self.productModel?.status == .exception {
                    let destVC = StatusDetailViewController()
                    destVC.title = "商品状态"
                    let param = StatusDetailParameter()
                     guard let model = productModel else { return  }
                    param.relationID = Int(model.goodsId)
                    param.type = .goods
                    destVC.param = param
                    navigationController?.pushViewController(destVC, animated: true)
                }
            case (1, 1):
                if productModel?.events.isEmpty == false {
                    AOLinkedStoryboardSegue.performWithIdentifier("ProductRelatedCampaign@Product", source: self, sender: nil)
                }
            case (3, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (5, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (10, 0):
                if productModel?.properList.isEmpty == false {
//                    AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath)
                    let destVC = SetProductSpecViewController()
                    destVC.disableCell = true
                    destVC.model.propList = productModel?.properList
                    navigationController?.pushViewController(destVC, animated: true)
                }
            case (10, 1):
                if productModel?.paramsStruct.isEmpty == false {
                    AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath)
                }
            default: break
            }
        case .service:
            switch (indexPath.section, indexPath.row) {
            case(0, 0):
                if self.productModel?.status == .exception {
                    let destVC = StatusDetailViewController()
                    destVC.title = "服务状态"
                    let param = StatusDetailParameter()
                    guard let model = productModel else { return  }
                    param.relationID = Int(model.goodsId)
                    param.type = .goods
                    destVC.param = param
                    navigationController?.pushViewController(destVC, animated: true)
                }
                break
            case (2, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (4, 0):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductSelectAddress@Product", source: self, sender: nil)
            case (5, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (10, 0):
                if productModel?.rulesStruct.isEmpty == false {
                    AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: nil)
                }
            default:
                break
            }
        }
    }
}

extension ProductNDetailViewController {
    fileprivate func initialData() {
        self.productModel = ProductDetailModel()
        if productType == .normal {
            navigationItem.title = "商品详情"
        } else {
            navigationItem.title = "服务详情"
        }
    }
    
    fileprivate func setupUI() {
        table.keyboardDismissMode = .onDrag
        table.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        table.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        table.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        table.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        table.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        table.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        table.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        /// ProductChoosecodeCell
        table.register(UINib(nibName: "ProductChoosecodeCell", bundle: nil), forCellReuseIdentifier: "ProductChoosecodeCell")
        table.separatorColor = table.backgroundColor
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "NavIconMore"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doMoreAction))
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
}
