//
//  SetServiceGoodsViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/11/2.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

private let cellID = "ItemDetailTableViewCell"
class SetServiceGoodsViewController: BaseViewController {
    var selctedCallback: ((_ selectedGoodsIDs: [String]) -> Void)?
    fileprivate var selectedGoodsIDs: [String]  = [String]()
    fileprivate var currentPage: Int = 0
    fileprivate var tottalPage: Int = 1
    fileprivate lazy var dataArray: [ProductModel] = [ProductModel]()
    fileprivate lazy var tableView: UITableView = {
        let tab = UITableView()
        tab.separatorStyle = .none
        tab.backgroundColor = UIColor.colorWithHex("f7f7f7")
        tab.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
        tab.isEditing = false
        tab.allowsSelectionDuringEditing = true
        tab.rowHeight = 115
        tab.dataSource = self
        tab.delegate = self
        tab.register(UINib(nibName: "ItemDetailTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 1
        tableView.mj_header.beginRefreshing()
    }
    
    override func bottomButtonAction() {
        bBtn.isSelected = !bBtn.isSelected
        if bBtn.isSelected == false {
            changeGoodsCodeCategoryAction()
        } else {
            tableView.isEditing = true
        }
        tableView.allowsSelection = bBtn.isSelected
    }
}

extension SetServiceGoodsViewController {
    // 刷新新数据
    func downRefresh() {
        currentPage = 1
        requestProductsList(1) { (items) in
            self.dataArray = items
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    // 刷新更多数据
    func upwardLoad() {
        currentPage += 1
        if currentPage > tottalPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
        requestProductsList(currentPage) { (items) in
            self.dataArray.append(contentsOf: items)
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            }
        }
    }
}

extension SetServiceGoodsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item = dataArray[indexPath.row]
        guard let idx = selectedGoodsIDs.index(of: item.goodsId) else { return  }
        selectedGoodsIDs.remove(at: idx)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataArray[indexPath.row]
        let configID = item.goodsId
        selectedGoodsIDs.append(configID)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if let style = UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.delete.rawValue | UITableViewCellEditingStyle.insert.rawValue) {
                return style
        } else {
            return .delete
        }        
    }
}

extension SetServiceGoodsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ItemDetailTableViewCell else { return UITableViewCell() }
        cell.model = self.dataArray[indexPath.row]
        return cell
    }
    
}

extension SetServiceGoodsViewController {
    fileprivate  func setupUI() {
        view.addSubview(tableView)
        view.addSubview(bBtn)
        tableView.addTableViewRefreshHeader(self, refreshingAction: "downRefresh")
        tableView.addTableViewRefreshFooter(self, refreshingAction: "upwardLoad")
        tableView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(-44)
        }
        bBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(44)
            make.bottom.equalTo(0)
        }
        bBtn.setTitle("批量编辑", for: UIControlState())
        bBtn.setTitle("移动到分类", for: .selected)
    }
    
    fileprivate func requestProductsList(_ page: Int, finishCallback: @escaping (_ items: [ProductModel]) -> Void) {
        let params: [String: Any] = ["page": page, "type": "2"]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsAll(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if object != nil, let result = object as? [String: Any] {
                guard  let obj = Mapper<ItemDetailModel>().map(JSON: result), let items = obj.items else { return }
                self.tottalPage = obj.totalPage
                self.currentPage = obj.currentPage
                finishCallback(items)
            } else {
                self.tableView.mj_header.endRefreshing()
                if let msg = msg {
                        Utility.showAlert(self, message: msg)
                }                
            }
        }
    }
    
    fileprivate func changeGoodsCodeCategoryAction() {
        if selectedGoodsIDs.isEmpty {
            Utility.showAlert(self, message: "请选择需要管理的商品")
             bBtn.isSelected = true
            return
        }
        
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ShopProductMove@MerchantCenter") as? ShopProductMoveViewController else {return}
        modalViewController.type = .service
        modalViewController.selectedProductIds = selectedGoodsIDs.map { "\($0)"}.joined(separator: ",")
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        modalViewController.confirmBlock = { [unowned self] in
            self.tableView.mj_header.beginRefreshing()
            self.selectedGoodsIDs.removeAll()
            self.tableView.isEditing = false
        }
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
    }
}
