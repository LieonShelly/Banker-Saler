//
//  ProductHomeViewController.swift
//  FPTrade
//
//  Created by Kuma on 10/27/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

import UIKit
import pop
import SDWebImage
import HMSegmentedControl
import SnapKit
import MJRefresh

/// segment数据结构体
struct SegmentStruct {
    var status1: Int = 0
    var status2: Int = 0
    var status3: Int = 0
    var status4: Int = 0
    var status5: Int = 0
}

/// tableView数据源类
 class TableData {
    var dataArray: [ProductModel] = [] 
    var currentPage: Int = 0
    var totalPage: Int = 0
    var orderByIndex: Int = 0
    var catListIndexArray: [Int] = [Int]()
    var orderByID: String = "1"
    var catListIDArray: [String] = [String]()
    var isFirst: Int = 1
    var totalItems: String = "0"
    var selectedEventType: [EvetnType]? {
        didSet {
            /// 只有两种类型的商品，不选或者两种一起选择，type都不传，服务器默认为全部商品
             guard let event = selectedEventType else { return  }
            if  event.isEmpty || event.count == 2 {
                self.event = nil
            } else {
                self.event = selectedEventType?[0]
            }
            
        }
    }
    var selectedGoodsType: [GoodsType]? {
        didSet {
             guard let type = selectedGoodsType else { return  }
            if type.isEmpty || type.count == 2 {
                self.type = nil
            } else {
                self.type = selectedGoodsType?[0]
            }
        }
    }
    
    var event: EvetnType?
    var type: GoodsType?

}

class ProductHomeViewController: BaseViewController {
    @IBOutlet  weak var segmentView: UIView!
     let tableScrollView: UIScrollView! = UIScrollView()
    var tableViews = [UITableView]()
    var segmentStruct: SegmentStruct = SegmentStruct()
    var saleData: TableData = TableData()
    var stockData: TableData = TableData()
    var shelvesData: TableData = TableData()
    var exceptionData: TableData = TableData()
    var auditData: TableData = TableData()
    var draftData: TableData = TableData()
    var pInfo: ProductModel = ProductModel()
    lazy var launchPage: UIImageView = UIImageView()
    var firstFlag: Int = 0
    fileprivate lazy var refreshCoverView: UIView = {
        let refreshCoverView = UIView()
        refreshCoverView.backgroundColor = UIColor.commonBgColor()
        return refreshCoverView
    }()

