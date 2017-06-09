//
//  ProductHomeHelper.swift
//  AdForMerchant
//
//  Created by lieon on 2016/12/29.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import HMSegmentedControl

extension ProductHomeViewController {
    func setupPageTitleView() {
        segmentView.addSubview(titleView)
        titleView.titleTapAction = { [unowned self] selectedIndex in
            self.isForbiden = true
            let offsetX = CGFloat(selectedIndex) * screenW
            self.tableScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            self.requestListWithReload()
        }
    }
    
    func createTableScrollView() {
        self.tableScrollView.delegate = self
        self.tableScrollView.bounces = false
        self.tableScrollView.isPagingEnabled = true
        self.tableScrollView.showsHorizontalScrollIndicator = false
        self.tableScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableScrollView)
        self.tableScrollView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(40)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
        self.tableViews.removeAll()
        var next_table: UITableView?
        for index in 0 ..< 6 {
            let table = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
            table.delegate = self
            table.dataSource = self
            table.backgroundColor = UIColor.commonBgColor()
            table.separatorColor = table.backgroundColor
            table.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
            table.register(UINib(nibName: "DoMoreFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "DoMoreFooterTableViewCell")
            table.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
            table.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
            self.tableScrollView.addSubview(table)
            self.tableViews.append(table)
            table.snp.makeConstraints({ (make) -> Void in
                if let last = next_table {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalTo(self.tableScrollView.snp.leading)
                }
                make.top.equalTo(self.tableScrollView.snp.top)
                make.bottom.equalTo(self.tableScrollView.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(self.tableScrollView.snp.height)
                if index == 5 {
                    make.trailing.equalTo(self.tableScrollView.snp.trailing)
                }
            })
            table.contentInset = UIEdgeInsets(top: 33, left: 0, bottom: 0, right: 0)
            table.contentOffset = CGPoint(x: 0.0, y: 0.0)
            next_table = table
        }
    }
    
    func showLoadingPage() {
        launchPage.contentMode = .scaleAspectFill
        launchPage.image = UIImage(named: "SigninBg")
        
        let screenSize = UIScreen.main.bounds
        launchPage.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        self.tabBarController?.view.addSubview(launchPage)
        let constrsH = NSLayoutConstraint.constraints(withVisualFormat: "[launchPage(\(screenSize.width))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["launchPage": launchPage])
        let constrsV = NSLayoutConstraint.constraints(withVisualFormat: "V:[launchPage(\(screenSize.height))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["launchPage": launchPage])
        
        launchPage.addConstraints(constrsH)
        launchPage.addConstraints(constrsV)
    }
    
    func showQRScanPage() {
        
        guard  let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ScanQR@Main") as? QRViewController else { return }
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
        
    }
    
    func showFilterPage() {
        AOLinkedStoryboardSegue.performWithIdentifier("ProductFilter@Product", source: self, sender: nil)
    }
    
}

extension ProductHomeViewController {
    func setFetchData(_ data: TableData, page: Int, result: [String: Any], refreshType: DataRefreshType) {
        guard let tempArray = result["items"] as? [Any] else { return }
        if  refreshType == .reload {
            data.dataArray.removeAll(keepingCapacity: false)
        }
        data.dataArray += tempArray.flatMap {
            if let json = $0 as? [String: Any] {
                return ProductModel(JSON: json)
            } else {
                return nil
            }
        }
        data.totalItems = result["total_items"] as? String ?? "0"
        data.totalPage = Int(result["total_page"] as? String ?? "0") ?? 0
    }
    
    func dataSourceNeedRefreshAfterAppear(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Int] {
            let status = ProductSaleStatus(rawValue: userInfo["ProductSaleStatus"]!)
            if status == ProductSaleStatus.waitingForReview {
                self.tableScrollView.setContentOffset( CGPoint(x: 3 * screenW, y: 0.0), animated: true)
                self.titleView.setTitle(progress: 1, sourceIndex: titleView.currentIndex, targetIndex: 3)
                self.tableViews[3].mj_header.beginRefreshing()
            }
            if status == ProductSaleStatus.draft {
                self.titleView.setTitle(progress: 1, sourceIndex: titleView.currentIndex, targetIndex: 5)
                self.tableScrollView.setContentOffset( CGPoint(x: 5 * screenW, y: 0.0), animated: true)
                self.tableViews[5].mj_header.beginRefreshing()
                
            }
        }
    }
    
    func removeFilterConditions() {
        for tableData in [saleData, stockData, shelvesData, auditData, exceptionData] {
            tableData.catListIDArray.removeAll()
            tableData.catListIndexArray.removeAll()
            tableData.orderByID = "1"
            tableData.orderByIndex = 0
        }
    }
    
    func segmentedControlChangedValue(index: Int) {
        tableScrollView.scrollRectToVisible(tableViews[index].frame, animated: true)
        requestListWithReload()
    }
    
    func judgeCurrentDataArray() -> TableData {
        switch titleView.currentIndex {
        case 0: return self.saleData
        case 1: return self.stockData
        case 2: return self.shelvesData
        case 3: return self.auditData //activityData // 活动 -> 审核中
        case 4: return self.exceptionData // 需要填一个异常数组
        case 5: return self.draftData
        default: return self.saleData
        }
    }
    
    func judgeDataArray(_ data: TableData) {
        requestListWithReload()
        //         self.tableViews[indexSelect - 1].mj_header.beginRefreshing()
        //        if data.isFirst == 1 {
        //            self.tableViews[indexSelect - 1].mj_header.beginRefreshing()
        //            data.isFirst = 0
        //        }
    }
    
    func nodataBgView(_ segmentIndex: Int) -> UIView {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableScrollView.bounds.height))
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.numberOfLines = 2
        descLbl.textAlignment = NSTextAlignment.center
        switch segmentIndex {
        case 0:
            descLbl.text = "您当前没有在售商品，请点“+”发布"
        case 1:
            descLbl.text = "没有缺货的商品"
        case 2:
            descLbl.text = "没有下架的商品"
        case 3:
            descLbl.text = "没有活动的商品"
        case 4:
            descLbl.text = "没有异常的商品"
        case 5:
            descLbl.text = "没有草稿的商品"
        default:
            break
        }
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
    }
    
    func filterStatus(_ params: inout [String: Any]) {
        params["orderby"] = judgeCurrentDataArray().orderByID
        if judgeCurrentDataArray().catListIDArray.isEmpty == false {
            var catID = [Any]()
            for item in judgeCurrentDataArray().catListIDArray {
                catID.append(item)
            }
            params["cat_id"] = catID
        }
        filterParams(&params, filterKey: "status1_cat_id", catListIDArr: saleData.catListIDArray)
        filterParams(&params, filterKey: "status2_cat_id", catListIDArr: stockData.catListIDArray)
        filterParams(&params, filterKey: "status3_cat_id", catListIDArr: shelvesData.catListIDArray)
        filterParams(&params, filterKey: "status4_cat_id", catListIDArr: exceptionData.catListIDArray)
        filterParams(&params, filterKey: "status0_cat_id", catListIDArr: auditData.catListIDArray)
    }
    
    func filterParams( _ params: inout [String: Any], filterKey: String, catListIDArr: [Any]) {
        //        var par = params
        var dicArr = [Any]()
        for item in catListIDArr {
            dicArr.append(item)
        }
        params[filterKey] = dicArr
    }
    
    func verificationGuide() {
        Utility.showConfirmAlert(self, title: "温馨提示", cancelButtonTitle: "暂不认证", confirmButtonTitle: "马上认证", message: "您已经注册成功，认证后方可使用本平台的所有功能，建议您先进行商家实名认证") {
            if let merchantCenter = UIStoryboard(name: "MerchantCenter", bundle: nil).instantiateViewController(withIdentifier: "MerchantCenterVerification") as? MerchantCenterVerificationViewController {
                let nav: UINavigationController = UINavigationController.init(rootViewController: merchantCenter)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    func shareItem(_ indexPath: IndexPath) {
        let info = judgeCurrentDataArray().dataArray[indexPath.section]
        
        let shareVC = ShareViewController()
        shareVC.shareTitle = info.title
        shareVC.shareDetailLink = info.shareUrl
        shareVC.shareItems = [.wechatFriends, .wechatCircle, .qqFriends, .copyLink]
        shareVC.transitioningDelegate = shareVC
        shareVC.modalPresentationStyle = .custom
        navigationController?.present(shareVC, animated: true, completion: nil)
    }
    
    func removeDataSourceWhenSignOut() {
        for tableData in [saleData, stockData, shelvesData, auditData, exceptionData] {
            tableData.dataArray.removeAll()
            tableData.catListIDArray.removeAll()
            tableData.catListIndexArray.removeAll()
            tableData.currentPage = 0
            tableData.totalPage = 0
            tableData.orderByID = "1"
            tableData.orderByIndex = 0
            tableData.isFirst = 1
        }
        for table in self.tableViews {
            table.mj_header.endRefreshing()
            table.mj_footer.endRefreshing()
            table.reloadData()
        }
        firstFlag = 0
    }
}

extension ProductHomeViewController {
    func deferProduct(type: ProductType, productID: String) {
        guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        destVC.modifyType = .edit
        destVC.productType = type
        destVC.productID = productID
        destVC.isdefer = true
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func addStockNum(type: ProductType, productID: String) {
        guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        destVC.modifyType = .edit
        destVC.productType = type
        destVC.productID = productID
        destVC.isAddStockNum = true
        navigationController?.pushViewController(destVC, animated: true)
        
    }
    func pushToEditVC(type: ProductType, productID: String) {
        guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        destVC.modifyType = .edit
        destVC.productType = type
        destVC.productID = productID
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func onShelves(_ indexPath: IndexPath) {
        let proID = judgeCurrentDataArray().dataArray[indexPath.section].goodsId
        let params = ["goods_id": proID]
        let product = judgeCurrentDataArray().dataArray[indexPath.section]
       
         guard  let typeValue = Int(product.type), let type = ProductType(rawValue: typeValue) else { return  }
        if type == .normal, let stockNum = Int(product.stockNum), stockNum == 0 {
           Utility.showConfirmAlert(self, message: "库存为0，请补充库存", confirmCompletion: {
                self.pushToEditVC(type: type, productID:proID )
                return
            
           })
        } else if type == .service { // FIXME:添加判断条件
            Utility.showConfirmAlert(self, message: "消费券使用日期已截止，请修改", confirmCompletion: {
                 self.pushToEditVC(type: type, productID:proID )
                return
            })
        } else {
            Utility.showConfirmAlert(self, message: "是否确认上架该商品", confirmCompletion: {
            Utility.showMBProgressHUDWithTxt()
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
            RequestManager.request(AFMRequest.goodsPutaway(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) in
                Utility.hideMBProgressHUD()
                if object == nil {
                    Utility.showAlert(self, message: msg ?? "")
                    return
                }
                self.requestListWithReload()
            })
        })
    }
    }
    
    func offShelves(_ indexPath: IndexPath) {
        let proID = judgeCurrentDataArray().dataArray[indexPath.section].goodsId
        let params = ["goods_id": proID]
        
        Utility.showConfirmAlert(self, message: "商品下架后，可在已下架商品中再次上架，确认下架？", confirmCompletion: {
            Utility.showMBProgressHUDWithTxt()
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
            RequestManager.request(AFMRequest.goodsSoldout(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
                Utility.hideMBProgressHUD()
                if object == nil {
                    Utility.showAlert(self, message: msg ?? "")
                    return
                }
                self.requestListWithReload()
            }
        })
    }
    
    func seePreview(_ indexPath: IndexPath) {
        let proID = judgeCurrentDataArray().dataArray[indexPath.section].goodsId
        
        let params = ["goods_id": proID]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsPreview(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if object == nil {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            } else {
                guard  let result = object as? [String: Any] else { return }
                guard let html = result["html"] as? String else { return }
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html)
            }
        }
        
    }
    
    func deleteProduct(_ indexPath: IndexPath) {
        
        let productId = judgeCurrentDataArray().dataArray[indexPath.section].goodsId
        let params = ["goods_id": productId]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showConfirmAlert(self, message: "是否确认删除该商品", confirmCompletion: {
            RequestManager.request(AFMRequest.goodsDel(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
                if object == nil {
                    if let msg = msg {
                        Utility.showAlert(self, message: msg)
                    }
                    return
                }
                
                self.requestListWithReload()
            }
        })
    }
    
    func requestDoubleClickListWithReload() {
        let table = self.tableViews[titleView.currentIndex]
        table.mj_header.beginRefreshing()
    }
    
    func requestListWithReload() {
        requestData(.reload, params: nil)
    }
    
    func requestListWithAppend() {
        requestData(.append, params: nil)
    }
    
    func requestData(_ refreshType: DataRefreshType, params: [String: AnyObject]?) {
        var parameters: [String: Any] = [:]
        // status	int	true	状态：0-待审核 1-出售中 2-无库存 3-下架 4-异常(审核不通过)
        var status: Int = 0
        switch titleView.currentIndex {
        case 0:
            status = 1
        case 1:
            status = 2
        case 2:
            status = 3
        case 3:
            status = 0
        case 4:
            status = 4
        case 5:
            status = 5
        default:
            break
        }
        parameters = params ?? ["status": String(status), "orderby": judgeCurrentDataArray().orderByID, "page": "1"]
        if let type = judgeCurrentDataArray().type {
            parameters["type"] = type.rawValue
        }
        
        if let event = judgeCurrentDataArray().event {
            parameters["event"] = event.rawValue
        }
        let data = judgeCurrentDataArray()
        if refreshType == .reload {
            data.currentPage = 1
            parameters["page"] = data.currentPage
        } else {
            if data.currentPage < data.totalPage {
                data.currentPage += 1
                parameters["page"] = data.currentPage
            } else {
                self.tableViews[titleView.currentIndex].mj_footer.endRefreshingWithNoMoreData()
                return
            }
        }
        
        self.filterStatus(&parameters)
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsIndex(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if let object = object {
                guard  let result = object as? [String: Any] else { return }
                switch self.titleView.currentIndex {
                case 0: // 出售中
                    self.setFetchData(self.saleData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.saleData.dataArray.isEmpty == true {
                        self.tableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                    } else {
                        self.tableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前出售的商品数量为:\(self.saleData.totalItems)", tableView:self.tableViews[self.titleView.currentIndex] )
                case 1: // 无库存
                    self.setFetchData(self.stockData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.stockData.dataArray.isEmpty == true {
                        self.tableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                        
                    } else {
                        self.tableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前缺货的商品数量为:\(self.stockData.totalItems)", tableView:self.tableViews[self.titleView.currentIndex]  )
                case 2: // 下架
                    self.setFetchData(self.shelvesData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.shelvesData.dataArray.isEmpty == true {
                        self.tableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                        
                    } else {
                        self.tableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前下架的商品数量为:\(self.shelvesData.totalItems)", tableView:self.tableViews[self.titleView.currentIndex]  )
                case 3: // 待审核
                    self.setFetchData(self.auditData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.auditData.dataArray.isEmpty == true {
                        self.tableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                    } else {
                        self.tableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前审核中的商品数量为:\(self.auditData.totalItems)", tableView:self.tableViews[self.titleView.currentIndex]  )
                case 4: // 异常
                    self.setFetchData(self.exceptionData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.exceptionData.dataArray.isEmpty == true {
                        self.tableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                        
                    } else {
                        self.tableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前异常的商品数量为:\(self.exceptionData.totalItems)", tableView:self.tableViews[self.titleView.currentIndex]  )
                case 5: //草稿
                    self.setFetchData(self.draftData, page: data.currentPage, result: result, refreshType: refreshType)
                    if self.draftData.dataArray.isEmpty == true {
                        self.tableViews[self.titleView.currentIndex].backgroundView = self.nodataBgView(self.titleView.currentIndex)
                        
                    } else {
                        self.tableViews[self.titleView.currentIndex].backgroundView = nil
                    }
                    self.showSumLabel(text: "您当前的草稿数量为:\(self.draftData.totalItems)", tableView:self.tableViews[self.titleView.currentIndex]  )
                default: break
                }
                
                self.tableViews[self.titleView.currentIndex].reloadData()
                self.tableViews[self.titleView.currentIndex].mj_header.endRefreshing()
                self.tableViews[self.titleView.currentIndex].mj_footer.endRefreshing()
                
            } else {
                self.tableViews[self.titleView.currentIndex].mj_header.endRefreshing()
                self.tableViews[self.titleView.currentIndex].mj_footer.endRefreshing()
            }
        }
    }
}
