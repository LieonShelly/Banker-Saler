//
//  ProductSearchViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/17/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import MJRefresh
import ObjectMapper

class ProductSearchViewController: BaseViewController, UIScrollViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    var bgView: UIScrollView!
    var searchBar: UISearchBar!
    var keyword: String = ""
    
    fileprivate var dataArray: [ProductModel] = []
    
    var keywordsHistoryArray: [String] = []
    
    var currentPage: Int = 0
    var totalPage: Int = 0
    @IBAction func showCampaignList() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getHistoryArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductEdit@Product" {
            guard let dVC = segue.destination as? ProductAddNewViewController else {return}
            if let indexPath = sender as? IndexPath {
                let pInfo = dataArray[indexPath.section]
                dVC.productID = pInfo.goodsId
                let pType = Int(pInfo.type) ?? 1
                dVC.productType = ProductType(rawValue: pType - 1) ?? .normal
                dVC.modifyType = ObjectModifyType.edit
            }
        } else if segue.identifier == "ProductDetail@Product", let dVC = segue.destination as? ProductNDetailViewController {
            if let indexPath = sender as? IndexPath {
                let pInfo = dataArray[indexPath.section]
                dVC.productID = pInfo.goodsId
                guard let pType = Int(pInfo.type) else {return}
                dVC.productType = ProductType(rawValue: pType-1) ?? .normal
            }
        } else if segue.identifier == "CommonWebViewScene@AccountSession", let destVC = segue.destination as? CommonWebViewController {
            destVC.htmlContent = sender as? String
            destVC.naviTitle = "预览"
        }
    }
}

extension ProductSearchViewController {
    fileprivate func setupUI() {
        navigationItem.hidesBackButton = true
        
        let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backAction))
        navigationItem.rightBarButtonItem = rightBarItem
        
        searchBar = UISearchBar()
        searchBar.placeholder = "请输入商品名/关键字"
        searchBar.searchBarStyle = .prominent
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = Utility.createImageWithColor((self.navigationController?.navigationBar.barTintColor) ?? UIColor.white)
        searchBar.becomeFirstResponder()
        searchBar.tintColor = UIColor.gray
        navigationItem.titleView = searchBar
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = .commonBgColor()
        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        tableView.register(UINib(nibName: "DoMoreFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "DoMoreFooterTableViewCell")
        tableView.keyboardDismissMode = .onDrag
        tableView.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
    }
    
    @objc fileprivate func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate  func recentKeywordBgView() -> UIView {
        
        if bgView == nil {
            bgView = UIScrollView(frame: view.bounds)
            bgView.backgroundColor = UIColor.white
        }
        
        for subview in bgView.subviews {
            subview.removeFromSuperview()
        }
        
        let recentSearchLbl = UILabel(frame:CGRect(x: 12, y: 0, width: 100, height: 44))
        recentSearchLbl.text = "历史搜索"
        recentSearchLbl.font = UIFont.systemFont(ofSize: 17.0)
        recentSearchLbl.textColor = UIColor.colorWithHex("ADAFBC")
        recentSearchLbl.textAlignment = .left
        bgView.addSubview(recentSearchLbl)
        
        let line = SeparatorLine(frame:CGRect(x: 12, y: 44, width: screenWidth, height: 0.5))
        line.backgroundColor = UIColor.backgroundLightGreyColor()
        bgView.addSubview(line)
        
        for i in 0 ..< keywordsHistoryArray.count {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: 12, y: 44 + CGFloat(i) * 44, width: bgView.frame.width, height: 44)
            btn.contentHorizontalAlignment = .left
            btn.setTitle(keywordsHistoryArray[i], for: UIControlState())
            btn.setTitleColor(UIColor.colorWithHex("141414"), for: UIControlState())
            btn.addTarget(self, action: #selector(self.searchKeywordWithHistoryBtn(_:)), for: .touchUpInside)
            bgView.addSubview(btn)
            
            let line = SeparatorLine(frame:CGRect(x: 12, y: 88 + CGFloat(i) * 44, width: screenWidth, height: 0.5))
            line.backgroundColor = UIColor.backgroundLightGreyColor()
            bgView.addSubview(line)
        }
        
        let attrTxt = NSAttributedString(string: "清空搜索历史", attributes: [NSForegroundColorAttributeName: UIColor.colorWithHex("ADAFBC"), NSFontAttributeName: UIFont.systemFont(ofSize: 15.0)])
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: (screenWidth - 134) / 2, y: 50 + CGFloat(keywordsHistoryArray.count) * 46, width: 134, height: 44)
        btn.setAttributedTitle(attrTxt, for: UIControlState())
        btn.addTarget(self, action: #selector(self.searchKeywordWithClearHistoryBtn(_:)), for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 22.0
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor.colorWithHex("ADAFBC").cgColor
        bgView.addSubview(btn)
        
        bgView.contentSize = CGSize(width: screenWidth, height: btn.frame.maxY + 50)
        
        return bgView
    }
    
    fileprivate func nodataBgView() -> UIView {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableView.bounds.height))
        
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.text = "搜索结果为空"
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        return bgView
        
    }
    
    @objc fileprivate func searchKeywordWithHistoryBtn(_ btn: UIButton) {
        searchKeyword(btn.title(for: UIControlState()) ?? "")
    }
    
    @objc fileprivate  func searchKeywordWithClearHistoryBtn(_ btn: UIButton) {
        clearHistoryArray()
    }
    
    fileprivate   func searchKeyword(_ keyword: String) {
        searchBar.resignFirstResponder()
        if keyword.isEmpty {
            return
        }
        self.keyword = keyword
        addHistoryArray(keyword)
        searchBar.text = keyword
        tableView.backgroundView = nil
        tableView.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        requestListWithReload()
    }
    
    fileprivate  func getHistoryArray() {
        let userDef = UserDefaults.standard
        if let array = userDef.value(forKey: "KeywordsHistory") as? [String] {
            keywordsHistoryArray = array
        }
        tableView.backgroundView = recentKeywordBgView()
    }
    
    fileprivate func addHistoryArray(_ str: String) {
        let userDef = UserDefaults.standard
        var indexOfItemFound = -1
        for (index, item) in keywordsHistoryArray.enumerated() where item == str {
            indexOfItemFound = index
            break
        }
        
        if indexOfItemFound >= 0 {
            keywordsHistoryArray.remove(at: indexOfItemFound)
        }
        
        if keywordsHistoryArray.count >= 10 {
            keywordsHistoryArray.removeLast()
            keywordsHistoryArray.insert(str, at: 0)
        } else {
            keywordsHistoryArray.insert(str, at: 0)
        }
        userDef.set(keywordsHistoryArray, forKey: "KeywordsHistory")
        tableView.backgroundView = recentKeywordBgView()
    }
    
    fileprivate  func clearHistoryArray() {
        keywordsHistoryArray.removeAll()
        let userDef = UserDefaults.standard
        userDef.set(keywordsHistoryArray, forKey: "KeywordsHistory")
        tableView.backgroundView = recentKeywordBgView()
    }
}

