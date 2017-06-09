//
//  ChooseItemViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/28.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ChooseItemViewController: ItemManageBaseViewController {
    let cellID = "ItemManageTableViewCell"
    var selectedGoodsConfigID: String?
    var selectedItemBlock: ((_ item: Goods) -> Void)?
    fileprivate var isSelectedIndexpath = (flag: Bool(), indexPath: IndexPath(row: 0, section: 0))
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "选择商品货号"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ItemManageTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)

    }
    override func downwardPull(_ models: [Goods]) {
       
       super.downwardPull(models)
        slectedPreviousItem()
       
    }
    
    override func upawardPullRefresh(_ models: [Goods]) {
        super.upawardPullRefresh(models)
        slectedPreviousItem()
    }
    
    override func bottomButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension ChooseItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ItemManageTableViewCell  else { return UITableViewCell() }
        cell.configChooseItem(models[indexPath.row])
        cell.markButtonTapAction = {
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        }
        return cell
    }
}

extension ChooseItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let modelsArray = models
        let model = modelsArray[indexPath.row]
      
        if let block = selectedItemBlock {
            isSelectedIndexpath = (true, indexPath)
            block(model)
            tableView.reloadData()
        }
          let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         guard let itemCell = cell as? ItemManageTableViewCell else { return  }
        let (flag, selectedIndexPath) = isSelectedIndexpath
        if flag == true && selectedIndexPath == indexPath {
            itemCell.isSelected = true
        } else {
            cell.isSelected = false
        }
        
    }
}

extension ChooseItemViewController {
    fileprivate  func slectedPreviousItem() {
       guard let selectedGoodsID = selectedGoodsConfigID else { return  }
        let items = models
            let idx = items.index(where: { (model) -> Bool in
                return model.goodsConfigID == selectedGoodsID
            })
          guard let index = idx else { return }
     let idexPath = IndexPath(row: index.hashValue, section: 0)
     tableView.selectRow(at: idexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
    }
}
