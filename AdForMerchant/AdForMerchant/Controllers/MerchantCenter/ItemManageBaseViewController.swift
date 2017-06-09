//
//  ItemManageBaseViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/30.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper
import MJRefresh

class ItemManageBaseViewController: BaseViewController {
    var models: [Goods] = [Goods]() {
        didSet {
            tableView.reloadData()
        }
    }
    lazy var addButton: UIButton = {
        let btn = UIButton(image: "IconAdd")
        btn.addTarget(self, action: #selector(self.addItemAction), for: .touchUpInside)
        return btn
    }()
    lazy var tableView: UITableView = {
        let tab = UITableView()
        tab.separatorStyle = .none
        tab.backgroundColor = UIColor.colorWithHex("f5f5f5")
        tab.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
        tab.rowHeight = 140
        return tab
    }()
    fileprivate var currentPage: Int = 0
    fileprivate var tottalPage: Int = 1
    
    override func bottomButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 0
        tableView.mj_header.beginRefreshing()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    /// 刷新新数据,数据全在models中，用于外部接收
    func downwardPull(_ models: [Goods]) {
        
    }
    
    /// 刷新更多数据,数据全在models中，用于外部接收
    func upawardPullRefresh(_ models: [Goods]) {
        
    }
}

extension ItemManageBaseViewController {
    func setupUI() {
         navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        let refreshHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(self.requestItemList))
        guard let label = refreshHeader?.lastUpdatedTimeLabel else {return}
        label.isHidden = true
        tableView.mj_header = refreshHeader
        let refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction:#selector(self.requestMoreItemList))
        tableView.mj_footer = refreshFooter
        view.backgroundColor = UIColor.colorWithHex("f5f5f5")
        view.addSubview(bBtn)
        view.addSubview(tableView)
        bBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-44)
        }
    }
}

extension ItemManageBaseViewController {
    @objc fileprivate func addItemAction() {
        present(UINavigationController(rootViewController: AddItemViewController()), animated: true, completion: nil)
    }
    
    @objc fileprivate  func requestItemList() {
        currentPage = 1
        loadItemList(1) {[unowned self] (models) in
            self.models = models
            self.downwardPull(models)
        }
    }
    
    @objc fileprivate func requestMoreItemList() {
        moreItemList { [unowned self] (models) in
            self.upawardPullRefresh(models)
        }
    }
    
    fileprivate func moreItemList(_ finishCallBack: @escaping ( (_ models: [Goods]) -> Void)) {
        currentPage += 1
        if currentPage > tottalPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            loadItemList(currentPage) { [unowned self] models in
                self.models.append(contentsOf: models)
                self.tableView.mj_footer.endRefreshing()
                finishCallBack(self.models)
            }
        }
    }
    
    fileprivate  func loadItemList(_ page: Int, finishCallback: @escaping (_ models: [Goods]) -> Void) {
        let params = ["page": page]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.getGoodsList(params, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, object, error, msg) in
            
            if let dict = object as? [String: Any] {
//                print(dict)
                guard  let obj = Mapper<GoodsListModel>().map(JSON: dict) else { return }
                self.currentPage = obj.currentPage
                self.tottalPage = obj.totalPage
                if let items = obj.items {
                     self.tableView.mj_header.endRefreshing()
                    finishCallback(items)
                }
            } else {
                self.tableView.mj_header.endRefreshing()
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
                
            }
        }
    }
}
