//
//  ItemManageViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/24.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ItemManageViewController: ItemManageBaseViewController {
    fileprivate lazy var cancelButton: UIButton = {
        let btn = UIButton(image: "item_delete")
        btn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func cancelAction() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
         guard let tab = tableView as? ItemManageTableView else { return  }
        tab.editFlag = false
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-44)
        }
        view.addSubview(bBtn)
        bBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        view.layoutIfNeeded()
    }
    
    override func bottomButtonAction() {
        guard let tab = tableView as? ItemManageTableView else { return  }
        tab.editFlag = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        bBtn.removeFromSuperview()
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(view.snp.height)
        }
        view.layoutIfNeeded()
    }
    
    override func loadView() {
        super.loadView()
        self.tableView = ItemManageTableView(frame: CGRect(), style: .plain)
    }

    override func setupUI() {
        super.setupUI()
        navigationItem.title = "货号管理"
        bBtn.setTitle("编辑货号", for: UIControlState())
        guard let tab = tableView as? ItemManageTableView else { return  }
        tab.editAction = { [unowned self] model in
            let destVC = ItemModifyViewController()
            destVC.newItem = model
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        tab.deleteAction = { [unowned self] model, index in
            Utility.showConfirmAlert(self, message: "确定删除该货号", confirmCompletion: { (_) in
                self.deleteItem(model, index: index)
            })
        }
        
        tab.selectRowAction = {[unowned self] model in
            let destVC = ItemDetailViewController()
            guard let goods = model as? Goods else { return  }
            guard let goodsConfigID = goods.goodsConfigID else {return}
            destVC.goodsConfigID = goodsConfigID
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
    
    override func upawardPullRefresh(_ models: [Goods]) {
        guard let tab = tableView as? ItemManageTableView else { return  }
        tab.models = models
    }
    
    override func downwardPull(_ models: [Goods]) {
        guard let tab = tableView as? ItemManageTableView else { return  }
        tab.models = models
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cancelAction()
    }
}

extension ItemManageViewController {
    fileprivate  func deleteItem(_ goods: Goods, index: IndexPath) {
        guard let goodsConfigID = goods.goodsConfigID else {return}
        let params = ["goods_config_id": goodsConfigID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.deleteGoodsConfig(params, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, object, error, msg) in
            if msg == "" {
                   guard let tab = self.tableView as? ItemManageTableView else { return  }
                tab.models?.remove(at: index.row)
//                print("Modelcount :\(tab.models?.count)")
                
                self.tableView.reloadData()
            } else {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
}
