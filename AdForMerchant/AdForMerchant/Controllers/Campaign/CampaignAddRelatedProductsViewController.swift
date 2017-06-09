//
//  CampaignAddRelatedProductsViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class CampaignRelatedProductTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate var productImgView: UIImageView!
    @IBOutlet fileprivate var productNameLabel: UILabel!
    @IBOutlet fileprivate var priceLabel: UILabel!
    @IBOutlet fileprivate var selectionButton: UIButton!
    @IBOutlet fileprivate var productViewBgLeading: NSLayoutConstraint!
    
    internal var isProductSelected: Bool = false {
        didSet {
            if isProductSelected {
                selectionButton.isSelected = true
            } else {
                selectionButton.isSelected = false
            }
        }
    }
    
    internal var willShowSelectButton: Bool = true {
        didSet {
            if willShowSelectButton {
                selectionButton.isHidden = false
                productViewBgLeading.constant = 50
            } else {
                
                selectionButton.isHidden = true
                productViewBgLeading.constant = 16
            }
        
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        selectionButton.isUserInteractionEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(_ imgName: String, title: String, price: Float, count: String) {
        productImgView.sd_setImage(with: URL(string: imgName), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
        
        productNameLabel.text = title
        priceLabel.text = "￥" + String(format: "%.2f", price)
    }
    
}

class CampaignAddRelatedProductsViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomButton: UIButton!
    @IBOutlet fileprivate var bottomBtnBottomConstr: NSLayoutConstraint!
    
    fileprivate var dataArray: [ProductModel] = []
    fileprivate var selectedProductsDataArray: Set<Int> = Set()
    fileprivate var filterCategory: String = ""
    
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    var productsAllSelected: Bool = false
    
    var canEdit: Bool = true
    var productsSelected: [Int] = []
    
    var completeBlock: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择关联商品"
        
        if canEdit {
            let rightBarItem = UIBarButtonItem(image: UIImage(named: "NaviIconFilter"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CampaignAddRelatedProductsViewController.showFilterPage))
            navigationItem.rightBarButtonItem = rightBarItem
        }
        
        selectedProductsDataArray = Set(productsSelected)
        
        bottomButton.addTarget(self, action: #selector(CampaignAddRelatedProductsViewController.confirmAction(_:)), for: .touchUpInside)
//        bottomButton.setBackgroundImage(UIImage(named: "CommonTopGrayLineButtonBg"), forState: .Normal)
        
//        dataArray += [false, true, false, true]
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = tableView.backgroundColor
        
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        tableView.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !canEdit {
            bottomBtnBottomConstr.constant = -49
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        selectCompletionBlock
        if segue.identifier == "CampaignProductFilter@Campaign", let desVC = segue.destination as? CampaignProductFilterViewController {
            desVC.selection = filterCategory
            desVC.selectCompletionBlock = {selection in
                self.filterCategory = selection
            }
        }
    }
}

extension CampaignAddRelatedProductsViewController {
    func addNewCategoryAction() {
    }
    
    func confirmAction(_ btn: UIButton) {
        if let block = completeBlock {
            if selectedProductsDataArray.isEmpty {
                Utility.showAlert(self, message: "请勾选至少一个商品")
                return
            }
            
            let selectedStringArr = selectedProductsDataArray.flatMap({ value in
                "\(value)"
            })
            let unitedStr = selectedStringArr.joined(separator: ",")
            block(unitedStr)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func selectAllAction(_ btn: UIButton) {
        productsAllSelected = !productsAllSelected
        if productsAllSelected {
            for product in dataArray {
                guard let id = Int(product.goodsId) else { continue }
                selectedProductsDataArray.insert(id)
            }
        } else {
            
            for product in dataArray {
                guard let id = Int(product.goodsId) else { continue }
                selectedProductsDataArray.remove(id)
            }
        }
        
        tableView.reloadData()
    }
    
    func showFilterPage() {
        AOLinkedStoryboardSegue.performWithIdentifier("CampaignProductFilter@Campaign", source: self, sender: nil)
        
    }
    
    func requestListWithReload() {
        requestProductsList(1)
    }
    
    func requestListWithAppend() {
        if currentPage >= totalPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            requestProductsList(currentPage + 1)
        }
    }
    
    func requestProductsList(_ page: Int) {
        var request: AFMRequest!
        var params: [String : Any] = ["page": page]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        if canEdit {
            if !filterCategory.isEmpty {
                let catIdArray = filterCategory.components(separatedBy: ",")
                
                params["cat_id"] = catIdArray.filter({!$0.isEmpty})
            }
            request = AFMRequest.goodsForEvents(params, aesKey, aesIV)
        } else {
            guard !productsSelected.isEmpty else {
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            params["goods_id"] = productsSelected as AnyObject?
            request = AFMRequest.goodsAll(params, aesKey, aesIV)
        }
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                guard let tempArray = result["items"] as? [AnyObject] else { return }
                self.dataArray = tempArray.flatMap({ProductModel(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]())})
                self.currentPage = page
                self.totalPage = Int((result["total_page"] as? String) ?? "0") ?? 0
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }
        }
    }
}

extension CampaignAddRelatedProductsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CampaignRelatedProductTableViewCell", for: indexPath) as? CampaignRelatedProductTableViewCell else { return UITableViewCell() }
            cell.willShowSelectButton = canEdit
            return cell
        
        }
    }
}

extension CampaignAddRelatedProductsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if canEdit {
                return 35
            } else {
                return CGFloat.leastNormalMagnitude
            }
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
        switch (indexPath.section, indexPath.row) {
        default:
            return 77
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if !canEdit {
                return nil
            }
            let allSelectedButton = UIButton(type: .custom)
            allSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOff"), for: UIControlState())
            allSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOn"), for: .selected)
            allSelectedButton.addTarget(self, action: #selector(CampaignAddRelatedProductsViewController.selectAllAction(_:)), for: .touchUpInside)
            allSelectedButton.frame = CGRect(x: 0, y: 3, width: 84, height: 30)
            allSelectedButton.isSelected = productsAllSelected
            allSelectedButton.setTitleColor(UIColor.commonTxtColor(), for: UIControlState())
            
            let attrText = NSMutableAttributedString(string: "  全选", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonTxtColor()])
            allSelectedButton.setAttributedTitle(attrText, for: UIControlState())
            
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 35))
            titleBg.addSubview(allSelectedButton)
//            titleBg.addSubview(agreementDetailButton)
            return titleBg
        }
        
        return nil
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let _cell = cell as? CampaignRelatedProductTableViewCell else {return }
        
        let product = dataArray[indexPath.section]
         guard let id = Int(product.goodsId) else { return  }
        _cell.isProductSelected = selectedProductsDataArray.contains(id)
        _cell.config(product.thumb, title: product.title, price: Float(product.price) ?? 0, count: product.stockNum)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let product = dataArray[indexPath.section]
        guard let id = Int(product.goodsId) else { return  }
        if selectedProductsDataArray.contains(id) {
            selectedProductsDataArray.remove(id)
        } else {
            selectedProductsDataArray.insert(id)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}
