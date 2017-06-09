//
//  SetItemCategoryViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class SetItemCategoryViewController: ItemBaseViewController {
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

extension SetItemCategoryViewController {
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
            cell.selectedAction = {[unowned self] in
                guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ShopCategory") as? ProductShopCategoryViewController else { return }
                destVC.storeParam.type = .normal
                destVC.selectCompletionBlock = {(categoryModel: ShopCategoryModel?) -> Void in
                    self.addItemHomeViewController.newItem.storeCatID = categoryModel?.catID
                    self.addItemHomeViewController.newItem.storeCatName = categoryModel?.catName
                    cell.subTitleLabel.text = self.addItemHomeViewController.newItem.storeCatName
                }
                self.navigationController?.pushViewController(destVC, animated: true)
              
            }
        case 1:
        cell.titleLabel.text = "商品分类"
        cell.selectedAction = {[unowned self] in
            guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductCategory") as? ProductCategoryViewController else { return }
            destVC.type = 1
            destVC.selectCompletionBlock = {(catId, catName, childCatId, childCatName) in
                self.addItemHomeViewController.newItem.catID = catId
                self.addItemHomeViewController.newItem.childCatID = childCatId
                self.addItemHomeViewController.newItem.catName = catName
                self.addItemHomeViewController.newItem.childCatName = childCatName
                cell.subTitleLabel.text = catName + "/" + childCatName
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

extension SetItemCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         guard let cell = tableView.cellForRow(at: indexPath) as? SetItemCatTableViewCell else { return  }
          if let block = cell.selectedAction {
             block()
         }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
