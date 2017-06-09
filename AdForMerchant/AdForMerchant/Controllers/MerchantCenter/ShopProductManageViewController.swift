//
//  ShopProductManageViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ShopProductManageViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomButton: UIButton!
    
    internal var manageType: ShopProductManageType = .normal
    
    fileprivate var selectedProductsDataSet: Set<Int> = Set()
    fileprivate var dataArray: [ProductModel] = []
    
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商品设置"
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = tableView.backgroundColor
        
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        tableView.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        
        tableView.register(UINib(nibName: "MyShopProductManageTableViewCell", bundle: nil), forCellReuseIdentifier: "MyShopProductManageTableViewCell")
        
        bottomButton.addTarget(self, action: #selector(ShopProductManageViewController.changeStyleAction(_:)), for: .touchUpInside)
        bottomButton.setTitleColor(UIColor.colorWithHex("0B86EE"), for: UIControlState())
        bottomButton.setBackgroundImage(UIImage(named: "CommonTopGrayLineButtonBg"), for: UIControlState())
                
        changeStyle()
        
        requestListWithReload()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Action
    
    func addNewCategoryAction() {
        
    }
    
    func changeStyleAction(_ btn: UIButton) {
        
        if manageType == .normal {
            manageType = .move
            btn.removeTarget(self, action: #selector(ShopProductManageViewController.changeStyleAction(_:)), for: .touchUpInside)
            btn.addTarget(self, action: #selector(ShopProductManageViewController.changeProductCategoryAction(_:)), for: .touchUpInside)
        } else {
            manageType = .normal
            btn.removeTarget(self, action: #selector(ShopProductManageViewController.changeProductCategoryAction(_:)), for: .touchUpInside)
            btn.addTarget(self, action: #selector(ShopProductManageViewController.changeStyleAction(_:)), for: .touchUpInside)
        }
        changeStyle()
        tableView.reloadData()
    }
    
    func changeProductCategoryAction(_ btn: UIButton) {
        if selectedProductsDataSet.isEmpty {
            Utility.showAlert(self, message: "请选择需要管理的商品")
            return
        }
        
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ShopProductMove@MerchantCenter") as? ShopProductMoveViewController else {return}
        modalViewController.selectedProductIds = selectedProductsDataSet.map { "\($0)"}.joined(separator: ",")
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        modalViewController.confirmBlock = {
            self.changeStyleAction(self.bottomButton)
            self.requestListWithReload()
        }
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - Methods
    
    func changeStyle() {
        if manageType == .normal {
            navigationItem.title = "商品设置"
            
            bottomButton.setImage(UIImage(named: "MyShopProductIconManage"), for: UIControlState())
            bottomButton.setTitle(" 批量管理商品", for: UIControlState())
        } else {
            navigationItem.title = "批量管理"
            selectedProductsDataSet.removeAll()
            
            bottomButton.setImage(UIImage(named: ""), for: UIControlState())
            bottomButton.setTitle("移动到分类", for: UIControlState())
        }
    }
    
    // MARK: - Http Request
    
    func requestListWithReload() {
        requestProductsList(1)
    }
    
    func requestListWithAppend() {
        if currentPage >= totalPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            requestProductsList(currentPage)
            currentPage += 1
        }
    }
    
    func requestProductsList(_ page: Int) {
        let params = ["page": page]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.goodsAll(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: Any] {
                guard let tempArray = result["items"] as? [[String: Any]] else {return}                            
                self.dataArray = tempArray.flatMap({Mapper<ProductModel>().map(JSON: $0)})
                self.currentPage = page
                guard let page = result["total_page"] as? String else {return}
                guard let totalPage = Int(page) else {return}
                self.totalPage = totalPage
                
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            } else {
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }
        }
    }
    
}

extension ShopProductManageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dataArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        default:
            if manageType == .normal {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyShopProductManageTableViewCell", for: indexPath) as? MyShopProductManageTableViewCell else {return UITableViewCell()}
                cell.type = .normal
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyShopProductManageTableViewCell", for: indexPath) as? MyShopProductManageTableViewCell else {return UITableViewCell()}
                cell.type = .move
                return cell
            }
        }
    }
}

extension ShopProductManageViewController: UITableViewDelegate {
    
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
        switch (indexPath.section, indexPath.row) {
        default:
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _cell = cell as? MyShopProductManageTableViewCell else {return}
        let product = dataArray[indexPath.row]
        guard let price = Float(product.price) else {return}
        guard let goodsID = Int(product.goodsId) else {return}

        _cell.config(product.thumb, title: product.title, price: price, saleCount: product.sellNum, stockCount: product.stockNum, category: product.storeCatName)

        if manageType == .normal {
            _cell.isProductSelected = false
        } else {
            _cell.isProductSelected = selectedProductsDataSet.contains(goodsID)
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let product = dataArray[indexPath.row]
        guard let goodsID = Int(product.goodsId) else {return}

        if selectedProductsDataSet.contains(goodsID) {
            selectedProductsDataSet.remove(goodsID)
        } else {
            selectedProductsDataSet.insert(goodsID)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)

    }
}