    lazy var sumLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.textAlignment = .center
        tagLabel.font = UIFont.systemFont(ofSize: 12)
        tagLabel.textColor = UIColor.colorWithHex("0x9498a9")
        tagLabel.backgroundColor = UIColor.colorWithHex("0xfffbce")
        tagLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        return tagLabel
    }()

    lazy var titleView: PageTitleView = { [unowned self] in
        let x: CGFloat = 0
        let y: CGFloat = 0
        let height: CGFloat = self.segmentView.height
        let width: CGFloat = UIScreen.width
        let titleView = PageTitleView(frame: CGRect(x: x, y: y, width: width, height: height), titles: ["出售", "缺货", "下架", "审核中", "异常", "草稿"])
        titleView.backgroundColor = UIColor.white
        return titleView
        }()
     var startOffsetX: CGFloat = 0.0
     var  isForbiden: Bool = false
    
    @IBAction func addNewProductAction(_ sender: UIButton) {
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("AddNewObject@Main") as? AddNewObjectViewController else { return }
        modalViewController.dismissBtnCenter = sender.superview?.convert(sender.center, to: nil)
        modalViewController.objectInfos = [("发布生活服务", "生活服务是指，以电子券为消费形式的服务类商品，包括消费券、团购券、折扣券、抵用券等，商品分类包括电影、美食、休闲、娱乐等等", "BtnPublishIconPart0102"), ("发布普通商品", "普通商品是指，日常百货类实物商品，如服饰鞋包、家居家纺、美妆个护、母婴玩具、食品茶酒、数码家电等生活用品等", "BtnPublishIconPart0101")]
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
        
        modalViewController.selectItemCompletionBlock = { index in
            switch index {
            case 0:
                AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: ProductType.service.rawValue)
            case 1:
                AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: ProductType.normal.rawValue)
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "NaviIconQRCode"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProductHomeViewController.showQRScanPage))
        navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "NaviIconFilter"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProductHomeViewController.showFilterPage))
        navigationItem.rightBarButtonItem = rightBarItem
        let searchBar = UISearchBar()
        searchBar.placeholder = "请输入商品名/关键字"
        searchBar.searchBarStyle = .prominent
        searchBar.delegate = self
        searchBar.backgroundImage = Utility.createImageWithColor((self.navigationController?.navigationBar.barTintColor) ?? UIColor.white)
        searchBar.backgroundColor = self.navigationController?.navigationBar.barTintColor
        navigationItem.titleView = searchBar
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        createTableScrollView()
        setupPageTitleView()
        showLoadingPage()
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeDataSourceWhenSignOut), name: NSNotification.Name(rawValue: userSignOutNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeFilterConditions), name: NSNotification.Name(rawValue: removeProductFilterConditionsNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dataSourceNeedRefreshAfterAppear), name: NSNotification.Name(rawValue: dataSourceNeedRefreshWhenNewProductAddedNotification), object: nil)
        addSumLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if UserManager.sharedInstance.signedIn {
            launchPage.removeFromSuperview()
            if firstFlag == 0 {
                tableViews[0].mj_header.beginRefreshing()
//                segmentCtrl?.selectedSegmentIndex = 0
//                segmentedControlChangedValue(segmentCtrl ?? HMSegmentedControl())
            }
            firstFlag = 1
        }
        if UserManager.sharedInstance.incompleteStoreInfo {
            UserManager.sharedInstance.incompleteStoreInfo = false
            verificationGuide()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductEdit@Product" {
            guard let dVC = segue.destination as? ProductAddNewViewController else { return }
            if let indexPath = sender as? IndexPath {
                let tableData = judgeCurrentDataArray()
                let pInfo = tableData.dataArray[indexPath.section]
                dVC.productID = pInfo.goodsId
                let pType = Int(pInfo.type) ?? 1
                dVC.productType = ProductType(rawValue: pType - 1) ?? .normal
                dVC.modifyType = ObjectModifyType.edit
            } else {
                let type = ProductType(rawValue: sender as? Int  ?? 0)
                dVC.productType = type ?? .normal
                dVC.modifyType = ObjectModifyType.addNew
            }
        } else if segue.identifier == "ProductDetail@Product", let dVC = segue.destination as? ProductNDetailViewController {
            let tableData = judgeCurrentDataArray()
            if let indexPath = sender as? IndexPath {
                let goods_id = tableData.dataArray[indexPath.section].goodsId
                dVC.productID = goods_id
                let data = judgeCurrentDataArray()
                let pInfo = data.dataArray[indexPath.section]
                let pType = Int(pInfo.type) ?? 1
                dVC.productType = ProductType(rawValue: pType) ?? .normal
            }
        } else if segue.identifier == "ProductFilter@Product", let fVC = segue.destination as? ProductFilterViewController {
            let tableData = judgeCurrentDataArray()
            fVC.selectedSortIndex = tableData.orderByIndex
            fVC.selectedCategoryIndex = tableData.catListIndexArray
            if let event = tableData.selectedEventType {
                fVC.selectedEventType = event
            
            }
            if let type = tableData.selectedGoodsType {
                fVC.selectedGoodsType = type
            }
            fVC.selectCompletionBlock = {(orderByID, catListIDArray, orderByIndex, catListIndexArray, selectedEventType, selectedGoodsType) -> Void in
                tableData.orderByIndex = orderByIndex
                tableData.catListIndexArray = catListIndexArray
                tableData.orderByID = orderByID
                tableData.catListIDArray = catListIDArray
                tableData.selectedGoodsType = selectedGoodsType
                tableData.selectedEventType = selectedEventType
                Utility.showMBProgressHUDWithTxt("", dimBackground: false)
                self.requestData(.reload, params: nil)
            }
        } else if segue.identifier == "CommonWebViewScene@AccountSession", let destVC = segue.destination as? CommonWebViewController {
            destVC.htmlContent = sender as? String
            destVC.naviTitle = "预览"
        }
    }
    
    fileprivate func addSumLabel() {
        view.insertSubview(refreshCoverView, aboveSubview: tableViews[0])
        refreshCoverView.snp.makeConstraints({make in
            make.height.equalTo(30)
            make.left.equalTo(0)
            make.top.equalTo(segmentView.frame.maxY)
            make.right.equalTo(0)
        })
        refreshCoverView.addSubview(sumLabel)
        sumLabel.snp.makeConstraints({make in
            make.height.equalTo(30)
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.right.equalTo(0)
        })
    }
    
    func showSumLabel(text: String, tableView: UITableView) {
        DispatchQueue.main.async {
            self.sumLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.5) {
                self.sumLabel.text = text
                let select = tableView
                select.setContentOffset(CGPoint(x: 0, y: -30), animated: false)
                 self.sumLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func showSumLabelNoAnimation(text: String) {
        sumLabel.text = text
    }
}

extension ProductHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as? ProductTableViewCell else { return  UITableViewCell()}
            return cell
        } else {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoMoreFooterTableViewCell", for: indexPath) as? DoMoreFooterTableViewCell else { return  UITableViewCell()}
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        if tableView.isEqual(self.tableViews[0]) {
            if self.saleData.dataArray.count > indexPath.section {
                pInfo = self.saleData.dataArray[indexPath.section]
            }
        }
        if tableView.isEqual(self.tableViews[1]) {
            if self.stockData.dataArray.count > indexPath.section {
                pInfo = self.stockData.dataArray[indexPath.section]
            }
        }
        if tableView.isEqual(self.tableViews[2]) {
            if self.shelvesData.dataArray.count > indexPath.section {
                pInfo = self.shelvesData.dataArray[indexPath.section]
            }
        }
        if tableView.isEqual(self.tableViews[3]) {
            if self.auditData.dataArray.count > indexPath.section {
                pInfo = self.auditData.dataArray[indexPath.section]
            }
        }
        if tableView.isEqual(self.tableViews[4]) {
            if self.exceptionData.dataArray.count > indexPath.section {
                pInfo = self.exceptionData.dataArray[indexPath.section]
            }
        }
        if tableView.isEqual(self.tableViews[5]) {
            if self.draftData.dataArray.count > indexPath.section {
                pInfo = self.draftData.dataArray[indexPath.section]
            }
        }
        if indexPath.row == 0 {
            guard let pCell = cell as? ProductTableViewCell else {
                return
            }
            
            pCell.config(self.pInfo)
            pCell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
            
        } else {
            guard let pCell = cell as? DoMoreFooterTableViewCell, let typeValue = Int(pInfo.type), let productType = ProductType(rawValue: typeValue) else {
                return
            }
             let dataArray = self.judgeCurrentDataArray().dataArray
            if indexPath.section >= dataArray.count {
                return
            }
            let proID = dataArray[indexPath.section].goodsId
            switch (tableView, productType) {
            case (self.tableViews[0], .normal): // 出售
                 pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = "预览"
                pCell.buttonTitle3 = "补库存"
                pCell.buttonTitle2 = "下架"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock4 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                // 补库存
                pCell.buttonBlock3 = {fCell in
                   self.addStockNum(type: productType, productID: proID)
                }
                
                pCell.buttonBlock2 = {fCell in
                   guard let index = tableView.indexPath(for: fCell) else { return }
                     self.offShelves(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                      self.shareItem(index)
                    
                }
            case (self.tableViews[0], .service): // 出售
                pCell.buttonTitle5 = nil
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = "延期"
                pCell.buttonTitle3 = "补库存"
                pCell.buttonTitle2 = "下架"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock4 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.pInfo = self.saleData.dataArray[index.section]
                    self.deferProduct(type: .service, productID: proID)
                }
                
                // 补库存
                pCell.buttonBlock3 = {fCell in
                     self.pInfo = self.saleData.dataArray[indexPath.section]
                     self.addStockNum(type: productType, productID: proID)
                }
                
                pCell.buttonBlock2 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                   self.offShelves(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.shareItem(index)
                }
            case (self.tableViews[1], .normal), (self.tableViews[1], .service): // 缺货
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = "预览"
                pCell.buttonTitle3 = "补库存"
                pCell.buttonTitle2 = "下架"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock4 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                // 补库存
                pCell.buttonBlock3 = {fCell in
                    if self.stockData.dataArray.count > indexPath.section {
                        self.pInfo = self.stockData.dataArray[indexPath.section]
                    }
                     self.addStockNum(type: productType, productID: proID)
                }
                
                pCell.buttonBlock2 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                     self.offShelves(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.shareItem(index)
                   
                }
            case (self.tableViews[2], .normal):
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = "预览"
                pCell.buttonTitle3 = "编辑"
                pCell.buttonTitle2 = "提交审核"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock4 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock3 = {fCell in
                    self.pushToEditVC(type: productType, productID: proID)
                    
                }
                
                pCell.buttonBlock2 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.onShelves(index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.deleteProduct(index)
                }

            case  (self.tableViews[2], .service): // 下架
                if let closeTime = pInfo.closeTime, Date().compare(closeTime)  == .orderedDescending || Date().compare(closeTime) == .orderedSame {
                    pCell.buttonTitle5 = nil
                    pCell.buttonTitle4 = "预览"
                    pCell.buttonTitle3 = "编辑"
                    pCell.buttonTitle2 = "提交审核"
                    pCell.buttonTitle1 = "删除"
                    pCell.buttonBlock4 = {fCell in
                        guard  let index = tableView.indexPath(for: fCell) else { return }
                        self.seePreview(index)
                    }
                    pCell.buttonBlock3 = {fCell in
                        self.pushToEditVC(type: productType, productID: proID)
                        
                    }
                    
                    pCell.buttonBlock2 = {fCell in
                        guard let index = tableView.indexPath(for: fCell) else { return }
                        self.onShelves(index)
                    }
                    pCell.buttonBlock1 = {fCell in
                        guard let index = tableView.indexPath(for: fCell) else { return }
                        self.deleteProduct(index)
                    }
                } else {
                    pCell.buttonTitle5 = nil
                     pCell.buttonTitle4 = nil
                    pCell.buttonTitle3 = "预览"
                    pCell.buttonTitle2 = "编辑"
                    pCell.buttonTitle1 = "提交审核"
                   
                    pCell.buttonBlock3 = {fCell in
                        guard  let index = tableView.indexPath(for: fCell) else { return }
                        self.seePreview(index)
                    }
                    pCell.buttonBlock2 = {fCell in
                        self.pushToEditVC(type: productType, productID: proID)
                    }
                    pCell.buttonBlock1 = {fCell in
                        guard let index = tableView.indexPath(for: fCell) else { return }
                        self.onShelves(index)
                    }
                }
               
            case (self.tableViews[3], .normal), (self.tableViews[3], .service): // 审核
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = nil
                pCell.buttonTitle1 = "预览"
                
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
            case (self.tableViews[4], .normal), (self.tableViews[4], .service):
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "编辑"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock3 = {fCell in
                    guard  let index = tableView.indexPath(for: fCell) else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = {fCell in
                    self.pushToEditVC(type: productType, productID: proID)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.deleteProduct(index)
                }
            case (self.tableViews[5], .normal), (self.tableViews[5], .service):
                pCell.buttonTitle5 = nil
                pCell.buttonTitle4 = nil
                pCell.buttonTitle3 = nil
                pCell.buttonTitle2 = "编辑"
                pCell.buttonTitle1 = "删除"
               
                pCell.buttonBlock2 = {fCell in
                    self.pushToEditVC(type: productType, productID: proID)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.deleteProduct(index)
                }
            default:
                break
            }
            
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case self.tableViews[0]:
            return saleData.dataArray.count
        case self.tableViews[1]:
            return stockData.dataArray.count
        case self.tableViews[2]:
            return shelvesData.dataArray.count
        case self.tableViews[4]:
            return exceptionData.dataArray.count
        case self.tableViews[3]:
            return auditData.dataArray.count
        case self.tableViews[5]:
            return draftData.dataArray.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

}

extension ProductHomeViewController: UIScrollViewDelegate {
    private func displayTag() {
        switch titleView.currentIndex {
        case 0:
            showSumLabelNoAnimation(text: "您当前出售的商品数量为:\(self.saleData.totalItems)")
        case 1:
            showSumLabelNoAnimation(text: "您当前缺货的商品数量为:\(self.stockData.totalItems)")
        case 2:
            showSumLabelNoAnimation(text: "您当前下架的商品数量为:\(self.shelvesData.totalItems)")
        case 3:
            showSumLabelNoAnimation(text: "您当前审核中的商品数量为:\(self.auditData.totalItems)")
        case 4:
            showSumLabelNoAnimation(text: "您当前异常的商品数量为:\(self.exceptionData.totalItems)")
        case 5:
            showSumLabelNoAnimation(text: "您当前草稿的数量为:\(self.draftData.totalItems)")
        default:
            break
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        displayTag()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            return
        }
        isForbiden = false
        startOffsetX = scrollView.contentOffset.x
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            return
        }
        if isForbiden {
            return
        }
        let currentOffsetX = scrollView.contentOffset.x
        var targetIndex: Int = 0
        var sourceIndex: Int = 0
        var progress: CGFloat = 0.0
         let titleCount: Int = 6
        let scrollViewWidth = scrollView.frame.width
        if currentOffsetX > startOffsetX {
            progress = currentOffsetX / scrollViewWidth - floor(currentOffsetX / scrollViewWidth)
            sourceIndex = Int(currentOffsetX / scrollViewWidth)
            targetIndex = sourceIndex + 1
           
            if targetIndex >= titleCount {
                targetIndex = titleCount - 1
            }
            if currentOffsetX - startOffsetX == scrollViewWidth {
                progress = 1
                targetIndex = sourceIndex
            }
        } else {
            progress = 1 - currentOffsetX/scrollViewWidth  + floor(currentOffsetX / scrollViewWidth)
            targetIndex = Int(currentOffsetX / scrollViewWidth)
            sourceIndex = targetIndex + 1
            if sourceIndex >= titleCount {
                sourceIndex = titleCount - 1
            }
        }
        titleView.setTitle(progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
        displayTag()

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tableScrollView {
            switch titleView.currentIndex {
            case 0: judgeDataArray(self.saleData)
            showSumLabelNoAnimation(text: "您当前出售的商品数量为:\(self.saleData.totalItems)")
            case 1: judgeDataArray(self.stockData)
            showSumLabelNoAnimation(text: "您当前缺货的商品数量为:\(self.stockData.totalItems)")
            case 2: judgeDataArray(self.shelvesData)
            showSumLabelNoAnimation(text: "您当前下架的商品数量为:\(self.shelvesData.totalItems)")
            case 3: judgeDataArray(self.auditData)
            showSumLabelNoAnimation(text: "您当前审核中的商品数量为:\(self.auditData.totalItems)")
            case 4: judgeDataArray(self.exceptionData)
            showSumLabelNoAnimation(text: "您当前异常的商品数量为:\(self.exceptionData.totalItems)")
            case 5: judgeDataArray(self.draftData)
            showSumLabelNoAnimation(text: "您当前草稿的数量为:\(self.draftData.totalItems)")
            default: break
            }

        }
    }
}

extension ProductHomeViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        AOLinkedStoryboardSegue.performWithIdentifier("ProductSearch@Product", source: self, sender: nil)
        return false
    }
}

extension ProductHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
        if indexPath.row == 0 {
            if tableView.isEqual(self.tableViews[0]) {
                    pInfo = self.saleData.dataArray[indexPath.section]
                    return pInfo.type == "1" ? 150 : 110
            }
            if tableView.isEqual(self.tableViews[1]) {
                    pInfo = self.stockData.dataArray[indexPath.section]
                    return pInfo.type == "1" ? 150 : 110
            }
            if tableView.isEqual(self.tableViews[2]) {
                    pInfo = self.shelvesData.dataArray[indexPath.section]
                    return pInfo.type == "1" ? 150 : 110
            }
            if tableView.isEqual(self.tableViews[3]) {
                    pInfo = self.auditData.dataArray[indexPath.section]
                    return pInfo.type == "1" ? 150 : 110
            }
            if tableView.isEqual(self.tableViews[4]) {
                    pInfo = self.exceptionData.dataArray[indexPath.section]
                    return pInfo.type == "1" ? 150 : 110
            }
            if tableView.isEqual(self.tableViews[5]) {
                pInfo = self.draftData.dataArray[indexPath.section]
                return pInfo.type == "1" ? 150 : 110
            }
        } else {
            return 45.0
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDetail@Product", source: self, sender: indexPath)
        }
    }
}