extension ProductSearchViewController {
   fileprivate func seePreview(_ indexPath: IndexPath) {
        let proID = dataArray[indexPath.section].goodsId
        
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
                guard let result = object as? [String: AnyObject], let html = result["html"] as? String else { return }
                AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html)
            }
        }
    }
    
   fileprivate func shareItem(_ indexPath: IndexPath) {
        let info = dataArray[indexPath.section]
        
        let shareVC = ShareViewController()
        shareVC.shareTitle = info.title
        shareVC.shareDetailLink = info.shareUrl
        shareVC.shareItems = [.wechatFriends, .wechatCircle, .qqFriends, .copyLink]
        shareVC.transitioningDelegate = shareVC
        shareVC.modalPresentationStyle = .custom
        navigationController?.present(shareVC, animated: true, completion: nil)
    }
    
   fileprivate func requestListWithReload() {
        requestList(.reload)
    }
    
   fileprivate func requestListWithAppend() {
        requestList(.append)
    }
    
   fileprivate func requestList(_ refreshType: DataRefreshType) {
        var params: [String: AnyObject] = [:]
        params["keyword"] = keyword as AnyObject?
        if refreshType == .reload {
            currentPage = 1
            params["page"] = currentPage as AnyObject?
        } else {
            if currentPage < totalPage {
                currentPage += 1
                params["page"] = currentPage as AnyObject?
            } else {
                if let footer = tableView.mj_footer {
                    footer.endRefreshingWithNoMoreData()
                    return
                }
            }
        }
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsSearch(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let footer = self.tableView.mj_footer {
                footer.endRefreshing()
            }
            
            Utility.hideMBProgressHUD()
            if let result = object as? [String: Any] {
                self.totalPage =  (result["total_page"] as? Int) ?? 0
                if refreshType == .reload {
                    self.dataArray.removeAll(keepingCapacity: false)
                }
                
                var tempArray: [ProductModel] = []
                if let productArray = result["items"] as? [[String: Any]] {
                    for obj in productArray {
                        if let model = Mapper<ProductModel>().map(JSON: obj) {
                            tempArray.append(model)
                        }
                    }
                }
                self.dataArray.append(contentsOf: tempArray)
                if self.dataArray.isEmpty {
                    self.tableView.backgroundView = self.nodataBgView()
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
   fileprivate func shelves(_ indexPath: IndexPath) {
        //获取当前点击的商品ID
        //        let tableData = judgeCurrentDataArray()
        
        let pInfo = dataArray[indexPath.section]
        let proID = pInfo.goodsId
        let params = ["goods_id": proID]
        
        if pInfo.status == .offShelf {
            let alertController = UIAlertController(title: "提示", message: "是否确认上架该商品", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: { (alert) in
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
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "提示", message: "是否确认下架该商品", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: { (alert) in
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
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
   fileprivate  func deleteProduct(_ indexPath: IndexPath) {
        
        let productId = dataArray[indexPath.section].goodsId
        let params = ["goods_id": productId]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsDel(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            if object == nil {
                Utility.showAlert(self, message: msg ?? "")
                return
            }
            let alertCtr = UIAlertController(title: "提示", message: msg ?? "", preferredStyle: .alert)
            let confimAct = UIAlertAction(title: "确定", style: .default, handler: { (alert) in
                _ = self.navigationController?.popViewController(animated: true)
            })
            alertCtr.addAction(confimAct)
            self.present(alertCtr, animated: true, completion: nil)
        }
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            keyword = Utility.getTextByTrim(text)
            if !keyword.isEmpty {
                if Utility.isIllegalCharacter(keyword) {
                    searchBar.resignFirstResponder()
                    addHistoryArray(keyword)
                    tableView.backgroundView = nil
                    requestListWithReload()
                } else {
                    Utility.showMBProgressHUDWithTxt()
                    tableView.backgroundView = nodataBgView()
                    Utility.hideMBProgressHUD()
                    return
                }
            }
        }
    }
}

extension ProductSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as? ProductTableViewCell else {  return UITableViewCell()   }
            return cell
        } else {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoMoreFooterTableViewCell", for: indexPath) as?DoMoreFooterTableViewCell else {  return UITableViewCell()   }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        let pInfo = dataArray[indexPath.section]
        if indexPath.row == 0 {
            guard let pCell = cell as? ProductTableViewCell else {
                return
            }
            
            pCell.config(pInfo)
        } else {
            guard let pCell = cell as? DoMoreFooterTableViewCell else {
                return
            }
//            let approved = pInfo.isApproved
//            let stauts = Int(pInfo.status) ?? 0
            
            //0-待审核 1-出售中 2-无库存 3-下架
            switch pInfo.status {
                
            case .waitingForReview:
                pCell.buttonTitle2 = "编辑"
                pCell.buttonTitle1 = "删除"
                pCell.buttonBlock2 = {fCell in
                    let index = tableView.indexPath(for: fCell)
                    AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: index)
                }
                pCell.buttonBlock1 = {fCell in
                    guard let index = tableView.indexPath(for: fCell) else { return }
                    self.deleteProduct(index)
                }
            case .readyForSale:
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "下架"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock3 = {fCell in
                  guard  let index = tableView.indexPath(for: fCell)  else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = {fCell in
                   guard let index = tableView.indexPath(for: fCell)  else { return }
                    self.shelves(index)
                }
                pCell.buttonBlock1 = {fCell in
                  guard  let index = tableView.indexPath(for: fCell)  else { return }
                    self.shareItem(index)
                }
            case .noStock:
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "下架"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock3 = {fCell in
                  guard  let index = tableView.indexPath(for: fCell)  else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = {fCell in
                  guard  let index = tableView.indexPath(for: fCell)  else { return }
                    self.shelves(index)
                }
                pCell.buttonBlock1 = {fCell in
                  guard  let index = tableView.indexPath(for: fCell)  else { return }
                    self.shareItem(index)
                }
            case .offShelf:
                pCell.buttonTitle3 = "预览"
                pCell.buttonTitle2 = "上架"
                pCell.buttonTitle1 = "分享"
                pCell.buttonBlock3 = {fCell in
                  guard  let index = tableView.indexPath(for: fCell)  else { return }
                    self.seePreview(index)
                }
                pCell.buttonBlock2 = {fCell in
                   guard let index = tableView.indexPath(for: fCell)  else { return }
                    self.shelves(index)
                }
                pCell.buttonBlock1 = {fCell in
                  guard  let index = tableView.indexPath(for: fCell)  else { return }
                    self.shareItem(index)
                }
            default:
                break
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
}

extension ProductSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 110.0
        } else {
            return 45.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDetail@Product", source: self, sender: indexPath)
        }
    }
}
