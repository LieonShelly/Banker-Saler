//
//  SetNormalGoodsViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/11/2.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class SetNormalGoodsViewController: CampaignChooseViewController {
    override func setupUI() {
        super.setupUI()
        bBtn.setTitle("批量编辑", for: UIControlState())
        bBtn.setTitle("移动到分类", for: .selected)
        tableView.isEditing = false
        tableView.allowsSelection = false
        view.backgroundColor = UIColor.white
         tableView.mj_header.beginRefreshing()
    }
    
    override func bottomButtonAction() {
        bBtn.isSelected = !bBtn.isSelected
        if bBtn.isSelected == false {
            changeItemCodeCategoryAction()
        } else {
            tableView.isEditing = true
        }
        tableView.allowsSelection = bBtn.isSelected
    }
}

extension SetNormalGoodsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = super.tableView(tableView, cellForRowAt: indexPath) as?  CampaginChooseItemCell else { return UITableViewCell() }
        cell.removeGesture()
        return cell
    }
}

extension SetNormalGoodsViewController {
    
    fileprivate func changeItemCodeCategoryAction() {
                if goodsConfigIDs.isEmpty {
                    Utility.showAlert(self, message: "请选择需要管理的货号")
                    bBtn.isSelected = true
                    return
                }
        
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ShopProductMove@MerchantCenter") as? ShopProductMoveViewController else {return}
        modalViewController.type = .normal
        modalViewController.selectedProductIds = goodsConfigIDs.map { "\($0)"}.joined(separator: ",")
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        modalViewController.confirmBlock = {[unowned self] in
            self.tableView.mj_header.beginRefreshing()
            self.goodsConfigIDs.removeAll()
            self.tableView.isEditing = false
        }
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
    }
}
