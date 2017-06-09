//
//  ModifyitemCatViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/28.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class ModifyitemCatViewController: ItemBaseViewController {
    override var cellID: String {
        return "SetItemCatTableViewCell"
    }
    
    override func setupUI() {
        super.setupUI()
        tableView.register(UINib(nibName: "SetItemCatTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.allowsSelection = true
    }
}

extension ModifyitemCatViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SetItemCatTableViewCell else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "店铺分类"
            cell.subTitleLabel.text = modifyItemHomeViewController.newItem.storeCatName
            cell.selectedAction = {[unowned self] in
                guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ShopCategory") as? ProductShopCategoryViewController else { return }
                destVC.selectCompletionBlock = {(categoryModel: ShopCategoryModel?) -> Void in
                    self.modifyItemHomeViewController.newItem.storeCatID = categoryModel?.catID
                    self.modifyItemHomeViewController.newItem.storeCatName = categoryModel?.catName
                    cell.subTitleLabel.text = self.modifyItemHomeViewController.newItem.storeCatName
                }
                self.navigationController?.pushViewController(destVC, animated: true)
                
            }
        case 1:
            cell.titleLabel.text = "商品分类"
            cell.subTitleLabel.text = modifyItemHomeViewController.newItem.childCatName
            cell.selectedAction = {[unowned self] in
                guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductCategory") as? ProductCategoryViewController else { return }
                destVC.selectCompletionBlock = {(catId, catName, childCatId, childCatName) in
                    self.modifyItemHomeViewController.newItem.catID = catId
                    self.modifyItemHomeViewController.newItem.childCatID = childCatId
                    self.modifyItemHomeViewController.newItem.catName = catName
                    self.modifyItemHomeViewController.newItem.childCatName = childCatName
                    cell.subTitleLabel.text = self.modifyItemHomeViewController.newItem.childCatName
                }
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        default:
            break
        }
        if indexPath.row == 1 {
            cell.clipsToBounds = true
        }
        return cell
    }
}

extension ModifyitemCatViewController: UITableViewDelegate {
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SetItemCatTableViewCell else { return  }
        if let block = cell.selectedAction {
            block()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
