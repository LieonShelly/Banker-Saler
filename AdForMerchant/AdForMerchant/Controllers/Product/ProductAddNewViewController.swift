//
//  ProductAddNewViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ALCameraViewController
import ObjectMapper

class ProductAddNewViewController: BaseViewController {
    @IBOutlet  weak var bottomBtnBottomConstr: NSLayoutConstraint!
    @IBOutlet  weak var tableView: UITableView!
    @IBOutlet  weak var bottomBtn: UIButton!
    var isAddStockNum: Bool = false
    var isdefer: Bool = false
    var isNoticeSource = false
    var addedStockNum: Int = 0
    var deferDate: String = ""
    internal var modifyType: ObjectModifyType = .addNew
    internal var productType: ProductType = .normal
     var willShowAlertWhenEnter: Bool = true
    var productModel: ProductDetailModel = ProductDetailModel()
    var goodsNumText: String = ""
    var productID: String! = ""
    var imageData: Data?
    var unEditProduct: ProductDetailModel?
    
    @IBAction func confirmAction(_ btn: UIButton) {
        if isdefer {
            postone(goodsID: self.productModel.goodsId, date: deferDate)
            return
        }
        if isAddStockNum {
            addStockNum(goodsID: productModel.goodsId, num: addedStockNum)
            return
        }
        switch (modifyType, productType) {
        case (.addNew, .normal), (.copy, .normal):
            validateNormalProductParams()
        case (.addNew, .service), (.copy, .service):
            requestAddServiceProductData()
        case (.edit, .normal):
            validateNormalProductParams()
        case (.edit, .service):
            requestAddServiceProductData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAlter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ObjectReleaseSucceed@Product", let desVC = segue.destination as? ObjectReleaseSucceedViewController {
            if modifyType == .edit {
                desVC.navTitle = "编辑商品"
                desVC.desc = "商品编辑成功，可直接在商品列表查看"
                desVC.completionBlock = {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewProductAddedNotification), object: nil, userInfo: ["ProductSaleStatus": ProductSaleStatus.readyForSale.rawValue])
                }
            } else {
                if productType == .normal {
                    desVC.navTitle = "发布商品"
                    desVC.desc = "商品发布完成，待平台审核"
                    desVC.completionBlock = {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewProductAddedNotification), object: nil, userInfo: ["ProductSaleStatus": ProductSaleStatus.waitingForReview.rawValue])
                    }
                } else {
                    desVC.navTitle = "发布商品"
                    desVC.desc = "商品发布完成，待平台审核"
                    desVC.productType = "发布服务商品"
                    desVC.completionBlock = {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewProductAddedNotification), object: nil, userInfo: ["ProductSaleStatus": ProductSaleStatus.waitingForReview.rawValue])
                    }
                }
            }
        } else if segue.identifier == "ProductAddAttribute@Product", let desVC = segue.destination as? ProductAddAttributeViewController, let indexPath = sender as? IndexPath {
            switch productType {
            case .normal:
                if indexPath.row == 0 {
                    desVC.type = .productParameter
                    for value in productModel.paramsStruct {
                        let strut = (value.paramName, value.paramValue)
                        desVC.dataArray.append(strut)
                    }
                    if validateEditable(indexPath) {
                        desVC.completeBlock = { paramsArray -> Void in
                            self.productModel.paramsStruct.removeAll()
                            for value in paramsArray {
                                var params = Params()
                                params.paramName = value.0
                                params.paramValue = value.1
                                self.productModel.paramsStruct?.append(params)
                            }
                        }
                    } else {
                        desVC.canEdit = false
                    }
                } else {
                    desVC.type = .productProperty
                    for prop in productModel.properties {
                        let property = (prop.propertyName, prop.propertyValue)
                        desVC.dataArray.append(property)
                    }
                    if validateEditable(indexPath) {
                        desVC.completeBlock = { propertyArray -> Void in
                            self.productModel.properties.removeAll()
                            for prop in propertyArray {
                                var property = Property()
                                property.propertyName = prop.0
                                property.propertyValue = prop.1
                                self.productModel.properties.append(property)
                            }
                        }
                    } else {
                        desVC.canEdit = false
                    }
                }
            case .service:
                desVC.type = .buyNote
                for value in productModel.rulesStruct {
                    let strut = (value.name, value.content)
                    desVC.dataArray.append(strut)
                }
                if validateEditable(indexPath) {
                    desVC.completeBlock = { rulesArray -> Void in
                        self.productModel.rulesStruct.removeAll()
                        for value in rulesArray {
                            var rules = Rules()
                            rules.name = value.0
                            rules.content = value.1
                            self.productModel.rulesStruct.append(rules)
                        }
                    }
                } else {
                    desVC.canEdit = false
                }
            }
        } else if segue.identifier == "ProductDescInput@Product", let desVC = segue.destination as? DetailInputViewController {
            
            guard let indexPath = sender as? IndexPath else { return }
            switch productType {
            case .normal:
                switch (indexPath.section, indexPath.row) {
                case (2, 0):
                    desVC.navTitle = "输入商品名称"
                    desVC.placeholder = "请输入简洁有特色的商品名称(限30字)"
                    if productModel.title.isEmpty == false {
                        desVC.txt = productModel.title
                    }
                    if validateEditable(indexPath) {
                        desVC.maxCharacterLimit = 30
                        desVC.limitPunctuation = true
                        desVC.completeBlock = {(goodsTitle: String) -> Void in
                            self.productModel.title = goodsTitle
                            self.tableView.reloadData()
                        }
                    } else {
                        desVC.canEdit = false
                    }
                case (2, 1):
                    desVC.navTitle = "输入商品概述"
                    desVC.placeholder = "请输入简洁的商品概述(限20字)"
                    if productModel.summary.isEmpty == false {
                        desVC.txt = productModel.summary
                    }
                    if validateEditable(indexPath) {
                        desVC.maxCharacterLimit = 20
                        desVC.completeBlock = {(goodsTitle: String) -> Void in
                            self.productModel.summary = goodsTitle
                            self.tableView.reloadData()
                        }
                    } else {
                        desVC.canEdit = false
                    }
                case (4, _):
                    desVC.navTitle = "输入商品描述"
                    desVC.placeholder = "商品使用方法、优缺点…详细的描述能使您的商品更撩人哦~（1000字以内）"
                    if productModel.detail.isEmpty == false {
                        desVC.txt = productModel.detail
                        }
                    if validateEditable(indexPath) {
                        desVC.maxCharacterLimit = 1000
                        desVC.completeBlock = {(goodsTitle: String) -> Void in
                            self.productModel.detail = goodsTitle
                            self.tableView.reloadData()
                        }
                    } else {
                        desVC.canEdit = false
                    }
                default:
                    break
                }
                
            case .service:
                switch (indexPath.section, indexPath.row) {
                case (2, 0):
                    desVC.navTitle = "输入商品名称"
                    desVC.placeholder = "请输入简洁有特色的商品名称(限30字)"
                    if productModel.title.isEmpty == false {
                        desVC.txt = productModel.title
                        }
                    if validateEditable(indexPath) {
                        desVC.maxCharacterLimit = 30
                        desVC.completeBlock = {(goodsTitle: String) -> Void in
                            self.productModel.title = goodsTitle
                            self.tableView.reloadData()
                            }
                        } else {
                            desVC.canEdit = false
                    }
                case (2, 1):
                    desVC.navTitle = "输入商品概述"
                    desVC.placeholder = "请输入简洁的商品概述(限20字)"
                    if productModel.summary.isEmpty == false {
                        desVC.txt = productModel.summary
                        }
                    if validateEditable(indexPath) {
                        desVC.maxCharacterLimit = 20
                        desVC.completeBlock = {(goodsTitle: String) -> Void in
                            self.productModel.summary = goodsTitle
                            self.tableView.reloadData()
                        }
                    } else {
                        desVC.canEdit = false
                    }
                case (5, _):
                    desVC.navTitle = "输入商品描述"
                    desVC.placeholder = "商品使用方法、优缺点…详细的描述能使您的商品更撩人哦~（1000字以内）"
                    if productModel.detail.isEmpty == false {
                        desVC.txt = productModel.detail
                    }
                    if validateEditable(indexPath) {
                        desVC.completeBlock = {(goodsTitle: String) -> Void in
                            self.productModel.detail = goodsTitle
                            self.tableView.reloadData()
                        }
                    } else {
                        desVC.canEdit = false
                    }
                    if isAddStockNum {
                        desVC.canEdit = false
                    }
                default:
                    break
                }
            }
        } else if segue.identifier == "ProductCategory@Product", let desVC = segue.destination as? ProductCategoryViewController {
         
            switch productType {
            case .normal:
                desVC.type = 1
            case .service:
                desVC.type = 2
            }
            desVC.categorySelected = self.productModel.catId
            desVC.childCategorySelected = self.productModel.childCatId
            desVC.selectCompletionBlock = {(catId, catName, childCatId, childCatName) in
                self.productModel.catId = catId
                self.productModel.catName = catName
                self.productModel.childCatId = childCatId
                self.productModel.childCatName = childCatName
            }
            
        } else if segue.identifier == "ShopCategory@Product", let desVC = segue.destination as? ProductShopCategoryViewController {
           
            desVC.storeParam.type = .service
            desVC.selectedShopCategory = self.productModel.storeCatId
            desVC.selectCompletionBlock = {(categoryModel: ShopCategoryModel?) -> Void in
                if let cate = categoryModel {
                    self.productModel.storeCatId = cate.catID
                    self.productModel.storeCatName = cate.catName
                } else {
                    self.productModel.storeCatId = ""
                    self.productModel.storeCatName = ""
                }
            }
        } else if segue.identifier == "ProductSelectAddress@Product", let desVC = segue.destination as? ProductSelectAddressViewController {
            
            if modifyType == .addNew || modifyType == .copy {
                desVC.isMoreSelect = true
                desVC.selectCompletionArrayBlock = {storesArr -> Void in
                    self.productModel.storesStruct = storesArr
                }
                if let array = productModel.storesStruct {
                    let storeIDs = array.flatMap({$0.id})
                    desVC.selectedCategoryIds = Set(storeIDs)
                }
            } else {
                guard let indexPath = sender as? IndexPath else {
                    return
                }
                if validateEditable(indexPath) {
                    desVC.isMoreSelect = true
                    desVC.selectCompletionArrayBlock = {storesArr -> Void in
                        self.productModel.storesStruct = storesArr
                    }
                    if let array = productModel.storesStruct {
                        let storeIDs = array.flatMap({$0.id})
                        desVC.selectedCategoryIds = Set(storeIDs)
                    }
                } else {
                    desVC.canEdit = false
                    if let array = productModel.storesStruct {
                        desVC.dataArray = array
                    }
                }
            }
        }
    }
}

