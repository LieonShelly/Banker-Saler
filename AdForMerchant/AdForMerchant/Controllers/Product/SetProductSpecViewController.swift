//
//  SetProductSpecViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/30.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

private let cellID = "SetProductSpecTableViewCell"
private let footerID = "ProductSetSpecFooterView"
class SetProductSpecViewController: UIViewController {
    var newModelCallBack: ((_ model: Goods) -> Void)?
    var disableCell: Bool = false
    lazy var model: Goods = Goods()
    fileprivate var goodsList: [GoodsModel]? {
        didSet {
            footerView.configSpec(goodsList)
        }
    }
    fileprivate lazy var enterButton: UIButton = {
        let btn = UIButton(backgroundImage: "CommonBlueBg")
        btn.setTitle("确定", for: UIControlState())
        btn.addTarget(self, action: #selector(self.enterAction), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var footerView: ProductSetSpecFooterView = {[unowned self] in 
        let footerView = ProductSetSpecFooterView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        return footerView
    }()

    fileprivate lazy var tableView: ItemTableView = { [unowned self] in
        let tab = ItemTableView()
        tab.separatorStyle = .none
        tab.backgroundColor = UIColor.colorWithHex("f5f5f5")
        tab.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        tab.rowHeight = 140
        tab.dataSource = self
        tab.allowsSelection = false
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let goodsCongfigID = model.goodsConfigID {
            requestData(goodsCongfigID)
        } else {
            tableView.tableFooterView = nil
            tableView.allowsSelection = false
        }
    }
}

extension SetProductSpecViewController {
    fileprivate func setupUI() {
        navigationItem.title = "设置商品规格"
        view.addSubview(tableView)
        view.addSubview(enterButton)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-44)
        }
        enterButton.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        tableView.register(UINib(nibName: "SetProductSpecTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.tableFooterView = footerView
    }
    
    fileprivate func requestData(_ id: String) {
        let params = ["goods_config_id": id]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsConfigDetail(params, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, obj, _, msg) in
            if let dict = obj as? [String: Any] {
                let model = Mapper<GoodsConfigDetailModel>().map(JSON: dict)
                self.goodsList = model?.goodsList
            }
        }
    }
    
    @objc fileprivate  func enterAction() {
        _ = navigationController?.popViewController(animated: true)
    }
}
extension SetProductSpecViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.propList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SetProductSpecTableViewCell else { return  UITableViewCell() }
        cell.roleNumberLabel.text = "规则\(indexPath.row + 1)"
        cell.maxCharacterCount = 15
        cell.endEditingBlock = {[unowned self] property in
            self.chageData(property)
        }
        cell.property = model.propList?[indexPath.row]
        cell.dividerLine.backgroundColor = tableView.backgroundColor
        cell.isUserInteractionEnabled = !disableCell
        return cell
    }
    
    fileprivate  func chageData(_ model: GoodsProperty) {
        guard  let list = self.model.propList else { return }
        guard let idx = list.index(where: { (proper) -> Bool in
            return proper.properID == model.properID
        }) else { return  }
        self.model.propList?.remove(at: idx)
        self.model.propList?.insert(model, at: idx)
        if let block = newModelCallBack {  
            block(self.model)
        }
    }
}
