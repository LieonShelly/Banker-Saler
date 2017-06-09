//
//  CampaignChooseViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/31.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let cellID = "CampaginChooseItemCell"
class CampaignChooseViewController: ItemManageBaseViewController {
    var choosedgoodsConfigIDsCallBack: ( (_ ids: [String], _ goodsNum: Int) -> Void)?
    var goodsConfigIDs: [String] = [String] ()
    var previousSelectedConfigIDs: [String]?
    fileprivate var goodsNum: Int = 0
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "选择商品货号"
        tableView.register(UINib(nibName: "CampaginChooseItemCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        guard let ids = previousSelectedConfigIDs else { return  }
        goodsConfigIDs.append(contentsOf: ids)

    }
    
    override func upawardPullRefresh(_ models: [Goods]) {
        super.upawardPullRefresh(models)
        if let ids = previousSelectedConfigIDs {
            selectedPrevious(ids, models: models)
        }
    }
    
    override func downwardPull(_ models: [Goods]) {
        super.downwardPull(models)
        if let ids = previousSelectedConfigIDs {
            selectedPrevious(ids, models: models)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        getLastSelectedItem()
    }
}

extension CampaignChooseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item = models[indexPath.row]
        guard let configID = item.goodsConfigID else { return  }
        guard let idx = goodsConfigIDs.index(of: configID) else { return  }
        goodsConfigIDs.remove(at: idx)
        let count = previousSelectedConfigIDs?.count ?? 0
        if idx < count {
            previousSelectedConfigIDs?.remove(at: idx)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = models[indexPath.row]
        guard let configID = item.goodsConfigID else { return  }
        if goodsConfigIDs.contains(configID) {
                return
        }
        goodsConfigIDs.append(configID)
    }
}

extension CampaignChooseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CampaginChooseItemCell else { return UITableViewCell() }
        cell.model = models[indexPath.row]
        cell.leftConstraint.constant = -40
        let view = UIView()
        let lineView = UIView()
        lineView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 15.5)
        lineView.backgroundColor = UIColor.colorWithHex("F5F5F5")
        view.addSubview(lineView)
        view.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = view
        cell.contentsViewTapAction = { [unowned self] selctedItem in
            let destVC = ItemDetailViewController()
             guard let selectedID = selctedItem.goodsConfigID else { return  }
            destVC.goodsConfigID = selectedID
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        return cell
    }
}

extension CampaignChooseViewController {
    fileprivate  func selectedPrevious(_ goodsConfigIDs: [String], models: [Goods]) {
        if goodsConfigIDs.isEmpty {
            return
        }
        for goodsConfigID in goodsConfigIDs {
          let idx = models.index { $0.goodsConfigID == goodsConfigID }
            if let index = idx {
                let indexPath = IndexPath(row: index.hashValue, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            }
        }
    }
    
    fileprivate func getLastSelectedItem() {
        if goodsConfigIDs.isEmpty {
            if let block = choosedgoodsConfigIDsCallBack {
                block(goodsConfigIDs, 0)
            }
        }
        let modelarray = models
        var goodsNum: Int = 0
        for id in goodsConfigIDs {
            let idx = modelarray.index { $0.goodsConfigID == id }
            if let index = idx {
                let item = modelarray[index.hashValue]
                let num = item.putawayGoodsNum 
                goodsNum += num
            }
        }
        if let block = choosedgoodsConfigIDsCallBack {
            block(goodsConfigIDs, goodsNum)
        }
    }
}