extension ProductAddNewViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch (modifyType, productType) {
        case (_, .normal):
            return 10
        case (_, .service):
            return 12
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (modifyType, productType, section) {
        case (_, .normal, 0):
            return 1
        case (_, .normal, 2):
            return 2
        case (_, .normal, 3):
            return 0
        case (_, .normal, 6):
            return 2
        case (_, .normal, 8):
            return 2
        case (_, .normal, 9):
            return 2
        case (_, .service, 0):
            return 0
        case (_, .service, 2):
            return 2
        case (_, .service, 3):
            return 2
        case (_, .service, 7):
            return 2
        case (_, .service, 11):
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductChoosecodeCell", for: indexPath)
                return cell
            case (0, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            case (1, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
                return cell
            case (2, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                return cell
            case (4, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
                return cell
            case (5, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath)
                return cell
            case (6, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                return cell
            case (7, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                return cell
            case (8, 0):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductStockTableViewCell", for: indexPath) as? ProductStockTableViewCell else { return UITableViewCell() }
                
                return configStock(cell)
            case (8, 1):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath) as? DefaultTxtTableViewCell else { return UITableViewCell() }
                return configDelivery(cell)
            case (9, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            }
        case .service:
            switch (indexPath.section, indexPath.row) {
            case (0, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            case (1, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
                return cell
            case (2, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                return cell
            case (3, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            case (4, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            case (5, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
                return cell
            case (6, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath)
                return cell
            case (7, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                return cell
            case (8, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                return cell
            case (9, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
                return cell
            case (10, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            case (11, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                return cell
            }
        }
    }
}

extension ProductAddNewViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       guard let oldImg = (info as NSDictionary).value(forKey: UIImagePickerControllerOriginalImage) as? UIImage else { return }
       guard let imageData1 = UIImageJPEGRepresentation(oldImg, 0.8) else { return }
       guard let image = UIImage(data: imageData1) else { return }
        
       imageData = UIImageJPEGRepresentation(image, 0.8)
       guard let imData =  imageData else { return }
        let parameters: [String: AnyObject] = [
            "cover": imData as AnyObject,
            "prefix[cover]": "goods/cover" as AnyObject
        ]
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
               guard let result = object as? [String: AnyObject] else { return }
               guard  let photoUploadedArray = result["success"] as? [AnyObject] else { return }

                if let photoInfo = photoUploadedArray.first, let coverImgUrl = photoInfo["url"] as? String {
                    self.productModel.cover = coverImgUrl
                    Utility.hideMBProgressHUD()
                    self.tableView.reloadData()
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            }
        }

        self.dismiss(animated: true) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
}

extension ProductAddNewViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch (modifyType, section) {
        case (_, 0):
            return CGFloat.leastNormalMagnitude
        case (_, 1):
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch (productType, section) {
        case (.normal, 1):
            return 35
        case (.normal, 7):
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
        
        switch (productType, section) {
        case (.normal, 1), (.service, 1):
            let attrTxt = NSAttributedString(string: "需要帮助？", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: screenWidth - 100, y: 0, width: 100, height: 35)
            btn.setAttributedTitle(attrTxt, for: UIControlState())
            btn.addTarget(self, action: #selector(self.showCoverHelpPage), for: .touchUpInside)
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
            titleBg.addSubview(btn)
            return titleBg
        case (.normal, 7), (.service, 8):
            var point = "0"
            if !productModel.pointPrice.isEmpty {
                point = String(format: "%.0f", (Float(productModel.pointPrice) ?? 0) * 100)
            }
            
            var percent = "0.00%"
            if !productModel.pointPrice.isEmpty && !productModel.price.isEmpty {
                if let price = Float(productModel.price), price > 0.001 {
                    percent = String(format: "%.2f%%", (Float(productModel.pointPrice) ?? 0) / price * 100)
                }
            }
            
            let text = iphone5 ? "ⓘ 本金额可兑换\(point)积分\n积分占整个商品金额的\(percent)" : "ⓘ 本金额可兑换\(point)积分,积分占整个商品金额的\(percent)"
            let attrTxt = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
            attrTxt.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor()], range: (text as NSString).range(of: "ⓘ"))
            attrTxt.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor()], range: (text as NSString).range(of: point))
            attrTxt.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor()], range: (text as NSString).range(of: percent, options: .backwards))
            let height = String.getLabHeigh(text, font: UIFont.systemFont(ofSize: 14), width: screenWidth - 20)
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: screenWidth - 20, height: height))
            label.numberOfLines = iphone5 ? 0 : 3
            label.textAlignment = .right
            label.attributedText = attrTxt
            
           let attrTxtHelp = NSAttributedString(string: "需要帮助？", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: screenWidth - 100, y: label.height, width: 100, height: 35)
            btn.setAttributedTitle(attrTxtHelp, for: UIControlState())
            btn.addTarget(self, action: #selector(self.showPointHelpPage), for: .touchUpInside)
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 55))
            titleBg.addSubview(label)
            titleBg.addSubview(btn)
            return titleBg
        default:
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            return titleBg
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (productType, indexPath.section, indexPath.row) {
        case (.normal, 0, 0):
            return 54
        case (.normal, 4, _):
            return 80
        case (.normal, 5, _):
            return 110
        case (.service, 5, _):
            return 80
        case (.service, 6, _):
            return 110
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.accessoryType = validateDisclosureIndicator(indexPath) ? .disclosureIndicator : .none
        switch productType {
        case .normal:
            switch (indexPath.section, indexPath.row) {
            case (0, 0): cellCode(cell, indexPath: indexPath)
            case (1, _): cellCover(cell, indexPath: indexPath)
            case (2, 0): cellName(cell, indexPath: indexPath)
            case (2, 1): cellSummary(cell, indexPath: indexPath)
//            case (3, 0): cellGoodsCategory(cell, indexPath: indexPath)
//            case (3, 1): cellShopCategory(cell, indexPath: indexPath)
            case (4, _): cellDetail(cell, indexPath: indexPath)
            case (5, _): cellGoodsImgs(cell, indexPath: indexPath)
            case (6, 0): cellPrice(cell, indexPath: indexPath)
            case (6, 1): cellMarketPrice(cell, indexPath: indexPath)
            case (7, 0): cellPoint(cell, indexPath: indexPath)
//            case (8, 0): cellStock(cell, indexPath: indexPath)
//            case (8, 1): cellDelivery(cell, indexPath: indexPath)
            case (9, 0): cellParams(cell, indexPath: indexPath)
            case (9, 1): cellProperties(cell, indexPath: indexPath)
            default: break
            }
        case .service:
            switch (indexPath.section, indexPath.row) {
            case (0, 0): cellStatus(cell, indexPath: indexPath)
            case (1, _): cellCover(cell, indexPath: indexPath)
            case (2, 0): cellName(cell, indexPath: indexPath)
            case (2, 1): cellSummary(cell, indexPath: indexPath)
            case (3, 0): cellGoodsCategory(cell, indexPath: indexPath)
            case (3, 1): cellShopCategory(cell, indexPath: indexPath)
            case (4, 0): cellBusiness(cell, indexPath: indexPath)
            case (5, _): cellDetail(cell, indexPath: indexPath)
            case (6, _): cellGoodsImgs(cell, indexPath: indexPath)
            case (7, 0): cellPrice(cell, indexPath: indexPath)
            case (7, 1): cellMarketPrice(cell, indexPath: indexPath)
            case (8, 0): cellPoint(cell, indexPath: indexPath)
            case (9, 0): cellStock(cell, indexPath: indexPath)
            case (10, 0): cellRules(cell, indexPath: indexPath)
            case (11, 0): cellStartTime(cell, indexPath: indexPath)
            case (11, 1): cellCloseTime(cell, indexPath: indexPath)
            default: break
            }
        }
        judgeAddStockNumAnddefer(cell: cell, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !kApp.pleaseAttestationAction(showAlert: true, type: .publish) {
            return
        }
        if productType == .normal {
            if indexPath == IndexPath(row: 0, section: 0) {
                guard let cell = tableView.cellForRow(at: indexPath) as? ProductChoosecodeCell else { return  }
                let destVC  = ChooseItemViewController()
                destVC.selectedGoodsConfigID = self.productModel.goodsConfigID
                destVC.selectedItemBlock = { [unowned self] selectedItem in
                    if let codestr = selectedItem.code, let title = selectedItem.title {
                        cell.subTitleLabel.text = "货号" + codestr + "(\(title))"
                        self.goodsNumText = title + "(\(codestr))"
                    }
                    self.requestSeletedItemFinalGoods(selectedItem)
                }
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        }
        if !validateEditable(indexPath) {
            if !validateDisclosureIndicator(indexPath) {
                if tableView.cellForRow(at: indexPath)?.accessoryType == .disclosureIndicator {
                
                } else {
                    return
                }
            }
        }
        
        switch productType {
        case .normal:
            switch (indexPath.section, indexPath.row) {
            case (1, 0):
                showAddPhotoAlertController()
            case (2, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (3, 0):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductCategory@Product", source: self, sender: nil)
            case (3, 1):
                AOLinkedStoryboardSegue.performWithIdentifier("ShopCategory@Product", source: self, sender: nil)
            case (4, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (9, 0):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath)
            case (9, 1):
                pushToSetProductSpeVC()
            default:
                break
            }
            
        case .service:
            switch (indexPath.section, indexPath.row) {
            case (1, 0):
                showAddPhotoAlertController()
            case (2, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (3, 0):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductCategory@Product", source: self, sender: nil)
            case (3, 1):
                AOLinkedStoryboardSegue.performWithIdentifier("ShopCategory@Product", source: self, sender: nil)
            case (4, 0):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductSelectAddress@Product", source: self, sender: indexPath)
            case (5, _):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
            case (10, 0):
                if modifyType == .edit && productModel.rulesStruct.isEmpty == true {
                    break
                }
                AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath)
            case (11, 0):
                let timeVC = TimeSelectViewController(nibName: "TimeSelectViewController", bundle: nil)
                timeVC.isTimeDetail = false
                timeVC.navTitle = "消费券起始日期"
                Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd"
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: productModel.startTime)
                navigationController?.pushViewController(timeVC, animated: true)
                timeVC.completeBlock = {(date) -> Void in
                   let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                      self.productModel.startTime = formatter.string(from: date as Date)
                }
            case (11, 1):
                let timeVC = TimeSelectViewController(nibName: "TimeSelectViewController", bundle: nil)
                timeVC.isTimeDetail = false
                timeVC.navTitle = "消费券截止日期"
                Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd"
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: productModel.closeTime)
                let originDate = Utility.sharedInstance.dateFormatter.date(from: productModel.closeTime)
                let originInterval = originDate?.timeIntervalSince1970
                navigationController?.pushViewController(timeVC, animated: true)
                timeVC.completeBlock = {(date) -> Void in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    /// 判断是否是延期
                    if  self.isdefer {
                        let currentSelectedInterval = (date as Date).timeIntervalSince1970
                        let intervalDeleta = currentSelectedInterval - (originInterval ?? 0)
                        if intervalDeleta > 3 * 30 * 24 * 60 * 60 {
                            Utility.showAlert(self, message: "每次只能延期3个月")
                        } else {
                            self.deferDate = formatter.string(from: date as Date)
                        }
                    } else {
                        self.productModel.closeTime = formatter.string(from: date as Date)
                    }
                }
            default:
                break
            }
            
        }
    }
    
    fileprivate func judgeAddStockNumAnddefer(cell: UITableViewCell, indexPath: IndexPath) {
        if isAddStockNum {
            cell.isUserInteractionEnabled = false
            switch productType {
            case .normal:
                switch (indexPath.section, indexPath.row) {
                case (8, 0), (2, 0), (2, 1), (4, _), (5, _): configOnlyStockNumCellEnable(cell: cell)
                default: break
                }
            case .service:
                switch (indexPath.section, indexPath.row) {
                case (9, 0), (2, 0), (2, 1), (5, _), (6, _): configOnlyStockNumCellEnable(cell: cell)
                default: break
                }
            }
        }
        if isdefer {
            cell.isUserInteractionEnabled = false
            switch productType {
            case .normal:
                break
            case .service:
                switch (indexPath.section, indexPath.row) {
                case (11, 1):
                    cell.isUserInteractionEnabled = true
                default: break
                }
            }
        }
    }
    
    fileprivate func configOnlyStockNumCellEnable(cell: UITableViewCell) {
        cell.isUserInteractionEnabled = true
    }
    
}

extension ProductAddNewViewController: UINavigationControllerDelegate {
    
}
