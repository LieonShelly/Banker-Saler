//
//  SetItemCodeViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
class SetItemCodeViewController: ItemBaseViewController {
    override var models: [AnyObject]? {
        var models = [SetItemCodeViewHelpModel]()
        let model0 = SetItemCodeViewHelpModel(desc: "货号标题", titleValue: "请输入货号标题")
        let model1 = SetItemCodeViewHelpModel(desc: "货号", titleValue: "请输入货号")
        models.append(model0)
        models.append(model1)
        return models
    }
    override var cellID: String {
        return "SetItemCodeTableViewCell"
    }
    
    override func setupUI() {
        super.setupUI()
        tableView.register(UINib(nibName: "SetItemCodeTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
    }
   
}

extension SetItemCodeViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SetItemCodeTableViewCell, let modelArray = models as? [SetItemCodeViewHelpModel] else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.endEditingBlock = { [unowned self] textField, _ in
                self.addItemHomeViewController.newItem.title = textField
            }
        case 1:
            cell.endEditingBlock = { [unowned self] textField, _ in
                self.addItemHomeViewController.newItem.code = textField
            }
        default:
            break
        }
        if indexPath.row == modelArray.count - 1 {
            cell.clipsToBounds = true
        }
        cell.model = modelArray[indexPath.row]
        return cell
    }
}
