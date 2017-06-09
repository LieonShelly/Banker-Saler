//
//  ItemDetailViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/25.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ItemDetailViewController: UIViewController {
    var goodsConfigID: String = ""
    fileprivate var currentPage: Int = 0
    fileprivate var tottalPage: Int = 1
    fileprivate lazy var dataArray: [ProductModel] = [ProductModel]()
    fileprivate lazy var tableView: ItemDetailTableView = {
        let tab = ItemDetailTableView(frame: CGRect(), style: .plain)
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 0
        tableView.mj_header.beginRefreshing()
    }
}

extension ItemDetailViewController {
    fileprivate func setupUI() {
        navigationItem.title = "商品列表"
        view.addSubview(tableView)
        tableView.allowsSelection = false
        tableView.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(view.snp.size)
        }
        tableView.addTableViewRefreshHeader(self, refreshingAction: "downRefresh")
        tableView.addTableViewRefreshFooter(self, refreshingAction: "upwardLoad")
    }
}

extension ItemDetailViewController {
    func downRefresh() {
        let param = ItemDetailParam()
        param.goodsConfigID = goodsConfigID
        requestGoodsDetail(param) {[unowned self] (goods) in
            self.dataArray = goods
            self.tableView.items = self.dataArray
        }
    }
    
    func upwardLoad() {
        var page = currentPage + 1
        if page >= tottalPage {
            page = tottalPage
        }
        let param = ItemDetailParam()
        param.goodsConfigID = goodsConfigID
        param.page = page
        requestGoodsDetail(param) {[unowned self] (goods) in
            self.dataArray.append(contentsOf: goods)
            self.tableView.items = goods
            self.tableView.mj_footer.endRefreshing()
        }
    }
    
    fileprivate  func requestGoodsDetail(_ param: ItemDetailParam, finishCallback: @escaping (_ goods: [ProductModel]) -> Void) {
        let par = param.toJSON()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsSearch(par, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, object, error, msg) in
            if let dict = object as? [String: AnyObject] {
                guard  let obj = Mapper<ItemDetailModel>().map(JSON: dict), let items = obj.items else { return }
                if items.isEmpty {
                    Utility.showAlert(self, message: "该货号下没有商品")
                } else {
                    guard let items = obj.items else {return}
                    for obj in items {
                        guard let properList = obj.properList else {return}
                        for pro in properList {
                            print(pro)
                        }
                    }
                    self.tottalPage = obj.totalPage
                    self.currentPage = obj.currentPage
                    finishCallback(items)
                }
                self.tableView.mj_header.endRefreshing()
            } else {
                if let msg = msg {
                        Utility.showAlert(self, message: msg)
                }                
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
}

class ItemDetailParam: Model {
    var goodsConfigID: String? // goods_config_id
    var page: Int = 1
    var perpage: Int = 20
    var keyword: String?
    
    override func mapping(map: Map) {
        goodsConfigID <- map["goods_config_id"]
        page <- map["page"]
        perpage <- map["perpage"]
        keyword <- map["keyword"]
    }
}
